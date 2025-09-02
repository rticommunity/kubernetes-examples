# Kubernetes Example Configurations for RTI Connext Applications
This directory provides example configurations for various use cases involving RTI Connext applications and services running on Kubernetes.

### Use Cases

|Name | Description | Kubernetes Features Used | RTI Components Used|
------------- | ------------- | ------------  | ------------  |
|[1. Communications Between Pods Inside a Kubernetes Cluster via Multicast Discovery](pod_to_pod_multicast_disc/) | Enable communications inside a Kubernetes cluster using RTI DDS Ping. | Deployment  | RTI DDS Ping |
|[2. Communications Between Pods Inside a Kubernetes Cluster via Unicast Discovery](pod_to_pod_unicast_disc/) | Enable discovery with RTI Cloud Discovery Service (CDS). | Deployment, ClusterIP Service, ConfigMap (for a single CDS); StatefulSet, Headless Service, ConfigMap (for redundant CDSes) | RTI DDS Ping, RTI CDS |
|[3. Intra Pod Communications Using Shared Memory](intra_pod_shmem/) | Establish communications using RTI DDS Ping over shared memory between containers in a pod. | Deployment, ClusterIP Service, ConfigMap | RTI DDS Ping, RTI CDS|
|[4. Communications Between External Applications and Pods Within a Kubernetes Cluster Using a Gateway](external_to_pod_gw/) | Expose DDS applications using RTI Routing Service (RS) over Real-time WAN (RWT) transport outside the Kubernetes cluster. | NodePort Service, StatefulSet, Deployment, ConfigMap | RTI DDS Ping, RTI CDS, RTI RS, RTI RWT Transport|
|[5. Communications Between External Applications And Pods Within a Kubernetes Cluster Using a Network Load-Balanced Gateway](external_to_pod_lb_gw/) | Load balance RTI Routing Service traffic over Real-time WAN transport. | LoadBalancer Service, Deployment, ConfigMap | RTI DDS Ping, RTI CDS, RTI RS, RTI RWT Transport |
<!--|[Remote Monitoring with RTI Routing Service with Real-time WAN Transport](routingservice_rwt_monitoring/) | Monitor DDS applications in a Kubernetes cluster from outside the cluster using RTI Routing Service with Real-time WAN Transport. | NodePort Service, StatefulSet, Deployment, ConfigMap |  |
|[External Participant Discovery behind Cone NATs Using RTI Cloud Discovery Service with a LoadBalancer](external_peer_to_peer/) |  Enable peer-to-peer communication with participants outside the cluster using LoadBalancer and RTI Cloud Discovery Service. | LoadBalancer Service, StatefulSet, Deployment, ConfigMap | |-->
