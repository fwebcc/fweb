#!/bin/sh
paths="$(cd "$(dirname "$0")"; pwd)"
name="/usr/sbin/lighttpd"
file_path='/etc/lighttpd/lighttpd.conf'
RETVAL=0
case "$1" in
        on)
                result=`ps aux  |grep $name |grep -v grep`
                if [ "$result" != "" ]; then 
                echo "yes"
                else
                echo "no"
                fi
                RETVAL=$?
                echo
                ;;
        start) 
                echo "$name start"
                /etc/init.d/lighttpd start
                RETVAL=$?
                echo
                ;;

        stop)
                echo "$name stop"
                /etc/init.d/lighttpd stop
                ps aux|grep $name|grep -v grep | awk '{print $2}' |sed -e "s/^/kill -9 /g" | sh 
                RETVAL=$?
                echo
                ;;
        restart)
                /etc/init.d/lighttpd restart
                ;;
        config_read) 
                serverport=$(sed '/^server.port=/!d;s/.*=//' $file_path)
                serverdocumentroot=$(sed '/^server.document-root=/!d;s/.*=//' $file_path) 
                serverdirlisting=$(sed '/^server.dir-listing=/!d;s/.*=//' $file_path) 
                echo '{"port":"'$serverport'","document":'$serverdocumentroot',"listing":'$serverdirlisting'}'
                RETVAL=$?
                echo
                ;;
        config_sed) 
                serverport=$(sed '/^server.port=/!d;s/.*=//' $file_path)
                serverdocumentroot=$(sed '/^server.document-root=/!d;s/.*=//' $file_path) 
                serverdirlisting=$(sed '/^server.dir-listing=/!d;s/.*=//' $file_path) 
                wwwpath_1=$(echo ${serverdocumentroot} |sed -e 's/\//\\\//g')
                new_path=$2
                wwwpath_2=$(echo ${new_path} |sed -e 's/\//\\\//g')
                sed -i "s/$serverport/$3/g" $file_path
                sed -i "s/$serverdirlisting/\"$4\"/g" $file_path
                sed -i "s/$wwwpath_1/\"$wwwpath_2\"/g" $file_path
                RETVAL=$?
                echo
                ;;
       config_bak) 
                rm -r -f $file_path
                cp -u $paths/lighttpd.confbak $file_path
                echo
                ;;
        *)
                echo $"Usage: $0 {start|stop|on|off}"
                RETVAL=1
esac

exit $RETVAL