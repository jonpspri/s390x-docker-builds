FROM openjdk:9-jre-slim

ARG kafka_version=0.11.0.2
ARG scala_version=2.12

#MAINTAINER wurstmeister
LABEL image_name=wurstmeister-kafka tags=0.11,latest

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    PATH=${PATH}:${KAFKA_HOME}/bin

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash curl jq wget \
 && rm -rf /var/lib/apt/lists/* 

COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh /tmp/

RUN chmod a+x /tmp/*.sh \
 && mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /usr/bin \
 && echo "--- Starting download of kafka_${scala_version}_${kafka_version}" \
 && /tmp/download-kafka.sh \
 && mkdir -p /opt \
 && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
 # A bunch of hacks needed to run with Java 9
 && sed -i.bak -e '/KAFKA_GC_LOG_OPTS=/s/-XX:.PrintGC\(Date\|Time\)Stamps //g' \
               -e '/KAFKA_GC_LOG_OPTS=/s/-XX:.UseGCLogFileRotation //' \
               -e '/KAFKA_GC_LOG_OPTS=/s/-XX:NumberOfGCLogFiles=10 //' \
               -e '/KAFKA_GC_LOG_OPTS=/s/-XX:GCLogFileSize=100M//' \
               -e '/\(nohup\|exec\) [$]JAVA/s/JAVA /JAVA --add-modules java.xml.bind /' \
               /opt/kafka/bin/kafka-run-class.sh \
 && rm /tmp/download-kafka.sh 


VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
