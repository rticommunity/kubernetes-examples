## Communicaitons Between External Applications and Pods Within a Kubernetes Cluster Using a Gateway


### Problem

You want to expose DDS applications outside a k8s cluster.

k8s creates a virtual network and each pod is given a virtual IP address. Because of that, applications in a k8s cluster cannot be directly communicated from applications outside of the cluster. This can be a matter if there are applications outside of a k8s cluster that need to exchange messages with applications running in the cluster. 


### Solution

To resolve this, **RTI Routing Service** is used to bridge internal and external DDS applications along with **Real-time WAN Transport**. A **NodePort Service** exposes a service on a static port on the node IP address. We used a NodePort Service to expose the internal RTI Routing Service (in the cluster) on each Node’s IP that can be reached by external participants. 


#### Required Components:

* **DDS Publisher** and **DDS Subscriber** are example applications that need to exchange data. 
* **Routing Service**: A bridge service residing in the k8s cluster that forwards data from the **external DDS Publisher** to the **internal DDS Subscriber**. 
* **NodePort Service**: We create a **NodePort Service** that exposes the **Routing Service** on each Node’s IP at a static port (e.g. Port 30007 in the figure). Then, the **external participant (DDS Publisher)** can contact the **Routing Service** by requesting NodeIP:NodePort (e.g. NODE2_IP:30007 in the figure). 

![Exposing DDS Applications with Real-time WAN Transport](routingservice_rwt.png)
(ADD CDS TO THE DIAGRAM)

### Required Docker Images
- [RTI Routing Service](../dockerfiles/rti_routingservice)
- [RTI Cloud Discovery Service](../dockerfiles/rti_clouddiscoveryservice)
- [RTI DDS Ping Subscriber](../dockerfiles/rti_ddsping_sub)

### Steps

#### 1. Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### 2. Create a Deployment and a Service for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

#### 3. Create a ConfigMap for the Routing Service XML configuration file
`$ kubectl create configmap routingservice-rwt --from-file=config.xml`

#### 4. Create a Deployment for the Routing Service. You should update the public IP address and ports in this file.
`$ kubectl create -f rs-statefulset.yaml`

#### 5. Create a NodePort Service for the Routing Service
`$ kubectl create -f rs-nodeport.yaml`

#### 6. Create a Deployment for a RTI DDS Ping subscriber
`$ kubectl create -f rtiddsping-sub.yaml`

#### 7. Run the external publisher (outside the cluster). You should update the public IP address and ports in this file.
`$ rtiddsping -qosFile rwt_participant.xml -qosProfile RWT_Demo::RWT_Profile -publisher -domainId 100`
