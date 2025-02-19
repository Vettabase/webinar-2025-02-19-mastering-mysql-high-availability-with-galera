#!/bin/bash

# Cleanup step
sysbench /usr/local/share/sysbench/oltp_read_write.lua \
    --db-driver=mysql \
    --mysql-host="${MYSQL_HOST_GALERA2}" --mysql-port="${MYSQL_PORT_GALERA}" --mysql-user="${MYSQL_USER}" --mysql-password="${MYSQL_PASSWORD}" --mysql-db="${MYSQL_DB}" \
    --time=10 --threads=16 --report-interval=1 --tables=5 --table-size=1000000 \
    cleanup

# Prepare step
sysbench /usr/local/share/sysbench/oltp_read_write.lua \
    --db-driver=mysql \
    --mysql-host="${MYSQL_HOST_GALERA2}" --mysql-port="${MYSQL_PORT_GALERA}" --mysql-user="${MYSQL_USER}" --mysql-password="${MYSQL_PASSWORD}" --mysql-db="${MYSQL_DB}" \
    --time=10 --threads=16 --report-interval=1 --tables=5 --table-size=1000000 \
    prepare