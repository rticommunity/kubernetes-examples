## Communications Between Pods with Unicast Discovery

These examples use RTI Cloud Discovery Service (CDS) for DDS discovery when the Kubernetes CNI does not support multicast. The single-CDS and redundant CDS scenarios are separate because they reuse deployment names.

## Deploy the single-CDS scenario

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl apply -k pod_to_pod_unicast_disc/overlays/rti-examples
```

## Deploy the redundant CDS (HA) scenario

Use a separate namespace or remove the single-CDS scenario first because both scenarios use the same publisher and subscriber deployment names:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl apply -k pod_to_pod_unicast_disc/overlays/rti-examples/ha
```

The HA scenario creates a StatefulSet and headless service. Participants discover its CDS instances through their stable DNS names.

To deploy either scenario to a different namespace, copy `overlays/rti-examples` (including `ha/` when needed), change `namespace: rti-examples` in the applicable copied `kustomization.yaml`, create the license ConfigMap in the target namespace, and apply that overlay.

For direct deployment without Kustomize, use raw base resources:

```bash
kubectl apply -f pod_to_pod_unicast_disc/base/*.yaml -n rti-examples
# HA:
kubectl apply -f pod_to_pod_unicast_disc/base/ha/*.yaml -n rti-examples
```
