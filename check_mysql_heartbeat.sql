GRANT UPDATE  ON test.heartbeat TO 'nagios'@'localhost';

CREATE TABLE test.heartbeat (
   id int NOT NULL PRIMARY KEY,
   ts datetime NOT NULL
 );
 INSERT INTO heartbeat(id) VALUES(1);

UPDATE test.heartbeat SET ts=NOW() WHERE id=1;

/*
CRONTAB
00,15,30,45 * * * * /opt/mysql5/bin/mysql -u nagios -e "UPDATE test.heartbeat SET ts=NOW() WHERE id=1;"
MONITOR QUERY
select count(1) from heartbeat where ts >  date_sub(now(), interval 20 minute);
*/
