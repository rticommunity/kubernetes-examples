# Kubernetes Example Configurations for RTI Connext DDS

[![CI/CD Pipeline](https://github.com/rticommunity/kubernetes-examples/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/rticommunity/kubernetes-examples/actions)
[![RTI Connext](https://img.shields.io/badge/RTI%20Connext-7.5.0-green.svg)](https://community.rti.com/documentation/rti-connext-750)

This repository provides example configurations for deploying RTI Connext DDS applications and services on Kubernetes clusters. Each example demonstrates specific networking patterns and deployment strategies for real-time distributed systems.

## 🚀 Quick Start

1. **Prerequisites**: Kubernetes cluster, RTI Connext DDS license
2. **Clone repository**: `git clone https://github.com/rticommunity/kubernetes-examples.git`
3. **Run tests**: `./tests/run_integration_tests.sh basic`
4. **Deploy example**: `cd pod_to_pod_unicast_disc && kubectl apply -f .`

### Use Cases

|Name | Description | Kubernetes Features Used | RTI Components Used|
------------- | ------------- | ------------  | ------------  |
|[1. Communications Between Pods Inside a Kubernetes Cluster via Multicast Discovery](pod_to_pod_multicast_disc/) | Enable communications inside a Kubernetes cluster using RTI DDS Ping. | Deployment  | RTI DDS Ping |
|[2. Communications Between Pods Inside a Kubernetes Cluster via Unicast Discovery](pod_to_pod_unicast_disc/) | Enable discovery with RTI Cloud Discovery Service (CDS). | Deployment, ClusterIP Service, ConfigMap (for a single CDS); StatefulSet, Headless Service, ConfigMap (for redundant CDSes) | RTI DDS Ping, RTI CDS |
|[3. Intra Pod Communications Using Shared Memory](intra_pod_shmem/) | Establish communications using RTI DDS Ping over shared memory between containers in a pod. | Deployment, ClusterIP Service, ConfigMap | RTI DDS Ping, RTI CDS|
|[4. Communications Between External Applications and Pods Within a Kubernetes Cluster Using a Gateway](external_to_pod_gw/) | Expose DDS applications using RTI Routing Service (RS) over Real-time WAN (RWT) transport outside the Kubernetes cluster. | NodePort Service, StatefulSet, Deployment, ConfigMap | RTI DDS Ping, RTI CDS, RTI RS, RTI RWT Transport|
|[5. Communications Between External Applications And Pods Within a Kubernetes Cluster Using a Network Load-Balanced Gateway](external_to_pod_lb_gw/) | Load balance RTI Routing Service traffic over Real-time WAN transport. | LoadBalancer Service, Deployment, ConfigMap | RTI DDS Ping, RTI CDS, RTI RS, RTI RWT Transport |

## 📋 Prerequisites

- **Kubernetes Cluster**: Version 1.27+ (tested with EKS)
- **RTI Connext DDS License**: Required for evaluation/production use
- **kubectl**: Latest version configured for your cluster
- **Docker Images**: Access to RTI Docker Hub repositories

## 🔧 Installation & Setup

### 1. Clone Repository
```bash
git clone https://github.com/rticommunity/kubernetes-examples.git
cd kubernetes-examples
```

### 2. Set Up RTI License
```bash
# Place your RTI license file in the repository root
cp /path/to/your/rti_license.dat .

# Create license ConfigMap (required for most examples)
kubectl create configmap rti-license --from-file=rti_license.dat
```

### 3. Run Integration Tests
```bash
# Test basic scenarios (unicast discovery - works on most CNIs)
./tests/run_integration_tests.sh basic

./tests/run_integration_tests.sh multicast

# Test advanced scenarios (complex networking and specialized transports)
./tests/run_integration_tests.sh advanced

# Test LoadBalancer scenarios (requires cloud provider LoadBalancer support)
./tests/run_integration_tests.sh loadbalancer

# Test all scenarios (comprehensive test suite)
./tests/run_integration_tests.sh all
```

#### Test Category Details:
- **`basic`**: Pod-to-pod unicast discovery with Cloud Discovery Service - reliable across all CNIs
- **`multicast`**: Pod-to-pod multicast discovery - only works if CNI supports multicast traffic
- **`advanced`**: 
  - Intra-pod shared memory communication between containers
  - External-to-pod gateway using RTI Routing Service with NodePort
- **`loadbalancer`**: External-to-pod gateway using RTI Routing Service with LoadBalancer service
- **`all`**: Runs all test categories (may fail on CNIs without multicast/LoadBalancer support)


## 🛠️ Troubleshooting

### Common Issues

#### 1. Multicast Not Supported
**Problem**: CNI doesn't support multicast (common in cloud providers)
**Solution**: Use unicast discovery examples with Cloud Discovery Service

#### 2. LoadBalancer Pending
**Problem**: LoadBalancer service stuck in pending state
**Solution**: 
- Verify cloud provider LoadBalancer controller
- Check service annotations for cloud-specific requirements
- Review cluster permissions

#### 3. License Issues
**Problem**: RTI services fail with license errors
**Solution**:
- Ensure `rti_license.dat` is valid and not expired
- Verify ConfigMap creation: `kubectl get configmap rti-license -o yaml`
- Check volume mounts in pod specifications

#### 4. Pod Communication Failures
**Problem**: DDS applications cannot discover each other
**Solution**:
- Verify Cloud Discovery Service is running: `kubectl logs deployment/rti-clouddiscoveryservice`
- Check network policies aren't blocking traffic
- Validate initial peer configurations

## 📄 License

This project is licensed under RTI License - see the [LICENSE](LICENSE) file for details.
