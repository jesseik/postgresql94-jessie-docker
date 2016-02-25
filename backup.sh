#!/bin/bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /workdir/passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/grou

source /tmp/environment.sh

while [ 1 ]
do
    sleep $[ ( $RANDOM % 24 )  + 1 ]h
    /usr/lib/postgresql/9.4/bin/pg_dumpall > /volume/postgresql-data/postgresql-dump.sql
    echo "Taking PostgreSQL backup."
done
