FROM ubuntu:22.04

# Set the working directory
WORKDIR /app

# Copy contents of current directory to container
COPY rti_connext_dds-7.1.0-pro-host-x64Linux.run .
COPY rti_connext_dds-7.1.0-pro-target-x64Linux4gcc7.3.0.rtipkg .

# set the environment variables
ENV NDDSHOME /opt/rti_connext_dds-7.1.0
ENV LD_LIBRARY_PATH /opt/rti_connext_dds-7.1.0/lib/x64Linux4gcc7.3.0
ENV RTI_EXAMPLE_ARCH x64Linux4gcc7.3.0

#install java on ubuntu
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install default-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install dependencies
RUN ./rti_connext_dds-7.1.0-pro-host-x64Linux.run --mode unattended --prefix /opt
RUN /opt/rti_connext_dds-7.1.0/bin/rtipkginstall rti_connext_dds-7.1.0-pro-target-x64Linux4gcc7.3.0.rtipkg -u
RUN rm rti_connext_dds-7.1.0-pro-target-x64Linux4gcc7.3.0.rtipkg rti_connext_dds-7.1.0-pro-host-x64Linux.run

