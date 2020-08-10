#!/bin/sh
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
RETVAL=0
webport=`grep -Po 'webport[" :]+\K[^"]+' ${DIR}/config/data.json`
case "$1" in
        start)
		       echo 'SWEB START......'
               cd $DIR
				"$0" Access_mode
                PORT=$(netstat -tunlp|grep $webport |awk  '{print $7}'| cut -d \/ -f 2 |sed -n '1p')
                killall $PORT
                screen -dmS rt $DIR/sweb
				echo "SWEB START......DEON"
				RETVAL=$?
				echo 
                ;;

        stop)
                    echo 'YES SWEB RUN'
                    killall sweb                   
                    echo 'KAILLALL SWEB'             
                ;;
        sh)
                cd $DIR
                PORT=$(netstat -tunlp|grep $webport |awk  '{print $7}'| cut -d \/ -f 2 |sed -n '1p')
                killall $PORT
				"$0" Access_mode
                screen -dmS rt $DIR/sweb
                ;;
Access_mode)
                Accessmode=`grep -Po 'Accessmode[" :]+\K[^"]+' ${DIR}/config/data.json`
				host=`grep -Po 'host[" :]+\K[^"]+' ${DIR}/config/data.json`
				if [ "$Accessmode" != "True" ]; then 
				  ip='0.0.0.0'				  			  
				else
				  ip=$(ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"|sed -n '1p')			  
				fi
				if [ "$host" != "ip" ]; then 
					sed -i  's/"host": "'$host'"/"host": "'$ip'"/g'   ${DIR}/config/data.json
				fi
                ;;				
install_start)
echo "#!/bin/sh
### BEGIN INIT INFO
# Provides:          test
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Should-Start: $network
# Should-Stop: $network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description: test
# Description: test
### END INIT INFO">/etc/init.d/start.sh
sleep 1
                echo $DIR/sweb.sh sh >>/etc/init.d/start.sh
                echo $DIR/config/s_start.sh >>/etc/init.d/start.sh
                chmod -R 777 /etc/init.d/start.sh
sleep 1
                #update-rc.d start.sh disable
                #update-rc.d -f start.sh remove
                update-rc.d start.sh defaults
                echo
                ;;
        install)
                echo 'y'|apt-get install usbutils screen ethtool hdparm lsof curl unzip zlib1g-dev
                echo 'y'|apt-get install python2.7  python-pycurl
                echo 'y'|apt-get install vsftpd samba smbclient nfs-common nfs-kernel-server cifs-utils smartmontools
                "$0" install_start
                echo
                ;;
        restart)
                echo "restart"
                "$0" stop
                 sleep 1
                "$0" start
                ;;
        *)
                echo $"Usage: $0 {on|off|start|stop}"
                RETVAL=1
esac

exit $RETVAL
