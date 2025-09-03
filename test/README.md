# RTI Connext Kubernetes Examples - Test Scripts

This directory contains comprehensive test scripts for validating the RTI Connext Kubernetes example configurations. The scripts provide automated testing, monitoring, and validation capabilities for all example use cases.

## Overview

The test suite includes:
- **Main test runner** (`test_runner.sh`) - Comprehensive automated testing for all examples
- **Individual test scripts** - Focused testing for each specific example
- **Monitoring tools** (`monitor.sh`) - Real-time monitoring and status checking
- **Validation utilities** - Network connectivity and DDS communication verification

## Quick Start

### Run All Tests
```bash
cd test
./test_runner.sh all --cleanup
```

### Run Specific Test
```bash
./test_runner.sh pod-to-pod-multicast
```

### Monitor Running Tests
```bash
./monitor.sh monitor
```

## Test Scripts

### Main Test Runner (`test_runner.sh`)

The comprehensive test runner that can execute all or specific test cases.

#### Usage
```bash
./test_runner.sh [OPTIONS] [TEST_CASE]
```

#### Options
- `-h, --help` - Show help message
- `-n, --namespace NAME` - Kubernetes namespace (default: k8s-example-test)
- `-t, --timeout SECONDS` - Timeout for operations (default: 300)
- `--cleanup` - Cleanup resources after tests
- `--dry-run` - Show what would be executed without running

#### Test Cases
- `all` - Run all test cases
- `pod-to-pod-multicast` - Test pod-to-pod multicast discovery
- `pod-to-pod-unicast` - Test pod-to-pod unicast discovery
- `intra-pod-shmem` - Test intra-pod shared memory communication
- `external-to-pod-gw` - Test external to pod gateway
- `external-to-pod-lb-gw` - Test external to pod load-balanced gateway
- `external-to-external-lb-gw` - Test external to external load-balanced gateway

#### Examples
```bash
# Run all tests with cleanup
./test_runner.sh all --cleanup

# Test specific configuration with custom namespace
./test_runner.sh pod-to-pod-unicast -n my-test-namespace

# Dry run to see what would be executed
./test_runner.sh external-to-pod-gw --dry-run
```

### Individual Test Scripts

Each example directory contains a specific test script focused on that configuration:

#### Pod-to-Pod Multicast Discovery
```bash
cd ../pod_to_pod_multicast_disc
./test_multicast_discovery.sh
```

#### Pod-to-Pod Unicast Discovery
```bash
cd ../pod_to_pod_unicast_disc
./test_unicast_discovery.sh
```

#### Intra-Pod Shared Memory
```bash
cd ../intra_pod_shmem
./test_shmem_communication.sh
```

#### External to Pod Gateway
```bash
cd ../external_to_pod_gw
./test_gateway.sh
```

#### External to Pod Load-Balanced Gateway
```bash
cd ../external_to_pod_lb_gw
./test_loadbalanced_gateway.sh
```

#### External to External Load-Balanced Gateway
```bash
cd ../external_to_external_lb_gw
./test_external_gateway.sh
```

### Monitoring Script (`monitor.sh`)

Real-time monitoring and status checking for running tests.

#### Usage
```bash
./monitor.sh [OPTIONS] [COMMAND]
```

#### Commands
- `status` - Show overall status of test namespace (default)
- `logs` - Show recent logs from all pods
- `monitor` - Continuous monitoring (press Ctrl+C to stop)
- `cleanup` - Clean up test namespace
- `help` - Show help

#### Options
- `-n, --namespace NAME` - Kubernetes namespace (default: k8s-example-test)
- `-f, --follow` - Follow logs in real-time (for logs command)
- `-t, --tail LINES` - Number of log lines to show (default: 20)

#### Examples
```bash
# Show current status
./monitor.sh status

# Follow logs in real-time
./monitor.sh logs --follow

# Continuous monitoring
./monitor.sh monitor

# Cleanup test resources
./monitor.sh cleanup
```

## Prerequisites

### Required Tools
- `kubectl` - Kubernetes command-line tool
- `bash` - Bash shell (version 4.0+)
- `nc` (netcat) - Network connectivity testing (optional)

### Kubernetes Cluster
- Running Kubernetes cluster with `kubectl` configured
- Sufficient resources for RTI Connext containers
- Network policies allowing pod-to-pod communication
- LoadBalancer support for load-balanced gateway tests (cloud environments)

### Important: Multicast Support
⚠️ **Many Kubernetes clusters do NOT support multicast networking:**
- **Amazon EKS**: No multicast support
- **Google GKE**: No multicast support  
- **Azure AKS**: No multicast support
- **Minikube/Kind**: Limited multicast support
- **On-premises**: Depends on CNI plugin configuration

The `pod-to-pod-multicast` test will validate deployment but may show limited connectivity in multicast-unsupported environments. This is expected behavior. For reliable communication in cloud environments, use the `pod-to-pod-unicast` example instead.

### RTI Connext (for external connectivity tests)
- RTI Connext DDS installation for external application testing
- Valid RTI license file (`rti_license.dat`)
- RTI DDS Ping utility (`rtiddsping`)

## Environment Variables

The test scripts support the following environment variables:

- `NAMESPACE` - Kubernetes namespace for tests (default: k8s-example-test)
- `TIMEOUT` - Timeout in seconds for operations (default: 300)
- `RTI_LICENSE_FILE` - Path to RTI license file (default: ../rti_license.dat)

## Test Validation

### What the Tests Check

1. **Deployment Status**
   - Pod readiness and health
   - Service availability
   - StatefulSet/Deployment status

2. **Network Connectivity**
   - Service endpoint accessibility
   - Port connectivity (NodePort/LoadBalancer)
   - Inter-pod communication

3. **RTI DDS Communication**
   - Publisher/Subscriber discovery
   - Sample transmission and reception
   - Routing Service functionality
   - Cloud Discovery Service operation

4. **Configuration Validation**
   - XML configuration file presence
   - Transport configuration
   - Domain routing setup

### Test Results

Tests provide clear pass/fail results with detailed information:

- ✅ **PASS** - All functionality working correctly
- ⚠️ **PARTIAL** - Basic functionality working, some features may need manual verification
- ❌ **FAIL** - Configuration or communication issues detected

### Special Considerations

#### Multicast Discovery Tests
The `pod-to-pod-multicast` test has special handling for environments without multicast support:
- **Deployment validation**: Always tested (pod startup, resource allocation)
- **Communication testing**: May be limited in cloud environments
- **Expected behavior**: PARTIAL results in EKS/GKE/AKS are normal

#### External Connectivity Tests
Tests involving external applications (`external-to-*` examples):
- May require manual verification with actual RTI applications
- Provide network endpoint information for manual testing
- Include configuration examples for external setup

## Troubleshooting

### Common Issues

1. **Namespace Already Exists**
   ```bash
   ./monitor.sh cleanup
   ```

2. **Pods Not Starting**
   ```bash
   kubectl describe pods -n k8s-example-test
   kubectl get events -n k8s-example-test
   ```

3. **LoadBalancer IP Not Assigned**
   - This is expected in local environments (minikube, kind)
   - Tests will fall back to NodePort-style testing

4. **RTI License Issues**
   - Ensure `rti_license.dat` is present and valid
   - Some tests may work without license but with warnings

5. **External Connectivity Tests**
   - Require RTI Connext DDS installation
   - Need network access to Kubernetes nodes
   - May require firewall configuration

### Debug Information

When tests fail, they provide debugging information including:
- Pod logs and status
- Network configuration details
- Recent events in the namespace
- Resource usage information

### Manual Verification

For external connectivity tests, manual verification instructions are provided:
- External application commands
- Network endpoint information
- Configuration file requirements

## CI/CD Integration

The test scripts are designed for CI/CD integration:

```bash
# Example CI/CD pipeline step
./test_runner.sh all --timeout 600 --cleanup
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "All tests passed"
else
    echo "Tests failed with exit code $exit_code"
    exit $exit_code
fi
```

## Contributing

When adding new examples or modifying existing ones:

1. Create corresponding test scripts following the existing patterns
2. Update the main test runner to include new test cases
3. Ensure proper cleanup and error handling
4. Add documentation for any new test parameters or requirements

## Support

For issues with the test scripts or RTI Connext Kubernetes examples:

1. Check the troubleshooting section above
2. Review Kubernetes cluster requirements
3. Verify RTI Connext DDS installation and licensing
4. Consult RTI Connext DDS documentation for configuration details
