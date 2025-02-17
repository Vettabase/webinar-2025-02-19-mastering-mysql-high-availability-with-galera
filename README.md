# Description

This repositories contains example for the webinar "Mastering MySQL High Availability with Galera", by Mike Rykmas, 2025/02/19.

We're making the examples publicly available not just as helper material for the webinar, but also for future reference. Even if you didn't attend the webinar, hopefully you'll find some useful examples and explanations here.

# Create custom sysbench image

- Version: 1.1.0 (with SSL support)

```
cd sysbench
docker build -t custom-sysbench:1.1.0 .
```

# (Re)-Build Stack

## Clean up
```
docker-compose down --remove-orphans
rm -rf volumes/
```

## Build
```
docker-compose up -d
```

# Apply aliases

The aliases helping you to simplify access to the current stack. 

```
source config/bash_aliases
```

# Stack Info

## Galera Cluster

- Hostname: galera1
  - Docker IP: 172.20.1.11
  - Docker Image: mariadb:11.4
  - Role: Primary Galera node
  - Port: 0.0.0.0:3301->3306/tcp
  - DB Credentials: root/root
- Hostname: galera2
  - Docker IP: 172.20.1.12
  - Docker Image: mariadb:11.4
  - Role: Galera replica node
  - Port: 0.0.0.0:3302->3306/tcp
  - DB Credentials: root/root
- Hostname: galera3
  - Docker IP: 172.20.1.13
  - Docker Image: mariadb:11.4
  - Role: Galera replica node
  - Port: 0.0.0.0:3303->3306/tcp
  - DB Credentials: root/root

## Load Balancers

### HAProxy
  - Hostname: haproxy
  - Docker IP: 172.20.1.14
  - Docker Image: haproxy:2.8
  - Role: HAProxy load balancer for Galera
  - Ports:
    - Admin Interface: 0.0.0.0:3310->8080/tcp
    - SQL Proxy: 0.0.0.0:3311->3307/tcp

### ProxySQL
  - Hostname: proxysql
  - Docker IP: 172.20.1.15
  - Docker Image: proxysql/proxysql:2.5
  - Role: Query router for Galera
  - Ports:
    - Admin Interface: 0.0.0.0:3320->6032/tcp
    - Write Hostgroup (10): 0.0.0.0:3321->6033/tcp
    - Read Hostgroup (20): 0.0.0.0:3322->6033/tcp

## Benchmarking

### Sysbench
  - Hostname: sysbench
  - Docker IP: 172.20.1.16
  - Docker Image: custom-sysbench:1.1.0
  - Role: Sysbench host (for benchmarks)

# Usage Example

```
$ galera1 -e "select @@hostname;"
+------------+
| @@hostname |
+------------+
| galera1  |
+------------+
```