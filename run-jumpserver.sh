#!/bin/sh

current_dir=$(cd `dirname $0`; pwd)
stack_name=jump

cd "$current_dir"
#create secrets configs, which will be used as secrets file in docker-compose later on.
mkdir -p secrets && rm -rf secrets/*
docker stack rm ${stack_name}
./secrets-generator/generate-secrets.sh && cp -r ./secrets-generator/secrets/* ./secrets/
#echo building images...
#docker-compose build
#echo images have been built...
echo deploying jumpserver...
docker stack deploy -c docker-compose.yml --resolve-image always --with-registry-auth ${stack_name}
if [ "$?" == "0" ]; then
    echo jumpserver deployed, visit http://localhost
fi
