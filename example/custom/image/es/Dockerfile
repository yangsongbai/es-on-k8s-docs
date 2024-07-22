ARG runtime_image=/centos:7-se2

FROM $runtime_image as builder

ARG runtime_arch="x86_64"
ARG es_version=7.14.2
ENV es_version ${es_version}

RUN yum clean all
RUN rm -rf /var/cache/yum/*
RUN yum makecache

## 基于不同 操作系统
RUN yum -y install wget

WORKDIR /usr/share/elasticsearch


COPY image/es/build.sh  build.sh

RUN ./build.sh && \
    rm -rf build.sh

FROM $runtime_image

WORKDIR /usr/share/elasticsearch

RUN groupadd -r elasticsearch -g 1010 && \
    useradd -u 1010 -r -g elasticsearch -d /usr/share/elasticsearch  -s /sbin/nologin -c "elasticsearch user" elasticsearch && \
    chown -R elasticsearch /usr/share/elasticsearch && \
#    chmod 755 /usr/share/elasticsearch && \
    usermod -s /bin/bash elasticsearch && \
    usermod -a -G root elasticsearch
USER elasticsearch:root
#
ENV JAVA_HOME /usr/share/elasticsearch/jdk
ENV PATH $PATH:/usr/share/elasticsearch/jdk/bin:/usr/share/elasticsearch/bin
COPY --from=builder /usr/share/elasticsearch/ /usr/share/elasticsearch/