# Ubuntu 16.04 is supported by RTI Connext DDS 5.3.0
FROM ubuntu:16.04
 
# Copy the RTI Connext DDS installation from build context
COPY rti_connext_dds-5.3.0 /opt/rti_connext_dds-5.3.0/
 
# Set up the DDS execution environment
ENV NDDSHOME /opt/rti_connext_dds-5.3.0
ENV PATH $PATH:$NDDSHOME/bin
 
# Install the necessary build tools
RUN apt-get update && apt-get -y install gcc g++ make
