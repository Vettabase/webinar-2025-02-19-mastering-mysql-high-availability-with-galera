#!/bin/bash

# Cleanup step
sysbench /usr/local/share/sysbench/tpcc.lua \
    --db-driver=mysql \
    --mysql-host="${MYSQL_HOST_GALERA2}" --mysql-port="${MYSQL_PORT_GALERA}" --mysql-user="${MYSQL_USER}" --mysql-password="${MYSQL_PASSWORD}" --mysql-db="${MYSQL_DB}" \
    --use_fk=1 \
    --time=10 --threads=16 --report-interval=1 --tables=1 --scale=1 \
    cleanup

# Prepare step
sysbench /usr/local/share/sysbench/tpcc.lua \
    --db-driver=mysql \
    --mysql-host="${MYSQL_HOST_GALERA2}" --mysql-port="${MYSQL_PORT_GALERA}" --mysql-user="${MYSQL_USER}" --mysql-password="${MYSQL_PASSWORD}" --mysql-db="${MYSQL_DB}" \
    --use_fk=1 \
    --time=10 --threads=16 --report-interval=1 --tables=1 --scale=1 \
    prepare