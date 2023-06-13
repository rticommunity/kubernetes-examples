# k8s-configs
This directory includes the example configurations of use cases with RTI Connext applications and services on Kubernetes. 

### Use Cases

|Name | Description | Kubernetes Features Used |
------------- | ------------- | ------------  |
|[Internal Pod-to-pod Communications](ddsping/) | Communications inside a cluster with RTI DDS Ping | Deployment  |
|[Internal Pod Discovery](ddsping_cds/) | Discovery with RTI Cloud Discovery Service | Deployment, ClusterIP Service, ConfigMap |
|[Replicated Cloud Discovery Service (CDS)](ddsping_cds_replicated/) | Replicated RTI Cloud Discovery Service | StatefulSet, Headless Service, ConfigMap |
|[Communications over Shared Memory](ddsping_shmem/) | Communications with RTI DDS Ping over Shared Memory  | Deployment, ClusterIP Service, ConfigMap |
|[RTI Perftest](perftest_cds/) | RTI Perftest with RTI Cloud Discovery Service | Deployment, ClusterIP Service, ConfigMap | 
|[External Communications with RTI Routing Service (RS) with Real-time WAN Transport (RWT)](routingservice_rwt/) | Exposing DDS applications with RTI Routing Service over Real-time WAN transport outside the k8s cluster | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Replicating RTI Routing Services with RWT](routingservice_rwt_replicated/) | Replicating RTI Routing Service RWT traffic | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Load Balancing RTI Routing Services with RWT](routingservice_rwt_lb/) | Load balancing RTI Routing Service RWT traffic | LoadBalancer Service, Deployment, ConfigMap | 
|[Remote Monitoring with RTI Routing Service with RWT](routingservice_rwt_monitoring/) | Monitoring DDS applications in a Kubernetes cluster from the outside of the cluster | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Peer-to-Peer Communications of Participants behind Cone NATs Using CDS using a NodePort](cds_wan_point_to_point_node_port/) | Enabling peer-to-peer communication with participants outside the cluster with a NodePort | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Peer-to-Peer Communications of Participants behind Cone NATs Using CDS using a LoadBalancer](cds_wan_point_to_point_load_balancer/) | Enabling peer-to-peer communication with participants outside the cluster with a NodePort | LoadBalancer Service, StatefulSet, Deployment, ConfigMap | 
