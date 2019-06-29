## jumpserver swarm
> [jumpserver](http://www.jumpserver.org/)的docker封装及swarm部署.\
> 官方文档参考: [这里](https://jumpserver.readthedocs.io/zh/master/). \
> github项目: 点击[这里](https://github.com/jumpserver/jumpserver)

### 项目结构:

---
### 使用说明:
#### 环境要求:
* Docker version 18.09.2+
* docker-compose version 1.23.2+
* 目前只有linux环境下运行的初始化脚本
---
#### 准备工作
该项目实现了在满足环境条件的前提下一键部署. 因此需要先准备出满足条件的环境: 
* docker swarm环境搭建参考[这里](https://docs.docker.com/engine/swarm/)
    * 因数据库和redis需要数据持久化, 所以需要在固定的某个node运行service.通过添加给node添加label实现:
        * 在manager上执行(下同)`docker node ls`, 以确定需要部署
        * 确定<i><b>`nodeID1`</b></i>为mysql运行节点. `docker node update --label-add mysql=true `<i><b>`nodeID1`</b></i>.  
        * 确定<i><b>`nodeID2`</b></i>为redis运行节点. `docker node update --label-add redis=ture `<i><b>`nodeID2`</b></i>.
        * <i><b>`nodeID1`</b></i>与<i><b>`nodeID2`</b></i>可以为同一节点
     * 以上步骤必须手动完成,否则应用无法启动
---
#### 配置及约定



---
#### 使用方法
1. 新建系统
    1. 执行`./init-env.sh`, 主要的步骤有:
        1. 生成secrets文件, 包括bootstrap_token,secret_key及数据库密码等.
        2. 构建image
        3. 运行服务
    
2. 

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


---
