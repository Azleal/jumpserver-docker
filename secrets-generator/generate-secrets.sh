#!/bin/sh
current_dir=$(cd `dirname $0`; pwd)
cd $current_dir

if [[ -d "secrets" ]] && ( [[ -z $1 ]] || [[ -n $1 ]] && [[ $1 != "-f" ]]); then
    echo "\033[31m CAUTION: secret files already exist! \n \
    use './generate-secrets.sh -f' to force a generation of new secret files. \n \
    which means that existing secret files will be deleted! \033[0m"
    exit 0
fi

rm -rf secrets
docker build -q -t azleal/secrets-generator .  > /dev/null
echo "\033[31m generating secret files... \033[0m"
docker run --rm --name generator -d azleal/secrets-generator > /dev/null
docker cp generator:/root/secrets/ secrets
docker stop generator > /dev/null
echo "\033[31m secret files generated. \033[0m"
