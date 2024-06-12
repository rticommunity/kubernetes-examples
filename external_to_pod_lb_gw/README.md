## Communicaitons Between External Applications And Pods Within a Kubernetes Cluster Using a Network Load-Balanced Gateway

### Problem

You need to ensure scalability and fault tolerance for Routing Services to accommodate varying loads and ensure high availability. 

### Solution

To address this challenge, deploying RTI Routing Services using a Kubernetes **Deployment** and **LoadBalancer service** facilitates scalability and high availability. A LoadBalancer Service, integrating with an external Network Load Balancer (NLB) provided by AWS, is utilized to expose the traffic of the Routing Services. This configuration allows the LoadBalancer Service, in conjunction with the external NLB, to distribute incoming traffic evenly from outside the cluster to multiple Routing Service pods, effectively scaling up the service in response to demand while maintaining high availability.

![Load Balancing Routing Services with Real-time WAN Transport](routingservice_rwt_lb.png)

### Required Docker Images
- [RTI Routing Service](../dockerfiles/rti_routingservice)
- [RTI Cloud Discovery Service](../dockerfiles/rti_clouddiscoveryservice)
- [RTI DDS Ping Subscriber](../dockerfiles/rti_ddsping_sub)

### Steps

#### 1. Create a ConfigMap for RTI License.
`$ kubectl create configmap rti-license --from-file rti_license.dat`

#### 2. Create a LoadBalancer Service for the Routing Service. 
`$ kubectl create -f rs-lb.yaml`

After this step, AWS will provide a DNS name (e.g., a709579e8e4db40248531847d6245779-0bc4e2a058d739ab.elb.us-east-2.amazonaws.com) for the LoadBalancer Service. You should use the DNS name in your RT WAN configurations in Step 4 and Step 7.

`$ kubectl get services rs-rwt`

`$ nslookup a709579e8e4db40248531847d6245779-0bc4e2a058d739ab.elb.us-east-2.amazonaws.com`

#### 3. Create a Deployment and a Service for Cloud Discovery Service.
`$ kubectl create -f rticlouddiscoveryservice.yaml`

#### 4. Create a ConfigMap for the Routing Service XML configuration file
`$ kubectl create configmap routingservice-rwt --from-file=config.xml`

#### 5. Create a Deployment for the Routing Service. You should update the public IP address and ports in this file. 
`$ kubectl create -f rtiroutingservice.yaml`

#### 6. Create a Deployment for a RTI DDS Ping subscriber
`$ kubectl create -f rtiddsping-sub.yaml`

#### 7. Run the external publisher (outside the cluster). You should update the public IP address and port in this file.
`$ rtiddsping -qosFile rwt_participant.xml -qosProfile RWT_Demo::RWT_Profile -publisher -domainId 100`
