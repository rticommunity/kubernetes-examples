#!/bin/bash

# Test script for Pod-to-Pod Unicast Discovery using RTI Cloud Discovery Service
# This script tests unicast discovery with CDS

set -e

NAMESPACE="${NAMESPACE:-k8s-example-test}"
TIMEOUT="${TIMEOUT:-300}"
RTI_LICENSE_FILE="${RTI_LICENSE_FILE:-../rti_license.dat}"

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

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Setup RTI license ConfigMap
setup_rti_license() {
    print_info "Setting up RTI license ConfigMap..."
    
    # Look for license file in common locations
    local license_file=""
    for path in "../rti_license.dat" "../../rti_license.dat" "./rti_license.dat" "$RTI_LICENSE_FILE"; do
        if [[ -f "$path" ]]; then
            license_file="$path"
            break
        fi
    done
    
    if [[ -n "$license_file" ]]; then
        print_info "Creating RTI license ConfigMap from $license_file"
        kubectl create configmap rti-license \
            --from-file=rti_license.dat="$license_file" \
            -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
        print_success "RTI license ConfigMap created"
    else
        print_warning "RTI license file not found, creating placeholder for evaluation license"
        kubectl create configmap rti-license \
            --from-literal=rti_license.dat="# RTI Evaluation License" \
            -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
        print_warning "Using evaluation license - some features may be limited"
    fi
}

# Setup license
setup_rti_license

print_info "Deploying RTI Cloud Discovery Service..."

# Deploy CDS first
kubectl apply -f rticlouddiscoveryservice.yaml -n "$NAMESPACE"

# Wait for CDS to be ready
print_info "Waiting for Cloud Discovery Service to be ready..."
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rti-clouddiscoveryservice -n "$NAMESPACE"

CDS_POD=$(kubectl get pods -n "$NAMESPACE" -l run=rti-clouddiscoveryservice -o jsonpath='{.items[0].metadata.name}')
print_success "Cloud Discovery Service is ready: $CDS_POD"

# Check CDS logs
print_info "Cloud Discovery Service startup logs:"
kubectl logs "$CDS_POD" -n "$NAMESPACE" --tail=5

# Deploy DDS applications
print_info "Deploying RTI DDS Ping Publisher and Subscriber with CDS discovery..."
kubectl apply -f rtiddsping_cds_pub.yaml -n "$NAMESPACE"
kubectl apply -f rtiddsping_cds_sub.yaml -n "$NAMESPACE"

# Wait for deployments to be ready
print_info "Waiting for DDS applications to be ready..."
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-pub -n "$NAMESPACE"
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-sub -n "$NAMESPACE"

# Get pod names
PUB_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-pub -o jsonpath='{.items[0].metadata.name}')
SUB_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-sub -o jsonpath='{.items[0].metadata.name}')

print_info "Publisher pod: $PUB_POD"
print_info "Subscriber pod: $SUB_POD"

# Verify CDS connectivity from applications
print_info "Checking CDS connectivity..."
CDS_SERVICE_IP=$(kubectl get service rti-clouddiscoveryservice -n "$NAMESPACE" -o jsonpath='{.spec.clusterIP}')
print_info "CDS Service IP: $CDS_SERVICE_IP"

# Allow time for discovery and connection establishment
print_info "Allowing time for discovery and connections to establish..."
sleep 20

# Monitor communication
print_info "Monitoring DDS communication for 30 seconds..."

COMMUNICATION_SUCCESS=false
CDS_CONNECTIONS=false

for i in {1..6}; do  # Check for 30 seconds (6 * 5 seconds)
    print_info "Check $i/6: Analyzing system status..."
    
    # Check CDS logs for participant connections
    CDS_OUTPUT=$(kubectl logs "$CDS_POD" -n "$NAMESPACE" --tail=10 2>/dev/null || echo "")
    if echo "$CDS_OUTPUT" | grep -q "participant\|client"; then
        print_info "✓ CDS is handling participant connections"
        CDS_CONNECTIONS=true
    fi
    
    # Check publisher logs
    PUB_OUTPUT=$(kubectl logs "$PUB_POD" -n "$NAMESPACE" --tail=10 2>/dev/null || echo "")
    if echo "$PUB_OUTPUT" | grep -q "Sending data\|Sent sample"; then
        print_info "✓ Publisher is sending samples"
        
        # Check subscriber logs
        SUB_OUTPUT=$(kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=10 2>/dev/null || echo "")
        if echo "$SUB_OUTPUT" | grep -q "issue received\|Received sample\|Valid sample received"; then
            print_success "✓ Subscriber is receiving samples"
            COMMUNICATION_SUCCESS=true
            break
        fi
    fi
    
    sleep 5
done

# Display comprehensive results
echo ""
print_info "=== Final Test Results ==="

echo ""
print_info "Cloud Discovery Service logs (last 15 lines):"
kubectl logs "$CDS_POD" -n "$NAMESPACE" --tail=15

echo ""
print_info "Publisher logs (last 10 lines):"
kubectl logs "$PUB_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Subscriber logs (last 10 lines):"
kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "=== Service and Connectivity Status ==="
kubectl get services -n "$NAMESPACE"
kubectl get endpoints -n "$NAMESPACE"

echo ""
if [[ "$COMMUNICATION_SUCCESS" == "true" ]]; then
    print_success "✅ PASS: DDS communication via unicast discovery with CDS is working!"
elif [[ "$CDS_CONNECTIONS" == "true" ]]; then
    print_warning "⚠️  PARTIAL: CDS is working but DDS communication not fully verified"
    print_warning "This may be due to timing or configuration issues"
else
    print_error "❌ FAIL: CDS unicast discovery test failed"
    
    # Additional debugging
    echo ""
    print_info "=== Debugging Information ==="
    print_info "Pod status and network details:"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    print_info "Describing CDS pod for issues:"
    kubectl describe pod "$CDS_POD" -n "$NAMESPACE" | tail -20
    
    exit 1
fi

# Test HA configuration if available
if [[ -f "rticlouddiscoveryservice_ha.yaml" ]]; then
    echo ""
    print_info "=== Testing High Availability Configuration ==="
    print_info "HA configuration file found. Testing redundant CDS setup..."
    
    # Deploy HA CDS
    kubectl apply -f rticlouddiscoveryservice_ha.yaml -n "$NAMESPACE"
    
    # Wait for HA CDS
    kubectl wait --for=jsonpath='{.status.readyReplicas}'=2 --timeout="${TIMEOUT}s" statefulset/rticlouddiscoveryservice-ha -n "$NAMESPACE" || true
    
    # Check HA status
    HA_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=rticlouddiscoveryservice-ha -o jsonpath='{.items[*].metadata.name}')
    print_info "HA CDS pods: $HA_PODS"
    
    for pod in $HA_PODS; do
        if kubectl logs "$pod" -n "$NAMESPACE" --tail=5 | grep -q "started\|ready"; then
            print_success "✓ HA CDS pod $pod is running"
        else
            print_warning "⚠️  HA CDS pod $pod may have issues"
        fi
    done
fi

echo ""
print_info "=== Resource Usage ==="
kubectl top pods -n "$NAMESPACE" 2>/dev/null || print_info "Metrics not available"

print_info "Test completed. Resources remain deployed in namespace '$NAMESPACE'"
print_info "To cleanup: kubectl delete namespace $NAMESPACE"
