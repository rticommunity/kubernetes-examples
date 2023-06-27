#!/bin/bash

# create namespace
kubectl create namespace hello-from-outside

# inject the istio sidecar and enable mTLS
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

# create a secret to pull the license controlled private images from dockerhub
kubectl create secret docker-registry regcred --namespace=hello-from-outside --docker-server=docker.io --docker-username=rtiresearch --docker-password=<password> --docker-email=research_docker@rti.com

# create the config
kubectl apply -f tcp_config_asym.yaml --namespace=hello-from-outside

# setup publisher deployment & node port service
kubectl apply -f hello-tcp-pub.yaml --namespace=hello-from-outside

# create istio gateway and virtual service
kubectl apply -f istio-ingress.yaml --namespace=hello-from-outside

