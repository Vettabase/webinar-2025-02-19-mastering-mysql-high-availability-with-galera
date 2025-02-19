DROP USER IF EXISTS
    'root'
  , 'haproxy_check'
  , 'monitor'
;
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL ON *.* TO 'root'@'%';

CREATE USER 'haproxy_check'@'%' IDENTIFIED BY '';
GRANT USAGE ON *.* TO 'haproxy_check'@'%';

CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitor';
GRANT USAGE, REPLICATION CLIENT ON *.* TO 'monitor'@'%';