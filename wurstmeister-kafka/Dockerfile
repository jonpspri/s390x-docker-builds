FROM s390x/ubuntu:rolling
#FROM anapsix/alpine-java

ARG kafka_version=0.11.0.2
ARG scala_version=2.12

#MAINTAINER wurstmeister
LABEL image_name=wurstmeister-kafka tags=0.11,latest

#RUN apk add --update unzip wget curl docker jq coreutils
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
	curl \
	docker.io \
	jq \
	net-tools \
	openjdk-9-jre-headless \
 	unzip \
	wget \
 && rm -rf /var/lib/apt/lists/*

ENV KAFKA_VERSION=$kafka_version SCALA_VERSION=$scala_version
ADD download-kafka.sh /tmp/download-kafka.sh
RUN chmod a+x /tmp/download-kafka.sh && sync && /tmp/download-kafka.sh \
 && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka 

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin

#  This is here to turn of Garbage Collector logging, which messes with OpenJDK's mind
ENV EXTRA_ARGS -name kafkaServer

#  In OpenJDK 9 onward, it's necessary to explicitly include the java.xml.bind module
ENV KAFKA_OPTS --add-modules java.xml.bind

ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD create-topics.sh /usr/bin/create-topics.sh
# The scripts need to have executable permission
RUN chmod a+x /usr/bin/start-kafka.sh && \
    chmod a+x /usr/bin/broker-list.sh && \
    chmod a+x /usr/bin/create-topics.sh
# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
