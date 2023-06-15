#!/bin/bash

export NDDSHOME=/opt/rti_connext_dds-6.1.2/
export LD_LIBRARY_PATH=/opt/rti_connext_dds-6.1.2/lib/x64Linux4gcc7.3.0/
export RTI_EXAMPLE_ARCH=x64Linux4gcc7.3.0/

#setup discovery peers for asymmetric TCP WAN transport
#publisher is the server
export PUBLIC_PUBLISHER_IP=52.14.231.203
export PUBLIC_PUBLISHER_PORT=7200
export PUBLISHER_PORT=7200

