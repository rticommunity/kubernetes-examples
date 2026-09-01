## Communications Between External Applications and Pods Using a Load-Balanced Gateway

This example uses an RTI Routing Service deployment behind a LoadBalancer service to expose DDS traffic over Real-time WAN Transport. It requires a Kubernetes environment with LoadBalancer support. Before deployment, set `PUBLIC_IP` in `rtiroutingservice.yaml` to an external address assigned by the load balancer.

## Deploy

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl create configmap routingservice-rwt \
  --from-file=external_to_pod_lb_gw/USER_ROUTING_SERVICE.xml -n rti-examples
kubectl apply -f external_to_pod_lb_gw/
```

Use `kubectl get services -n rti-examples` to obtain the external endpoint. Configure the external publisher from `rwt_participant.xml` with that endpoint.

All resources are deployed to the fixed `rti-examples` namespace.
