注意事项： 支持DEBIAN 7|8|9 操作系统 语言请设置成英文 使用root权限运行！

[A B选择一项安装即可]

A:一键安装命令
控制台或者使用PUTTY连接设备，使用下面命令安装

wget -O - wget 'http://fweb.cc/down?paths=/vps&name=swebinstall.sh'  | sh

或者 

wget -O - wget 'http://sweb.ink:88/down?paths=/vps&name=swebinstall.sh'  | sh



B:以下分步安装命令 
#安装必要的程序 #

=============== ==
apt-get update 
echo 'y'|apt-get install usbutils screen ethtool hdparm lsof curl unzip zlib1g-dev sudo ntfs-3g ntpdate

#选装各种通讯协议 
#=============== 
echo 'y'|apt-get install vsftpd samba smbclient nfs-common nfs-kernel-server cifs-utils smartmontools


##[开发者模式选装]
#===============
#echo 'y'|apt-get install python2.7 python-pycurl python-flask  python-setuptools python-pip

#清理安装垃圾
#===============
apt-get autoremove 
apt-get clean
#安装SWEB 程序
#===============  

wget 'http://fweb.cc/down?paths=/FWEB/ROM&name=fweb.tar.gz'  -O /home/fweb.tar.gz

tar zxvf /home/fweb.tar.gz -C /home

/home/fweb/cmd install_start

rm -r /home/fweb.tar.gz 

chmod 777 /home/fweb/fweb

chmod 777 /home/fweb/cmd

/home/fweb/cmd start

IP=$(ifconfig  | grep 'inet'| grep -v '127.0.0.1' |awk '{ print $2}'|sed -n '1p'| cut -d: -f2 | awk '{ print $1}')

echo 'OPEN http://'$IP' USER:admin PASS:pass'

echo 'DOEN'

=======================

默认端口88 http://ip:88

默认用户名 admin

默认密码 pass
