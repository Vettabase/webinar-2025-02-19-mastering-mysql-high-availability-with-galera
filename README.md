# Description


This repositories contains example for the webinar "Mastering MySQL High Availability with Galera", by Mike Rykmas, 2025/02/19.

We're making the examples publicly available not just as helper material for the webinar, but also for future reference. Even if you didn't attend the webinar, hopefully you'll find some useful examples and explanations here.

# Create custom sysbench image based on newer version of Sysbench

- Version: 1.1.0 (with custom tests, forcing deadlocks)

```
docker build -t custom-sysbench:1.1.0 -f sysbench/Dockerfile sysbench/
```

# (Re)-Build Stack

## Clean up
```
docker-compose down --remove-orphans
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

# Hosts Example

```
$ galera1 -e "select @@hostname;"
+------------+
| @@hostname |
+------------+
| galera1  |
+------------+
```

# Sysbench Tests (simulate deadlock):

```bash
docker exec -it sysbench bash
```

## Galera2 - Direct Write

### Test 1

- Run test 

```bash
./sb_prepare.sh
./sb_run_on_galera2.sh
```

- Statistics

```bash
SQL statistics:
    queries performed:
        read:                            10194
        write:                           8406
        other:                           8459
        total:                           27059
    transactions:                        203    (4.38 per sec.)
    queries:                             27059  (583.29 per sec.)
    ignored errors:                      3747   (80.77 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      4.3759
    time elapsed:                        46.3905s
    total number of events:              203

Latency (ms):
         min:                                 1172.38
         avg:                                26281.32
         max:                                46388.64
         95th percentile:                    46103.52
         sum:                              5335108.40

Threads fairness:
    events (avg/stddev):           1.5859/0.70
    execution time (avg/stddev):   41.6805/5.09
```

- Deadlocks

```bash
- Galera1: 0
- Galera2: 1604
- Galera3: 0
```

# High Availability

## Stop/Start any node

- Galera 1

```bash
docker compose down galera1 && rm -rf volumes/galera1
docker compose up -d galera1
```

- Galera 2

```bash
docker compose down galera2 && rm -rf volumes/galera2
docker compose up -d galera2
```

- Galera 3

```bash
docker compose down galera3 && rm -rf volumes/galera3
docker compose up -d galera3
```

## HAProxy

```bash
while true; do haproxy_sql --execute "select now(), concat('Current hostname: ', @@hostname)" | tail -1; sleep 2; done
```

## ProxySQL

- Write connection

```bash
while true; do proxysql_write --execute "SELECT now(), concat('Writer: ', @@hostname)" 2>/dev/null | tail -1; sleep 2; done
```

- Read connection

```bash
while true; do proxysql_read --execute "USE mysql; SELECT now(), concat('Reader: ', @@hostname)" 2>/dev/null | tail -1; sleep 2; done
```