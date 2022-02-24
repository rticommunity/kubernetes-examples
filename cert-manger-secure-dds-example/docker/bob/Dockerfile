FROM ubuntu:20.04

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib

COPY . /app

WORKDIR /app

CMD ./PatientMonitoring_subscriber --domain 1
