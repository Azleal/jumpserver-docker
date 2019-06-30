FROM jumpserver/jms_guacamole:1.5.0
MAINTAINER Azleal

ENV JUMPSERVER_KEY_DIR=/config/guacamole/key \
    JUMPSERVER_SERVER=http://jumpserver-app:8080

RUN apt-get update && apt-get install -y curl


WORKDIR /root
COPY entrypoint.sh .

EXPOSE 8081

ENTRYPOINT ["./entrypoint.sh"]