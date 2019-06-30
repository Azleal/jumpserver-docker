FROM alpine:3.7
MAINTAINER Azleal

WORKDIR /root/secrets

RUN cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 49 > secret_key \
    && cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 > bootstrap_token \
    && cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 > mysql_root_password \
    && echo jumpserver > mysql_user \
#    && cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 > redis_password \
    && cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 > mysql_password

ENTRYPOINT ["ping", "127.0.0.1"]