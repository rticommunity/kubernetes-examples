#!/bin/bash

export NDDSHOME=/Applications/rti_connext_dds-6.1.1
source $NDDSHOME/resource/scripts/rtisetenv_arm64Darwin20clang12.0.bash
export PATH=$PATH:/Users/pbanerjee/Library/Python/3.10/bin

# Setting up x64 JRE for Java compiles
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export RTI_EXAMPLE_ARCH=x64Darwin17clang9.0

#setup discovery peers for asymmetric TCP WAN transport
#public IP address of the istio ingress gateway load balancer
export INGRESS_GATEWAY_IP=`dig +short a3b4e8877f4604924893ef2afa99af86-49787318.us-east-2.elb.amazonaws.com | tail -1`

export PUBLISHER_IP=$INGRESS_GATEWAY_IP

#configured public port on the istio ingress gateway allocated to the publisher service  
export PUBLISHER_PORT=7200

export NDDS_DISCOVERY_PEERS=tcpv4_wan://$PUBLISHER_IP:$PUBLISHER_PORT
