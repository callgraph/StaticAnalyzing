当服务器的ip发生了变化的时候，需要重新配置服务器ip
这里以服务器的80端口变为http://124.16.141.181:23043 ，8080端口变为http://124.16.141.181:23044 为例，进行说明。  
1、	修改/lxr/lxr.conf  
    ,’host_names’=>[‘//localhost’,’http://124.16.141.181:23043’]  
2、	修改call的$ttbasurl中的ip地址  
    $ttbasurl=sprintf(“http://124.16.141.181:23043/lxr”);  
3、	修改watchlist的$ttbasurl中的ip地址  
    $ttbasurl=sprintf(“http://124.16.141.181:23043/lxr”);  
4、 同上面类似，修改vulnermap和taintrace以及binder、diffe、energy、import、inst的$ttbasurl  
5、 修改调用了8080端口中的jsp页面的文件，inst-perl和import-perl中的$result_link_name的ip地址  
    $result_link_name=sprintf("http://124.16.141.181:23044/xxx");
