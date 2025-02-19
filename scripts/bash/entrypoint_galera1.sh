#!/bin/bash

# Set MySQL data directory
DATADIR="/var/lib/mysql"

# Ensure correct ownership
chown -R mysql:mysql ${DATADIR}

# Check if MySQL is already initialized
if [ ! -d "$DATADIR/mysql" ]; then
    echo "No existing MariaDB data found. Bootstrapping new cluster..."
    WSREP_CLUSTER_ADDRESS="gcomm://"
    
    # Initialize database system tables if missing
    mariadb-install-db --user=mysql --datadir=${DATADIR}
fi

# Execute MySQL with dynamic cluster address
/usr/sbin/mariadbd \
    --bind-address=0.0.0.0 \
    --datadir=${DATADIR} \
    --user=mysql \
    --server-id=1 \
    --wsrep_cluster_address=${WSREP_CLUSTER_ADDRESS} \
    --wsrep_node_address=172.20.1.11 \
    --wsrep_cluster_name=${WSREP_CLUSTER_NAME} \
    --wsrep_node_name=galera1 \
    --binlog_format=ROW \
    --wsrep_provider=/usr/lib/galera/libgalera_smm.so \
    --wsrep_provider_options="gcache.size=1G" \
    --wsrep_on=ON \
    --wsrep_auto_increment_control=on \
    --wsrep_sst_method=rsync & 

bash /docker-entrypoint-initdb.d/init_galera1_users.sh
bash /docker-entrypoint-initdb.d/init_galera1_db.sh

sleep infinity