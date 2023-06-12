FROM rticom/ubuntu_connext7_java

# Set the working directory
WORKDIR /app

# Copy contents of current directory to container
COPY helloworld_tcp/ .

# set the environment variables
ENV NDDSHOME /opt/rti_connext_dds-7.1.0
ENV LD_LIBRARY_PATH /opt/rti_connext_dds-7.1.0/lib/x64Linux4gcc7.3.0
ENV RTI_EXAMPLE_ARCH x64Linux4gcc7.3.0

# install dig to perform IP address lookup (for now)
RUN apt-get update && \
   DEBIAN_FRONTEND=noninteractive \
    apt-get install -y dnsutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# set the mode (pub/sub) to be pub by default
ENV MODE pub

# setup environment variables for publisher and subscriber IP
ENV PUBLISHER_PORT 7100
ENV SUBSCRIBER_PORT 7101

# Expose the TCP ports
# note that these are set in the USER_QOS_PROFILES.xml
EXPOSE $PUBLISHER_PORT $SUBSCRIBER_PORT

# final configuration
CMD ./runHello.sh $MODE
