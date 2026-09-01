# Kubernetes Example Configurations for RTI Connext DDS

[![CI/CD Pipeline](https://github.com/rticommunity/kubernetes-examples/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/rticommunity/kubernetes-examples/actions)
[![RTI Connext](https://img.shields.io/badge/RTI%20Connext-7.5.0-green.svg)](https://community.rti.com/documentation/rti-connext-750)

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

Each example has a standard Kustomize base containing its deployable resource YAML and an `overlays/rti-examples` overlay that selects the `rti-examples` namespace. From the repository root, create that namespace and the ConfigMaps required by the selected example:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
# Gateway examples also need their Routing Service configuration:
kubectl create configmap routingservice-rwt \
  --from-file=external_to_pod_gw/USER_ROUTING_SERVICE.xml -n rti-examples
```

The multicast example needs no ConfigMap. Use the corresponding `USER_ROUTING_SERVICE.xml` path for the load-balanced gateway. Then apply an overlay, for example:

```bash
kubectl apply -k pod_to_pod_unicast_disc/overlays/rti-examples
# Redundant Cloud Discovery Service (HA):
kubectl apply -k pod_to_pod_unicast_disc/overlays/rti-examples/ha
```

To deploy to a different namespace, copy the selected `overlays/rti-examples` directory, change `namespace: rti-examples` in its `kustomization.yaml`, create the same ConfigMaps in the new namespace, and apply the copied overlay.

Kustomize is optional. Raw manifests remain directly deployable from their bases, for example `kubectl apply -f pod_to_pod_unicast_disc/base/*.yaml -n rti-examples` (or `pod_to_pod_unicast_disc/base/ha/*.yaml` for HA).

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
