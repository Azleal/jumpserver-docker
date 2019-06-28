FROM jumpserver/jms_coco:1.4.10
MAINTAINER Azleal

RUN yum install -y telnet nc lsof

WORKDIR /opt/coco

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 2222
EXPOSE 5000