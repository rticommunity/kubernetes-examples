# k8s Manifests for RTI PerfTest with Cloud Discovery Service

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### Create a Deployment and a Service for Cloud Discovery Service
`$ kubectl create -f rticlouddiscoveryservice.yaml`

#### Create a Deployment for PerfTest publisher
`$ kubectl create -f rtiperftest-cds-pub.yaml`

#### Create a Deployment for PerfTest subscriber
`$ kubectl create -f rtiperftest-cds-sub.yaml`
