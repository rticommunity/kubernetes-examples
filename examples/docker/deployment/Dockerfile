FROM ubuntu:16.04
 
# Store the test apps in /app 
WORKDIR /app
 
# Copy the apps and QoS file
COPY USER_QOS_PROFILES.xml \
    objs/x64Linux3gcc5.4.0/Values_publisher \
    objs/x64Linux3gcc5.4.0/Values_subscriber \
    rti_license.dat \
    ./
 
# Add the apps to the PATH
ENV PATH $PATH:/app
