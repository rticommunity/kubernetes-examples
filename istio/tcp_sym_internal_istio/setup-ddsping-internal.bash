#!/bin/bash

# create the namespace
kubectl create namespace ddsping-internal

# inject the istio sidecars and enable mTLS
kubectl label namespace ddsping-internal istio-injection=enabled

kubectl apply -n ddsping-internal -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

# create a secret to pull the license controlled private images from dockerhub
kubectl create secret docker-registry regcred --namespace=ddsping-internal --docker-server=docker.io --docker-username=<dockerhub-account> --docker-password=<password> --docker-email=<email-address>

# create the config
kubectl apply -f tcp_config_sym.yaml --namespace=ddsping-internal

# start the publisher and subscriber
kubectl apply -f ddsping-tcp-pub.yaml --namespace=ddsping-internal
kubectl apply -f ddsping-tcp-sub.yaml --namespace=ddsping-internal


