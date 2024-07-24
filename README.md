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

## 水平缩容
注意⚠️： 缩容个数一次性不能超过一半；[ElasticSearch集群灾难：别放弃，也许能再抢救一下](https://www.51cto.com/article/785498.html)   
将要缩容的节点上的数据排除走,建议使用节点名称，作为排除参数，因为容器ip会发生变化；sts缩容只能从前往后缩容（pod编号从大到小），    
不能指定特定节点缩容掉； 如果有`es-sxsecs-node-0，es-sxsecs-node-1,es-sxsecs-node-2` 三个节点要缩容掉一个，则排除数据命令如下；
```
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.exclude._name" : "es-sxsecs-node-2"
  }
}
```
等待数据排除完成，查看节点上数据有数据,如果没有数据则可以进行缩容个数 
```
GET _cat/allocation?v
```

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
1 更新每个节点对应的pvc大小       
2 删除sts,但不级联删除pod      
```
kubectl delete sts <sts-name> --cascade=false  
```
3 修改sts模版中的磁盘大小，重新apply 创建sts    

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
