#!/bin/bash

# RTI Kubernetes Examples - Test Monitor
# Monitor running tests and provide status information

set -e

NAMESPACE="${NAMESPACE:-k8s-example-test}"

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

# Usage information
usage() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  status          Show overall status of test namespace"
    echo "  logs            Show recent logs from all pods"
    echo "  monitor         Continuous monitoring (press Ctrl+C to stop)"
    echo "  cleanup         Clean up test namespace"
    echo "  help            Show this help"
    echo ""
    echo "Options:"
    echo "  -n, --namespace NAME    Kubernetes namespace (default: k8s-example-test)"
    echo "  -f, --follow           Follow logs in real-time (for logs command)"
    echo "  -t, --tail LINES       Number of log lines to show (default: 20)"
}

# Check if namespace exists
check_namespace() {
    if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
        print_warning "Namespace '$NAMESPACE' does not exist"
        print_info "No active tests found"
        exit 0
    fi
}

# Show overall status
show_status() {
    check_namespace
    
    print_info "=== Test Namespace Status: $NAMESPACE ==="
    
    # Show pods
    echo ""
    print_info "Pods:"
    kubectl get pods -n "$NAMESPACE" -o wide 2>/dev/null || print_warning "No pods found"
    
    # Show services
    echo ""
    print_info "Services:"
    kubectl get services -n "$NAMESPACE" 2>/dev/null || print_warning "No services found"
    
    # Show deployments
    echo ""
    print_info "Deployments:"
    kubectl get deployments -n "$NAMESPACE" 2>/dev/null || print_warning "No deployments found"
    
    # Show statefulsets
    echo ""
    print_info "StatefulSets:"
    kubectl get statefulsets -n "$NAMESPACE" 2>/dev/null || print_warning "No statefulsets found"
    
    # Show recent events
    echo ""
    print_info "Recent Events:"
    kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -10 2>/dev/null || print_warning "No events found"
    
    # Resource usage if available
    echo ""
    print_info "Resource Usage:"
    kubectl top pods -n "$NAMESPACE" 2>/dev/null || print_info "Metrics not available"
}

# Show logs from all pods
show_logs() {
    local follow=${1:-false}
    local tail_lines=${2:-20}
    
    check_namespace
    
    local pods=($(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo ""))
    
    if [[ ${#pods[@]} -eq 0 ]]; then
        print_warning "No pods found in namespace '$NAMESPACE'"
        return
    fi
    
    if [[ "$follow" == "true" ]]; then
        print_info "Following logs from all pods in namespace '$NAMESPACE' (press Ctrl+C to stop)..."
        echo ""
        
        # Use kubectl logs with --follow for real-time monitoring
        # This will show logs from all pods, but we'll do it sequentially
        for pod in "${pods[@]}"; do
            print_info "=== Logs from $pod ==="
            kubectl logs "$pod" -n "$NAMESPACE" --tail="$tail_lines" --follow &
        done
        
        # Wait for all background processes
        wait
    else
        print_info "=== Recent Logs from All Pods ==="
        
        for pod in "${pods[@]}"; do
            echo ""
            print_info "=== Logs from $pod ==="
            
            # Check if pod has multiple containers
            local containers=($(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null || echo ""))
            
            if [[ ${#containers[@]} -gt 1 ]]; then
                # Multi-container pod
                for container in "${containers[@]}"; do
                    echo ""
                    print_info "--- Container: $container ---"
                    kubectl logs "$pod" -c "$container" -n "$NAMESPACE" --tail="$tail_lines" 2>/dev/null || print_warning "Could not get logs for container $container"
                done
            else
                # Single container pod
                kubectl logs "$pod" -n "$NAMESPACE" --tail="$tail_lines" 2>/dev/null || print_warning "Could not get logs for pod $pod"
            fi
        done
    fi
}

# Continuous monitoring
monitor() {
    print_info "Starting continuous monitoring of namespace '$NAMESPACE'"
    print_info "Press Ctrl+C to stop"
    echo ""
    
    while true; do
        clear
        echo "=== RTI Kubernetes Test Monitor ==="
        echo "Namespace: $NAMESPACE"
        echo "Time: $(date)"
        echo ""
        
        show_status
        
        echo ""
        print_info "Refreshing in 10 seconds... (Ctrl+C to stop)"
        sleep 10
    done
}

# Clean up test namespace
cleanup() {
    check_namespace
    
    print_warning "This will delete the entire namespace '$NAMESPACE' and all its resources"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cleaning up namespace '$NAMESPACE'..."
        kubectl delete namespace "$NAMESPACE"
        print_success "Cleanup completed"
    else
        print_info "Cleanup cancelled"
    fi
}

# Parse command line arguments
FOLLOW=false
TAIL_LINES=20
COMMAND=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -t|--tail)
            TAIL_LINES="$2"
            shift 2
            ;;
        status|logs|monitor|cleanup|help)
            COMMAND="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Set default command if not provided
COMMAND=${COMMAND:-status}

# Execute command
case "$COMMAND" in
    "status")
        show_status
        ;;
    "logs")
        show_logs "$FOLLOW" "$TAIL_LINES"
        ;;
    "monitor")
        monitor
        ;;
    "cleanup")
        cleanup
        ;;
    "help")
        usage
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac
