# es-on-k8s-docs
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

### 2 自构建镜像
 未完成  
#### 2.1 角色混合方式
 
#### 2.2 专有master  


#### 2.3 专有master与协调节点  


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
