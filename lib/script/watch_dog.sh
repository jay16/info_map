#!/bin/bash

ENVIRONMENT=$1
APP_ROOT_PATH=$2
POOL_WAIT_PATH=$3

# stop process id
echo $$ > ${APP_ROOT_PATH}/tmp/pids/watch_dog.pid
while true
do
    if test -f ${APP_ROOT_PATH}/tmp/crontab.wait
    then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): be forced to skip."
    else
        if [[ $(ls ${POOL_WAIT_PATH} | wc -l) -eq 0 ]];
        then
            echo "$(date '+%Y-%m-%d %H:%M:%S'): idleness."
        else
            /bin/sh ${APP_ROOT_PATH}/lib/script/rake.sh ${APP_ROOT_PATH} ${ENVIRONMENT}
        fi
    fi
    sleep 5
done
