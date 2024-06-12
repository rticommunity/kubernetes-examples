## Testing Cloud Discovery Service Self Healing

### Description

This is created to test the official Cloud Discovery Service (CDS) Docker image with Kubernetes Self Healing. 

### Steps
Follow these steps to test within your Kubernetes cluster:

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### Create a Deployment and a Service for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

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
` $ kubectl get pods`

`$ kubectl delete pod rti-clouddiscoveryservice-xxxx`

This command will kill the CDS pod.

After some time, Kubernetes will automatically create a new CDS pod. 

You can check the status of the CDS pod by running the following command.

`$ kubectl get pod rti-clouddiscoveryservice-xxxx`

After the new CDS pod is created, let's kill the publisher and subscriber to go through the discovery process again with the new CDS. 

`$ kubectl get pod`

` $ kubectl delete pod rtiddsping-pub-xxxx`

` $ kubectl delete pod rtiddsping-sub-xxxx`

After both publisher and subscriber pods are recreated and running, let's check the output of the subscriber to check they discovered each other. 

` $ kubectl logs rtiddsping-sub-xxxx`

#### Clean up resources
`$ kubectl delete -f rtiddsping_cds_pub.yaml`

`$ kubectl delete -f rtiddsping_cds_sub.yaml`

`$ kubectl delete -f rticlouddiscoveryservice`
