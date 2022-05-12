# k8s-configs
This directory includes the example configurations of use cases with RTI Connext applications and services on Kubernetes. 

### Use Cases

|Name | Description | Kubernetes Features Used |
------------- | ------------- | ------------  |
|[DDS Ping](ddsping/) | Communications inside a cluster with RTI DDS Ping | Deployment  |
|[DDS Ping with CDS](ddsping_cds/) | Discovery without multicast RTI Cloud Discovery Service | Deployment, ClusterIP Service, ConfigMap |
|[DDS Ping with Replicated CDS](ddsping_cds_replicated/) | Replicated RTI Cloud Discovery Service | StatefulSet, Headless Service, ConfigMap |
|[DDS Ping over Shared Memory](ddsping_shmem/) | Communications with RTI DDS Ping over Shared Memory  | Deployment, ClusterIP Service, ConfigMap |
|[RTI Perftest with CDS](perftest_cds/) | RTI Perftest with RTI Cloud Discovery Service | Deployment, ClusterIP Service, ConfigMap | 
|[RTI Routing Service with Real-time WAN Transport (RWT)](routingservice_rwt/) | Exposing DDS applications with RTI Routing Service over Real-time WAN transport outside the k8s cluster | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Replicating RTI Routing Services with RWT](routingservice_rwt_replicated/) | Replicating RTI Routing Service RWT traffic | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Load Balancing RTI Routing Services with RWT](routingservice_rwt_lb/) | Load balancing RTI Routing Service RWT traffic | LoadBalancer Service, Deployment, ConfigMap | 
|[Remote Monitoring with RTI Routing Service with RWT](routingservice_rwt_monitoring/) | Monitoring DDS applications in a Kubernetes cluster from the outside of the cluster | NodePort Service, StatefulSet, Deployment, ConfigMap | 
|[Cert Manager Secure DDS](cert-manger-secure-dds-example/) | Bootstrap Secure DDS using Cert Manager and Kubernetes | 
|[RBAC Example](rbac-example/) | Simple RBAC Secret Managment with Kubernetes | 

