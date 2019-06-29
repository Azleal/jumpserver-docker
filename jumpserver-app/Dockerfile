FROM registry.fit2cloud.com/public/python:v3
MAINTAINER Azleal

ENV MYSQL_HOST=mysql \
    MYSQL_USER=jumpserver \
    REDIS_HOST=redis

#定义时区参数
ENV TZ=Asia/Shanghai
#设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone
#设置编码
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
#设置环境变量
ENV LC_ALL zh_CN.utf8
ENV LANG=zh_CN.UTF-8

#阿里镜像
#RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
#    && yum clean all && yum makecache

RUN useradd jumpserver && yum install -y git
RUN echo nameserver 8.8.8.8 >> /etc/resolv.conf

WORKDIR /opt

RUN git clone --depth 1 https://github.com/jumpserver/jumpserver.git

WORKDIR /opt/jumpserver

RUN cp -r ./requirements /tmp/requirements

RUN yum -y install epel-release nc

WORKDIR /tmp/requirements

RUN yum -y install $(cat rpm_requirements.txt)
RUN pip install --upgrade pip setuptools && \
    pip install -r requirements.txt
RUN mkdir -p /root/.ssh/ && echo -e "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null" > /root/.ssh/config

WORKDIR /opt/jumpserver

COPY entrypoint.sh /bin/entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/jumpserver/logs

EXPOSE 8080

ENTRYPOINT ["entrypoint.sh"]


