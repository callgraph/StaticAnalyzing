#!/bin/bash

# 安装必须环境
realpath=`sed  's/REAL_PATH=/''/' realpath`
#realpaht值为/mnt/freenas/DCG-RTL

linkpath=/usr/local/share/cg-rtl
ln -s $realpath $linkpath
scriptpath=`pwd`
#dolink

apt-get update
apt-get install ruby
apt-get install git 
apt-get install perl
apt-get install exuberant-ctags
apt-get install mysql-server mysql-client
apt-get install apache2
apt-get install swish-e
apt-get install libdbi-perl libdbd-mysql-perl libfile-mmagic-perl libapache2-mod-perl2
apt-get install graphviz

##############配置apache##########################
rm -rf /etc/apache2/conf.d/apache-lxrserver.conf
rm -rf /etc/apache2/httpd.conf

echo "ServerName localhost" >>/etc/apache2/httpd.conf
rm -rf /etc/apache2/conf.d/lxr
echo "Alias /lxr /usr/local/share/cg-rtl/lxr" >>/etc/apache2/conf.d/lxr
echo "<Directory /usr/local/share/cg-rtl/lxr>" >>/etc/apache2/conf.d/lxr
echo "Options All" >>/etc/apache2/conf.d/lxr
echo "AllowOverride All" >>/etc/apache2/conf.d/lxr
echo "</Directory>" >>/etc/apache2/conf.d/lxr
chmod -R 777 /etc/apache2/conf.d/lxr
chmod -R 777 /etc/apache2/httpd.conf
/etc/init.d/apache2 restart

#############安装arm交叉编译工具###################
apt-get install gcc-arm-linux-gnueabi cpp-arm-linux-gnueabi
apt-get install gcc-arm-linux-gnueabihf cpp-arm-linux-gnueabihf 
apt-get build-dep linux-image-$(uname -r) 
apt-get install dpkg-dev kernel-wedge
apt-get install uboot-mkimage  

#gcc for ucore on raspberrypi 20140408
#add-apt-repository ppa:terry.guo/gcc-arm-embedded
#apt-get update
#apt-get install gcc-arm-none-eabi

#############安装arm交叉编译工具###################
mkdir $linkpath/source
sourcepath=$linkpath/source
cd $sourcepath/db-rtl-callgraph/auto_install
#tar jxvf arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
#echo "PATH=\"$PATH:/usr/local/share/cg-rtl/source/db-rtl-callgraph/auto_install/arm-2010q1/bin\"" >> /etc/profile
#echo "PATH=\"$PATH:/usr/local/share/cg-rtl/source/db-rtl-callgraph/auto_install/arm-2010q1/bin\"" >> ~/.bashrc

###############安装mysql-ruby##############
tar zxvf mysql-ruby-2.8.2.tar.gz
cd mysql-ruby-2.8.2
apt-get install ruby-dev
apt-get install libmysqlclient-dev
ruby extconf.rb
make
ruby ./test.rb
make install
cd  $sourcepath/db-rtl-callgraph/complier
tar xvf virtual-linux-3.5.4.tar

##############初始化数据库####################
cd $linkpath
ln -s $sourcepath/db-rtl-callgraph/lxr ./lxr
cd lxr/
./custom.d/initdb.sh
