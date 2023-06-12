#!/bin/sh
###############################################################################
##         (c) Copyright, Real-Time Innovations, All rights reserved.        ##
##                                                                           ##
##         Permission to modify and use for internal purposes granted.       ##
## This software is provided "as is", without warranty, express or implied.  ##
##                                                                           ##
###############################################################################

# You can override the following settings with the correct location of Java
JAVA=`which java`

# Make sure JAVA and NDDSHOME are set correctly
test -z "$JAVA" && echo "java not found" && exit 0
test -z "$NDDSHOME" && echo "NDDSHOME environment variable not set!" && exit 0
test -z "$RTI_EXAMPLE_ARCH" && echo "RTI_EXAMPLE_ARCH environment variable not set!" && exit 0

if [ `uname` = "Darwin" ]; then
   DYLD_LIBRARY_PATH=${NDDSHOME}/lib/${RTI_EXAMPLE_ARCH}:${NDDSHOME}/third_party/openssl-1.1.1n/${RTI_EXAMPLE_ARCH}/release/lib:${DYLD_LIBRARY_PATH}
   export DYLD_LIBRARY_PATH
elif [ `uname` = "AIX" ]; then
   LIBPATH=${NDDSHOME}/lib/${RTI_EXAMPLE_ARCH}:${NDDSHOME}/third_party/openssl-1.1.1n/${RTI_EXAMPLE_ARCH}/release/lib:${LIBPATH}
   export LIBPATH
else
   LD_LIBRARY_PATH=${NDDSHOME}/lib/${RTI_EXAMPLE_ARCH}:${NDDSHOME}/third_party/openssl-1.1.1n/${RTI_EXAMPLE_ARCH}/release/lib:${LD_LIBRARY_PATH}
   export LD_LIBRARY_PATH
fi

# Ensure this script is invoked from the root directory of the project
test ! -d src && echo "You must run this script from the example root directory" && exit 0

# Run example in either the publish or subscribe mode
MODE=$1

test -z $PUBLISHER_IP && export PUBLISHER_IP=`dig +short $PUBLISHER_NAME | tail -1`
echo $PUBLISHER_NAME " maps to:" $PUBLISHER_IP

test -z $SUBSCRIBER_IP && export SUBSCRIBER_IP=`dig +short $SUBSCRIBER_NAME | tail -1`
echo $SUBSCRIBER_NAME " maps to:" $SUBSCRIBER_IP

if [ $MODE = 'pub' ]; then
  $JAVA -classpath objs:"$NDDSHOME/lib/java/nddsjava.jar" HelloWorldPublisher
else
   $JAVA -classpath objs:"$NDDSHOME/lib/java/nddsjava.jar" HelloWorldSubscriber
fi

