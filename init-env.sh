#!/bin/sh

current_dir=$(cd `dirname $0`; pwd)
cd "$current_dir"
#create secrets configs, which will be used as secrets file in docker-compose later on.
mkdir -p secrets && rm -rf secrets/*
docker stack rm jumpserver
./secrets-generator/generate-secrets.sh && cp -r ./secrets-generator/secrets/* ./secrets/
echo building images...
docker-compose build
echo images have been built...
echo deploying jumpserver...
docker stack deploy -c docker-compose.yml jumpserver
if [ "$?" == "0" ]; then
    echo jumpserver deployed, visit http://managerIP
fi
