## Communications Between Pods Inside a Kubernetes Cluster via Multicast Discovery

This example uses DDS built-in multicast discovery between publisher and subscriber pods. It requires a Kubernetes CNI that supports multicast traffic.

## Deploy

Run these commands from the repository root. This example needs no ConfigMap:

```bash
kubectl create namespace rti-examples
kubectl apply -f pod_to_pod_multicast_disc/
```

All resources are deployed to the fixed `rti-examples` namespace.
