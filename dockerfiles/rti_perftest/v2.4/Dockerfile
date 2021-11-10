# Build command:
# $ docker build -t rti-perftest:v2.4 .

# Run command:
# $ docker run -tdi -e "perftest_args=-pub -domain 10" rti-perftest:v2.4

FROM ubuntu:18.04 as builder

RUN apt-get update \
    && apt-get install -y wget

RUN mkdir /build && cd /build \
    && wget https://github.com/rticommunity/rtiperftest/releases/download/2.4/rti_perftest-2.4_x64Linux.tar.gz \
    && tar xvfz rti_perftest-2.4_x64Linux.tar.gz

WORKDIR /build

FROM ubuntu:18.04

ENV perftest_args=

COPY --from=builder /build/rti_perftest-2.4_x64Linux3gcc4.8.2/perftest_qos_profiles.xml /app/perftest_qos_profiles.xml
COPY --from=builder /build/rti_perftest-2.4_x64Linux3gcc4.8.2/bin/x64Linux3gcc4.8.2/release/perftest_cpp /app/perftest_cpp

WORKDIR /app

CMD ./perftest_cpp ${perftest_args}
