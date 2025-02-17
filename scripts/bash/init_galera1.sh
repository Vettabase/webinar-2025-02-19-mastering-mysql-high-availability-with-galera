#!/bin/bash
set -e

echo "Initializing Galera Cluster on galera1..."

# Wait for MariaDB to be ready
until mariadb-admin --defaults-file=/etc/.my.cnf --silent ping; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done

echo "Loading Sakila database..."
mariadb --defaults-file=/etc/.my.cnf < /tmp/sql/sakila-schema.sql
mariadb --defaults-file=/etc/.my.cnf < /tmp/sql/sakila-data.sql

echo "Galera1 initialization complete."