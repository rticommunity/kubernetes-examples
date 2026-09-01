## Communications Between External Applications and Pods Using a Gateway

This example uses RTI Routing Service and Real-time WAN Transport to expose an internal DDS subscriber through a NodePort service. Before deployment, set the appropriate `PUBLIC_IP` and `PUBLIC_PORT` values in `rtiroutingservice.yaml`.

## Deploy

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl create configmap routingservice-rwt \
  --from-file=external_to_pod_gw/USER_ROUTING_SERVICE.xml -n rti-examples
kubectl apply -f external_to_pod_gw/
```

Get the assigned NodePort with `kubectl get service -n rti-examples`. Run the external publisher with the `RWT_Demo::RWT_Profile` from `rwt_participant.xml`, using the node address and assigned port.

All resources are deployed to the fixed `rti-examples` namespace.
