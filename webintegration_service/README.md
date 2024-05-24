## Testing Web Integration Service

### Description

This is created to test the official Web Integration Service (WIS) Docker image. 

### Steps
Follow these steps to test persistence service image within your Kubernetes cluster:

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

This command creates a ConfigMap to store the RTI License, which is necessary for running the RTI PS in the evaluation package.

#### Create a ConfigMap for the Web Integraton Service XML configuration file
`$ kubectl create configmap web-integration-service --from-file=USER_WEB_INTEGRATION_SERVICE.xml`

#### Create a StatefulSet and a Service for Web Integration Service.
`$ kubectl create -f rtiwebintegration.yaml`

#### Create a Deployment for DDS ping subscriber.
`$ kubectl create -f rtiddsping_cds_sub.yaml`

#### List Types
` $curl -X GET -H "Cache-Control:no-cache" http://sjc01k8s04.sjcvirt.rti.com:30007/dds/rest1/types`

#### Sending Samples
` $curl -X POST -H "Content-Type:application/dds-web+xml" -H "Cache-Control:no-cache" -d '<data>
    <number>0</number>
</data>' http://sjc01k8s04.sjcvirt.rti.com:30007/dds/rest1/applications/PingDemoApp/domain_participants/MyParticipant/publishers/MyPublisher/data_writers/MyPingWriter`

Now you can check the output of the DDS ping subscriber to validate it receives the sample
` $ kubectl get pods`
After running the command above you can get the pod name of the DDS ping subscriber. 

` $ kubectl get rtiddsping-sub-xxxx`
This command will display the output of the DDS ping subscriber.
