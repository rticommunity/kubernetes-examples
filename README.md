# Kubernetes Example Configurations for RTI Connext DDS
This directory provides example configurations for various use cases involving RTI Connext applications and services running on Kubernetes.

NOTE: Please note that the container images in the example configurations are not publicly available. We encourage you to create your own container images and utilize your container image repository for pushing and pulling these images. Then, you need to update the container image names in the example configurations. 

### Use Cases

|Name | Description | Kubernetes Features Used |
------------- | ------------- | ------------  |
|[Internal Pod-to-pod Communications](ddsping/) | Enable communications inside a Kubernetes cluster using RTI DDS Ping. | Deployment  |
|[Internal Pod Discovery with RTI Cloud Discovery Service](ddsping_cds/) | Enable discovery with RTI Cloud Discovery Service. | Deployment, ClusterIP Service, ConfigMap |
|[Replicated RTI Cloud Discovery Service](ddsping_cds_replicated/) | Deploy a replicated RTI Cloud Discovery Service for improved availability. | StatefulSet, Headless Service, ConfigMap |
|[Communications over Shared Memory](ddsping_shmem/) | Establish communications using RTI DDS Ping over shared memory between containers in a pod. | Deployment, ClusterIP Service, ConfigMap |
|[RTI Perftest](perftest_cds/) | Run RTI Perftest with RTI Cloud Discovery Service for performance testing. | Deployment, ClusterIP Service, NodeSelector | 
|[External Communications with RTI Routing Service with Real-time WAN Transport](routingservice_rwt/) | Expose DDS applications using RTI Routing Service over Real-time WAN transport outside the Kubernetes cluster. | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Replicating RTI Routing Services with Real-time WAN Transport](routingservice_rwt_replicated/) | Replicate RTI Routing Services over Real-time WAN Transport | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Load Balancing RTI Routing Services with Real-time WAN Transport](routingservice_rwt_lb/) | Load balance RTI Routing Service traffic over Real-time WAN transport. | LoadBalancer Service, Deployment, ConfigMap | 
|[Remote Monitoring with RTI Routing Service with Real-time WAN Transport](routingservice_rwt_monitoring/) | Monitor DDS applications in a Kubernetes cluster from outside the cluster using RTI Routing Service with Real-time WAN Transport. | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[External Participant Discovery behind Cone NATs Using RTI Cloud Discovery Service with a NodePort](cds_wan_point_to_point_node_port/) | Enable peer-to-peer communication with participants outside the cluster using NodePort and RTI Cloud Discovery Service. | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[External Participant Discovery behind Cone NATs Using RTI Cloud Discovery Service with a LoadBalancer](cds_wan_point_to_point_load_balancer/) |  Enable peer-to-peer communication with participants outside the cluster using LoadBalancer and RTI Cloud Discovery Service. | LoadBalancer Service, StatefulSet, Deployment, ConfigMap | 
