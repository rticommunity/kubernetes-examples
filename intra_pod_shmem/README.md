## Communications over Shared Memory

### Problem
You want to make Connext containers communicate over shared memory.

### Solution
Containers in a pod share the same IPC namespace, which means they can communicate with each other using standard inter-process communications such as SystemV semaphores or POSIX shared memory. If containers are in the same pod, Connext containers with a version above 6.0 can communicate over shared memory with the default settings. (Please see [this](https://community.rti.com/kb/communicate-between-two-docker-containers-using-rti-connext-dds-and-shared-memory) if you use an older version.) A Connext container can use both shared memory transport for container-to-container communications (in the same pod) and UDP transport for pod-to-pod communications. 

![Container Communications over Shared Memory](ddsping_shmem.png)

### Required Docker Images
- [RTI Cloud Discovery Service](https://hub.docker.com/repository/docker/rticom/cloud-discovery-service)
- [RTI DDS Ping](https://hub.docker.com/repository/docker/rticom/dds-ping)

### Steps

#### Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

This command creates a ConfigMap to store the RTI License, which is necessary for running RTI CDS in the evaluation package.

#### Create a Deployment and a Service for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

Use this command to create a Deployment and a Service for the RTI CDS.

#### Create a publisher and subscriber over shared memory transport.
`$ kubectl create -f rtiddsping-shmem.yaml`

This command deploys the RTI DDS Ping Publisher and Subscriber that communicate over shared memory transport.

#### Deploy a subscriber over UDP transport.
`$ kubectl create -f rtiddsping-sub.yaml`
This command deploys the RTI DDS Ping Subscriber that communicates using UDP transport.
