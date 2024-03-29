## Replicated Cloud Discovery Service (CDS)

### Problem

You want to make Cloud Discovery Service (CDS) replicated to avoid service unavailability of CDS. 

### Solution

To make CDS highly available, a **StatefulSet** with **Headless Service** can be used. **StatefulSet** manages and scales a set of stateful pods by providing guarantees about the ordering and uniqueness of these pods. To access the StatefulSet CDS pods from other Connext application pods, **Headless Service** is used. The **Headless Service** creates a domain for all of the Pods, rti-cds-hs.default.svc.cluster.local. Connext application pods need to add DNS names of CDS services (e.g., rti-cds-0.rti-cds-hs.default.svc.cluster.local:7400) to their initial discovery peer list, so they can still use an available CDS instance even when one of the CDS instances in the list fails. 

![Discovery without Multicast](cds_replicated.png)

### Required Docker Images
- [RTI Cloud Discovery Service](../dockerfiles/rti_clouddiscoveryservice)
- [RTI DDS Ping Publisher](../dockerfiles/rti_ddsping_pub)
- [RTI DDS Ping Subscriber](../dockerfiles/rti_ddsping_sub)

### Steps

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### Create a StatefulSet and Headless Services for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

#### Create a Deployment for DDS ping publisher.
`$ kubectl create -f rtiddsping-cds-pub.yaml`

#### Create a Deployment for DDS ping subscriber.
`$ kubectl create -f rtiddsping-cds-sub.yaml`
