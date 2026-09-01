## Communications Between External Applications and Pods Using a Gateway

This example uses RTI Routing Service and Real-time WAN Transport to expose an internal DDS subscriber through a NodePort service. Before deployment, set the appropriate `PUBLIC_IP` and `PUBLIC_PORT` values in `base/rtiroutingservice.yaml`.

## Deploy

Run these commands from the repository root:

```bash
kubectl create namespace rti-examples
kubectl create configmap rti-license --from-file=rti_license.dat -n rti-examples
kubectl create configmap routingservice-rwt \
  --from-file=external_to_pod_gw/USER_ROUTING_SERVICE.xml -n rti-examples
kubectl apply -k external_to_pod_gw/overlays/rti-examples
```

Get the assigned NodePort with `kubectl get service -n rti-examples`. Run the external publisher with the `RWT_Demo::RWT_Profile` from `rwt_participant.xml`, using the node address and assigned port.

To deploy to a different namespace, copy `overlays/rti-examples`, change `namespace: rti-examples` in the copied `kustomization.yaml`, and create both ConfigMaps in the new namespace before applying the copy. For direct raw deployment, use:

```bash
kubectl apply -f external_to_pod_gw/base/*.yaml -n rti-examples
```
