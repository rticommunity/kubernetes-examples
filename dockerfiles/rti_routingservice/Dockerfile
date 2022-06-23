# Connext lib should be located at the current directory
# cp -rf $NDDSHOME/resource/app/lib/x64Linux2.6gcc4.4.5 ./lib

# Routing Service executable (rtiroutingserviceapp) should be located at your current directory
# cp $NDDSHOME/resource/app/bin/x64Linux2.6gcc4.4.5/rtiroutingserviceapp .

# Example commands for building and running the image:
# $ docker build -t rti-routingservice .
# $ docker run -tdi -v $PWD/rti_license.dat:/app/license/rti_license.dat rti-routingservice
# $ docker run -tdi -v $PWD/rti_license.dat:/app/license/rti_license.dat -v $PWD/your_config.xml:/app/config.xml -e "ARGS=-cfgName your_config_name" rti-routingservice

FROM ubuntu:20.04

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib
ENV RTI_LICENSE_FILE=/app/license/rti_license.dat
ENV ARGS="-cfgFile ./config.xml -cfgName default"

COPY . /app

WORKDIR /app

CMD ./rtiroutingserviceapp $ARGS
