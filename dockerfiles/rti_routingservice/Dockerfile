FROM ubuntu:20.04

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib
ENV CFG_NAME=default
ENV ARGS=

COPY . /app

WORKDIR /app

CMD ./rtiroutingserviceapp -cfgFile ./config.xml -cfgName $CFG_NAME $ARGS
