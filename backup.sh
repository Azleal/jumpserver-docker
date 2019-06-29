#!/bin/sh

stack_name=jump
current_dir=$(cd `dirname $0`; pwd)


cd "$current_dir"
mkdir -p migration/backup/data/mysql migration/backup/data/redis migration/backup/secrets
echo backing up secrets...
cp -f secrets/* migration/backup/secrets/
echo secrets backed up

echo backing up mysql data...
cd "$current_dir/migration/backup/data/mysql"
docker run --rm --network jump_jumpserver-network -it mysql:5.7 mysqldump -h mysql \
    -u $(cat "$current_dir/migration/backup/secrets/mysql_user") -p$(cat "$current_dir/migration/backup/secrets/mysql_password") \
    jumpserver > jumpserver.sql
tar czf jumpserver.sql.tar.gz jumpserver.sql && rm -f jumpserver.sql
echo mysql data backed up
