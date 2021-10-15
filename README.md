# k8s-configs
This directory includes the example configurations of use cases with RTI Connext DDS applications on Kubernetes. 

### Use Cases

|Name | Description | Kubernetes Features Used |
------------- | ------------- | ------------  |
|[DDS Ping](ddsping/) | Communications inside a cluster with RTI DDS Ping | Deployment  |
|[DDS Ping with CDS](ddsping_cds/) | Discovery without multicast RTI CDS | Deployment, Service, ConfigMap |
|[RTI Perftest with CDS](perftest_cds/) | RTI Perftest with Cloud Discovery Service | Deployment, ClusterIP Service, ConfigMap | 
|[RTI Routing Service with Real-time WAN Transport (RWT)](routingservice_rwt/) | Exposing DDS applications with RTI Routing Service over Real-time WAN transport outside the k8s cluster | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Replicating RTI Routing Services with RWT](routingservice_rwt_replicated/) | Replicating RTI Routing Service RWT traffic | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Load Balancing RTI Routing Services with RWT](routingservice_rwt_lb/) | Load balancing RTI Routing Service RWT traffic | LoadBalancer Service, Deployment, ConfigMap | 
|[Remote Monitoring with RTI Routing Service with RWT](routingservice_rwt_monitoring/) | Monitoring DDS applications in a Kubernetes cluster from the outside of the cluster | NodePort Service, StatefulSet, Deployment, ConfigMap | 
