## Testing DDS Spy

### Description

This is created to test the official DDS Spy Docker image. 

### Steps
Follow these steps to test DDS Spy image within your Kubernetes cluster:

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### Create a Deployment and a Service for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

#### Create a Deployment for DDS ping publisher.
`$ kubectl create -f rtiddsping_cds_pub.yaml`

#### Create a Deployment for DDS ping subscriber.
`$ kubectl create -f rtiddsping_cds_sub.yaml`

#### Create a Deployment for DDS Spy
`$ kubectl create -f rtiddsspy.yaml`

#### Check Samples Received
Now you can check the output of the DDS Spy to validate it receives the sample

` $ kubectl get pods`

After running the command above you can get the pod name of the DDS Spy.

` $ kubectl logs rtiddsspy-xxxx`

This command will display the output of the DDS Spy.

#### Clean up resources
`$ kubectl delete -f rticlouddiscoveryservice.yaml`

`$ kubectl delete -f rtiddsping_cds_pub.yaml`

`$ kubectl delete -f rtiddsping_cds_sub.yaml`

`$ kubectl delete -f rtiddsspy.yaml`


