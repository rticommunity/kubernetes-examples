## Communications Between External Applications and Pods Using a Load-Balanced Gateway

This example uses an RTI Routing Service deployment behind a LoadBalancer service to expose DDS traffic over Real-time WAN Transport. It requires a Kubernetes environment with LoadBalancer support. Before deployment, set `PUBLIC_IP` in `base/rtiroutingservice.yaml` to an external address assigned by the load balancer.

## Deploy

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl create configmap routingservice-rwt \
  --from-file=external_to_pod_lb_gw/USER_ROUTING_SERVICE.xml -n rti-examples
kubectl apply -k external_to_pod_lb_gw/overlays/rti-examples
```

Use `kubectl get services -n rti-examples` to obtain the external endpoint. Configure the external publisher from `rwt_participant.xml` with that endpoint.

To deploy to another namespace, copy `overlays/rti-examples`, update `namespace: rti-examples` in its copied `kustomization.yaml`, create both ConfigMaps in the target namespace, and apply the copy. For direct raw deployment, use:

```bash
kubectl apply -f external_to_pod_lb_gw/base/ -n rti-examples
```
