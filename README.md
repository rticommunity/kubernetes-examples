# Kubernetes Example Configurations for RTI Connext DDS

[![CI/CD Pipeline](https://github.com/rticommunity/kubernetes-examples/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/rticommunity/kubernetes-examples/actions)
[![RTI Connext](https://img.shields.io/badge/RTI%20Connext-7.7.0-green.svg)](https://community.rti.com/documentation/rti-connext-770)

This repository provides Kubernetes configurations for RTI Connext DDS networking patterns and deployment strategies.

## Examples

| Example | Description |
| --- | --- |
| [pod_to_pod_multicast_disc](pod_to_pod_multicast_disc/) | Pod-to-pod communication using multicast discovery. |
| [pod_to_pod_unicast_disc](pod_to_pod_unicast_disc/) | Pod-to-pod communication using single or redundant Cloud Discovery Services. |
| [intra_pod_shmem](intra_pod_shmem/) | Shared-memory communication between containers in one pod. |
| [external_to_pod_gw](external_to_pod_gw/) | External-to-pod connectivity through a NodePort Routing Service gateway. |
| [external_to_pod_lb_gw](external_to_pod_lb_gw/) | External-to-pod connectivity through a load-balanced Routing Service gateway. |

## Deploying an example

All example manifests use the fixed `rti-examples` namespace. From the repository root, create that namespace and the ConfigMaps required by the selected example:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
# Gateway examples also need their Routing Service configuration:
kubectl create configmap routingservice-rwt \
  --from-file=external_to_pod_gw/USER_ROUTING_SERVICE.xml -n rti-examples
```

The multicast example needs no ConfigMap. Use the corresponding `USER_ROUTING_SERVICE.xml` path for the load-balanced gateway. Apply an example directly, for example:

```bash
kubectl apply -f pod_to_pod_multicast_disc/
# Redundant Cloud Discovery Service (HA):
kubectl apply -f pod_to_pod_unicast_disc/rticlouddiscoveryservice_ha.yaml
kubectl apply -f pod_to_pod_unicast_disc/rtiddsping_cds_pub_ha.yaml
kubectl apply -f pod_to_pod_unicast_disc/rtiddsping_cds_sub_ha.yaml
```

The single-CDS unicast and HA resources share publisher and subscriber names, so deploy only one of those scenarios in `rti-examples` at a time.

## Running integration tests

```bash
./tests/run_integration_tests.sh basic
./tests/run_integration_tests.sh multicast
./tests/run_integration_tests.sh advanced
./tests/run_integration_tests.sh loadbalancer
./tests/run_integration_tests.sh all
```

The integration test script creates and removes its own dynamic test namespace.

## License

This project is licensed under RTI License. See [LICENSE](LICENSE).
