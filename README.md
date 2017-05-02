db-rtl-callgraph
================

DataBase and RTL based CallGraph

Database version: 5.5.40

LXR version: 1.2.0

1. 安装过程
================
如果不是root用户登录，请使用sudo su切换到root账号进行以下操作

1. 安装GIT
apt-get install git

2. 进入/home/zhangsan，新建work文件夹  
cd /home/zhangsan 
mkdir work  
cd work 
git clone https://github.com/callgraph/StaticAnalyzing.git  

3. 安装数据库

3.1
apt-get install mysql-server mysql-client
其中会弹出窗口要求输入mysql的密码，设置密码123456
由于需要把数据库链接到存储空间上，/mnt下应该已经挂载好了freenas
cd /var/lib/ 
cp -a mysql /mnt/freenas/mysql  
rm -rf mysql  
ln -s /mnt/freenas/mysql mysql  

3.2
修改/etc/apparmor.d/usr.sbin.mysqld 
注释掉
	#  /var/lib/mysql/ r,
	#  /var/lib/mysql/** rwk,
添加
	/mnt/freenas/mysql/ r,
	/mnt/freenas/mysql/** rwk,
3.3	
修改/etc/mysql/my.cnf  
	在第109行增加如下内容
	innodb_file_per_table 
然后重启mysql
/etc/init.d/mysql restart

4. 新建必要的目录  
cd /home/**/work  
mkdir -p  /mnt/freenas/DCG-RTL/source  
mv db-rtl-callgraph/ /mnt/freenas/DCG-RTL/source/

5. 编辑realpath文件  
lxr及其依赖数据的文件夹真实存放的路径。例如：  
REAL_PATH=/mnt/freenas/DCG-RTL  
envir1.sh脚本中会有语句将lxr移动到这个路径下


7.安装必要的软件、初始化数据库

如果是一台从未进行过部署的机器的话，则还需执行envir1.sh脚本（只需要运行一次,路径为：/mnt/freenas/DCG-RTL/source/db-rtl-callgraph/auto_install）
显示以下提示时
echo "*** MySQL - Creating global user lxr"
Enter password:   #123456
Enter password:   #123456


8. 编辑/mnt/freenas-intel/DCG-RTL/source/db-rtl-callgraph/auto_install/conf
该文件配置了内核源码版本（version），编译平台(platform)、是否为虚目录(directory)、获取注释方式(comment)、代码下载地址(link)、源代码lxr地址（code_url）、代码注释地址（note_url）。编译平台目前支持x86_32、x86_64、arm-Raspnerrrypi、arm-pandaboard三种，虚目录有real、virtual两个选项、注释方式可选doxygen和非doxygen。
以x86_32平台的linux-3.5.4为例，内容如下：
version=linux-3.5.4  
platform=x86_32  
directory=real  
comment=doxygen  
link=                 //如果已有源代码则link=后边为空;部署过程中发现，在一台没有部署过任何版本的机器上，此处应该为空。
code_url=http://124.16.141.184/lxr/lxr-code/linux-3.5.4/
note_url=http://124.16.141.184/doxygen_kernel/linux-3.5.4/html/files.html
#newtree

以arm-Nexus5平台的Android-4.4.3为例，内容如下：
version=Android-4.4.3
platform=arm-Nexus5
directory=real
comment=iscas
link=
code_url=http://124.16.141.184/lxr/source/
note_url=http://124.16.141.171:81/mediawiki/index.php  
#new_tree

这个文件中写入的是将要部署的版本可以写多个版本例如
version=linux-3.5.4
platform=x86_32
directory=real
comment=iscas
link=
code_url=http://124.16.141.160/lxr-0401/source/
note_url=http://124.16.141.171:81/mediawiki/index.php/
#new_tree
version=linux-3.8.13
platform=x86_64
directory=real
comment=iscas
link=
code_url=http://124.16.141.160/lxr-0401/source/
note_url=http://124.16.141.171:81/mediawiki/index.php/
#new_tree

注意已经部署过的版本不要写在这里，可以写到confall文件中

9. 手动放置内核源码
如果已有源代码可以直接复制到对应目录，用以下命令将内核文件拷贝到source文件夹下，官方源码下载网址：https://www.kernel.org/pub/linux/kernel/v3.x/
cd /home/zhangsan
tar zxf linux-3.5.4.tar.gz  #生成linux3.5.4文件夹
mv linux-3.5.4   /mnt/freenas/DCG-RTL/source/

tar zxf linux-3.8.13.tar.gz  #生成linux3.8.13文件夹
mv linux-3.8.13   /mnt/freenas/DCG-RTL/source/
并将rline文件夹下的finalrline.rb、sched2rline.rb、saddress.rb、prepare.rb复制到每个内核文件夹下

10. 进入自动安装
chmod -R 777 /mnt/freenas/DCG-RTL/source/db-rtl-callgraph #使得目录对所有用户授权读写可执行，最重要的是给.sh文件增加可执行属性
#有些.sh脚本默认没有执行属性

cd /mnt/freenas/DCG-RTL/source/db-rtl-callgraph/auto_install

./start.sh
执行完脚本后进入到内核文件夹内，以linux-3.5.4的x86_32平台为例，执行命令
prepare.rb linux-3.5.4
saddress.rb linux-3.5.4 x86_32
sched2rline.rb linux-3.5.4 x86_32
finalrline.rb linux-3.5.4 x86_32

为每个内核版本在lxr文件夹下建立软链接,以linux-3.5.4为例
ln -s /mnt/freenas/DCG_RTL/source/linux-3.5.4 /usr/local/share/cg-rtl/lxr/lxr-code/




1. 自动配置脚本介绍
========
######1、	start.sh
自动运行总处理脚本包含envir.sh(设置lxr依赖环境)、run.sh(修改js文件)、call_reuslt.sh(生成画图依赖的数据)
######2、	设置lxr依赖环境envir.sh
1)、检查DCG-RTL依赖的软件是否已经存在，没有则安装。  
2)、设置服务器相关配置文件  
3)、从github下载DCG-RTL需要的脚本  
4)、下载配置文件中涉及版本的内核源码
######3、	修改js文件以及生成源码索引run.sh
1)、生成源码的索引文件并存放到数据库  
2)、在js文件中插入版本平台等信息
######4、	生成画图依赖的数据call_result.sh
根据版本和平台编译源码，并生成相应中间结果.sched2、.aux_info等文件，经过call_graph.rb的处理生成画图需要的中间结果。



1. 读取已部署的版本
====
运行auto_install文件夹下的record.sh脚本可以输出已经部署了哪些版本

1. 补充未部署的版本
====
用完整的conf文件，更名为confall，并与add_ver文件夹下文件一起复制到auto_install中，运行startnew.sh
