#! /bin/sh

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
mysqlpath=' /opt/mysql5/bin/amd64'
warn=30
crit=60
null="NULL"
usage1="Usage: $0 -u user -p password [-w <warn>] [-c <crit>]"
usage2="<warn> is lag time, in seconds, to warn at.  Default is 30."
usage3="<crit> is lag time, in seconds, to be critical at.  Default is 60."

exitstatus=$STATE_WARNING #default
while test -n "$1"; do
    case "$1" in
        -c)
            crit=$2
            shift
            ;;
        -w)
            warn=$2
            shift
            ;;
        -u)
            user=$2
            shift
            ;;
        -p)
            pass=$2
            shift
            ;;
        -h)
            echo $usage1;
	    echo 
            echo $usage2;
            echo $usage3;
            exit $STATE_UNKNOWN
	    ;;
	-H)
            host=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo $usage1;
	    echo 
            echo $usage2;
            echo $usage3;
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

seconds=`$mysqlpath/mysql -u $user -p$pass -e 'show slave status\G' | /bin/grep Seconds_Behind_Master | /bin/cut -f2 -d:`

# on the number line, we need to test 6 cases:
# 0-----w-----c----->
# 0, 0<lag<w, w, w<lag<c, c, c<lag
# which we simplify to 
# lag>=c, w<=lag<c, 0<=lag<warn

# if null, critical
if [ $seconds = $null ]; then
echo CRITICAL - Slave is $seconds seconds behind 
exit $STATE_CRITICAL;
fi

#w<=lag<c
if [ $seconds -lt $crit ]; then 
if [ $seconds -ge $warn ]; then
echo WARNING - Slave is $seconds seconds behind 
exit $STATE_WARNING;
fi
fi

if [ $seconds -ge $crit ]; then
echo CRITICAL - Slave is $seconds seconds behind 
exit $STATE_CRITICAL;
fi

# 0<=lag<warn
if [ $seconds -lt $warn ]; then
echo OK - Slave is $seconds seconds behind 
exit $STATE_OK;
fi


