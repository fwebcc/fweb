#!/bin/sh
DIR="$(cd "$(dirname "$0")"; pwd)"
paths=${DIR%/*}'/config'
home=${DIR%/*}
case "$1" in
        freecler)
                sync && echo 1 > /proc/sys/vm/drop_caches
                sync && echo 2 > /proc/sys/vm/drop_caches
                sync && echo 3 > /proc/sys/vm/drop_caches
                echo "OK" > /var/log/mem.log
                echo "Not required" > /var/log/mem.log
                echo "clerdoen"
                RETVAL=$?
                ;;
        hddcler)
                cat $paths/hdd | awk '{print $1}'|sed -e "s/^/rm -rf \/var\/log\//g" | sh 
                #apt-get -y autoremove 
                #apt-get -y autoclean 
                apt-get -y clean               
                rm -rf /var/lib/php5/sessions/sess_.*
                rm -rf /var/log/daemon.log
                rm -rf /var/log/kern.log
                rm -rf /var/log/vsftpd.log
                rm -rf /var/log/syslog
                rm -rf /var/log/shadowsocks.log
                rm -rf /var/log/messages
                rm -rf /var/log/btmp
                rm -rf /var/log/lastlog
                rm -rf /var/log/dpkg.log
                rm -rf user.log
                rm -rf mysql.log
                rm -rf mysql.err
                rm -rf /var/log/apt/term.log
                rm -rf /var/log/apt/paniclog
                rm -rf /var/log/phddns
                rm -rf /var/log/nginx/access.log.*
                rm -rf /var/log/nginx/error.log.*
                rm -rf /var/log/nginx/access.log
                rm -rf /var/log/nginx/error.log
                rm -rf /var/log/apt/term.log.*
                rm -rf /var/log/exim4/mainlog.*
                rm -rf /var/log/lighttpd/error.log.*
                rm -rf /var/log/lighttpd/error.log
                rm -rf /var/log/mysql/error.log.*
                rm -rf /var/log/samba/log.nmbd.*
                rm -rf /var/log/samba/log.winbindd.*
                rm -rf /var/cache/debconf/templates.dat-*
                rm -rf /var/cache/debconf/config.dat-*
                rm -rf /var/backups/apt.extended_states.*.*
                rm -rf /var/backups/dpkg.diversions.*.*
                rm -rf /var/backups/dpkg.statoverride.*.*
                rm -rf /var/backups/dpkg.status.*.*
                rm -rf /var/cache/debconf/config.dat.*
                rm -rf /var/lib/dpkg/statoverride-*
                rm -rf /var/lib/dpkg/diversions-*
                rm -rf /var/lib/dpkg/status-*
                rm -rf /tmp/thunder
                rm -rf /root/.bash_history
                "$0"  Clear_file_tmp
                echo 'clerdoen'
                RETVAL=$?
                ;;
        kill9) 
                kill -9 $2
                RETVAL=$?
                echo
                ;;
        mkdirs)
                mkdir $2
                chmod -R 777 $2
                echo 'mkdirdoen'
                RETVAL=$?
                echo
                ;;
        iptablesd)
                iptables -D INPUT $2
                echo 'doen'
                RETVAL=$?
                echo
                ;;
        iptablesa)
                str=$(iptables -nvL --line-number |awk '{ if($1 ~ /^[0-9]+$/) print $9}')
                result=$(echo $str | grep "${2}")
                if [ "$result" != "" ]; then 
                  echo "repeat"
                else
                  iptables -I INPUT -s $2 -j DROP
                  echo 'doen'
                fi 
                RETVAL=$?
                echo
                ;;
        dns)
                echo 'nameserver '$2>/etc/resolv.conf
                echo 'doen'
                RETVAL=$?
                echo
                ;;
        rep)
                sed -i 's/'$2'/'$3'/' $4
                RETVAL=$?
                echo
                ;;
        dell)

                sed -i '/'"$2"'/d;:go;{P;$!N;D};N;bgo' $3
                sed -i '/^$/d' $3
                echo '' >>$3
                RETVAL=$?
                echo
                ;;
       hostname)
                hostname $2
                echo $2 >/etc/hostname
                RETVAL=$?
                echo
                ;;
        debianpass)

                passwd=$2 && (echo $passwd;echo $passwd) |passwd root
                echo
                ;;
        killssh)
                 who -a  |grep "$2" | awk '{print $(NF-1) }'|sed -e "s/^/kill -9 /g" | sh
                RETVAL=$?
                echo
                ;;
        start_up_add)
                #./linux_json_api_in.sh start_up_add aria2 restart
                a=`cat $paths'/s_start.sh' |grep $home'/app/'$2'/'`
                if [ "$a" != "" ]; then 
                   echo "yes"
                else
                   echo  $home'/app/'$2'/kaiguan.sh '$3 >>$paths'/s_start.sh'
                fi                   
                RETVAL=$?
                echo
                ;;
        start_up_stop)
               #./linux_json_api_in.sh start_up_stop aria2
                chmod -R 777 $paths'/s_start.sh'
                sed -i '/'"$2\/kaiguan"'/d;:go;{P;$!N;D};N;bgo' $paths'/s_start.sh' 
                sed -i '/^$/d' $paths'/s_start.sh'
                RETVAL=$?
                echo
                ;;
        crontab_add)
                 #调用./linux_json_api_in.sh crontab_add aria2 kaiguan restart文件夹名 kaiguan=kaiguan.sh restart表示命令重启
                 if [ "$3" != "" ]; then 
                    teshu=$2'/'$3
                 else
                    teshu='x'
                 fi 
                 a=`cat $paths'/crontab.sh' |grep $teshu`
                 if [ "$a" != "" ]; then 
                    echo "yes"
                 else
                    if [ "$2" = "freecler" ]; then 
                           echo  $DIR'/linux_json_api_in.sh' $2 >>$paths'/crontab.sh'
                        
                    elif [ "$2" = "hddcler" ] ; then  

                           echo  $DIR'/linux_json_api_in.sh' $2 >>$paths'/crontab.sh'

                    else                  

                           echo  $home'/app/'$2'/'$3'.sh' $4 >>$paths'/crontab.sh'

                    fi 
                fi   
                RETVAL=$?
                echo
                ;;
        crontab_stop)
                #./linux_json_api_in.sh crontab_stop aria2
                chmod -R 777 $paths'/crontab.sh'
                sed -i '/'"$2"'/d;:go;{P;$!N;D};N;bgo' $paths'/crontab.sh' 
                sed -i '/^$/d' $paths'/crontab.sh'
                RETVAL=$?
                echo
                ;;
        switc)
               val=$home'/app/'$2'/kaiguan.sh '$3
                echo $($val)
                echo
                ;;
        crontab_state)
                #./linux_json_api_in.sh crontab_state aria2
                a=`cat $paths'/crontab.sh' |grep $2`
                if [ "$a" != "" ]; then 
                    echo "yes"
                else
                    echo "no"
                fi            
                RETVAL=$?
                echo
                ;;
        recoveryconf)
                bakfile=$2'bak'
                if [ !  -f "$bakfile" ];then
                     echo "nocmd"
                else
                     rm -rf $2
                     cp $bakfile $2
                 fi
                RETVAL=$?
                echo
                ;;
        rm_rf)
		        if [ "$2" = "sweb" ];then
                     path_pic=$home"$3"
					 rm -rf "$path_pic"
					 echo "$path_pic"
                else				 
                   a=`echo '\/bin,\/boot,\/dev,\/etc,\/lib,lost+found,\/proc,\/run,\/sbin,\/srv,\/usr' |grep "$2"`
                   if [ "$a" != "" ];then
                      echo "nocmd"
                   else
                      rm -rf "$2"
                   fi				                      
                fi	  
                RETVAL=$?
                echo
                ;;
        systime)
                myFile="/etc/localtime" 
                if [ ! -f "$myFile" ]; then 
                   echo 'ok'
                else 
                   rm -rf /etc/localtime
                fi
                 echo 'Etc/'$3>timezone
                 dpkg=`dpkg -l|grep ntpdate`
                 if [ ! -n "$dpkg" ]; then
                      echo 'Y'|apt-get install ntpdate ;
                      ln -svf /usr/share/zoneinfo/Etc/$2 /etc/localtime
                      ntpdate  cn.pool.ntp.org
                      #同步bios时间
                      hwclock -w
                 else 
                      ln -svf /usr/share/zoneinfo/Etc/$2 /etc/localtime
                      ntpdate  cn.pool.ntp.org
                      #同步bios时间
                      hwclock -w
                 fi
                RETVAL=$?
                echo
                ;;
        apt_get_remove)
                 str="apt adduser bash dpkg dpkg-dev iptables python"
                 result=$(echo $str | grep "$2")
                 if [ "$result" != "" ]
                  then
                       echo "NOREMOVE"
                 else
                       echo 'Y'|apt-get remove $2
                       echo 'Y'|apt-get autoremove
                       dpkg -P $2
                  fi
               
                RETVAL=$?
                echo
                ;;

        apt_get_install)
                 dpkg --configure -a
                 echo 'Y'|apt-get install $2
                 apt-get -y clean
                echo
                ;;
        debianpass)
               passwd=$2 && (echo $passwd;echo $passwd) |passwd root
               echo 'OKDONE'
                RETVAL=$?
                echo
                ;;
        debianupdatestart)
                update-rc.d $2 defaults 20 80
                update-rc.d $2 enable
                ;;
        debianupdatestop)
                update-rc.d $2 disable
                update-rc.d -f $2 remove
                echo 'ok'
                RETVAL=$?
                echo
                ;;
        Clear_file_tmp)
                rm -rf $home/static/tmp/P_*
				rm -rf $home/static/tmp/F_*
                rm -rf $home/static/tmp/M_*
                rm -rf $home/static/tmp/MU_*
                rm -rf $home/static/tmp/DOWN_*
		        rm -rf $paths/debianstart.json
		        rm -rf /tmp/apt-cache.txt
                RETVAL=$?
                echo
                ;;
        swebrestart)
                 $home'/sweb/sweb.sh restart'
                RETVAL=$?
                echo
                ;;
	del_debian_user)	
		deluser "$2"
                RETVAL=$?
                echo
                ;;
	updatestart)
	            updatamodel=`grep -Po 'updatamodel[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`
				if [ "$updatamodel" != "prohibit" ]; then 
		        Service=`grep -Po 'Service[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`
                versionnumber=`grep -Po 'versionnumber[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'|sed s/[[:space:]]//g`
				Servicenumber=`grep -Po 'Servicenumber[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'|sed s/[[:space:]]//g`
                str=$(curl --connect-timeout 1 -m 1 $Service/SWEB/Service/count/cmd.php?mode_json=versionnumber)
                ip=$(echo "$str"|grep -Po 'number[" :]+\K[^"]+' | sed 's:\\\/:\/:g')
                     if [ "$ip" != "$versionnumber" ]; then 
                         sed -i 's/"Servicenumber": "'$Servicenumber'"/"Servicenumber": "'$ip'"/' $paths/data.json
						 if [ "$updatamodel" = "auto" ]; then 
						 "$0" updatesweb
						 fi
                     else
				
                         echo 'ok'
                     fi
				else
				  echo 'prohibit'
				fi
                RETVAL=$?
                echo
                ;;	
		updatesweb)	
                Service=`grep -Po 'Service[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`	
                Servicenumber=`grep -Po 'Servicenumber[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'|sed s/[[:space:]]//g`
                versionnumber=`grep -Po 'versionnumber[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'|sed s/[[:space:]]//g`
                rm -rf /tmp/up.sh				
				wget $Service/SWEB/Service/update/$Servicenumber/up.sh -O - | tr -d '\r' > /tmp/up.sh
                chmod 777 /tmp/up.sh
                /tmp/up.sh >/dev/null
				sed -i 's/"versionnumber": "'$versionnumber'"/"versionnumber": "'$Servicenumber'"/' $paths/data.json
                echo 'done'
				
                RETVAL=$?
                echo
                ;;					
        *)
                echo $"Usage: $0 {start|stop|on|off}"
                RETVAL=1
esac

exit $RETVAL