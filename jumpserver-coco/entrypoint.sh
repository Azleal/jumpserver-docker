#!/bin/bash
#

localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

if [ ! -f "/opt/coco/config.yml" ]; then
    cp /opt/coco/config_example.yml /opt/coco/config.yml
    sed -i '5d' /opt/coco/config.yml
    sed -i "5i CORE_HOST: $CORE_HOST" /opt/coco/config.yml
    sed -i "s/BOOTSTRAP_TOKEN: <PleasgeChangeSameWithJumpserver>/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/coco/config.yml
    sed -i "s/# LOG_LEVEL: INFO/LOG_LEVEL: ERROR/g" /opt/coco/config.yml
fi

status_code=`curl -f -s 172.17.0.1:81 > /dev/null && echo $? || echo 1`
while [ $status_code -ne 0 ]
do
    echo "waiting for jumpserver_app up..."
    sleep 1
    status_code=`curl -f -s 172.17.0.1:81 > /dev/null && echo $? || echo 1`
done
echo "jumpserver_app is up, ready to start coco"

source /opt/py3/bin/activate
cd /opt/coco && ./cocod start -d
tail -f /opt/readme.txt