# Ubuntu 16.04 is supported by RTI Connext DDS 5.3.0
# Use Docker's multi-stage build capability to create an image that
# contains only Ubuntu and the fully-installed RTI Connext distribution
FROM ubuntu:16.04 as dds_install
 
# /app will hold our installation files
WORKDIR /app
 
# Copy the installation files into the image
COPY rti_connext_dds-5.3.0-pro-host-x64Linux.run \
     rti_connext_dds-5.3.0-pro-target-x64Linux3gcc5.4.0.rtipkg \
     ./
 
# Run the host package installer
RUN chmod +x rti_connext_dds-5.3.0-pro-host-x64Linux.run && \
    ./rti_connext_dds-5.3.0-pro-host-x64Linux.run --mode unattended
 
# Run the target package installer
RUN /opt/rti_connext_dds-5.3.0/bin/rtipkginstall \
    -u rti_connext_dds-5.3.0-pro-target-x64Linux3gcc5.4.0.rtipkg
 
# Start from a fresh image
FROM ubuntu:16.04
 
# Copy the RTI Connext DDS installation from the image created above
COPY --from=dds_install \
     /opt/rti_connext_dds-5.3.0 /opt/rti_connext_dds-5.3.0
 
# Set up the DDS execution environment
ENV NDDSHOME /opt/rti_connext_dds-5.3.0
ENV PATH $PATH:$NDDSHOME/bin
 
# Install build tools
RUN apt-get update && apt-get -y install gcc g++ make
