#!/bin/bash

kubectl apply -f ./namespace-hello.yaml
kubectl label namespace hello-internal istio-injection=enabled

kubectl apply -n hello-internal -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

kubectl create secret docker-registry regcred --namespace=hello-internal --docker-server=docker.io --docker-username=rtiresearch --docker-password=[password] --docker-email=research_docker@rti.com

kubectl apply -f hello-tcp-pub.yaml --namespace=hello-internal
kubectl apply -f hello-tcp-sub.yaml --namespace=hello-internal


