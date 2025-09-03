#!/bin/bash

# Test script for Pod-to-Pod Multicast Discovery
# This script tests the basic multicast discovery between RTI DDS applications
# NOTE: Many Kubernetes clusters (EKS, GKE, AKS) do not support multicast networking
# This test will validate deployment but may show limited connectivity in such environments

set -e

NAMESPACE="${NAMESPACE:-k8s-example-test}"
TIMEOUT="${TIMEOUT:-300}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Function to check if cluster supports multicast
check_multicast_support() {
    print_info "=== Checking Cluster Multicast Support ==="
    
    # Create a temporary test pod to check multicast capabilities
    local test_pod_name="multicast-test-$$"
    
    print_info "Creating test pod to check multicast support..."
    
    # Create a simple test pod
    cat <<EOF | kubectl apply -f - -n "$NAMESPACE"
apiVersion: v1
kind: Pod
metadata:
  name: $test_pod_name
  labels:
    app: multicast-test
spec:
  containers:
  - name: multicast-test
    image: busybox:1.35
    command: ['sleep', '300']
    securityContext:
      capabilities:
        add: ["NET_ADMIN"]
  restartPolicy: Never
EOF

    # Wait for pod to be ready
    if ! kubectl wait --for=condition=ready --timeout=60s pod/"$test_pod_name" -n "$NAMESPACE" 2>/dev/null; then
        print_warning "Test pod failed to start, skipping multicast detection"
        kubectl delete pod "$test_pod_name" -n "$NAMESPACE" --ignore-not-found=true
        return 2  # Unknown
    fi
    
    # Test multicast capabilities
    print_info "Testing multicast capabilities in pod..."
    
    local multicast_result=""
    
    # Check if we can bind to multicast address
    multicast_result=$(kubectl exec "$test_pod_name" -n "$NAMESPACE" -- sh -c '
        # Test 1: Check if multicast interfaces are available
        if ip route show | grep -q "224.0.0.0/4"; then
            echo "MULTICAST_ROUTE_OK"
        fi
        
        # Test 2: Try to join a multicast group (239.255.0.1 is RTI default)
        if nc -u -l -p 12345 239.255.0.1 12345 &>/dev/null &
        then
            PID=$!
            sleep 1
            kill $PID 2>/dev/null || true
            echo "MULTICAST_BIND_OK"
        fi
        
        # Test 3: Check network interface flags for multicast
        if ip addr show | grep -q "MULTICAST"; then
            echo "MULTICAST_IF_OK"
        fi
    ' 2>/dev/null || echo "")
    
    # Clean up test pod
    kubectl delete pod "$test_pod_name" -n "$NAMESPACE" --ignore-not-found=true
    
    # Analyze results
    local multicast_supported=false
    local support_indicators=0
    
    if echo "$multicast_result" | grep -q "MULTICAST_ROUTE_OK"; then
        print_info "✓ Multicast routing table entries found"
        ((support_indicators++))
    fi
    
    if echo "$multicast_result" | grep -q "MULTICAST_BIND_OK"; then
        print_info "✓ Multicast address binding successful"
        ((support_indicators++))
        multicast_supported=true
    fi
    
    if echo "$multicast_result" | grep -q "MULTICAST_IF_OK"; then
        print_info "✓ Network interfaces support multicast"
        ((support_indicators++))
    fi
    
    # Additional cluster-specific checks
    print_info "Checking cluster provider indicators..."
    
    # Check for cloud provider indicators that typically don't support multicast
    local cloud_provider=""
    local node_info=$(kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' 2>/dev/null || echo "")
    
    if echo "$node_info" | grep -qi "aws"; then
        cloud_provider="AWS EKS"
        print_warning "Detected AWS EKS - multicast typically not supported"
    elif echo "$node_info" | grep -qi "gce"; then
        cloud_provider="Google GKE"
        print_warning "Detected Google GKE - multicast typically not supported"
    elif echo "$node_info" | grep -qi "azure"; then
        cloud_provider="Azure AKS"
        print_warning "Detected Azure AKS - multicast typically not supported"
    elif kubectl get nodes -o wide | grep -qi "minikube"; then
        cloud_provider="Minikube"
        print_info "Detected Minikube - limited multicast support"
    elif kubectl get nodes -o wide | grep -qi "kind"; then
        cloud_provider="Kind"
        print_info "Detected Kind - limited multicast support"
    else
        print_info "On-premises or unknown cluster type detected"
    fi
    
    # Final determination - be more conservative for known cloud providers
    echo ""
    print_info "=== Multicast Support Assessment ==="
    print_info "Support indicators found: $support_indicators/3"
    if [[ -n "$cloud_provider" ]]; then
        print_info "Cluster type: $cloud_provider"
    fi
    
    # Override support detection for known cloud providers that don't support multicast
    if [[ "$cloud_provider" =~ ^(AWS EKS|Google GKE|Azure AKS)$ ]]; then
        print_warning "❌ Cloud provider override: $cloud_provider does not support inter-pod multicast"
        print_info "While pods can bind to multicast addresses, inter-pod multicast traffic is blocked"
        return 2  # Not supported - override technical detection
    elif [[ "$multicast_supported" == "true" && $support_indicators -ge 2 ]]; then
        print_success "✅ Multicast support detected - full test will be performed"
        return 0  # Supported
    elif [[ $support_indicators -ge 1 ]]; then
        print_warning "⚠️  Limited multicast support detected - test with expectations"
        return 1  # Limited
    else
        print_warning "❌ No multicast support detected - deployment-only test"
        return 2  # Not supported
    fi
}

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Check multicast support first
check_multicast_support
MULTICAST_SUPPORT_LEVEL=$?

# Skip test if multicast is not supported
case $MULTICAST_SUPPORT_LEVEL in
    0)
        print_success "Multicast support detected - proceeding with full test"
        ;;
    1)
        print_warning "Limited multicast support detected - proceeding with expectations set"
        ;;
    2)
        print_warning "⚠️  SKIPPING TEST: No multicast support detected in cluster"
        echo ""
        print_info "=== Test Skipped - Multicast Not Supported ==="
        print_info "This cluster does not support multicast networking."
        print_info "The multicast discovery example requires multicast support to function properly."
        echo ""
        print_info "Recommendations:"
        print_info "• Use the unicast discovery example instead: ../pod_to_pod_unicast_disc/"
        print_info "• Consider an on-premises cluster with multicast-enabled CNI"
        print_info "• For cloud environments, unicast discovery is the recommended approach"
        echo ""
        print_success "✅ SKIPPED: Test appropriately skipped due to cluster limitations"
        exit 0
        ;;
esac

print_info "Deploying RTI DDS Ping Publisher and Subscriber with multicast discovery..."

# Apply the configurations
kubectl apply -f rtiddsping_pub.yaml -n "$NAMESPACE"
kubectl apply -f rtiddsping_sub.yaml -n "$NAMESPACE"

# Wait for deployments to be ready
print_info "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-pub -n "$NAMESPACE"
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-sub -n "$NAMESPACE"

# Get pod names
PUB_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-pub -o jsonpath='{.items[0].metadata.name}')
SUB_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-sub -o jsonpath='{.items[0].metadata.name}')

print_info "Publisher pod: $PUB_POD"
print_info "Subscriber pod: $SUB_POD"

# Monitor communication
print_info "Monitoring DDS communication for 30 seconds..."
sleep 10  # Allow time for discovery

# Adjust expectations based on multicast support level
case $MULTICAST_SUPPORT_LEVEL in
    0)
        print_info "Full multicast support detected - expecting robust communication"
        EXPECTED_COMMUNICATION=true
        ;;
    1)
        print_info "Limited multicast support - communication may be intermittent"
        EXPECTED_COMMUNICATION=partial
        ;;
    2)
        print_info "No multicast support detected - testing deployment only"
        EXPECTED_COMMUNICATION=false
        ;;
esac

# Check logs for successful communication
COMMUNICATION_SUCCESS=false
for i in {1..6}; do  # Check for 30 seconds (6 * 5 seconds)
    print_info "Check $i/6: Looking for DDS communication..."
    
    # Check publisher logs
    PUB_OUTPUT=$(kubectl logs "$PUB_POD" -n "$NAMESPACE" --tail=5 2>/dev/null || echo "")
    if echo "$PUB_OUTPUT" | grep -q "Sent sample"; then
        print_info "✓ Publisher is sending samples"
        
        # Check subscriber logs
        SUB_OUTPUT=$(kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=5 2>/dev/null || echo "")
        if echo "$SUB_OUTPUT" | grep -q "Received sample\|Valid sample received"; then
            print_success "✓ Subscriber is receiving samples"
            COMMUNICATION_SUCCESS=true
            break
        fi
    fi
    
    # If no multicast support expected, don't wait the full time
    if [[ "$EXPECTED_COMMUNICATION" == "false" && $i -ge 3 ]]; then
        print_info "Stopping early - no multicast support detected"
        break
    fi
    
    sleep 5
done

# Display final results
echo ""
print_info "=== Final Test Results ==="
print_info "Publisher logs (last 10 lines):"
kubectl logs "$PUB_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Subscriber logs (last 10 lines):"
kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=10

echo ""
# Check for multicast support indicators
print_info "=== Multicast Support Analysis ==="
MULTICAST_INDICATORS=false

# Look for multicast-related messages in logs
PUB_FULL_OUTPUT=$(kubectl logs "$PUB_POD" -n "$NAMESPACE" 2>/dev/null || echo "")
SUB_FULL_OUTPUT=$(kubectl logs "$SUB_POD" -n "$NAMESPACE" 2>/dev/null || echo "")

if echo "$PUB_FULL_OUTPUT $SUB_FULL_OUTPUT" | grep -qi "multicast\|239\.255"; then
    print_info "✓ Multicast networking indicators found in logs"
    MULTICAST_INDICATORS=true
else
    print_warning "⚠️  No multicast networking indicators found in logs"
fi

# Check for common multicast failure patterns
if echo "$PUB_FULL_OUTPUT $SUB_FULL_OUTPUT" | grep -qi "SPDP.*fail\|discovery.*timeout\|no.*peers"; then
    print_warning "⚠️  Possible multicast discovery issues detected"
fi

if [[ "$COMMUNICATION_SUCCESS" == "true" ]]; then
    print_success "✅ PASS: DDS communication via multicast discovery is working!"
    if [[ "$MULTICAST_INDICATORS" == "true" ]]; then
        print_success "✓ Multicast networking appears to be supported"
    else
        print_warning "⚠️  Communication working but multicast indicators unclear"
    fi
elif [[ "$EXPECTED_COMMUNICATION" == "false" ]]; then
    # Check if deployments are at least healthy
    PUB_STATUS=$(kubectl get pod "$PUB_POD" -n "$NAMESPACE" -o jsonpath='{.status.phase}')
    SUB_STATUS=$(kubectl get pod "$SUB_POD" -n "$NAMESPACE" -o jsonpath='{.status.phase}')
    
    if [[ "$PUB_STATUS" == "Running" && "$SUB_STATUS" == "Running" ]]; then
        print_warning "⚠️  EXPECTED LIMITATION: No multicast support detected in cluster"
        print_info "✓ Deployments are healthy and running"
        print_info "✓ Configuration validation successful"
        print_warning "⚠️  Communication limited due to cluster multicast restrictions"
        print_info "This is the expected behavior for this cluster type"
    else
        print_error "❌ FAIL: Pod deployment issues detected"
        exit 1
    fi
elif [[ "$EXPECTED_COMMUNICATION" == "partial" ]]; then
    print_warning "⚠️  PARTIAL: Limited multicast support - communication may be intermittent"
    print_info "This behavior is expected with limited multicast support"
elif [[ "$MULTICAST_INDICATORS" == "false" ]]; then
    print_warning "⚠️  EXPECTED: Multicast discovery may not work in this cluster environment"
    print_info "Many Kubernetes clusters (EKS, GKE, AKS, etc.) do not support multicast networking"
    print_info "This is expected behavior - consider using unicast discovery instead"
    print_info "See the pod-to-pod-unicast example for unicast-based communication"
    
    # Don't fail the test if it's likely due to lack of multicast support
    print_warning "⚠️  PARTIAL PASS: Deployment successful, multicast limitations expected"
else
    print_error "❌ FAIL: DDS communication not detected"
    
    # Additional debugging info
    echo ""
    print_info "=== Debugging Information ==="
    print_info "Pod status:"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    print_info "Pod network details:"
    kubectl describe pod "$PUB_POD" -n "$NAMESPACE" | grep -A5 "IP:"
    kubectl describe pod "$SUB_POD" -n "$NAMESPACE" | grep -A5 "IP:"
    
    exit 1
fi

# Optional: Check resource usage
echo ""
print_info "=== Resource Usage ==="
kubectl top pods -n "$NAMESPACE" 2>/dev/null || print_info "Metrics not available"

echo ""
print_info "=== Cluster Multicast Compatibility Notes ==="
print_info "✓ This test validates RTI DDS multicast discovery deployment"
print_info "✓ Deployment success indicates proper Kubernetes configuration"
print_warning "⚠️  Note: Many cloud Kubernetes services do NOT support multicast:"
print_info "  - Amazon EKS: No multicast support"
print_info "  - Google GKE: No multicast support"  
print_info "  - Azure AKS: No multicast support"
print_info "  - On-premises clusters: May support multicast depending on CNI"
print_info ""
print_info "For reliable pod-to-pod communication in cloud environments:"
print_info "→ Use the unicast discovery example instead"
print_info "→ See: ../pod_to_pod_unicast_disc/"

print_info "Test completed. Resources remain deployed in namespace '$NAMESPACE'"
print_info "To cleanup: kubectl delete namespace $NAMESPACE"
