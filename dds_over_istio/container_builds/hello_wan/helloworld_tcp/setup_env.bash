#!/bin/bash

export NDDSHOME=/opt/rti_connext_dds-7.1.0/
export LD_LIBRARY_PATH=/opt/rti_connext_dds-7.1.0/lib/x64Linux4gcc7.3.0/
export RTI_EXAMPLE_ARCH=x64Linux4gcc7.3.0/

#setup discovery peers
export PUBLISHER_IP=52.14.231.203
export SUBSCRIBER_IP=52.14.231.203

#these are used as environment variables to configure the xml profile
export PUBLISHER_PORT=7100
export SUBSCRIBER_PORT=7101

export NDDS_DISCOVERY_PEERS=tcpv4_wan://$PUBLISHER_IP:$PUBLISHER_PORT,tcpv4_wan://$SUBSCRIBER_IP:$SUBSCRIBER_PORT
