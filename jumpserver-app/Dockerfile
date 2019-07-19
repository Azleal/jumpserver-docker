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

RUN useradd jumpserver && yum install -y git epel-release nc
RUN echo nameserver 8.8.8.8 >> /etc/resolv.conf

WORKDIR /opt

#默认分支
ARG APP_VERSION=master

RUN echo arg app version: ${APP_VERSION} && git clone https://github.com/jumpserver/jumpserver.git \
    && cd jumpserver \
    && if [[ "${APP_VERSION}" != "master" ]]; then \
        echo checking out to ${APP_VERSION} \
        && git checkout tags/${APP_VERSION} -b ${APP_VERSION}; \
       fi

WORKDIR /opt/jumpserver

RUN cp -r ./requirements /tmp/requirements

WORKDIR /tmp/requirements

RUN mkdir -p ~/.pip && echo [global] > ~/.pip/pip.conf \
    && echo trusted-host =  mirrors.aliyun.com >> ~/.pip/pip.conf \
    && echo index-url = https://mirrors.aliyun.com/pypi/simple >> ~/.pip/pip.conf

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


