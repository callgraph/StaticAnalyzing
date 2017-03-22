db-rtl-callgraph
================

DataBase and RTL based CallGraph

Database version: 5.5.40

LXR version: 1.2.0

一、安装过程
================
如果不是root用户登录，请使用sudo su切换到root账号进行以下操作

1. 安装GIT
apt-get install git

2. 进入/home/zhangsan，新建work文件夹  
cd /home/zhangsan 
mkdir work  
cd work 
git clone https://jiadi:jdi5609@github.com/xyongcn/db-rtl-callgraph.git  

3. 安装数据库

3.1
apt-get install mysql-server mysql-client
其中会弹出窗口要求输入mysql的密码，直接按下回车即可（设置密码为空）
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

6. 配置服务器ip

这里以当前机器的ip地址为124.16.141.184为例，如果不是，则都要进行相应的修改。  
1、	修改/lxr/lxr.conf  
    ,’host_names’=>[‘//localhost’,’//124.16.141.184’]  
2、	修改call  
    $ttbasurl=sprintf(“http://124.16.141.184/lxr”);  
3、	修改watchlist  
    $ttbasurl=sprintf(“http://124.16.141.184/lxr”);  
如果有vulnermap、inst、diffe、energy、import、binder和taintrace的话也需要进行同样的修改。  

7.安装必要的软件、初始化数据库

如果是一台从未进行过部署的机器的话，则还需执行envir1.sh脚本（只需要运行一次,路径为：/mnt/freenas/DCG-RTL/source/db-rtl-callgraph/auto_install）
显示以下提示时
echo "*** MySQL - Creating global user lxr"
Enter password:   #直接按下回车
Enter password:   #直接按下回车


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

安装doxygen
apt-get install doxygen

修改complier文件夹下的config_doxygen文件，修改其INPUT和OUTPUT_DIRECTORY中的内容，以linux-3.5.4为例
INPUT=/mnt/freenas/DCG-RTL/source/linux-3.5.4
OUTPUT_DIRECTORY=/var/www/doxygen_kernel/linux-3.5.4

执行congfig_doxygen脚本
doxygen config_doxygen
11.如果要新增加部署版本，则重复步骤8,9,10即可
增加新版本后lxr/templates/html/html_head_btn_files下的plat.js文件内容可能会乱，以linux-3.5各个版本为例，将此文件按照如下格式进行修改：
dsy.add("0",["linux-3.5","linux-3.5.1","linux-3.5.2","linux-3.5.3","linux-3.5.4","linux-3.5.5","linux-3.5.6","linux-3.5.7"]);
dsy.add("0_0",["x86_32","x86_64"]);
dsy.add("0_0_0",["real"]);
dsy.add("0_0_1",["real"]);
dsy.add("0_1",["x86_32","x86_64"]);
dsy.add("0_1_0",["real"]);
dsy.add("0_1_1",["real"]);
dsy.add("0_2",["x86_32","x86_64"]);
dsy.add("0_2_0",["real"]);
dsy.add("0_2_1",["real"]);
dsy.add("0_3",["x86_32","x86_64"]);
dsy.add("0_3_0",["real"]);
dsy.add("0_3_1",["real"]);
dsy.add("0_4",["x86_32","x86_64"]);
dsy.add("0_4_0",["real"]);
dsy.add("0_4_1",["real"]);
dsy.add("0_5",["x86_32","x86_64"]);
dsy.add("0_5_0",["real"]);
dsy.add("0_5_1",["real"]);
dsy.add("0_6",["x86_32","x86_64"]);
dsy.add("0_6_0",["real"]);
dsy.add("0_6_1",["real"]);
dsy.add("0_7",["x86_32","x86_64"]);
dsy.add("0_7_0",["real"]);
dsy.add("0_7_1",["real"]);

######12. 动态数据处理成标准格式
a、self_time.py，把动态数据转化为标准格式并计算每个函数执行时间  
1)、需要更改动态数据对应的名和标准化的数据名（包含函数执行时间）  
2)、python self_time.py    
b、total_time.py:每个函数所有的执行之和    
1)、需要更改动态数据标准化的数据名和每个函数执行时间  
2)、python total_time.py

######13.动态数据倒入数据库
1) 以x86_32平台的linux-3.5.4内核举例： 
EnterDynamic-S2E.rb /mnt/freenas/DCG-RTL/source/linux-3.5.4-dyn/  linux-3.5.4 real x86_32
其中/mnt/freenas/DCG-RTL/source/linux-3.5.4-dyn/为存放标准格式的动态数据文件所在的文件夹
目前动态脚本对于动态数据文件名是写死的需要修改该脚本

S2ETimeList.rb
该脚本是把每个函数执行时间导入到数据库中  

2) 以arm-Nexus5平台的Android-4.4.3内核举例：
EnterDynamic-Nexux5.rb /mnt/freenas/DCG-RTL/source/Android-4.4.3-dyn/ Android-4.4.3 real arm-Nexus5
目前动态脚本对于动态数据文件名是写死的需要修改该脚本


四、	自动配置脚本介绍
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

五、	Lxr新增和修改脚本列表
====
######1、	函数调用图相关脚本：  
call：跟lxr结合的接口  
callgraph-perl：ruby与perl接口  
callgraph-sql.rb：函数调用图实现，数据库版本  
amplify.rb：函数调用图放大  
pic.rb：函数调用图菜单控件  
######2、	函数调用列表相关脚本：  
watchlist：跟lxr结合的接口  
watchfuc-perl：ruby与perl的接口  
watch-sql.rb：函数调用列表实现，数据库版  
######3、	漏洞地图相关脚本：  
vulnermap:跟lxr结合的接口  
vulnermap-perl：ruby与perl接口  
vulnermap.rb：漏洞地图的实现  
######4、	函数执行路径图相关脚本：  
Taintrace：跟lxr结合的接口  
taint-perl：ruby与perl的接口  
taint-trace.rb：函数执行路径的实现
######5、	Systrace相关脚本：
script.js、style.css：由真机下生成的trace.html页面分离  
systrace-perl：ruby与perl的接口
######6、	Js脚本实现多版本：  
templats/html/html_head_btn_files/plat.js  
######7、	修改的脚本  
lib/LXR/Common.pm Template.pm：新增控件

六、	读取已部署的版本
====
运行auto_install文件夹下的record.sh脚本可以输出已经部署了哪些版本

七、	补充未部署的版本
====
用完整的conf文件，更名为confall，并与add_ver文件夹下文件一起复制到auto_install中，运行startnew.sh

八、	部署ucore_plus
====
从以下地址下载ucore_plus的源代码
https://github.com/caoruidong/ucore_plus.git  
下载之后需要ucore_plus文件夹中的ucore文件夹拷贝到source目录下
compiler文件夹下的call_graph_db.rb文件,在第133行为ucore增加了一个新的判断条件  
if( ((line.index("(insn/f")==0 ||(line.index("(insn")==0) ||(line.index("(call_insn")==0) ) && flag1==0) ||(line.index("(jump_insn")==0) ||(line.index("call_insn") ) )  
改为了  
if( ((line.index("(insn/f")==0 ||(line.index("(insn")==0) ||(line.index("(call_insn")==0) ) && flag1==0) ||(line.index("(jump_insn")==0) ||(line.index("call_insn") ) || (line.index("(insn")==0 and $kernel_version=="ucore") )  

在第242行为ucore增加了一个新的判断条件  
if line2.index("call_insn")  
改为了  
if line2.index("call_insn") or line.index("function_decl")  

在第244行为ucore增加了一个新的判断条件  
if regex.match(line)  
改为了  
if regex.match(line) and regex1

九，基于python的文件上传功能
    环境：apache+mod_python+ubuntu
    1，安装apache：sudo apt-get install apache2
    2，安装mod_python库：sudo apt-get install libapache2-mod-python
    (如果/etc/apache2/mods-available/有python.load文件就说明安装好)
    3，配置mod_python：
    sudo vi /etc/apache2/conf.d/lxr
    加入如下内容：
          Alias /lxr /usr/local/share/cg-rtl/lxr
          <Directory /usr/local/share/cg-rtl/lxr>
             Options All
             AllowOverride All
             AddHandler mod_python .py
             PythonHandler dispatcher2
             PythonDebug On
          </Directory>
    4，重启apache服务器：
    sudo /etc/init.d/apache2 restart
    5，把dispatcher2.py，ChangeParameter.py，ExcuteTestScript.py，
    ImportSymbolTable.py，UploadFile.py，uploadpage.htm加入
    /usr/local/share/cg-rtl/lxr/中
    6，新修改，为了满周3提出的要求，弥补在./import中引用uploadpage.htm的不足，
    我重新写了一个叫做uploadpage.py的脚本来替代uploadpage.htm，现在可以满足
    “change”按钮的要求。
