## jumpserver swarm
> [jumpserver](http://www.jumpserver.org/)的docker封装及swarm部署.\
> 官方文档参考: [这里](https://jumpserver.readthedocs.io/zh/master/). \
> github项目: 点击[这里](https://github.com/jumpserver/jumpserver)

### 项目结构:
.
├── README.md
├── backup.sh   # 获取secret, mysql的备份文件. redis需要手动获取.
├── docker-compose.yml 
├── jumpserver-app  # (jumpserver-app)[https://github.com/jumpserver/jumpserver]
├── jumpserver-coco # (jumpserver-coco)[https://github.com/jumpserver/coco]
├── jumpserver-guacamole #(jumpserver-guacamole)[https://github.com/jumpserver/docker-guacamole]
├── migration   # 用来迁移的文件夹,
├── mysql       # mysql service
├── openresty   # openresty service
├── redis       # redis service
├── resore.sh   # 恢复服务 //TODO
├── run-jumpserver.sh   # 运行服务 
├── secrets     # secret, token, mysql密码等 
└── secrets-generator   #  secret, token, mysql密码等生成器

---
### 使用说明:
#### 环境要求:
* Docker version 18.09.2+
* docker-compose version 1.23.2+
* 因部分命令或脚本在mac或者windows下不能正常使用,**因此目前该项目只能在linux环境下使用**, 后续会兼容mac和windows
---
#### 准备工作
该项目实现了在满足环境条件的前提下一键部署. 因此需要先准备出满足条件的环境: 
* docker swarm环境搭建参考[这里](https://docs.docker.com/engine/swarm/)
    * 因数据库和redis需要数据持久化, 所以需要在固定的某个node运行service.通过添加给node添加label实现:
        * 在manager上执行(下同)`docker node ls`, 以确定需要部署
        * 确定<i><b>`nodeID1`</b></i>为mysql运行节点. `docker node update --label-add mysql=true `<i><b>`nodeID1`</b></i>.  
        * 确定<i><b>`nodeID2`</b></i>为redis运行节点. `docker node update --label-add redis=true `<i><b>`nodeID2`</b></i>.
        * <i><b>`nodeID1`</b></i>与<i><b>`nodeID2`</b></i>可以为同一节点
     * 以上步骤必须手动完成,否则应用无法启动
---
#### 配置及约定
//TODO


---
#### 使用方法
1. 新建系统
    1. 执行`./run-jumpserver.sh`, 主要的步骤有:
        1. 生成secrets文件, 包括bootstrap_token,secret_key及数据库密码等.
        2. 构建image[可选,默认不构建,从dockerhub拉取]
        3. 运行服务
    2. 可重复执行
2. 部分组件不是docker:
比如mysql用的是rds, 那么需要在`docker-compose.yml`中注释mysql服务,并在`jumpserver-app`服务中增加环境变量以修改默认的mysql地址. redis同理.
    

##### 迁移系统

###### 备份
数据备份位置: `migration/backup`
对于docker运行的服务使用一下方法进行数据备份:
1. 执行`./backup.sh`进行secrets和mysql数据的备份
2. 执行`docker stack ps jump`确定redis节点
3. 在redis节点上执行`docker ps`确定redis的`containerID`
4. 执行`docker cp containerID:/data/appendonly.aof . && tar czf appendonly.aof.tar.gz appendonly.aof`,其中`containerID`为第三步中获取到的redis容器ID.
5. 将得到的`appendonly.aof.tar.gz`文件置于manager节点的`migration/backup/data/redis`之下

如果你的mysql和redis是外部服务,则使用`mysqldump`命令导出数据; redis则需要开启`appendonly`, 并在配置文件指定的位置获取`appendonly.aof`文件

###### 恢复
恢复操作会覆盖所有之前的所有数据,**慎用**.
1. 停止系统,`docker stack rm jump`
2. 丢弃原数据,`docker volume rm jump_mysql_data_volume`
3. 修改`secrets/secret_key`为mysql数据来源系统的`secret_key`[**重要**],没有这个key, mysql中的数据加密数据无法解密.
4. 将导出的sql文件,放在`mysql/initdb.d/`下
5. `docker volume inspect jump_redis_data_volume`得到volume的挂载点
6. 将`appendonly.aof`置于第5步得到的挂载点下
7. `./run-jumpserver.sh`


---
### TODOS:
1. 恢复系统时,原系统和新系统的jumpserver-app版本需要一致,否则会出现新旧版本不兼容(缺表)导致运行异常. 后续会按照官方版本维护镜像.
2. 添加`luna`插件