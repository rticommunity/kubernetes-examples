# Using multi-stage build approach
# Install Base Image
FROM ubuntu:18.04 as builder
EXPOSE 8080/udp

run apt-get update && apt-get update && apt-get -y install netcat gcc g++ vim libssl-dev openssl

WORKDIR /home/rti/

# Copy perfTest Binary from https://github.com/rticommunity/rtiperftest/releases/download/3.2/rti_perftest-3.2.0_ConnextDDS_Pro_6.1.0_x64Linux.tar.gz 
COPY patient_monitoring_project/ patient_monitoring_project/

# Copy external Libraries need for WAN -- Real_time_WAN
COPY rti_connext_dds-6.1.0/lib/x64Linux4gcc7.3.0/ /usr/lib/x86_64-linux-gnu/

# Copy lib files
COPY libstdc++.so.6 /usr/lib/x86_64-linux-gnu/
COPY libm.so.6 /lib/x86_64-linux-gnu/libm.so.6
COPY libnddssecurityd.so /usr/lib/x86_64-linux-gnu/ 

WORKDIR /home/rti/patient_monitoring_project

# Hack to just spin & wait forever
CMD [ "/bin/bash", "-c", "--", "while true; do sleep 30; done;" ]
# CMD ["./bin/x64Linux3gcc4.8.2/release/perftest_cpp", \
#        "-sub", \
#        "-noPrint", \
#        "-transport", \
#        "UDPv4_WAN" ]
#       "-transportPublicAddress", \
#       "<public_ip>:8080" ]

# ./bin/x64Linux4gcc7.3.0/release/perftest_cpp -sub -noPrint -transport UDPv4_WAN -transportPublicAddress 172.17.0.2:8080

