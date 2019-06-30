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

status_code=`curl -f -s jumpserver-app:8080 > /dev/null && echo $? || echo 1`
while [ $status_code -ne 0 ]
do
    echo "waiting for jumpserver-app up..."
    sleep 1
    status_code=`curl -f -s jumpserver-app:8080 > /dev/null && echo $? || echo 1`
done
echo "jumpserver-app is up, ready to start guacamole"

/bin/entrypoint.sh