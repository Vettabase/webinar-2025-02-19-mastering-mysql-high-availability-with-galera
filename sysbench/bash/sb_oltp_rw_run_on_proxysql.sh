#!/bin/bash

sysbench /usr/local/share/sysbench/oltp_read_write.lua \
    --db-driver=mysql \
    --mysql-host="${MYSQL_HOST_PROXYSQL}" --mysql-port="${MYSQL_PORT_PROXYSQL}" --mysql-user="${MYSQL_USER}" --mysql-password="${MYSQL_PASSWORD}" --mysql-db="${MYSQL_DB}" \
    --mysql-ignore-errors=all \
    --time=10 --threads=16 --report-interval=1 --tables=5 --table-size=1000000 \
    run