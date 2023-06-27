#!/bin/bash

# create the namespace
kubectl create namespace hello-internal

# inject the istio sidecars and enable mTLS
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

# create a secret to pull the license controlled private images from dockerhub
kubectl create secret docker-registry regcred --namespace=hello-internal --docker-server=docker.io --docker-username=rtiresearch --docker-password=<password> --docker-email=research_docker@rti.com

# create the config
kubectl apply -f tcp_config_sym.yaml --namespace=hello-internal

# start the publisher and subscriber
kubectl apply -f hello-tcp-pub.yaml --namespace=hello-internal
kubectl apply -f hello-tcp-sub.yaml --namespace=hello-internal


