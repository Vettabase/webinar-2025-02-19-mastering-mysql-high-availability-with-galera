#!/bin/bash
set -e

echo "Initializing Users..."

# Wait for MariaDB to be ready
until mariadb-admin --defaults-file=/etc/.my.cnf --silent ping; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done

mariadb --defaults-file=/etc/.my.cnf < /tmp/sql/monitoring-users.sql

echo "Users initialization complete."