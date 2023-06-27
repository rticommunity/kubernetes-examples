#!/bin/bash

# create namespace
kubectl create namespace ddsping-external

# inject the istio sidecar and enable mTLS
kubectl label namespace ddsping-external istio-injection=enabled

kubectl apply -n ddsping-external -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

# create a secret to pull the license controlled private images from dockerhub
kubectl create secret docker-registry regcred --namespace=ddsping-external --docker-server=docker.io --docker-username=<dockerhub-account> --docker-password=<password> --docker-email=<email-address>

# create the config
kubectl apply -f tcp_config_asym.yaml --namespace=ddsping-external

# setup publisher deployment & node port service
kubectl apply -f ddsping-tcp-pub.yaml --namespace=ddsping-external

# create istio gateway and virtual service
kubectl apply -f istio-ingress.yaml --namespace=ddsping-external

