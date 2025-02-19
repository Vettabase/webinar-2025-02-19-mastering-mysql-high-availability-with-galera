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

- Run test 

```bash
./sb_tpcc_prepare.sh
./sb_tpcc_run_on_galera2.sh
./sb_tpcc_run_on_haproxy.sh
```

## Galera2 - Direct Write

### CASE 1

```bash
SQL statistics:
    queries performed:
        read:                            5767
        write:                           5937
        other:                           1429
        total:                           13133
    transactions:                        382    (23.98 per sec.)
    queries:                             13133  (824.50 per sec.)
    ignored errors:                      189    (11.87 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      23.9824
    time elapsed:                        15.9284s
    total number of events:              382

Latency (ms):
         min:                                    3.08
         avg:                                  664.66
         max:                                 4741.92
         95th percentile:                     1803.47
         sum:                               253899.09

Threads fairness:
    events (avg/stddev):           23.8750/3.79
    execution time (avg/stddev):   15.8687/0.04
    
SHOW GLOBAL STATUS LIKE 'Innodb_deadlocks';
- Galera1: 0
- Galera2: 121
- Galera3: 0
```

### CASE 2

```bash
SQL statistics:
    queries performed:
        read:                            862
        write:                           558
        other:                           822
        total:                           2242
    transactions:                        22     (0.24 per sec.)
    queries:                             2242   (24.48 per sec.)
    ignored errors:                      352    (3.84 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      0.2402
    time elapsed:                        91.5865s
    total number of events:              22

Latency (ms):
         min:                                 2164.52
         avg:                                40173.42
         max:                                89540.74
         95th percentile:                    88157.45
         sum:                               883815.20

Threads fairness:
    events (avg/stddev):           1.3750/0.60
    execution time (avg/stddev):   55.2384/31.45
    
SHOW GLOBAL STATUS LIKE 'Innodb_deadlocks';
- Galera1: 0
- Galera2: 42
- Galera3: 0
```

## Haproxy

### CASE 1

```bash
SQL statistics:
    queries performed:
        read:                            5931
        write:                           5953
        other:                           2678
        total:                           14562
    transactions:                        238    (20.02 per sec.)
    queries:                             14562  (1224.64 per sec.)
    ignored errors:                      913    (76.78 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      20.0155
    time elapsed:                        11.8908s
    total number of events:              238

Latency (ms):
         min:                                   13.36
         avg:                                  729.68
         max:                                 7025.29
         95th percentile:                     3095.38
         sum:                               173663.66

Threads fairness:
    events (avg/stddev):           14.8750/5.69
    execution time (avg/stddev):   10.8540/0.82

SHOW GLOBAL STATUS LIKE 'Innodb_deadlocks';
- Galera1: 25
- Galera2: 42
- Galera3: 30
```

### CASE 2

```bash
SQL statistics:
    queries performed:
        read:                            822
        write:                           670
        other:                           475
        total:                           1967
    transactions:                        24     (0.78 per sec.)
    queries:                             1967   (64.00 per sec.)
    ignored errors:                      174    (5.66 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      0.7809
    time elapsed:                        30.7350s
    total number of events:              24

Latency (ms):
         min:                                 1096.95
         avg:                                14362.98
         max:                                29710.48
         95th percentile:                    28867.59
         sum:                               344711.63

Threads fairness:
    events (avg/stddev):           1.5000/0.61
    execution time (avg/stddev):   21.5445/5.50
    
SHOW GLOBAL STATUS LIKE 'Innodb_deadlocks';
- Galera1: 6
- Galera2: 14
- Galera3: 9
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
while true; do proxysql_read --execute "SELECT now(), concat('Reader: ', @@hostname)" 2>/dev/null | tail -1; sleep 2; done
```