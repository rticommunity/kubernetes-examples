## Communications over Shared Memory

This example runs DDS Ping containers in one pod so they communicate over shared memory, while a separate subscriber uses UDP through Cloud Discovery Service.

## Deploy

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl apply -f intra_pod_shmem/
```

All resources are deployed to the fixed `rti-examples` namespace.
