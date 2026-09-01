## Communications over Shared Memory

This example runs DDS Ping containers in one pod so they communicate over shared memory, while a separate subscriber uses UDP through Cloud Discovery Service.

## Deploy

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl apply -k intra_pod_shmem/overlays/rti-examples
```

The overlay puts all resources in `rti-examples`. To deploy to another namespace, copy `overlays/rti-examples`, update `namespace: rti-examples` in the copied `kustomization.yaml`, create the license ConfigMap in that namespace, and apply the copy.

For direct raw-manifest deployment without Kustomize:

```bash
find intra_pod_shmem/base -maxdepth 1 -name '*.yaml' ! -name kustomization.yaml -exec kubectl apply -n rti-examples -f {} \;
```
