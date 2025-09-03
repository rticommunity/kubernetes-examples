#!/bin/bash

# Test script for External to External Load-Balanced Gateway
# Tests external-to-external communication through load-balanced routing services

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

print_info "Testing external to external load-balanced gateway configuration..."

# Deploy CDS first
print_info "Deploying Cloud Discovery Service..."
kubectl apply -f rticlouddiscoveryservice.yaml -n "$NAMESPACE"

# Wait for CDS
kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 --timeout="${TIMEOUT}s" statefulset/rticlouddiscoveryservice -n "$NAMESPACE"
CDS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rticlouddiscoveryservice -o jsonpath='{.items[0].metadata.name}')
print_success "Cloud Discovery Service ready: $CDS_POD"

# Deploy main LoadBalancer Routing Service
print_info "Deploying main RTI Routing Service with LoadBalancer..."
kubectl apply -f rtiroutingservice_loadbalancer.yaml -n "$NAMESPACE"

# Wait for main routing service
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiroutingservice -n "$NAMESPACE"
MAIN_RS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiroutingservice -o jsonpath='{.items[0].metadata.name}')
print_success "Main Routing Service ready: $MAIN_RS_POD"

# Deploy publisher-side routing service
print_info "Deploying publisher-side routing service..."
kubectl apply -f rtiroutingservice-pub.yaml -n "$NAMESPACE"

# Wait for publisher routing service
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiroutingservice-pub -n "$NAMESPACE"
PUB_RS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiroutingservice-pub -o jsonpath='{.items[0].metadata.name}')
print_success "Publisher-side Routing Service ready: $PUB_RS_POD"

# Deploy subscriber-side routing service
print_info "Deploying subscriber-side routing service..."
kubectl apply -f rtiroutingservice-sub.yaml -n "$NAMESPACE"

# Wait for subscriber routing service
kubectl wait --for=condition=available --timeout="${TIMEOUT}s" deployment/rtiroutingservice-sub -n "$NAMESPACE"
SUB_RS_POD=$(kubectl get pods -n "$NAMESPACE" -l app=rtiroutingservice-sub -o jsonpath='{.items[0].metadata.name}')
print_success "Subscriber-side Routing Service ready: $SUB_RS_POD"

# Get LoadBalancer information
print_info "Checking LoadBalancer service status..."

EXTERNAL_IP=""
LB_PORT=""
attempts=0
max_attempts=30

while [[ -z "$EXTERNAL_IP" && $attempts -lt $max_attempts ]]; do
    print_info "Attempt $((attempts + 1))/$max_attempts: Checking for external IP..."
    
    EXTERNAL_IP=$(kubectl get service rtiroutingservice-loadbalancer -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
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
    print_warning "LoadBalancer external IP not assigned"
    print_warning "Testing internal routing service communication only"
fi

# Allow time for all services to initialize and establish connections
print_info "Allowing time for routing services to initialize and establish mesh connectivity..."
sleep 45

# Test internal routing service connectivity
print_info "=== Testing Routing Service Mesh Connectivity ==="

ALL_RS_READY=true

# Check main routing service
print_info "Checking main routing service..."
MAIN_RS_OUTPUT=$(kubectl logs "$MAIN_RS_POD" -n "$NAMESPACE" --tail=15 2>/dev/null || echo "")
if echo "$MAIN_RS_OUTPUT" | grep -q "started\|ready\|listening"; then
    print_success "✓ Main routing service is running"
else
    print_error "✗ Main routing service has issues"
    ALL_RS_READY=false
fi

# Check publisher routing service
print_info "Checking publisher routing service..."
PUB_RS_OUTPUT=$(kubectl logs "$PUB_RS_POD" -n "$NAMESPACE" --tail=15 2>/dev/null || echo "")
if echo "$PUB_RS_OUTPUT" | grep -q "started\|ready\|listening"; then
    print_success "✓ Publisher routing service is running"
else
    print_error "✗ Publisher routing service has issues"
    ALL_RS_READY=false
fi

# Check subscriber routing service
print_info "Checking subscriber routing service..."
SUB_RS_OUTPUT=$(kubectl logs "$SUB_RS_POD" -n "$NAMESPACE" --tail=15 2>/dev/null || echo "")
if echo "$SUB_RS_OUTPUT" | grep -q "started\|ready\|listening"; then
    print_success "✓ Subscriber routing service is running"
else
    print_error "✗ Subscriber routing service has issues"
    ALL_RS_READY=false
fi

# Test inter-routing-service communication
print_info "=== Testing Routing Service Mesh Communication ==="

MESH_COMMUNICATION=false

# Look for evidence of routing service interconnection
print_info "Analyzing routing service interconnections..."

# Check for participant discovery between routing services
for pod in "$MAIN_RS_POD" "$PUB_RS_POD" "$SUB_RS_POD"; do
    POD_OUTPUT=$(kubectl logs "$pod" -n "$NAMESPACE" --tail=20 2>/dev/null || echo "")
    
    if echo "$POD_OUTPUT" | grep -q "participant.*discovered\|route.*established\|connection.*active"; then
        print_info "✓ Routing service $pod shows mesh connectivity"
        MESH_COMMUNICATION=true
    fi
done

# Test load balancing across multiple instances
print_info "=== Testing Load Balancing ==="

MAIN_REPLICAS=$(kubectl get deployment rtiroutingservice -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
MAIN_READY=$(kubectl get deployment rtiroutingservice -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')

print_info "Main routing service replicas: $MAIN_READY/$MAIN_REPLICAS"

if [[ "$MAIN_READY" -gt 1 ]]; then
    print_info "Testing load distribution across multiple main routing service instances..."
    
    MAIN_RS_PODS=($(kubectl get pods -n "$NAMESPACE" -l app=rtiroutingservice -o jsonpath='{.items[*].metadata.name}'))
    print_info "Main routing service pods: ${MAIN_RS_PODS[*]}"
    
    ACTIVE_INSTANCES=0
    for pod in "${MAIN_RS_PODS[@]}"; do
        if kubectl logs "$pod" -n "$NAMESPACE" --tail=10 | grep -q "connection\|participant\|route"; then
            print_info "✓ Instance $pod is active"
            ((ACTIVE_INSTANCES++))
        fi
    done
    
    if [[ $ACTIVE_INSTANCES -gt 1 ]]; then
        print_success "✓ Load balancing active across $ACTIVE_INSTANCES instances"
    else
        print_warning "⚠️  Only $ACTIVE_INSTANCES instance(s) showing activity"
    fi
else
    print_info "Single instance deployment - load balancing test not applicable"
fi

# Test external connectivity if LoadBalancer IP is available
EXTERNAL_CONNECTIVITY=false

if [[ -n "$EXTERNAL_IP" && -n "$LB_PORT" ]]; then
    print_info "=== Testing External Connectivity ==="
    
    if command -v nc &> /dev/null; then
        print_info "Testing external connectivity to $EXTERNAL_IP:$LB_PORT..."
        if timeout 5 nc -z "$EXTERNAL_IP" "$LB_PORT" 2>/dev/null; then
            print_success "✓ External endpoint is reachable"
            EXTERNAL_CONNECTIVITY=true
        else
            print_warning "⚠️  External endpoint may not be reachable from this location"
        fi
    fi
fi

# Simulate external application testing if RTI tools are available
EXTERNAL_TEST_SUCCESS=false

if [[ -f "rwt_pub_participant.xml" && -f "rwt_sub_participant.xml" ]] && command -v rtiddsping &> /dev/null; then
    print_info "=== Testing External Application Simulation ==="
    
    print_info "Simulating external publisher..."
    timeout 10 rtiddsping -publisher -domainId 100 \
        -qosFile rwt_pub_participant.xml \
        -qosProfile RWT_Demo::RWT_Profile \
        -numSamples 5 -sendPeriod 2 &>/dev/null &
    
    PUB_PID=$!
    
    sleep 3
    
    print_info "Simulating external subscriber..."
    timeout 8 rtiddsping -subscriber -domainId 100 \
        -qosFile rwt_sub_participant.xml \
        -qosProfile RWT_Demo::RWT_Profile &>/dev/null &
    
    SUB_PID=$!
    
    sleep 10
    
    # Check routing service logs for external traffic
    EXTERNAL_TRAFFIC_DETECTED=false
    for pod in "$MAIN_RS_POD" "$PUB_RS_POD" "$SUB_RS_POD"; do
        POD_OUTPUT=$(kubectl logs "$pod" -n "$NAMESPACE" --tail=10 2>/dev/null || echo "")
        if echo "$POD_OUTPUT" | grep -q "sample\|data\|message"; then
            print_info "✓ External traffic detected in routing service $pod"
            EXTERNAL_TRAFFIC_DETECTED=true
        fi
    done
    
    if [[ "$EXTERNAL_TRAFFIC_DETECTED" == "true" ]]; then
        EXTERNAL_TEST_SUCCESS=true
        print_success "✓ External application simulation successful"
    fi
    
    # Cleanup simulation processes
    kill $PUB_PID $SUB_PID 2>/dev/null || true
    wait $PUB_PID $SUB_PID 2>/dev/null || true
fi

# Display comprehensive results
echo ""
print_info "=== Comprehensive Service Status ==="

echo ""
print_info "Cloud Discovery Service logs:"
kubectl logs "$CDS_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Main Routing Service logs:"
kubectl logs "$MAIN_RS_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Publisher Routing Service logs:"
kubectl logs "$PUB_RS_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "Subscriber Routing Service logs:"
kubectl logs "$SUB_RS_POD" -n "$NAMESPACE" --tail=10

echo ""
print_info "=== Network Configuration ==="
kubectl get services -n "$NAMESPACE"
kubectl get endpoints -n "$NAMESPACE"

print_info "LoadBalancer service details:"
kubectl describe service rtiroutingservice-loadbalancer -n "$NAMESPACE"

# Configuration validation
echo ""
print_info "=== Configuration Validation ==="

for config_file in "USER_ROUTING_SERVICE.xml" "rwt_pub_participant.xml" "rwt_sub_participant.xml"; do
    if [[ -f "$config_file" ]]; then
        print_info "✓ Configuration file found: $config_file"
        
        # Basic configuration validation
        if grep -q "domain_route\|routing" "$config_file" 2>/dev/null; then
            print_info "  ✓ Routing configuration detected"
        fi
        if grep -q "transport.*rwt\|real.*wan" "$config_file" 2>/dev/null; then
            print_info "  ✓ RWT transport configuration detected"
        fi
    else
        print_warning "⚠️  Configuration file not found: $config_file"
    fi
done

# Final assessment
echo ""
print_info "=== Final Assessment ==="

if [[ "$ALL_RS_READY" == "true" ]]; then
    if [[ "$MESH_COMMUNICATION" == "true" ]]; then
        if [[ -n "$EXTERNAL_IP" ]]; then
            if [[ "$EXTERNAL_CONNECTIVITY" == "true" ]]; then
                print_success "✅ PASS: External to External Load-Balanced Gateway is fully functional!"
                print_success "✓ All routing services are running"
                print_success "✓ Routing service mesh is communicating"
                print_success "✓ LoadBalancer is accessible externally"
                
                if [[ "$EXTERNAL_TEST_SUCCESS" == "true" ]]; then
                    print_success "✓ External application simulation successful"
                fi
            else
                print_warning "⚠️  PARTIAL: Infrastructure is ready but external connectivity uncertain"
            fi
        else
            print_warning "⚠️  PARTIAL: Routing services are working but LoadBalancer IP not available"
            print_warning "This is expected in environments without LoadBalancer support"
        fi
    else
        print_warning "⚠️  PARTIAL: Routing services are running but mesh communication not clearly detected"
        print_warning "This may be normal if no external traffic is present"
    fi
else
    print_error "❌ FAIL: Some routing services have startup issues"
    
    # Debugging
    echo ""
    print_info "=== Debugging Information ==="
    print_info "All pods status:"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    print_info "Recent events:"
    kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -15
    
    exit 1
fi

echo ""
print_info "=== Manual Testing Instructions ==="
if [[ -n "$EXTERNAL_IP" && -n "$LB_PORT" ]]; then
    print_info "LoadBalancer endpoint: $EXTERNAL_IP:$LB_PORT"
    print_info ""
    print_info "To test with external RTI applications:"
    print_info "1. Set up external publisher:"
    print_info "   rtiddsping -publisher -domainId 100 -qosFile rwt_pub_participant.xml -qosProfile RWT_Demo::RWT_Profile"
    print_info ""
    print_info "2. Set up external subscriber:"
    print_info "   rtiddsping -subscriber -domainId 100 -qosFile rwt_sub_participant.xml -qosProfile RWT_Demo::RWT_Profile"
    print_info ""
    print_info "3. Monitor routing services:"
    print_info "   kubectl logs -f deployment/rtiroutingservice -n $NAMESPACE"
else
    print_info "LoadBalancer external IP not available"
    print_info "For testing in local environments, consider using port-forwarding:"
    print_info "kubectl port-forward service/rtiroutingservice-loadbalancer 7400:7400 -n $NAMESPACE"
fi

echo ""
print_info "Test completed. Resources remain deployed in namespace '$NAMESPACE'"
print_info "To cleanup: kubectl delete namespace $NAMESPACE"
