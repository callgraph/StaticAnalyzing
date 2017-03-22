对下拉框的功能数目进行变化（增加/减少），除了需要更改html-head-btn.html外，还要更改Template.pm文件（usr/local/share/cg-rtl/lxr/lib/LXR）.  
其中，注意修改"sub modeexpand"中的$modename="功能项"的代码段。  
此次后添加项得不到对应提醒，就是缺少了"$modeselect"项的对应代码。  
