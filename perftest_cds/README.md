##  RTI PerfTest with RTI Cloud Discovery Service

### Problem

You want to experiment performance of RTI Connext DDS applications within a Kubernetes cluster. 

### Solution

To perform performance experiments of RTI Connext DDS applicaitons within a Kubernetes cluster, you can deploy RTI PerfTest applications pods. Like other DDS applications, RTI PerfTest requires RTI Cloud Discovery Service for discovery if a CNI does not support multicast. Therefore, we deploy a pod for RTI Cloud Discovery Service and create a ClusterIP service for the pod. After running RTI PerfTest applicaiton pods, you can get the results of performance tests through output logs of the application pods. 

### Required Docker Images
- [RTI Cloud Discovery Service](../dockerfiles/rti_clouddiscoveryservice)
- [RTI PerfTest](../dockerfiles/rti_perftest)

### Steps

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### Assign a label for a publisher node
kubectl label nodes <your-pub-node-name> perftest_type=pub

#### Assign a label for a subscriber node
kubectl label nodes <your-sub-node-name> perftest_type=sub

#### Create a Deployment and a Service for Cloud Discovery Service
`$ kubectl create -f rticlouddiscoveryservice.yaml`

#### Create a Deployment for PerfTest publisher
`$ kubectl create -f rtiperftest-cds-pub.yaml`

#### Create a Deployment for PerfTest subscriber
`$ kubectl create -f rtiperftest-cds-sub.yaml`

