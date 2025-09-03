#!/bin/bash

# Test script for Intra-Pod Shared Memory Communication
# Tests shared memory communication between containers in the same pod

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

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

print_info "Testing intra-pod shared memory communication..."

# Deploy CDS first
print_info "Deploying Cloud Discovery Service..."
kubectl apply -f rticlouddiscoveryservice.yaml -n "$NAMESPACE"

# Wait for CDS
kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 --timeout="${TIMEOUT}s" statefulset/rticlouddiscoveryservice -n "$NAMESPACE"
CDS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rticlouddiscoveryservice -o jsonpath='{.items[0].metadata.name}')
print_success "Cloud Discovery Service ready: $CDS_POD"

# Deploy shared memory application (publisher and subscriber in same pod)
print_info "Deploying shared memory DDS application..."
kubectl apply -f rtiddsping_shmem.yaml -n "$NAMESPACE"

# Deploy separate subscriber for comparison
print_info "Deploying separate subscriber pod..."
kubectl apply -f rtiddsping_sub.yaml -n "$NAMESPACE"

# Wait for deployments
print_info "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-shmem -n "$NAMESPACE"
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-sub -n "$NAMESPACE"

# Get pod names
SHMEM_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-shmem -o jsonpath='{.items[0].metadata.name}')
SUB_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-sub -o jsonpath='{.items[0].metadata.name}')

print_info "Shared memory pod: $SHMEM_POD"
print_info "Separate subscriber pod: $SUB_POD"

# Allow time for discovery and shared memory setup
print_info "Allowing time for shared memory setup and discovery..."
sleep 30

# Monitor shared memory communication
print_info "Monitoring shared memory communication for 30 seconds..."

SHMEM_SUCCESS=false
NETWORK_SUCCESS=false

for i in {1..6}; do
    print_info "Check $i/6: Analyzing communication patterns..."
    
    # Check shared memory publisher container
    SHMEM_PUB_OUTPUT=$(kubectl logs "$SHMEM_POD" -c rtiddsping-shmem-pub -n "$NAMESPACE" --tail=5 2>/dev/null || echo "")
    
    # Check shared memory subscriber container (same pod)
    SHMEM_SUB_OUTPUT=$(kubectl logs "$SHMEM_POD" -c rtiddsping-shmem-sub -n "$NAMESPACE" --tail=5 2>/dev/null || echo "")
    
    # Check separate network subscriber
    NETWORK_SUB_OUTPUT=$(kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=5 2>/dev/null || echo "")
    
    # Analyze shared memory communication
    if echo "$SHMEM_PUB_OUTPUT" | grep -q "Sent sample"; then
        if echo "$SHMEM_SUB_OUTPUT" | grep -q "Received sample\|Valid sample received"; then
            print_info "✓ Shared memory communication detected"
            SHMEM_SUCCESS=true
        fi
    fi
    
    # Analyze network communication
    if echo "$SHMEM_PUB_OUTPUT" | grep -q "Sent sample"; then
        if echo "$NETWORK_SUB_OUTPUT" | grep -q "Received sample\|Valid sample received"; then
            print_info "✓ Network communication also working"
            NETWORK_SUCCESS=true
        fi
    fi
    
    if [[ "$SHMEM_SUCCESS" == "true" ]]; then
        break
    fi
    
    sleep 5
done

# Display detailed results
echo ""
print_info "=== Detailed Test Results ==="

echo ""
print_info "Cloud Discovery Service logs:"
kubectl logs "$CDS_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Shared Memory Publisher logs (same pod):"
kubectl logs "$SHMEM_POD" -c rtiddsping-shmem-pub -n "$NAMESPACE" --tail=10

echo ""
print_info "Shared Memory Subscriber logs (same pod):"
kubectl logs "$SHMEM_POD" -c rtiddsping-shmem-sub -n "$NAMESPACE" --tail=10

echo ""
print_info "Separate Network Subscriber logs:"
kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=10

# Analyze shared memory usage
echo ""
print_info "=== Shared Memory Analysis ==="
print_info "Pod resource usage and shared memory mounts:"
kubectl describe pod "$SHMEM_POD" -n "$NAMESPACE" | grep -A10 -B5 "Mounts:\|/dev/shm"

echo ""
print_info "Container resource usage:"
kubectl top pods "$SHMEM_POD" --containers -n "$NAMESPACE" 2>/dev/null || print_info "Container metrics not available"

# Performance comparison
echo ""
print_info "=== Performance Indicators ==="

# Check if we can analyze transport methods from logs
SHMEM_TRANSPORT_DETECTED=false
if kubectl logs "$SHMEM_POD" -c rtiddsping-shmem-pub -n "$NAMESPACE" | grep -qi "shmem\|shared"; then
    SHMEM_TRANSPORT_DETECTED=true
    print_info "✓ Shared memory transport detected in logs"
fi

if kubectl logs "$SHMEM_POD" -c rtiddsping-shmem-sub -n "$NAMESPACE" | grep -qi "shmem\|shared"; then
    SHMEM_TRANSPORT_DETECTED=true
    print_info "✓ Shared memory transport detected in subscriber logs"
fi

# Final assessment
echo ""
print_info "=== Final Assessment ==="

if [[ "$SHMEM_SUCCESS" == "true" ]]; then
    print_success "✅ PASS: Intra-pod shared memory communication is working!"
    
    if [[ "$NETWORK_SUCCESS" == "true" ]]; then
        print_info "✓ Both shared memory and network communication are functional"
    fi
    
    if [[ "$SHMEM_TRANSPORT_DETECTED" == "true" ]]; then
        print_success "✓ Shared memory transport explicitly detected"
    else
        print_warning "⚠️  Shared memory transport not explicitly detected in logs"
        print_warning "Communication may be using network transport as fallback"
    fi
    
else
    print_error "❌ FAIL: Intra-pod shared memory communication failed"
    
    if [[ "$NETWORK_SUCCESS" == "true" ]]; then
        print_warning "Network communication is working, but shared memory is not"
    else
        print_error "Neither shared memory nor network communication is working"
    fi
    
    # Debugging information
    echo ""
    print_info "=== Debugging Information ==="
    print_info "Pod status:"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    print_info "Pod events:"
    kubectl get events -n "$NAMESPACE" --field-selector involvedObject.name="$SHMEM_POD"
    
    print_info "Shared memory pod description:"
    kubectl describe pod "$SHMEM_POD" -n "$NAMESPACE" | tail -30
    
    exit 1
fi

echo ""
print_info "=== Resource Summary ==="
kubectl get all -n "$NAMESPACE"

print_info "Test completed. Resources remain deployed in namespace '$NAMESPACE'"
print_info "To cleanup: kubectl delete namespace $NAMESPACE"
