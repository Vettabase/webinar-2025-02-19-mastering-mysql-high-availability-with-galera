#!/bin/bash

sysbench /usr/local/share/sysbench/tpcc.lua \
    --db-driver=mysql \
    --mysql-host="${MYSQL_HOST_HAPROXY}" --mysql-port="${MYSQL_PORT_HAPROXY}" --mysql-user="${MYSQL_USER}" --mysql-password="${MYSQL_PASSWORD}" --mysql-db="${MYSQL_DB}" \
    --mysql-ignore-errors=all \
    --use_fk=1 \
    --time=10 --threads=16 --report-interval=1 --tables=1 --scale=1 \
    run