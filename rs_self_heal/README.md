## Testing Routing Service Self Healing

### Description

This is created to test the official Routing Service (RS) Docker image with Kubernetes Self Healing. 

### Steps
Follow these steps to test within your Kubernetes cluster:

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### Create a Deployment and a Service for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

#### Create a StatefulSet for RS
`$ kubectl create -f rtiroutingservice.yaml`

#### Create a Deployment for DDS ping publisher.
`$ kubectl create -f rtiddsping_cds_pub.yaml`

#### Create a Deployment for DDS ping subscriber.
`$ kubectl create -f rtiddsping_cds_sub.yaml`

#### Check Samples Received
Now you can check the output of the DDS ping subscriber to validate it receives the sample

` $ kubectl get pods`

After running the command above you can get the pod name of the DDS ping subscriber. 

` $ kubectl logs rtiddsping-sub-xxxx`

This command will display the output of the DDS ping subscriber.

#### Delete the RS pod
`$ kubectl delete pod rti-rs-0`

This command will kill the RS pod, so the publisher and subscriber cannot communicate for a while. 

However, after some time, Kubernetes will automatically create a new RS pod. 

You can check the status of the RS pod by running the following command.

`$ kubectl get pod rti-rs-0`

After the new RS pod is created, you can see the subscriber pod can receive samples again. 

` $ kubectl logs rtiddsping-sub-xxxx`

This command will display the output of the DDS ping subscriber.

#### Clean up resources
`$ kubectl delete -f rtiroutingservice.yaml`

`$ kubectl delete -f rtiddsping_cds_pub.yaml`

`$ kubectl delete -f rtiddsping_cds_sub.yaml`

`$ kubectl delete -f rticlouddiscoveryservice`
