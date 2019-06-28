#!/bin/bash

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
#		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
#		exit 1
        unset "$var"
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

file_env 'BOOTSTRAP_TOKEN'


if [ ! -f "/opt/coco/config.yml" ]; then
    cp /opt/coco/config_example.yml /opt/coco/config.yml
    sed -i '5d' /opt/coco/config.yml
    sed -i "5i CORE_HOST: $CORE_HOST" /opt/coco/config.yml
    sed -i "s/BOOTSTRAP_TOKEN: <PleasgeChangeSameWithJumpserver>/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/coco/config.yml
    sed -i "s/# LOG_LEVEL: INFO/LOG_LEVEL: ERROR/g" /opt/coco/config.yml
fi

status_code=`curl -f -s jumpserver-app:8080 > /dev/null && echo $? || echo 1`
while [ $status_code -ne 0 ]
do
    echo "waiting for jumpserver-app up..."
    sleep 1
    status_code=`curl -f -s jumpserver-app:8080 > /dev/null && echo $? || echo 1`
done
echo "jumpserver-app is up, ready to start coco"

source /opt/py3/bin/activate
cd /opt/coco && ./cocod start -d
tail -f /opt/readme.txt