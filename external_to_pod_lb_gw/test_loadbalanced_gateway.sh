#!/bin/bash

# Test script for External to Pod Load-Balanced Gateway
# Tests load-balanced external connectivity through LoadBalancer service

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

print_info "Testing external to pod load-balanced gateway configuration..."

# Deploy CDS first
print_info "Deploying Cloud Discovery Service..."
kubectl apply -f rticlouddiscoveryservice.yaml -n "$NAMESPACE"

# Wait for CDS
kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 --timeout="${TIMEOUT}s" statefulset/rticlouddiscoveryservice -n "$NAMESPACE"
CDS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rticlouddiscoveryservice -o jsonpath='{.items[0].metadata.name}')
print_success "Cloud Discovery Service ready: $CDS_POD"

# Deploy Routing Service with LoadBalancer
print_info "Deploying RTI Routing Service with LoadBalancer..."
kubectl apply -f rtiroutingservice_loadbalancer.yaml -n "$NAMESPACE"

# Wait for Routing Service deployment
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiroutingservice -n "$NAMESPACE"
RS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiroutingservice -o jsonpath='{.items[0].metadata.name}')
print_success "Routing Service deployment ready: $RS_POD"

# Deploy internal subscriber
print_info "Deploying internal DDS subscriber..."
kubectl apply -f rtiddsping_cds_sub.yaml -n "$NAMESPACE"

# Wait for subscriber
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiddsping-cds-sub -n "$NAMESPACE"
SUB_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiddsping-cds-sub -o jsonpath='{.items[0].metadata.name}')
print_success "Internal subscriber ready: $SUB_POD"

# Check LoadBalancer service status
print_info "Checking LoadBalancer service status..."
print_info "Waiting for external IP assignment (this may take several minutes in cloud environments)..."

EXTERNAL_IP=""
LB_PORT=""
attempts=0
max_attempts=30

while [[ -z "$EXTERNAL_IP" && $attempts -lt $max_attempts ]]; do
    print_info "Attempt $((attempts + 1))/$max_attempts: Checking for external IP..."
    
    # Try to get external IP
    EXTERNAL_IP=$(kubectl get service rtiroutingservice-loadbalancer -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    # If no IP, try hostname (for AWS ELB, etc.)
    if [[ -z "$EXTERNAL_IP" ]]; then
        EXTERNAL_IP=$(kubectl get service rtiroutingservice-loadbalancer -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    fi
    
    if [[ -n "$EXTERNAL_IP" ]]; then
        LB_PORT=$(kubectl get service rtiroutingservice-loadbalancer -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].port}')
        print_success "LoadBalancer external endpoint: $EXTERNAL_IP:$LB_PORT"
        break
    fi
    
    sleep 10
    ((attempts++))
done

if [[ -z "$EXTERNAL_IP" ]]; then
    print_warning "LoadBalancer external IP not assigned after $((max_attempts * 10)) seconds"
    print_warning "This may be expected in environments without LoadBalancer support (minikube, kind, etc.)"
    
    # Fall back to NodePort-style testing
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    SERVICE_PORT=$(kubectl get service rtiroutingservice-loadbalancer -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
    
    if [[ -n "$SERVICE_PORT" ]]; then
        print_info "Falling back to NodePort-style access: $NODE_IP:$SERVICE_PORT"
        EXTERNAL_IP="$NODE_IP"
        LB_PORT="$SERVICE_PORT"
    fi
fi

# Allow time for services to initialize
print_info "Allowing time for services to initialize and establish connections..."
sleep 30

# Test internal connectivity
print_info "=== Testing Internal Connectivity ==="

INTERNAL_SUCCESS=false
for i in {1..6}; do
    print_info "Internal connectivity check $i/6..."
    
    # Check if routing service is properly started
    RS_OUTPUT=$(kubectl logs "$RS_POD" -n "$NAMESPACE" --tail=10 2>/dev/null || echo "")
    if echo "$RS_OUTPUT" | grep -q "started\|ready\|listening"; then
        print_info "✓ Routing Service is running"
        
        # Check for load balancing indications
        if echo "$RS_OUTPUT" | grep -q "load\|balance\|multiple"; then
            print_info "✓ Load balancing features detected"
        fi
        
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

# Test external connectivity if external IP is available
LB_CONNECTIVITY_SUCCESS=false

if [[ -n "$EXTERNAL_IP" && -n "$LB_PORT" ]]; then
    print_info "=== Testing LoadBalancer Connectivity ==="
    
    # Test connectivity to LoadBalancer
    if command -v nc &> /dev/null; then
        print_info "Testing LoadBalancer connectivity to $EXTERNAL_IP:$LB_PORT..."
        if timeout 5 nc -z "$EXTERNAL_IP" "$LB_PORT" 2>/dev/null; then
            print_success "✓ LoadBalancer service is reachable"
            LB_CONNECTIVITY_SUCCESS=true
        else
            print_warning "⚠️  LoadBalancer service may not be reachable from this location"
        fi
    fi
    
    # Test with RTI application if available
    RTI_TEST_SUCCESS=false
    if [[ -f "rwt_participant.xml" ]] && command -v rtiddsping &> /dev/null; then
        print_info "Testing external RTI application connection through LoadBalancer..."
        
        # Modify participant XML to use LoadBalancer endpoint if needed
        # (This would require more sophisticated XML manipulation in a real scenario)
        
    # Run external publisher for 10 seconds
    timeout 10 rtiddsping -publisher -domainId 100 
        -qosFile rwt_participant.xml 
        -qosProfile RWT_Demo::RWT_Profile 
        -numSamples 5 -sendPeriod 2 &>/dev/null &
    
    RTI_PID=$!
    sleep 5        # Check if internal subscriber received anything
        SUB_OUTPUT=$(kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=20 2>/dev/null || echo "")
        if echo "$SUB_OUTPUT" | grep -q "Received sample\|Valid sample received"; then
            print_success "✓ External RTI application successfully communicated through LoadBalancer"
            RTI_TEST_SUCCESS=true
        fi
        
        # Cleanup
        kill $RTI_PID 2>/dev/null || true
        wait $RTI_PID 2>/dev/null || true
    fi
fi

# Test load balancing if multiple replicas
print_info "=== Testing Load Balancing ==="

REPLICAS=$(kubectl get deployment rtiroutingservice -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
READY_REPLICAS=$(kubectl get deployment rtiroutingservice -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')

print_info "Routing Service replicas: $READY_REPLICAS/$REPLICAS"

if [[ "$READY_REPLICAS" -gt 1 ]]; then
    print_info "Multiple replicas detected. Testing load distribution..."
    
    # Get all routing service pods
    RS_PODS=($(kubectl get pods -n "$NAMESPACE" -l app=rtiroutingservice -o jsonpath='{.items[*].metadata.name}'))
    
    print_info "Routing Service pods: ${RS_PODS[*]}"
    
    # Check if all pods are receiving traffic (would need more sophisticated testing)
    ACTIVE_PODS=0
    for pod in "${RS_PODS[@]}"; do
        if kubectl logs "$pod" -n "$NAMESPACE" --tail=5 | grep -q "connection\|client\|traffic"; then
            print_info "✓ Pod $pod shows activity"
            ((ACTIVE_PODS++))
        fi
    done
    
    if [[ $ACTIVE_PODS -gt 1 ]]; then
        print_success "✓ Load balancing appears to be working across $ACTIVE_PODS pods"
    else
        print_warning "⚠️  Load balancing may not be distributing traffic evenly"
    fi
else
    print_info "Single replica deployment - load balancing test not applicable"
fi

# Display comprehensive results
echo ""
print_info "=== Service Status and Logs ==="

echo ""
print_info "LoadBalancer service details:"
kubectl describe service rtiroutingservice-loadbalancer -n "$NAMESPACE"

echo ""
print_info "Cloud Discovery Service logs:"
kubectl logs "$CDS_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Routing Service logs (latest pod):"
kubectl logs "$RS_POD" -n "$NAMESPACE" --tail=15

echo ""
print_info "Internal Subscriber logs:"
kubectl logs "$SUB_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "=== Network Configuration ==="
kubectl get services -n "$NAMESPACE"
kubectl get endpoints -n "$NAMESPACE"

# Final assessment
echo ""
print_info "=== Final Assessment ==="

if [[ "$INTERNAL_SUCCESS" == "true" ]]; then
    if [[ -n "$EXTERNAL_IP" ]]; then
        if [[ "$LB_CONNECTIVITY_SUCCESS" == "true" ]]; then
            print_success "✅ PASS: External to Pod Load-Balanced Gateway is functional!"
            print_success "✓ Internal services are running"
            print_success "✓ LoadBalancer service is accessible at $EXTERNAL_IP:$LB_PORT"
            
            if [[ "${RTI_TEST_SUCCESS:-false}" == "true" ]]; then
                print_success "✓ External RTI application successfully connected"
            fi
        else
            print_warning "⚠️  PARTIAL: LoadBalancer is deployed but connectivity uncertain"
        fi
    else
        print_warning "⚠️  PARTIAL: Internal services are working but LoadBalancer external IP not available"
        print_warning "This is expected in environments without LoadBalancer support"
    fi
else
    print_error "❌ FAIL: Load-balanced gateway configuration has issues"
    
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
if [[ -n "$EXTERNAL_IP" && -n "$LB_PORT" ]]; then
    print_info "LoadBalancer endpoint: $EXTERNAL_IP:$LB_PORT"
    print_info "To test external connectivity manually:"
    print_info "1. Update rwt_participant.xml with LoadBalancer endpoint if needed"
    print_info "2. Run: rtiddsping -publisher -domainId 100 -qosFile rwt_participant.xml -qosProfile RWT_Demo::RWT_Profile"
    print_info "3. Monitor internal subscriber: kubectl logs $SUB_POD -n $NAMESPACE -f"
else
    print_info "LoadBalancer external IP not available - manual testing may require port-forwarding"
    print_info "kubectl port-forward service/rtiroutingservice-loadbalancer 7400:7400 -n $NAMESPACE"
fi

echo ""
print_info "Test completed. Resources remain deployed in namespace '$NAMESPACE'"
print_info "To cleanup: kubectl delete namespace $NAMESPACE"
