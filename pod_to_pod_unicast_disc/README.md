## Communications Between Pods with Unicast Discovery

These examples use RTI Cloud Discovery Service (CDS) for DDS discovery when the Kubernetes CNI does not support multicast. The single-CDS and redundant CDS scenarios are separate because they reuse deployment names.

## Deploy the single-CDS scenario

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl apply -f pod_to_pod_unicast_disc/rticlouddiscoveryservice.yaml
kubectl apply -f pod_to_pod_unicast_disc/rtiddsping_cds_pub.yaml
kubectl apply -f pod_to_pod_unicast_disc/rtiddsping_cds_sub.yaml
```

## Deploy the redundant CDS (HA) scenario

Use a separate namespace or remove the single-CDS scenario first because both scenarios use the same publisher and subscriber deployment names:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl apply -f pod_to_pod_unicast_disc/rticlouddiscoveryservice_ha.yaml
kubectl apply -f pod_to_pod_unicast_disc/rtiddsping_cds_pub_ha.yaml
kubectl apply -f pod_to_pod_unicast_disc/rtiddsping_cds_sub_ha.yaml
```

The HA scenario creates a StatefulSet and headless service. Participants discover its CDS instances through their stable DNS names.

All resources are deployed to the fixed `rti-examples` namespace.
