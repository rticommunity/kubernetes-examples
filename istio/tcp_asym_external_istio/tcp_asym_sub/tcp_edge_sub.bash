#!/bin/bash

export NDDSHOME=/Applications/rti_connext_dds-6.1.1
source $NDDSHOME/resource/scripts/<ARCH>

#setup discovery peers for asymmetric TCP WAN transport
#public IP address of the istio ingress gateway load balancer
export INGRESS_GATEWAY_IP=`dig +short <load_balancer_dns_name> | tail -1`

export PUBLISHER_IP=$INGRESS_GATEWAY_IP

#configured public port on the istio ingress gateway allocated to the publisher service  
export PUBLISHER_PORT=7200

export NDDS_DISCOVERY_PEERS=tcpv4_wan://$PUBLISHER_IP:$PUBLISHER_PORT

$NDDSHOME/bin/rtiddsping -subscriber -domainId 10 -qosFile ./tcp_config_asym.xml -qosProfile qos_lib::sub_profile -Verbosity 2
