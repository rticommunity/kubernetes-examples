#!/bin/bash

kubectl apply -f ./namespace-hello-from-outside.yaml
kubectl label namespace hello-from-outside istio-injection=enabled

kubectl apply -n hello-from-outside -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

kubectl create secret docker-registry regcred --namespace=hello-from-outside --docker-server=docker.io --docker-username=rtiresearch --docker-password=[password] --docker-email=research_docker@rti.com

# setup publisher deployment & node port service
kubectl apply -f hello-tcp-pub.yaml --namespace=hello-from-outside

# create istio gateway and virtual service
kubectl apply -f istio-ingress.yaml --namespace=hello-from-outside

