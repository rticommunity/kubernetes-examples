FROM ubuntu:20.04

# $NDDSHOME/resource/app/lib/x64Linux2.6gcc4.4.5 should be located at ./lib
# $NDDSHOME/resource/app/bin/x64Linux2.6gcc4.4.5/rtiddsping should be located at your current directory
# Example commands for running the image:
# $ docker build rti-ddsping-sub
# $ docker run -tdi rti-ddsping-sub
# $ docker run -tdi -e "ARGS=-numSamples 10" rti-ddsping-sub

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib
ENV ARGS=

COPY . /app

WORKDIR /app

CMD ./rtiddsping -subscriber ${ARGS}
