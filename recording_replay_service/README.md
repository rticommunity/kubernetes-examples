## Testing Recording and Replay Services

### Description

This is created to test the official Recording and Replay (RnR) Docker image. 

### Steps
Follow these steps to test RnR image within your Kubernetes cluster:

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### Create a Deployment and a Service for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

### Create a Persistent Volume for RnR services
`$ kubectl create -f pv.yaml`

#### Create a StatefulSet for Recording service
`$ kubectl create -f rtirecordingservice.yaml`

#### Create a Deployment for DDS ping publisher.
`$ kubectl create -f rtiddsping_cds_pub.yaml`

### Wait for a while to record some data from the DDS ping publisher. Then, terminate both Recording Service and the DDS ping publisher
`$ kubectl delete -f rtiddsping_cds_pub.yaml`

`$ kubectl delete -f rtirecordingservice.yaml`

#### Create a Deployment for DDS ping subscriber.
`$ kubectl create -f rtiddsping_cds_sub.yaml`

#### Create a StatefulSet for Replay service
`$ kubectl create -f rtireplayservice.yaml`

#### Check Samples Received
Now you can check the output of the DDS ping subscriber to validate it receives the sample

` $ kubectl get pods`

After running the command above you can get the pod name of the DDS ping subscriber. 

` $ kubectl logs rtiddsping-sub-xxxx`

This command will display the output of the DDS ping subscriber.

#### Clean up resources
`$ kubectl delete -f pv.yaml`

`$ kubectl delete -f rtiddsping_cds_sub.yaml`

`$ kubectl delete -f rticlouddiscoveryservice`
