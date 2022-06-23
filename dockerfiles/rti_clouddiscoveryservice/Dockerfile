FROM ubuntu:20.04

# Connext lib should be located at the current directory
# cp -rf $NDDSHOME/resource/app/lib/x64Linux2.6gcc4.4.5 ./lib

# Cloud Discovery Service executable (rticlouddiscoveryserviceapp) should be located at your current directory
# cp $NDDSHOME/resource/app/bin/x64Linux2.6gcc4.4.5/rticlouddiscoveryserviceapp .

# Example commands for building and running the image:
# $ docker build -t rti-clouddiscoveryservice .
# $ docker run -tdi -v $PWD/rti_license.dat:/app/license/rti_license.dat rti-clouddiscoveryservice
# $ docker run -tdi -v $PWD/rti_license.dat:/app/license/rti_license.dat -v $PWD/your_config.xml:/app/config.xml -e "ARGS=-cfgName your_config_name" rti-clouddiscoveryservice

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib
ENV RTI_LICENSE_FILE=/app/license/rti_license.dat
ENV ARGS="-cfgFile ./config.xml -cfgName default"

COPY . /app

WORKDIR /app

CMD ./rticlouddiscoveryserviceapp $ARGS
