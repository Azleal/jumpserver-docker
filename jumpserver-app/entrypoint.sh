#!/bin/sh
set -eo pipefail
shopt -s nullglob


# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
# possible secrets variables are:
# SECRET_KEY, BOOTSTRAP_TOKEN, MYSQL_USER, MYSQL_PASSWORD, REDIS_PASSWORD
file_env() {
    echo inside file env: $1
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
        echo inside file env, var: $val
	elif [ "${!fileVar:-}" ]; then
		val="$(cat "${!fileVar}")"
		echo inside file env, var: $val
	fi
	export "$var"="$val"
	unset "$fileVar"
}

#wait for mysql and redis to ready so that this application could run properly.
#generally, it takes a very short time to have the underlying mysql and redis ready,
#but for a newly setup system, it would take a little bit longer.
wait_for_dbs(){
    echo 'start to waiting for mysql getting ready...'
    local status_code=`nc -w 1 mysql 3306 > /dev/null && echo $? || echo 1`
    while [ $status_code -ne 0 ]
    do
        echo "waiting for mysql getting ready..."
        sleep 1
        status_code=`nc -w 1 mysql 3306 > /dev/null && echo $? || echo 1`
    done
    echo 'mysql is up....'

    echo 'start to waiting for redis getting ready....'
    status_code=`nc -w 1 redis 6379 > /dev/null && echo $? || echo 1`
    while [ $status_code -ne 0 ]
    do
        echo "waiting for redis getting ready..."
        sleep 1
        status_code=`nc -w 1 redis 6379 > /dev/null && echo $? || echo 1`
    done
    echo 'redis is up....'

    echo "mysql and redis are up, ready to start jumpserver-app.."

}

file_env 'SECRET_KEY'
file_env 'BOOTSTRAP_TOKEN'
file_env 'MYSQL_USER'
file_env 'MYSQL_PASSWORD'
#file_env 'REDIS_PASSWORD'

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    cp /opt/jumpserver/config_example.yml /opt/jumpserver/config.yml
    sed -i "s#SECRET_KEY:#SECRET_KEY: $SECRET_KEY#g" /opt/jumpserver/config.yml
    sed -i "s#BOOTSTRAP_TOKEN:#BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN#g" /opt/jumpserver/config.yml
    sed -i "s#DB_HOST: 127.0.0.1#DB_HOST: $MYSQL_HOST#g" /opt/jumpserver/config.yml
    sed -i "s#DB_USER: jumpserver#DB_USER: $MYSQL_USER#g" /opt/jumpserver/config.yml
    sed -i "s#DB_PASSWORD:#DB_PASSWORD: $MYSQL_PASSWORD#g" /opt/jumpserver/config.yml
    sed -i "s#REDIS_HOST: 127.0.0.1#REDIS_HOST: $REDIS_HOST#g" /opt/jumpserver/config.yml
#    sed -i "s/# REDIS_PASSWORD: /REDIS_PASSWORD: $REDIS_PASSWORD/g" /opt/jumpserver/config.yml
    sed -i "s/# LOG_LEVEL: INFO/LOG_LEVEL: ERROR/g" /opt/jumpserver/config.yml
fi

wait_for_dbs

cd /opt/jumpserver && ./jms start all
