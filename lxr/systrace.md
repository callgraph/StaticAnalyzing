systrace分析服务部署
1.	将script.js、style.css两个文件上传至服务器/usr/local/share/cg-rtl/lxr/templates/路径。

2.	将systrace-perl脚本上传至服务器usr/local/share/cg-rtl/lxr/路径。
	此文件的作用是生成lxr的头和尾，接受并处理来自前端的参数：path0和path1，然后执行new.rbx生成中间的Systrace页面，最终生成一个完整的页面。

3.	将Systrace嵌入lxr
1)	修改usr/local/share/cg-rtl/lxr/.htaccess文件，将systrace-perl加入到该文件选项中，则Apache会调用perl模块，将生成的结果页面返回，而不是将源码页面返回。
2)	修改/usr/local/share/cg-rtl/lxr/lib/LXR/Template.pm，在lxr头部和尾部分别追加一个按钮盒一个超链接。搜索call，按照call的配置方法配置systrace-perl即可。
