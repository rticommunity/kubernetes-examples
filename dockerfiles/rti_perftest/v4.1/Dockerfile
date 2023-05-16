# Build command:
# $ docker build -t rti-perftest:v4.1 .

# Run command:
# $ docker run -tdi -e "perftest_args=-pub -domain 10" rti-perftest:v4.1

FROM ubuntu:20.04 as builder

RUN apt-get update \
    && apt-get install -y wget

RUN mkdir /build && cd /build \
    && wget https://github.com/rticommunity/rtiperftest/releases/download/4.1/rti_perftest-4.1_ConnextDDS-7.1.0_x64Linux4gcc7.3.0.tar.gz \
    && tar xvfz rti_perftest-4.1_ConnextDDS-7.1.0_x64Linux4gcc7.3.0.tar.gz

WORKDIR /build

FROM ubuntu:20.04

ENV perftest_args=

COPY --from=builder /build/rti_perftest-4.1_ConnextDDS-7.1.0_x64Linux4gcc7.3.0/perftest_qos_profiles.xml /app/perftest_qos_profiles.xml
COPY --from=builder /build/rti_perftest-4.1_ConnextDDS-7.1.0_x64Linux4gcc7.3.0/bin/x64Linux4gcc7.3.0/release/perftest_cpp /app/perftest_cpp

WORKDIR /app

CMD ./perftest_cpp ${perftest_args}
