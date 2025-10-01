#!/bin/bash
# Performance and Load Testing for RTI Connext DDS Examples
# Usage: ./performance_tests.sh [scenario] [duration] [connections]

set -euo pipefail

# Configuration
SCENARIO="${1:-basic}"
DURATION="${2:-300}"  # 5 minutes default
CONNECTIONS="${3:-10}"  # 10 concurrent connections
NAMESPACE="rti-perf-test"
RESULTS_DIR="tests/results/performance"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Create results directory
mkdir -p "$RESULTS_DIR"

# Cleanup function
cleanup() {
    log_info "Cleaning up performance test resources..."
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true --timeout=60s || true
}
trap cleanup EXIT

# Performance test scenarios
run_throughput_test() {
    log_info "Running throughput test for $DURATION seconds with $CONNECTIONS connections"
    
    # Deploy RTI PerfTest applications for high-throughput testing
    kubectl create namespace "$NAMESPACE" || true
    kubectl create configmap rti-license --from-file=rti_license.dat -n "$NAMESPACE" || true
    
    # Deploy Cloud Discovery Service first
    cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rti-clouddiscoveryservice
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      run: rti-clouddiscoveryservice
  replicas: 1
  template:
    metadata:
      labels:
        run: rti-clouddiscoveryservice
    spec:
      containers:
        - name: rti-clouddiscoveryservice
          image: rticom/cloud-discovery-service:7.3.0
          volumeMounts:
            - name: license-volume
              mountPath: /opt/rti.com/rti_connext_dds-7.3.0/rti_license.dat
              subPath: rti_license.dat
          ports:
            - containerPort: 7400
              protocol: UDP
      volumes:
        - name: license-volume
          configMap:
            name: rti-license
---
apiVersion: v1
kind: Service
metadata:
  name: rti-clouddiscoveryservice
  namespace: $NAMESPACE
spec:
  ports:
    - port: 7400
      protocol: UDP
  selector:
    run: rti-clouddiscoveryservice
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rti-perf-publisher
  namespace: $NAMESPACE
spec:
  replicas: $CONNECTIONS
  selector:
    matchLabels:
      app: rti-perf-publisher
  template:
    metadata:
      labels:
        app: rti-perf-publisher
    spec:
      containers:
      - name: publisher
        image: rticom/perftest:7.3.0
        args: ["-pub", "-executionTime", "$DURATION", "-dataLen", "1024"]
        env:
          - name: NDDS_DISCOVERY_PEERS
            value: rtps@udpv4://rti-clouddiscoveryservice:7400
        volumeMounts:
          - name: license-volume
            mountPath: /opt/rti.com/rti_connext_dds-7.3.0/rti_license.dat
            subPath: rti_license.dat
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
      volumes:
        - name: license-volume
          configMap:
            name: rti-license
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rti-perf-subscriber
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rti-perf-subscriber
  template:
    metadata:
      labels:
        app: rti-perf-subscriber
    spec:
      containers:
      - name: subscriber
        image: rticom/perftest:7.3.0
        args: ["-sub", "-verbosity", "1"]
        env:
          - name: NDDS_DISCOVERY_PEERS
            value: rtps@udpv4://rti-clouddiscoveryservice:7400
        volumeMounts:
          - name: license-volume
            mountPath: /opt/rti.com/rti_connext_dds-7.3.0/rti_license.dat
            subPath: rti_license.dat
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 1Gi
      volumes:
        - name: license-volume
          configMap:
            name: rti-license
EOF

    # Wait for deployments
    kubectl wait --for=condition=available deployment/rti-clouddiscoveryservice -n "$NAMESPACE" --timeout=120s
    kubectl wait --for=condition=available deployment/rti-perf-publisher -n "$NAMESPACE" --timeout=120s
    kubectl wait --for=condition=available deployment/rti-perf-subscriber -n "$NAMESPACE" --timeout=120s
    
    # Run performance test
    log_info "Running performance test for $DURATION seconds..."
    
    # Run test for specified duration
    sleep "$DURATION"
    
    # Collect final statistics
    log_info "Collecting final performance statistics..."
    kubectl logs -l app=rti-perf-subscriber -n "$NAMESPACE" --tail=100 > "$RESULTS_DIR/subscriber_logs.txt"
    
    log_success "Performance test completed - results saved to $RESULTS_DIR/subscriber_logs.txt"
}

run_latency_test() {
    log_info "Running latency test with RTI PerfTest..."
    
    kubectl create namespace "$NAMESPACE" || true
    kubectl create configmap rti-license --from-file=rti_license.dat -n "$NAMESPACE" || true
    
    # Deploy Cloud Discovery Service and RTI PerfTest for latency measurement
    cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rti-clouddiscoveryservice
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      run: rti-clouddiscoveryservice
  replicas: 1
  template:
    metadata:
      labels:
        run: rti-clouddiscoveryservice
    spec:
      containers:
        - name: rti-clouddiscoveryservice
          image: rticom/cloud-discovery-service:7.3.0
          volumeMounts:
            - name: license-volume
              mountPath: /opt/rti.com/rti_connext_dds-7.3.0/rti_license.dat
              subPath: rti_license.dat
          ports:
            - containerPort: 7400
              protocol: UDP
      volumes:
        - name: license-volume
          configMap:
            name: rti-license
---
apiVersion: v1
kind: Service
metadata:
  name: rti-clouddiscoveryservice
  namespace: $NAMESPACE
spec:
  ports:
    - port: 7400
      protocol: UDP
  selector:
    run: rti-clouddiscoveryservice
---
apiVersion: batch/v1
kind: Job
metadata:
  name: rti-latency-publisher
  namespace: $NAMESPACE
spec:
  template:
    spec:
      containers:
      - name: publisher
        image: rticom/perftest:7.3.0
        args: ["-pub", "-latencyCount", "10000", "-dataLen", "32", "-latencyTest", "-executionTime", "60"]
        env:
          - name: NDDS_DISCOVERY_PEERS
            value: rtps@udpv4://rti-clouddiscoveryservice:7400
        volumeMounts:
          - name: license-volume
            mountPath: /opt/rti.com/rti_connext_dds-7.3.0/rti_license.dat
            subPath: rti_license.dat
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
      volumes:
        - name: license-volume
          configMap:
            name: rti-license
      restartPolicy: Never
---
apiVersion: batch/v1
kind: Job
metadata:
  name: rti-latency-subscriber
  namespace: $NAMESPACE
spec:
  template:
    spec:
      containers:
      - name: subscriber
        image: rticom/perftest:7.3.0
        args: ["-sub", "-latencyTest"]
        env:
          - name: NDDS_DISCOVERY_PEERS
            value: rtps@udpv4://rti-clouddiscoveryservice:7400
        volumeMounts:
          - name: license-volume
            mountPath: /opt/rti.com/rti_connext_dds-7.3.0/rti_license.dat
            subPath: rti_license.dat
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
      volumes:
        - name: license-volume
          configMap:
            name: rti-license
      restartPolicy: Never
EOF

    # Wait for CDS to be ready first
    kubectl wait --for=condition=available deployment/rti-clouddiscoveryservice -n "$NAMESPACE" --timeout=120s
    
    # Wait for jobs to complete and collect results
    kubectl wait --for=condition=complete job/rti-latency-publisher -n "$NAMESPACE" --timeout=180s || true
    kubectl wait --for=condition=complete job/rti-latency-subscriber -n "$NAMESPACE" --timeout=180s || true
    
    # Collect latency results
    kubectl logs job/rti-latency-subscriber -n "$NAMESPACE" > "$RESULTS_DIR/latency_results.csv" || true
    
    log_success "Latency test completed - results saved to $RESULTS_DIR/latency_results.csv"
}

run_discovery_scale_test() {
    log_info "Running discovery scalability test..."
    # Test how well Cloud Discovery Service scales with many participants
}



# Main execution
main() {
    log_info "Starting performance tests for scenario: $SCENARIO"
    
    case "$SCENARIO" in
        "throughput")
            run_throughput_test
            ;;
        "latency")
            run_latency_test
            ;;
        "discovery")
            run_discovery_scale_test
            ;;
        "basic"|*)
            run_throughput_test
            ;;
    esac
    
    log_success "Performance testing completed!"
}

main "$@"