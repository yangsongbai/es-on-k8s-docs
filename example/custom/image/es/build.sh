#!/bin/bash
set -e
echo "docker build param ${es_version} , ${runtime_arch}"

version=(${es_version//\./})
echo $version

## 构建es存在目录
mkdir -p  /usr/share/elasticsearch


if [[ ${runtime_arch} == "aarch64" ]]; then
    tar -zvxf /tmp/elasticsearch-${es_version}-linux-${runtime_arch}.tar.gz --strip-component=1 -C /usr/share/elasticsearch
    rm /tmp/elasticsearch-${es_version}-linux-${runtime_arch}.tar.gz
    exit 0
fi

tar -zvxf /tmp/elasticsearch-${es_version}.tar.gz --strip-component=1 -C /usr/share/elasticsearch