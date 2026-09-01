## Communications Between Pods Inside a Kubernetes Cluster via Multicast Discovery

This example uses DDS built-in multicast discovery between publisher and subscriber pods. It requires a Kubernetes CNI that supports multicast traffic.

## Deploy

Run these commands from the repository root. This example needs no ConfigMap:

```bash
kubectl create namespace rti-examples
kubectl apply -k pod_to_pod_multicast_disc/overlays/rti-examples
```

The overlay places every resource in `rti-examples`. To deploy elsewhere, copy `overlays/rti-examples`, change `namespace: rti-examples` in the copied `kustomization.yaml`, create that namespace, and apply the copied overlay.

For a non-Kustomize workflow, apply the raw resources directly:

```bash
kubectl apply -f pod_to_pod_multicast_disc/base/ -n rti-examples
```
