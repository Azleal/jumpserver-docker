FROM openresty/openresty:centos
MAINTAINER Azleal
#定义时区参数
ENV TZ=Asia/Shanghai
#设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone
#设置编码
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
#设置环境变量
ENV LC_ALL zh_CN.utf8
#阿里镜像
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && yum clean all && yum makecache


WORKDIR /root


WORKDIR /usr/local/openresty/nginx
COPY ./nginx/conf/nginx.conf ./conf/

WORKDIR /etc/nginx/
RUN rm -rf ./conf.d
COPY ./nginx/conf.d ./conf.d

WORKDIR /root
RUN mkdir nginx
RUN ln -s /etc/nginx/conf.d ./nginx/conf.d
RUN ln -s /usr/local/openresty/nginx/conf ./nginx/conf
RUN ln -s /usr/local/openresty/nginx/logs ./nginx/logs

EXPOSE 80 443




