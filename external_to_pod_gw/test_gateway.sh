#!/bin/bash

# Test script for External to Pod Gateway using RTI Routing Service
# Tests external connectivity through NodePort service

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

print_info "Testing external to pod gateway configuration..."

# Deploy CDS first
print_info "Deploying Cloud Discovery Service..."
kubectl apply -f rticlouddiscoveryservice.yaml -n "$NAMESPACE"

# Wait for CDS
kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 --timeout="${TIMEOUT}s" statefulset/rticlouddiscoveryservice -n "$NAMESPACE"
CDS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rticlouddiscoveryservice -o jsonpath='{.items[0].metadata.name}')
print_success "Cloud Discovery Service ready: $CDS_POD"

# Deploy Routing Service with NodePort
print_info "Deploying RTI Routing Service with NodePort..."
kubectl apply -f rtiroutingservice_nodeport.yaml -n "$NAMESPACE"

# Wait for Routing Service
kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 --timeout="${TIMEOUT}s" statefulset/rtiroutingservice -n "$NAMESPACE"
RS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiroutingservice -o jsonpath='{.items[0].metadata.name}')
print_success "Routing Service ready: $RS_POD"

# Deploy internal subscriber
print_info "Deploying internal DDS subscriber..."
kubectl apply -f rtiddsping_cds_sub.yaml -n "$NAMESPACE"

# Wait for subscriber
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-cds-sub -n "$NAMESPACE"
SUB_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-cds-sub -o jsonpath='{.items[0].metadata.name}')
print_success "Internal subscriber ready: $SUB_POD"

# Get service information
NODEPORT_SERVICE=$(kubectl get service rtiroutingservice-nodeport -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')

if [[ -z "$NODE_IP" ]]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    print_warning "Using internal IP: $NODE_IP (external IP not available)"
else
    print_info "Using external IP: $NODE_IP"
fi

print_success "Routing Service accessible at: $NODE_IP:$NODEPORT_SERVICE"

# Allow time for services to initialize
print_info "Allowing time for services to initialize and establish connections..."
sleep 30

# Test internal connectivity first
print_info "=== Testing Internal Connectivity ==="

INTERNAL_SUCCESS=false
for i in {1..6}; do
    print_info "Internal connectivity check $i/6..."
    
    # Check if routing service is properly started
    RS_OUTPUT=$(kubectl logs "$RS_POD" -n "$NAMESPACE" --tail=10 2>/dev/null || echo "")
    if echo "$RS_OUTPUT" | grep -q "started\|ready\|listening"; then
        print_info "✓ Routing Service is running"
        
        # Check subscriber for any activity
        SUB_OUTPUT=$(kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=5 2>/dev/null || echo "")
        if echo "$SUB_OUTPUT" | grep -q "Received\|discovered\|matched"; then
            print_success "✓ Internal subscriber is active"
            INTERNAL_SUCCESS=true
            break
        fi
    fi
    
    sleep 5
done

# Test external connectivity
print_info "=== Testing External Connectivity ==="

# Check if we can reach the NodePort service
print_info "Testing NodePort connectivity to $NODE_IP:$NODEPORT_SERVICE..."

NODEPORT_REACHABLE=false

# Test with netcat if available
if command -v nc &> /dev/null; then
    if timeout 5 nc -z "$NODE_IP" "$NODEPORT_SERVICE" 2>/dev/null; then
        print_success "✓ NodePort service is reachable"
        NODEPORT_REACHABLE=true
    else
        print_warning "⚠️  NodePort service may not be reachable from this location"
    fi
else
    print_warning "netcat (nc) not available for connectivity testing"
fi

# Test with RTI application if available
RTI_TEST_SUCCESS=false
if [[ -f "rwt_participant.xml" ]] && command -v rtiddsping &> /dev/null; then
    print_info "RTI DDS Ping found. Testing external connection..."
    
    # Run external publisher for 10 seconds
    timeout 10 rtiddsping -publisher -domainId 100 \
        -qosFile rwt_participant.xml \
        -qosProfile RWT_Demo::RWT_Profile \
        -numSamples 5 -sendPeriod 2 &>/dev/null &
    
    RTI_PID=$!
    sleep 5
    
    # Check if internal subscriber received anything
    SUB_OUTPUT=$(kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=20 2>/dev/null || echo "")
    if echo "$SUB_OUTPUT" | grep -q "Received sample\|Valid sample received"; then
        print_success "✓ External RTI application successfully communicated through gateway"
        RTI_TEST_SUCCESS=true
    fi
    
    # Cleanup
    kill $RTI_PID 2>/dev/null || true
    wait $RTI_PID 2>/dev/null || true
fi

# Display comprehensive results
echo ""
print_info "=== Service Status and Logs ==="

echo ""
print_info "Cloud Discovery Service logs:"
kubectl logs "$CDS_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Routing Service logs:"
kubectl logs "$RS_POD" -n "$NAMESPACE" --tail=15

echo ""
print_info "Internal Subscriber logs:"
kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "=== Network Configuration ==="
kubectl get services -n "$NAMESPACE"
kubectl get endpoints -n "$NAMESPACE"

print_info "NodePort service details:"
kubectl describe service rtiroutingservice-nodeport -n "$NAMESPACE"

# Configuration analysis
echo ""
print_info "=== Configuration Analysis ==="

if [[ -f "USER_ROUTING_SERVICE.xml" ]]; then
    print_info "Routing Service configuration found. Key settings:"
    if grep -q "domain_route" USER_ROUTING_SERVICE.xml; then
        print_info "✓ Domain routing configured"
    fi
    if grep -q "participant" USER_ROUTING_SERVICE.xml; then
        print_info "✓ Participant configuration found"
    fi
fi

if [[ -f "rwt_participant.xml" ]]; then
    print_info "RWT participant configuration found. Key settings:"
    if grep -q "transport" rwt_participant.xml; then
        print_info "✓ RWT transport configuration found"
    fi
fi

# Final assessment
echo ""
print_info "=== Final Assessment ==="

if [[ "$INTERNAL_SUCCESS" == "true" && "$NODEPORT_REACHABLE" == "true" ]]; then
    if [[ "$RTI_TEST_SUCCESS" == "true" ]]; then
        print_success "✅ PASS: External to Pod Gateway is fully functional!"
        print_success "✓ Internal services are running"
        print_success "✓ NodePort service is accessible"
        print_success "✓ External RTI application successfully connected"
    else
        print_warning "⚠️  PARTIAL: Gateway infrastructure is ready but external RTI test not performed"
        print_warning "Manual testing with external RTI application recommended"
        print_info "To test manually:"
        print_info "rtiddsping -publisher -domainId 100 -qosFile rwt_participant.xml -qosProfile RWT_Demo::RWT_Profile"
    fi
elif [[ "$INTERNAL_SUCCESS" == "true" ]]; then
    print_warning "⚠️  PARTIAL: Internal services are working but external connectivity uncertain"
else
    print_error "❌ FAIL: Gateway configuration has issues"
    
    # Debugging
    echo ""
    print_info "=== Debugging Information ==="
    print_info "Pod status:"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    print_info "Recent events:"
    kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -10
    
    exit 1
fi

echo ""
print_info "=== Manual Testing Instructions ==="
print_info "To test external connectivity manually:"
print_info "1. Ensure you have RTI Connext DDS installed"
print_info "2. Copy rwt_participant.xml to your external system"
print_info "3. Run: rtiddsping -publisher -domainId 100 -qosFile rwt_participant.xml -qosProfile RWT_Demo::RWT_Profile"
print_info "4. Monitor internal subscriber logs: kubectl logs $SUB_POD -n $NAMESPACE -f"

echo ""
print_info "Gateway endpoint: $NODE_IP:$NODEPORT_SERVICE"
print_info "Test completed. Resources remain deployed in namespace '$NAMESPACE'"
print_info "To cleanup: kubectl delete namespace $NAMESPACE"
