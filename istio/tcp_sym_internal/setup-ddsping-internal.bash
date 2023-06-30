#!/bin/bash

# create the namespace
kubectl create namespace ddsping-internal

# create a secret to pull the license controlled private images from dockerhub
kubectl create secret docker-registry regcred --namespace=ddsping-internal --docker-server=docker.io --docker-username=<dockerhub-account> --docker-password=<password> --docker-email=<email-address>

# create the config
kubectl apply -f tcp_config_sym.yaml --namespace=ddsping-internal

# start the publisher and subscriber
kubectl apply -f ddsping-tcp-pub.yaml --namespace=ddsping-internal
kubectl apply -f ddsping-tcp-sub.yaml --namespace=ddsping-internal


