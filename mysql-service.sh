#!/usr/bin/sh
#

. /lib/svc/share/smf_include.sh

DB_DIR=/data/set/mydb1/mydata
PIDFILE=${DB_DIR}/`/usr/bin/uname -n`.pid

case "$1" in
        start)
 /opt/mysql5/bin/mysqld_safe --defaults-file=/data/set/mydb1/mydata/my.cnf --user=mysql --datadir=${DB_DIR} --pid-file=${PIDFILE} --log-error=/intmirror/set/mydb1/mylog/mysqldb1.err > /dev/null & 
                ;;
        stop)
                if [ -f ${PIDFILE} ]; then
                /usr/bin/pkill mysqld_safe >/dev/null 2>&1
                /usr/bin/kill `cat ${PIDFILE}` > /dev/null 2>&1 && echo -n ' mysqld'
                fi
                ;;
        restart)
                stop
                while pgrep mysqld > /dev/null
                do
                       sleep 1
                done
                start
                ;;
        *)
                echo ""
                echo "Usage: `basename $0` { start | stop | restart }"
                echo ""
                exit -1
                ;;
esac

