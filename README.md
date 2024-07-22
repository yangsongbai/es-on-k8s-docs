# es-on-k8s-docs
**文档内容仅供参考**       

## 部署
### 1 原生镜像
```
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.14.2
```

#### 角色混合方式   
项目目录 example/origin/mix

* 方式一：
可以进入到 `example/origin/mix`目录，按照业务需求修改values.yaml中的配置，回退一个目录，   
 然后执行如下命令进行渲染，其中es-namespace表示部署资源所在的命令空间。
```
helm template cluster-release-name ./mix -n my-es-namespace > es-release.yaml
```
然后将生成的资源，部署到k8s中    
```
kubectl apply -f es-release.yaml     
```

# 故障处理     
## 单节点故障     
Q1: **物理机器故障如何迁移？**      
A1: pod所在物理机故障,查看集群是否green 
```
GET  _cluster/health?pretty
```
如果集群是green状态，重建故障pod，使其重新分配即可
**第一步：**     
查看有问题的pod，被分配在哪一个节点
```
kubectl get pod es-xxxx-nodes-2  -o wide -n my-es-namespace
```
**第二步：**    
禁止调度到当前节点
```
# NODE_NAME 为第一步获取得到的节点名称
kubectl cordon NODE_NAME
```

**第三步**   
删除对应pod,重新调度到其他机器上       
```
kubectl delete pod es-xxxx-nodes-2  -n my-es-namespace     
```
如果需要的话，可能需要对属主机，进行`kubectl uncordon NODE`,恢复pod可以调度到该节点上，比如属主机修复好了。     

# 扩容 
## 水平扩容   
在k8s中执行命令，或者当前的集群sts值
```
kubectl get sts es-sxsecs-node  -o yaml  -n  my-es-namespace > es-sxsecs-node.yaml
```
修改其中spec下的`replicas字段的值`，比如从3节点扩容到5节点，replicas的值修改成5即可；   
然后执行如下命令完成水平扩容     
```
kubectl apply -f es-sxsecs-node.yaml -n  my-es-namespace
```


## 垂直扩容
**⚠注意️**： 保证所有索引都有副本，且盘支持垂直扩容，不会抹除数据;不建议垂直扩容，因为当前不会判断，集群是否green,再进行下一个节点变配，变配会有一定风险，集群可能会处于red状态写入失败，查询失败或者数据不全    

在k8s中执行命令，或者当前的集群sts值
```
kubectl get sts es-sxsecs-node  -o yaml  -n  my-es-namespace > es-sxsecs-node.yaml
```
修改其中volumeClaimTemplates下的`storage字段的值`，比如从节点20Gi扩容到100Gi，storage的值修改成100Gi即可；   
然后执行如下命令完成水平扩容
```
kubectl apply -f es-sxsecs-node.yaml -n  my-es-namespace
```

*注意*⚠️：PodDisruptionBudget资源控制；设置 maxUnavailable 为 1，表示在维护期间最多只允许一个 Pod 离线  


# 参考 
[1] https://www.elastic.co/cn/blog/alpha-helm-charts-for-elasticsearch-kibana-and-cncf-membership    
[2] https://www.elastic.co/guide/en/elasticsearch/reference/7.14/docker.html    
[3] https://github.com/elastic/helm-charts/tree/7.14/elasticsearch       
[4] [Elasticsearch：基于文件的用户认证](https://elasticstack.blog.csdn.net/article/details/128341242)    
[5] [Elastic：为 Elasticsearch 启动 HTTPS 访问](https://elasticstack.blog.csdn.net/article/details/105044365)     
[6] [Elasticsearch：配置 TLS/SSL 和 PKI 身份验证](https://elasticstack.blog.csdn.net/article/details/120568128)    
[7] [Elasticsearch：使用 elasticsearch-keystore 配置安全并创建内置用户账号](https://elasticstack.blog.csdn.net/article/details/113172420)     
[8] [Elasticsearch：使用 docker compose 来实现热温冷架构的 Elasticsearch 集群](https://elasticstack.blog.csdn.net/article/details/127896705)    
[9] [Elasticsearch：使用 Docker compose 来一键部署 Elastic Stack 8.x](https://elasticstack.blog.csdn.net/article/details/123958356)    
[10] [ElasticSearch 8.12.0 K8S部署实践【超详细】【一站式】](https://blog.csdn.net/windywolf301/article/details/136227389)


```
# 步骤1: 生成私钥和CSR
openssl genrsa -out elasticsearch.key 2048
openssl req -new -key elasticsearch.key -out elasticsearch.csr -subj "/CN=elasticsearch-cluster/O=elasticsearch"
 
# 步骤2: 使用CA签名证书
openssl x509 -req -in elasticsearch.csr -signkey elasticsearch.key -out elasticsearch.crt -days 36500
 
# 步骤3: 创建Kubernetes secret
kubectl create secret tls elasticsearch-tls --cert=elasticsearch.crt --key=elasticsearch.key
 
# 步骤4: 在Elasticsearch部署中引用Kubernetes secret
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
spec:
  ...
  template:
    spec:
      containers:
      - name: elasticsearch
        ...
        volumeMounts:
        - name: elasticsearch-certs
          mountPath: /usr/share/elasticsearch/config/certs
      volumes:
      - name: elasticsearch-certs
        secret:
          secretName: elasticsearch-tls
 
# 步骤5: 配置Elasticsearch以使用TLS证书和私钥
...
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elasticsearch.crt
xpack.security.transport.ssl.keystore.password: <your_keystore_password>
xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elasticsearch.crt
...
```