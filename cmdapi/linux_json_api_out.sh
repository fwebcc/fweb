#!/bin/bash
DIR="$(cd "$(dirname "$0")"; pwd)"
paths=${DIR%/*}'/config'
home=${DIR%/*}
cmdapi=${DIR%/*}'/cmdapi'
CRON='/var/spool/cron/crontabs/root'
ECHO=$(type -P echo)
SED=$(type -P sed)
GREP=$(type -P grep)
TR=$(type -P tr)
AWK=$(type -P awk)
CAT=$(type -P cat)
HEAD=$(type -P head)
CUT=$(type -P cut)
PS=$(type -P ps)
_parseAndPrint() {
  while read data; do
    echo -n "$data" | sed -r 's/\\//g' | tr -d "\n";
  done;
}
dir=`grep -Po 'Diskspacedirectory[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`



RETVAL=0
case "$1" in
        memory_info)
                free=$(free | grep "Mem:"|awk '{print "\"free\":{\"total\":\"" $2 "\"," "\"used\":\"" $3 "\"," "\"free\":\"" $4 "\","}')
                Swap=$(free | grep "Swap:"|awk '{print "\"Swap_total\":\"" $2 "\"," "\"Swap_used\":\"" $3 "\"," "\"Swap_free\":\"" $4 "\"}"}')
               echo '{'
                wcCmd=$(which wc)

                swapLineCount=$(cat /proc/swaps | $wcCmd -l)

                if [ "$swapLineCount" -gt 1 ]; then

                    result=$(cat /proc/swaps \
                  | $AWK 'NR>1 {print "\"swapf\":{ \"filename\": \"" $1"\", \"type\": \""$2"\", \"size\": \""$3"\", \"used\": \""$4"\", \"priority\": \""$5"\"}," }'
                   )

                   echo ${result%?}"," 

               else
                   echo  "\"swapf\":{\"filename\": \"no\"},"
                fi

                echo $free$Swap'}'
                RETVAL=$?
                echo
                ;;
        cpu_i)
                result=$(ps aux | awk  'BEGIN {print ""} NR>1 \
                        {print "[ \"" $1"\",\""$2"\",\""$3"\",\""$4"\",\""$10"\",\""$11"\" ], " \
                        } \
                        END {print ""}' \
                        | sed 'N;$s/],/]/;P;D')		
                  echo "{\"data\": [" ${result%?} "]}"
                RETVAL=$?
                echo
                ;;
        mkdirswap) 

                filepath=${DIR%/*/*}
                syssize=`df |awk '{print $4}'|sed -n '2,1p'`                 
                if [ "$syssize" -lt "1500000" ] ; then
                    echo "nosize"
                else
                    echo "nosize"
                fi
                    rm -rf $2/wapfile
                    dd if=/dev/zero of=$2/swapfile bs=1M count=$3
                    mkswap $2/swapfile
                    swapon $2/swapfile
                    echo $2'/swapfile swap swap defaults 0 0'>>/etc/fstab 
                RETVAL=$?
                echo
                ;;
        lsdir) 

                if [ ! -n "$2" ] ;then
                  dir=$dir
                else
                  dir=$2
                fi 
                result=$(ls -l "${dir}" |awk '/^d/ {print "\"" $NF "\","}')
                echo "[" ${result%?} "]" 
                RETVAL=$?
                echo
                ;;
        lsfile) 

                result=$(ls -lFi "$2" |awk 'NR>1{print "[\"" $1 "\",\""$2"\",\""$3"\",\""$4"\",\""$5"\",\""$6"\",\""$7"\",\""$8"\",\""$9"\",\""$10"\",\""$11"\",\""$12"\"],"}')

                echo '{"lsx":[' ${result%?} '],"lsu":['
                for folder in $(ls "$2" |tr " " "?")
                    do
                      folder=${folder//'?'/' '}
                      echo '{'
                      echo  '"funame":"'"$folder"'"'
                      echo '},'
                    done| sed 'N;$s/},/}/;P;D' 
                    echo ']}' 
                RETVAL=$?
                echo
                ;;
     disk_partitions) 
		fdisk=$(fdisk -l)
		mount=$(mount)
		dfh=$(df -h)
                smartctlif=$(dpkg -l|grep smartmontools)
                start=$(echo "$fdisk"|grep 'Disk /dev/'|awk '{print $2}'| sed 's/\://g')        
                 echo "{"
                     for i in $start
                          do
                           echo \"$i"disk\": [{\"Size\":\""$(echo "$fdisk"|grep 'Disk '$i''|awk '{print $3 $4}'| sed 's/\,//g')\"","
	                                       if  [ ! -n "$smartctlif" ] ;then
                                                   echo "\"Temperature\":\"NO SOFT\",\"Power_On_Hours\":\"NO SOFT\"}],"
                                               else                                                           
	                                               smartctl=$(smartctl -A $i)
                                                   echo "\"Temperature\":"\"$(echo "$smartctl"|grep Temperature_Cel|awk '{print $10}'|head -1)\"",\"Power_On_Hours\":"\"$(echo "$smartctl"|grep Power_On_Hours|awk '{print $10}'|head -1)\""}],"  							 
                                               fi
 
                            echo "\""$i"\":["
	                            start2=$(echo "$fdisk"|grep $i  |awk '{print $1}'|grep dev|awk '{print $1}')
	                            for x in $start2
                                        do
                                          echo "{\"Device\":\""$x"\","
	                                      echo "$fdisk"|grep $x|awk '{print "\"Start\":\""$2"\",\"Size\":\""$5"\",\"Type\":\""$6"\","}'	   
	                                
	                                       mounts=$(echo "$mount" |grep $x)
	                                       if  [ ! -n "$mounts" ] ;then
	                                                echo "\"Mounted\":\"\",\"Type2\":\"\","
                                               else       
                                                     echo $(echo "$mount" |grep $x |awk '{print "\"Mounted\":\""$3"\",\"Type2\":\""$5"\","}')			 
                                               fi	
                                        
	                                       dfs=$(echo "$dfh"|grep $x)
	                                       if  [ ! -n "$dfs" ] ;then
	                                                 echo "\"Size2\":\"\",\"user\":\"\",\"baifen\":\"\""
                                               else    
                                                      echo $(echo "$dfh" |grep $x |awk '{print "\"Size2\":\""$2"\",\"user\":\""$3"\",\"baifen\":\""$5"\""}')		 
                                               fi	
                                        echo "},"       
                                done | sed 'N;$s/},/}/;P;D'  
                                        echo "],"
                     done | sed 'N;$s/],/]/;P;D'
                                       echo "}"
                RETVAL=$?
                echo
                ;;
        df_i)
                  result=$(df -Ph | awk 'NR>1 {print "{\"file_system\": \"" $1 "\", \"size\": \"" $2 "\", \"used\": \"" $3 "\", \"avail\": \"" $4 "\", \"used%\": \"" $5 "\", \"mounted\": \"" $6 "\"},"}') 
                  echo [ ${result%?} ] 
                RETVAL=$?
                echo
                ;;
        seepd)
                 eth=`grep -Po 'Networkcard[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`
                 RXpre=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $2}')
                 TXpre=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $10}')
                 sleep 1
                 RXnext=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $2}')
                 TXnext=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $10}')

                 RX=$((${RXnext}-${RXpre}))
                 TX=$((${TXnext}-${TXpre}))

                 RXVAL=$(iptables -nvx -L|grep 'Chain INPUT'|awk '{print $7}')
                 TXVAL=$(iptables -nvx -L|grep 'Chain OUTPUT'|awk '{print $7}')
                 
                 echo '{"up":"'$RX'","RXpre":"'$RXVAL'","down":"'$TX'","TXpre":"'$TXVAL'"}'
                

                RETVAL=$?
                echo
                ;;
        ip_i)
                  eth=`grep -Po 'Networkcard[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`
                  dns=$(cat /etc/resolv.conf|awk '{print $2}')
                  ethtool=$(ethtool $eth|grep Speed|awk -F ':' '{print $2}')
                  hostname=$(uname -n)
                  echo '{"ethtool":"'$ethtool'","Networkcard":"'$eth'","hostname":"'$hostname'","dns":"'$dns'"}' 
                RETVAL=$?
                echo
                ;;
        ip_w)
                Service=`grep -Po 'Service[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`
                str=$(curl --connect-timeout 1 -m 1 $Service/SWEB/Service/count/IP.php)
                if [ "$str" != "" ]; then 
                     echo "[\""$str"\"]"
                else
                    strs=$(curl --connect-timeout 1 -m 1 icanhazip.com/ip)                    
                    if [ "$strs" != "" ]; then 
                       echo "[\""$strs"\"]"
                    else            
                       strz=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'|sed -n '1p')
					   echo "[\""$strz"\"]"
                    fi
                fi 
                RETVAL=$?
                echo
                ;;

        netstat)
                para1=$(ifconfig  | grep 'inet'| grep -v '127.0.0.1' |awk '{ print $2}'|sed -n '1p'| cut -d: -f2 | awk '{ print $1}')
                result=$(netstat -nat | grep "$para1"|awk '{print $5}'|awk -F: '{print $1}'|sort|uniq -c|sort -nr| awk -F " " '{if($2!="0.0.0.0") print "\""$2 "\","}')
                 echo "[" ${result%?} "]"
				RETVAL=$?
                echo
                ;;
        netstattlnp)
                result=$(netstat -tlnp|awk 'NR>2{print "[ \"" $1"\",\""$4"\",\""$5"\",\""$7"\"],"}')
                echo "{\"data\": [" ${result%?} "]}"
                RETVAL=$?
                echo
                ;;
        iptables)
                result=$(iptables -nvL --line-number |awk  'BEGIN {print ""} NR>0 \
                        {if($1 ~ /^[0-9]+$/) print "[ \"" $1"\",\""$4"\",\""$5"\",\""$9"\",\""$10"\",\""$12"\" ], " \
                        } \
                        END {print ""}' \
                        | sed 'N;$s/],/]/;P;D')		
                  echo "{\"data\": [" ${result%?} "]}"
                RETVAL=$?
                echo
                ;;
       cpu_info)
                 result=$(cat /proc/cpuinfo \
                        | $AWK -F: '{print "\""$1"\": \""$2"\"," }  '\
                        )

                echo "{" ${result%?} "}" 

                RETVAL=$?
                echo
                ;;
       systime)
                echo $(date "+%G-%m-%d %H:%M:%S")
                #echo $(date +%s)'000'
                RETVAL=$?
                echo
                ;;
       starttime)
                   uptime_seconds=$(cat /proc/uptime | awk '{print $1}')
                   echo ${uptime_seconds%.*}
                RETVAL=$?
                echo
                ;;

        logged_in_users)
                  result=$(PROCPS_FROMLEN=40 w -h | $AWK '{print "{\"user\": \"" $1 "\", \"from\": \"" $3 "\", \"when\": \"" $4 "\"},"}')
                  echo [ ${result%?} ] | _parseAndPrint                
                RETVAL=$?
                echo
                ;;
        switc_start) 
                a=$(cat $paths'/s_start.sh' |grep $home'/app/'$2'/')
                if [ "$a" != "" ]; then 
                    echo '{"start_up_state": "checked"}'
                else
                    echo '{"start_up_state": ""}'
                fi 
                RETVAL=$?
                echo
                ;;         
        switc_switc) 
                result=$($home/app/$2/kaiguan.sh on)
                if [ "$result" == "yes" ]; then 
                   echo '{"switc_state": "checked"}'
                else
                   echo '{"switc_state": ""}'
                fi
                echo
                ;;
        crontab_state)
                #./linux_json_api_in.sh crontab_state aria2
                a=`cat $paths'/crontab.sh' |grep $2`
                if [ "$a" != "" ]; then 
                    echo '{ "start_up_state": "checked"}'
                else
                    echo '{ "start_up_state": ""}'
                fi
                RETVAL=$?
                echo
                ;;	
        zoneinfo)
                if [ ! -n "$2" ] ;then
                  dir="Asia"
                else
                  dir=$2
                fi 
                results=$(ls -al /etc/localtime|awk '{print $11}')                
                utf=${results##*/}
                #echo $utf
                if [ ! -n "$utf" ] ;then
                  utfb="GMT-8"
                else
                  utfb=$utf
                fi 
                result=$(ls -a /usr/share/zoneinfo/Etc  |awk '{if($1~"GMT+"||$1~"GMT-") print "\"" $1"\","}')
                echo '{"ETC": [' ${result%?} '],"bing": ["'$utfb'"]}'               
                RETVAL=$?
                ;;
        dpkg_l)
                  result=$(dpkg -l|sed "s/\"\b/-/g" |awk  'FNR>5  {print "[\""$2"\",\""$3"\",\""$4"\",\"" $5 "\"],"}')
                  echo '{"data": [' ${result%?}']}'              
                RETVAL=$?
                echo
                ;;
        apt-cache)
                 
                    if [ ! -f "/tmp/apt-cache.txt" ];then
                             result=$(apt-cache pkgnames |awk  '{print "[\""$0"\",\"lin"NR"\"],"}')
                             #result=$(cat /var/lib/apt/lists/ftp.cn.debian.org_debian_dists_jessie_main_binary-armhf_Packages |grep 'Package:'|awk  '{print "[\""$2"\",\"lin"NR"\"],"}')
                             echo '{"data": [' ${result%?}']}'
                             echo '{"data": [' ${result%?}']}' >/tmp/apt-cache.txt  
                    else
                            echo $(cat "/tmp/apt-cache.txt")
                    fi

      
                RETVAL=$?
                echo
                ;;
        apt_cache_search)
                 a=$(apt-cache show $2) 
                 echo "$a"       
                RETVAL=$?
                echo
                ;;
#资源管理器类别 
       cat_file)
                type=$(file -i "$2"|awk '{print $3}')
                var=${type#*=}
                if [ "$var" == "iso-8859-1" ];then
                       iconv -f GBK -t UTF-8 "$2" -o "$2"
                fi
                ln -s "$2" $home/static/tmp/F_"$4".$3
                RETVAL=$?
                echo
                ;;	
        save_file)
                echo "$3">"$2"
                RETVAL=$?
                echo
                ;;	
        cat_pic)

                ln -s "$2" $home/static/tmp/P_"$4".$3
                RETVAL=$?
                echo
                ;;	
        cat_picstart)
                ln -s "$2" $home/static/tmp/P_"$3"
                RETVAL=$?
                echo
                ;;	
        cat_video)

                ln -s "$2" $home/static/tmp/M_"$4".$3
                RETVAL=$?
                echo
                ;;	
        cat_music)

                ln -s "$2" $home/static/tmp/MU_"$4".$3
                echo
                ;;
        cat_othe)
                ln -s $2 $home/static/tmp/DOWN_"$4".$3
                RETVAL=$?
                echo
                ;;	

        tar_zxvf_file)
		     sizes=$(du -s "$2" | awk '{print $1}')
			 if [ 204800  -lt  $sizes ]; then		        
				echo "20480"
			else
		         type=$(file -i "$2" |awk '{print $2}'| sed 's/.$//')
		          if [ "$type" == "application/gzip"  ]; then
			          cd $3
                      tar -xzvf "$2"
			      fi
			      if [ "$type" == "application/x-xz"  ]; then
			          cd $3
                      tar -xvf  "$2"
			      fi
			      if [ "$type" == "application/zip"  ]; then
                      unzip "$2" -d $3
			      fi
            fi
                RETVAL=$?
                echo
                ;;	
        tar_zcvf_file)
		     sizes=$(du -s "$3""/""$2" | awk '{print $1}')
			 if [ 204800  -lt  $sizes ]; then
		        
				echo "20480"
			 else
			   	cd $3
                tar zcvf "$2"".tar.gz"  "$2"
				echo 'DOEN'
             fi	
                RETVAL=$?
                echo
                ;;	
        mv_file)
                mv $2 $3
                RETVAL=$?
                echo
                ;;	
        hebingfile)
		       	if [[ "$2" =~ "../" ]]; then
			       path_sh=$(echo "$2"|awk '{$1=substr($1,3)}1' )
                   path_new=$home"$path_sh"
                else
				   path_new="$2"
				fi
                 				
                     for ((i=1;i<$3;i++))
                        do

                         cat "$path_new""/.""$5""/""$4""_"$i>>"$path_new""/""$4"	
		                   a=`echo '\/bin,\/boot,\/dev,\/etc,\/lib,lost+found,\/proc,\/run,\/sbin,\/srv,\/usr' |grep "$path_new"`
                           if [ "$a" != "" ];then
                                echo "nocmd"
                           else
                                
                                echo 'rm'
                           fi
				 
                     done 
	             rm -rf "$path_new""/.""$5""/"		
                RETVAL=$?
                echo
                ;;	
        del_up_file)
		        a=`echo '\/bin,\/boot,\/dev,\/etc,\/lib,lost+found,\/proc,\/run,\/sbin,\/srv,\/usr' |grep "$2"`
                if [ "$a" != "" ];then
                     echo "nocmd"
                else
                     rm -rf "$2""/.""$3""/"
                 fi
                    
                RETVAL=$?
                echo
                ;;
#系统开机启动类别
        debianupdatefind)
                result=`ls /etc/rc2.d | grep $2`
                if [ "$result" != "" ]; then 
                echo "yes"
                else
                echo "no"
                fi
                RETVAL=$?
                echo
                ;;	
        swebupdate)
                result=$(cat $paths'/s_start.sh'|awk -F '/' '{if($4!="") print "{\"url\":\""$4"\",\"soft_name\":\""$5"\",\"state\":\"checked\"},"}')
                echo "[" ${result%?} "]" 
                RETVAL=$?
                echo
                ;;	
#定时任务类别
        switc_crontab) 
                a=$(cat '/var/spool/cron/crontabs/root' |grep '/sweb/config/crontab.sh')
                if [ "$a" != "" ]; then 
                    echo '{"crontab_up_state": "checked"}'
                else
                    echo '{"crontab_up_state": ""}'
                fi 
                RETVAL=$?
                echo
                ;; 
        crontab_start)
                if [ "$2" == "0" ];then
                 hour="*"
                else
                 hour="*/"$2
                fi

                if [ "$3" == "0" ];then
                 Minute="*"
                else
                 Minute="*/"$3
                fi


                echo  $Minute" "$hour"  * * * root "$paths"/crontab.sh"  >>$CRON
                crontab -u root  $CRON
                /etc/init.d/cron restart
                RETVAL=$?
                echo
                ;;
		crontab_confing)
                
                echo $(cat /etc/crontab |grep '/sweb/config/crontab.sh'|awk '{print "{\"Minute\":\""$1 "\",\"hour\":\""$2"\"}"}')
                RETVAL=$?
                echo
                ;;	              		
				
        crontab_stop)
                sed -i '/'"\/sweb\/config\/crontab.sh"'/d;:go;{P;$!N;D};N;bgo' $CRON
                sed -i '/^$/d' /etc/crontab
                crontab -u root  $CRON
				/etc/init.d/cron restart
                RETVAL=$?
                echo
                ;;
        crontab_add)
		        syss=$(echo "$2" | awk -F " " '{print $1}' )
				name=$(echo "$2" | awk -F " " '{print $2}' )
				mode=$(echo "$2" | awk -F " " '{print $3}' )
				
                jus=$(cat $paths/crontab.sh|grep $name)
          
                if [ "$jus" == "" ]; then   
                  	if [ "$syss" == "Sweb" ]; then			
                       echo $cmdapi"/linux_json_api_in.sh "$name >> $paths'/crontab.sh' 
					fi
					
                  	if [ "$syss" == "APP" ]; then			
                       echo $home"/app/"$name"/kaiguan.sh "$mode >> $paths'/crontab.sh' 
					fi					
                else  
                   echo "yes is set !"
                fi
                RETVAL=$?
                echo
                ;;	
		crontab_add_app)
                ju=$(cat $paths'/crontab.sh'|grep $home"/app/"$3"/"$4)

                if [ "$ju" == "" ]; then 
                  echo $home"/app/"$3"/"$4 >> $paths'/crontab.sh' 
                 
                else  
                    echo "yes is set !"
                fi
                RETVAL=$?
                echo
                ;;	
		crontab_list)
                result=$(cat $paths'/crontab.sh' |grep sweb|awk '{print "{\"list\":\""$1 " "$2" "$3"\"},"}')
				echo [ ${result%?} ] | _parseAndPrint                
                RETVAL=$?
                echo
                ;;
		crontab_list_del)
		        text=$(echo "$2" | awk -F " " '{print $1" "$2}' )
                sed -i '/'"$text"'/d;:go;{P;$!N;D};N;bgo' $paths'/crontab.sh' 
                sed -i '/^$/d' $paths'/crontab.sh'               
                RETVAL=$?
                echo
                ;;
        debian_user_list)				
               result=$($AWK -F: '{ \
                       if ($3<=499){userType="system";} \
                       else {userType="user";} \
                        print "[ \"" userType "\"" ", \"" $1 "\", \"" $6 "\" ]," }' < /etc/passwd
                       )

                length=$(echo ${#result})

                if [ $length -eq 0 ]; then
                    result=$(getent passwd | $AWK -F: '{ if ($3<=499){userType="system";} else {userType="user";} print "[ \"" userType "\"" ",\"" $1 "\",\"" $6 "\" }," ]')
                fi

                echo '{"data":'[ ${result%?} ] '}'| _parseAndPrint				
                RETVAL=$?
                echo
                ;;	
		background_list)		             
				result=$(ls $home/static/img/background|awk '{print "{\"pic\":" "\""$1"\"},"}')
                echo [${result%?}] | _parseAndPrint  				
                RETVAL=$?
                echo
                ;;				
		letter)		             
				result=$(fdisk -l|grep '/dev/'|awk '{print $1}'|grep '/dev/'|awk '{print "{\"disk\":\""$1"\"},"}')
                echo [${result%?} ]| _parseAndPrint  
				
                RETVAL=$?
                echo
                ;;	
		Networkcards)		             
				result=$(ifconfig | grep -o ^[a-z0-9]*|awk '{print "{\"card\":\""$1"\"},"}')
                echo [${result%?} ]| _parseAndPrint  
				
                RETVAL=$?
                echo
                ;;
		APP_wget)		             
				if [ ! -n "$2" ] ;then
                   echo "you have not address!"
                else
				Service=`grep -Po 'Service[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`
                 rm -rf /tmp/$3
                 rm -rf /tmp/$3.tar.gz 
                 rm -rf /tmp/$3.tar.gz.* 
				 rm -rf $home'/static/img/app'/$3
                 rm -rf $home'/static/img/app'/$3.png
                 rm -rf $home'/static/img/app'/$3.png.*
                 wget -P /tmp  $2 
				 wget -P $home'/static/img/app'  'http://'$Service'/SWEB/Service/img/'$3'.png'
				 echo 'deon'
               fi
				
                RETVAL=$?
                echo
                ;;				
		APP_size)		             
				APP_size=$(ls -l /tmp/$2.tar.gz | awk '{print $5}')
				echo $APP_size
				
                RETVAL=$?
                echo
                ;;	
		APP_soft_md5)
				if [ ! -n "$2" ] ;then
                   echo "you have not address!"
                else		
				   L_file_md5=$(md5sum /tmp/$2.tar.gz|awk '{print $1}')				
				   echo $L_file_md5
				fi
                RETVAL=$?
                echo
                ;;	
		APP_tar)
		        softname=$2
				if [ ! -n "$softname" ] ;then
                   echo "NO"
                else		
                  tar zxvf '/tmp/'$softname'.tar.gz' -C '/tmp'
                  cp -u -R '/tmp/'$softname'/app/'$softname $home'/app/'
				  cp -u -R '/tmp/'$softname'/ui/'$softname $home'/static/js/app/'
				  chmod -R 777 $home'/app/'$softname
				  chmod -R 777 $home'/static/js/app/'$softname
				  chmod -R 777 '/tmp/'$softname'/install.sh' 
				  '/tmp/'$softname'/install.sh'
				 rm -rf /tmp/$softname 
                 rm -rf /tmp/$softname.tar.gz 
                 rm -rf /tmp/$softname.tar.gz.* 
				 echo 'deon'
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
		APP_remove)	
		    softname=$2
			if [ ! -n "$softname" ] ;then
                   echo "NO"
            else	
			    #判断开关命令是否存在
			    cmd=$home'/app/'$softname'/kaiguan.sh'
                if [ ! -f "$cmd" ];then
                    cmdy=''
                else
                    cmdy=$cmd				
			    fi
				#判断卸载命令是否存在
			    remove_file=$home'/app/'$softname'/remove.sh'
                if [ ! -f "$remove_file" ];then
                    removey=''
                else
                    removey=$remove_file				
			    fi				
				$cmdy
			    rm -rf $home'/app/'$softname
			    rm -rf $home'/static/js/app/'$softname
				rm -rf $home'/static/img/app/'$softname'.png'
                removey remove
				"$0" crontab_list_del $softname
                "$0" start_up_stop $softname
                echo 'deon'	
			fi  
			
                RETVAL=$?
                echo
                ;;	
		APP_update)
		   softname=$2
			if [ ! -n "$softname" ] ;then
                   echo "NO"
               else			
			       cmd=$home'/app/'$softname'/kaiguan.sh'
                   if [ ! -f "$cmd" ];then
                        echo 'deon'
                   else
                        $cmd stop
						rm -rf $home'/app/'$softname
			            rm -rf $home'/static/js/app/'$softname
                        echo 'deon'						
			       fi			
				
            fi				
                RETVAL=$?
                echo
                ;;
		sys_reboot)		             
				 reboot -f
				  
				shutdown -r now 
                RETVAL=$?
                echo
                ;;
		sys_halt)		
                 		
				shutdown -h now 
				halt
				poweroff 
                RETVAL=$?
                echo
                ;;	
		sys_mount)		
                pan=`fdisk -l |grep $2`
                if [ "$pan" != "" ]; then 
                echo "$name start"
                if [ "$2" != "" ]; then 
                  mkdir /mnt/$2
                  chmod -R 777 /mnt/$2
                 #mount  /dev/$3 $2
                 for loop in nfs nfs4 smbfs cifs coda ncpfs ocfs2 gfs ceph ext3 ntfs-3g ext4 vfat
                  do
                    mount -t $loop  /dev/$2 /mnt/$2
                    
                  done
                  fi
                fi
                echo  "mount /dev/$2 /mnt/$2"  >>$paths/mount.sh
                RETVAL=$?
                echo
                ;;
		sys_umount)		
                umount -l /mnt/$2
                #fuser -cu /mnt/$2
                #fuser -ck /mnt/$2
                #fuser -c /mnt/$2
                sed -i '/'"\/mnt\/$2"'/d;:go;{P;$!N;D};N;bgo' $paths/mount.sh
                para1=$(mount -l |grep $2)  
                if [ ! -n $para1 ]; then  
                    echo "IS NULL"  
                else  
                    rm -rf  /mnt/$2
                fi 
                RETVAL=$?
                echo
                ;;	
		restart_web)		
			    ${DIR%/*}/sweb.sh restart &
                RETVAL=$?
                echo
                ;;
		mac_add)		
			    ifconfig |grep HWaddr |awk '{print $5}'|sed -n '1p'
                RETVAL=$?
                echo
                ;;
		IP_add)		
			    ifconfig -a|grep inet|grep -v '127.0.0.1'|grep -v inet6|awk '{print $2}'|tr -d \"addr:\"|sed -n '1p'
                RETVAL=$?
                echo
                ;;	
      Library_add)	
	            lib=$(ls /usr/lib |grep linux-gnu)
				#判断值否存在
                if [ !  "$lib" ];then
                    echo `grep -Po 'Library_file[" :]+\K[^"]+' ${paths}/data.json| sed 's:\\\/:\/:g'`
                else
                    echo $lib			
			    fi	
                RETVAL=$?
                echo
                ;;
      debian_add)	
	             cat /etc/debian_version
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
                echo $"Usage: $0 {nodata}"
                RETVAL=1
esac

exit $RETVAL