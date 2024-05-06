# Kubernetes Example Configurations for RTI Connext DDS
This directory provides example configurations for various use cases involving RTI Connext applications and services running on Kubernetes.

NOTE: Please note that the container images in the example configurations are not publicly available. We encourage you to create your own container images and utilize your container image repository for pushing and pulling these images. You also need to update the container image names in the example configurations. 

### Use Cases

|Name | Description | Kubernetes Features Used | RTI Components|
------------- | ------------- | ------------  | ------------  |
|[1. Communications Between Pods Inside a Kubernetes Cluster via Multicast Discovery](ddsping/) | Enable communications inside a Kubernetes cluster using RTI DDS Ping. | Deployment  | RTI DDS Ping |
|[2. Communications Between Pods Inside a Kubernetes Cluster via Unicast Discovery](ddsping_cds/) | Enable discovery with RTI Cloud Discovery Service (CDS). | Deployment, ClusterIP Service, ConfigMap (for a single CDS) StatefulSet, Headless Service, ConfigMap (for redundant CDSes) | RTI DDS Ping, RTI CDS |
|[3. Intra Pod Communications Using Shared Memory](ddsping_shmem/) | Establish communications using RTI DDS Ping over shared memory between containers in a pod. | Deployment, ClusterIP Service, ConfigMap | RTI DDS Ping, RTI CDS|
|[4. Communicaitons Between External Applications and Pods Within a Kubernetes Cluster Using a Gateway](routingservice_rwt/) | Expose DDS applications using RTI Routing Service (RS) over Real-time WAN (RWT) transport outside the Kubernetes cluster. | NodePort Service, StatefulSet, Deployment, ConfigMap | RTI DDS Ping, RTI CDS, RTI RS RTI RWT Transport|
|[5. Communicaitons Between External Applications And Pods Within a Kubernetes Cluster Using a Network Load-Balanced Gateway](routingservice_rwt_lb/) | Load balance RTI Routing Service traffic over Real-time WAN transport. | LoadBalancer Service, Deployment, ConfigMap | RTI DDS Ping, RTI CDS, RTI RS RTI RWT Transport |
<!--|[Remote Monitoring with RTI Routing Service with Real-time WAN Transport](routingservice_rwt_monitoring/) | Monitor DDS applications in a Kubernetes cluster from outside the cluster using RTI Routing Service with Real-time WAN Transport. | NodePort Service, StatefulSet, Deployment, ConfigMap |  |
|[External Participant Discovery behind Cone NATs Using RTI Cloud Discovery Service with a NodePort](cds_wan_point_to_point_node_port/) | Enable peer-to-peer communication with participants outside the cluster using NodePort and RTI Cloud Discovery Service. | NodePort Service, StatefulSet, Deployment, ConfigMap |  |
|[External Participant Discovery behind Cone NATs Using RTI Cloud Discovery Service with a LoadBalancer](cds_wan_point_to_point_load_balancer/) |  Enable peer-to-peer communication with participants outside the cluster using LoadBalancer and RTI Cloud Discovery Service. | LoadBalancer Service, StatefulSet, Deployment, ConfigMap | |-->
