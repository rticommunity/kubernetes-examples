#!/bin/bash
# Integration Test Suite for RTI Connext DDS Kubernetes Examples
# 
# Usage: ./run_integration_tests.sh [test_category]
#
# Test Categories:
#   basic       - Pod-to-pod unicast discovery (recommended for CI/CD)
#   multicast   - Pod-to-pod multicast discovery (CNI dependent)
#   advanced    - Shared memory + external gateway scenarios  
#   loadbalancer- External gateway with LoadBalancer service
#   all         - All test categories (comprehensive)
#
# Examples:
#   ./run_integration_tests.sh basic      # Run reliable unicast tests
#   ./run_integration_tests.sh advanced   # Run complex networking tests
#   ./run_integration_tests.sh all        # Run complete test suite

set -euo pipefail

# Configuration
NAMESPACE="rti-test-$(date +%s)"
TEST_TIMEOUT=600
LOG_LEVEL="INFO"
CLEANUP_ON_EXIT=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

# Test categories (using functions instead of associative arrays for compatibility)
get_test_cases() {
    local category="$1"
    case "$category" in
        "basic")
            # Basic DDS communication using unicast discovery with Cloud Discovery Service
            # Works reliably across all Kubernetes CNI implementations
            echo "pod_to_pod_unicast_disc"
            ;;
        "advanced")
            # Advanced scenarios: shared memory transport and external gateway
            # - intra_pod_shmem: Containers communicate via shared memory within same pod
            # - external_to_pod_gw: External apps communicate with pods via RTI Routing Service + NodePort
            echo "intra_pod_shmem external_to_pod_gw"
            ;;
        "multicast")
            # Multicast-based discovery (requires CNI with multicast support)
            # May fail on cloud providers or CNIs that block multicast traffic
            echo "pod_to_pod_multicast_disc"
            ;;
        "loadbalancer")
            # External-to-pod communication via LoadBalancer service
            # Requires cloud provider with LoadBalancer controller support
            echo "external_to_pod_lb_gw"
            ;;
        "all")
            # Comprehensive test suite - runs all available test cases
            # Note: Some tests may fail depending on CNI capabilities and cloud provider features
            echo "pod_to_pod_multicast_disc pod_to_pod_unicast_disc intra_pod_shmem external_to_pod_gw external_to_pod_lb_gw"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Test results
TEST_RESULTS=""
FAILED_TESTS=""
PASSED_TESTS=""

# Cleanup function
cleanup() {
    if [[ "$CLEANUP_ON_EXIT" == "true" ]]; then
        log_info "Cleaning up test namespace: $NAMESPACE"
        kubectl delete namespace "$NAMESPACE" --ignore-not-found=true --timeout=60s || true
    fi
}
trap cleanup EXIT

# Create test namespace
setup_test_environment() {
    log_info "Setting up test environment..."
    kubectl create namespace "$NAMESPACE" || {
        log_error "Failed to create test namespace"
        return 1
    }
    
    # Create RTI license ConfigMap if rti_license.dat exists
    if [[ -f "rti_license.dat" ]]; then
        kubectl create configmap rti-license --from-file=rti_license.dat -n "$NAMESPACE"
        log_info "Created RTI license ConfigMap"
    else
        log_warn "RTI license file not found - some tests may fail"
    fi
}

# Create routing service ConfigMaps for specific use cases
create_routing_service_configmaps() {
    local use_case="$1"
    
    case "$use_case" in
        "external_to_pod_gw"|"external_to_pod_lb_gw")
            if [[ -f "USER_ROUTING_SERVICE.xml" ]]; then
                kubectl create configmap routingservice-rwt --from-file=USER_ROUTING_SERVICE.xml -n "$NAMESPACE" 2>/dev/null || true
                log_info "Created routing service ConfigMap for $use_case"
            fi
            ;;
    esac
}

# Verify data flow between publisher and subscriber
verify_data_flow() {
    local use_case="$1"
    log_info "Verifying data flow for $use_case..."
    
    # Brief pause to let pods start communicating (CDS is already ready)
    sleep 5
    
    # Get publisher and subscriber pod names
    local pub_pod
    local sub_pod
    
    pub_pod=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-pub --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -1)
    sub_pod=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-sub --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -1)
    
    if [[ -z "$pub_pod" ]] || [[ -z "$sub_pod" ]]; then
        log_error "Could not find publisher or subscriber pods"
        TEST_RESULTS="$TEST_RESULTS $use_case:FAIL"
        FAILED_TESTS="$FAILED_TESTS $use_case"
        return 1
    fi
    
    log_info "Found publisher pod: $pub_pod"
    log_info "Found subscriber pod: $sub_pod"
    
    # Simple test - exactly like the proven debug script
    log_info "Testing data reception..."
    local sub_logs
    sub_logs=$(kubectl logs "$sub_pod" -n "$NAMESPACE" --tail=50 2>/dev/null || echo "")
    
    if echo "$sub_logs" | grep -q -E "(issue received|Received sample|Latency:|samples received|Samples received)"; then
        log_success "✓ Subscriber is receiving data from publisher!"
        echo ""
        echo "========== SUBSCRIBER DATA RECEPTION PROOF =========="
        echo "Publisher pod: $pub_pod"
        echo "Subscriber pod: $sub_pod"
        echo ""
        echo "Recent subscriber logs showing data reception:"
        echo "$sub_logs" | tail -20
        echo ""
        echo "Data reception samples:"
        echo "$sub_logs" | grep -E "(issue received|Received sample|Latency:|samples received)" | tail -5
        echo "====================================================="
        echo ""
        log_success "Data flow verification passed for $use_case"
        return 0
        log_error "✗ No data reception detected in subscriber logs"
        echo ""
        echo "========== DIAGNOSTIC INFORMATION =========="
        echo "Publisher pod: $pub_pod"
        echo "Subscriber pod: $sub_pod"
        echo ""
        echo "Recent subscriber logs (last 20 lines):"
        kubectl logs "$sub_pod" -n "$NAMESPACE" --tail=20 2>/dev/null || echo "No subscriber logs available"
        echo ""
        echo "Recent publisher logs (last 20 lines):"
        kubectl logs "$pub_pod" -n "$NAMESPACE" --tail=20 2>/dev/null || echo "No publisher logs available"
        echo "============================================="
        echo ""
        
        TEST_RESULTS="$TEST_RESULTS $use_case:FAIL"
        FAILED_TESTS="$FAILED_TESTS $use_case"
        return 1
    fi
}

# Test individual use case
test_use_case() {
    local use_case="$1"
    local test_dir="$use_case"
    
    log_info "Testing use case: $use_case"
    
    if [[ ! -d "$test_dir" ]]; then
        log_error "Test directory not found: $test_dir"
        TEST_RESULTS["$use_case"]="SKIP"
        return 1
    fi
    
    pushd "$test_dir" > /dev/null
    
    # Create required ConfigMaps for routing service examples
    create_routing_service_configmaps "$use_case"
    
    # Get all YAML files (excluding HA files to avoid conflicts)
    local yaml_files
    yaml_files=$(find . -maxdepth 1 -name "*.yaml" -o -name "*.yml" | grep -v "_ha\.yaml" | head -10)
    
    if [[ -z "$yaml_files" ]]; then
        log_warn "No YAML files found in $test_dir"
        TEST_RESULTS="$TEST_RESULTS $use_case:SKIP"
        popd > /dev/null
        return 0
    fi
    
    # Deploy Cloud Discovery Service first and wait for it to be ready
    local cds_file=""
    local other_files=""
    for yaml_file in $yaml_files; do
        if [[ "$yaml_file" == *"clouddiscoveryservice"* ]]; then
            cds_file="$yaml_file"
        else
            other_files="$other_files $yaml_file"
        fi
    done
    
    # Deploy CDS first if it exists
    if [[ -n "$cds_file" ]]; then
        log_info "Deploying Cloud Discovery Service first: $cds_file"
        if ! kubectl apply -f "$cds_file" -n "$NAMESPACE" --timeout=60s; then
            log_error "Failed to apply $cds_file"
            TEST_RESULTS="$TEST_RESULTS $use_case:FAIL"
            FAILED_TESTS="$FAILED_TESTS $use_case"
            popd > /dev/null
            return 1
        fi
        
        # Wait for CDS to be ready before deploying pub/sub
        log_info "Waiting for Cloud Discovery Service to be ready..."
        if ! kubectl wait --for=condition=available deployment -l app=rti-clouddiscoveryservice -n "$NAMESPACE" --timeout=120s 2>/dev/null; then
            log_warn "CDS deployment may not be fully ready, continuing anyway..."
        fi
    fi
    
    # Deploy remaining resources (publisher and subscriber)
    local deploy_success=true
    for yaml_file in $other_files; do
        log_info "Applying $yaml_file"
        if ! kubectl apply -f "$yaml_file" -n "$NAMESPACE" --timeout=60s; then
            log_error "Failed to apply $yaml_file"
            deploy_success=false
            break
        fi
    done
    
    if [[ "$deploy_success" == "false" ]]; then
        TEST_RESULTS="$TEST_RESULTS $use_case:FAIL"
        FAILED_TESTS="$FAILED_TESTS $use_case"
        popd > /dev/null
        return 1
    fi
    
    # Wait for deployments to be ready
    log_info "Waiting for deployments to be ready..."
    if ! kubectl wait --for=condition=available deployment --all -n "$NAMESPACE" --timeout=300s 2>/dev/null; then
        log_warn "Some deployments may not be ready, checking individual status..."
    fi
    
    # Check pod status
    local failed_pods
    failed_pods=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
    
    if [[ "$failed_pods" -gt 0 ]]; then
        log_error "Found $failed_pods pods not in Running state"
        kubectl get pods -n "$NAMESPACE" --field-selector=status.phase!=Running
        TEST_RESULTS="$TEST_RESULTS $use_case:FAIL"
        FAILED_TESTS="$FAILED_TESTS $use_case"
    else
        log_success "All pods are running successfully"
        TEST_RESULTS="$TEST_RESULTS $use_case:PASS"
        PASSED_TESTS="$PASSED_TESTS $use_case"
    fi
    
    # Data flow verification test for basic DDS communication
    if [[ "$use_case" == "pod_to_pod_unicast_disc" || "$use_case" == "pod_to_pod_multicast_disc" ]]; then
        verify_data_flow "$use_case"
    fi
    
    # Basic connectivity test (if applicable)
    if [[ -f "test_connectivity.sh" ]]; then
        log_info "Running connectivity test..."
        if timeout 60 ./test_connectivity.sh "$NAMESPACE"; then
            log_success "Connectivity test passed"
        else
            log_error "Connectivity test failed"
            TEST_RESULTS="$TEST_RESULTS $use_case:FAIL"
        fi
    fi
    
    # Cleanup resources for this test
    for yaml_file in $yaml_files; do
        kubectl delete -f "$yaml_file" -n "$NAMESPACE" --ignore-not-found=true --timeout=60s || true
    done
    
    popd > /dev/null
    sleep 5  # Brief pause between tests
}

# Generate test report
generate_report() {
    local passed_count=0
    local failed_count=0
    
    # Count results
    for result in $TEST_RESULTS; do
        if [[ "$result" == *":PASS" ]]; then
            ((passed_count++))
        elif [[ "$result" == *":FAIL" ]]; then
            ((failed_count++))
        fi
    done
    
    local total_tests=$((passed_count + failed_count))
    
    echo
    log_info "=== TEST REPORT ==="
    echo "Total Tests: $total_tests"
    echo "Passed: $passed_count"
    echo "Failed: $failed_count"
    echo
    
    if [[ $failed_count -gt 0 ]]; then
        log_error "Failed Tests:"
        for test in $FAILED_TESTS; do
            echo "  - $test"
        done
        echo
    fi
    
    if [[ $passed_count -gt 0 ]]; then
        log_success "Passed Tests:"
        for test in $PASSED_TESTS; do
            echo "  - $test"
        done
        echo
    fi
    
    # Exit with failure if any tests failed
    [[ $failed_count -eq 0 ]]
}

# Create simple test report (JUnit generation removed for bash 3.2 compatibility)
create_test_report() {
    local report_file="tests/results/test_report.txt"
    mkdir -p "$(dirname "$report_file")"
    
    {
        echo "RTI Connext DDS Kubernetes Examples Test Report"
        echo "=============================================="
        echo "Test run: $(date)"
        echo ""
        echo "Results:"
        for result in $TEST_RESULTS; do
            echo "  $result"
        done
    } > "$report_file"
    
    log_info "Test report saved to $report_file"
}

# Main execution
main() {
    local category="${1:-all}"
    
    log_info "Starting RTI Connext DDS Kubernetes Examples Test Suite"
    log_info "Test category: $category"
    log_info "Namespace: $NAMESPACE"
    
    # Get test cases for the category
    local test_cases
    test_cases=$(get_test_cases "$category")
    
    if [[ -z "$test_cases" ]]; then
        log_error "Unknown test category: $category"
        log_info "Available categories: basic, advanced, loadbalancer, all"
        exit 1
    fi
    
    setup_test_environment || exit 1
    
    # Run tests for specified category
    for use_case in $test_cases; do
        test_use_case "$use_case"
    done
    
    generate_report
}

# Run main function with all arguments
main "$@"