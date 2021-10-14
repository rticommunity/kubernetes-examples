### Pod-to-pod Communications Inside a Cluster


#### Problem

You want DDS applications in pods to communicate with each other in a k8s cluster. 


#### Solution

If you use a networking plugin supporting multicast (e.g. WeaveNet) for your k8s cluster, DDS pods can automatically discover each other through multicast. With **DDS built-in discovery**, you do not need a k8s service for discovery because DDS pods can discover and establish connections with each other by topics, abstracting IP-based communications. This will allow DDS pods to discover and communicate without a k8s service, resolving the IP unreliability issue of a pod.

![Pod-to-pod Communications Inside a Cluster](ddsping.png)

#### Steps

##### Create a Deployment for DDS ping publisher
`$ kubectl create -f rtiddsping-pub.yaml`

##### Create a Deployment for DDS ping subscriber
`$ kubectl create -f rtiddsping-sub.yaml`
