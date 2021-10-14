FROM ubuntu:20.04

# $NDDSHOME/resource/app/lib/x64Linux2.6gcc4.4.5 should be located at ./lib
# $NDDSHOME/resource/app/bin/x64Linux2.6gcc4.4.5/rticlouddiscoveryservice should be located at your current directory
# Example commands for building and running the image:
# $ docker build -t rti-clouddiscoveryservice .
# $ docker run -tdi -v $PWD/rti_license.dat:/app/license/rti_license.dat rti-clouddiscoveryservice
# $ docker run -tdi -v $PWD/rti_license.dat:/app/license/rti_license.dat -v $PWD/your_config.xml:/app/config.xml -e "CFG_NAME=your_config_name" rti-clouddiscoveryservice

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib
ENV CFG_NAME=default
ENV RTI_LICENSE_FILE=/app/license/rti_license.dat

COPY . /app

WORKDIR /app

CMD ./rticlouddiscoveryservice -cfgFile ./config.xml -cfgName $CFG_NAME
