# sweb
DEBIAN9 WEB UI 操作页面<br>
试用于debian8 9 X86 64位系统<br>
采用html+js+python+shell <br>
直接克隆到home目录给与权限 ./sweb.sh 运行即可<br>

#安装必要的程序
#===============
apt-get update
echo 'y'|apt-get install usbutils screen ethtool hdparm lsof curl unzip zlib1g-dev sudo ntfs-3g ntpdate net-tools

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


git clone https://github.com/fwebcc/sweb.git<br>
chmod -R 777 ./sweb<br>
cd sweb<br>
./sweb.sh<br>

