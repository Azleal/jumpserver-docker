#!/bin/sh

stack_name=jump
current_dir=$(cd `dirname $0`; pwd)
migration_base="$current_dir/migration"

echo "restore data will discard existing data, which means all the existing mysql data and redis data \
will be removed and then import new data. And during restoration procedure, the services will be destroyed and rebuilt."
read -p "are you sure to proceed?[y/n]:" confirmation

case ${confirmation} in
        [yY]*)
                echo "proceeding to retore data."
                ;;
        *)
                exit
                ;;
esac
echo "stopping services..."
docker stack rm ${stack_name} && sleep 8
echo "services stopped"

if [ -f "$migration_base/restore/data/mysql/*.gz" ]; then
    docker volume rm -f ${stack_name}_mysql_data_volume
    cp -f "${migration_base}/restore/data/mysql/*.gz" "${current_dir}/mysql/initdb.d/"
fi

if [ -f "$migration_base/restore/data/mysql/*.gz" ]; then
    docker volume rm -f ${stack_name}_mysql_data_volume
    cp -f "${migration_base}/restore/data/mysql/*.gz" "${current_dir}/mysql/initdb.d/"
fi



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
