# 获取内核依赖文件帮助文档
为了剔除二次编译中一些与内核无关的文件如scripts文件夹中的文件，编写了depend.rb脚本，使用方法为depend.rb makeinfo.txt re_compile.sh  
现在的auto_run.rb脚本中直接排除了scripts文件夹，以后可以直接用depend.rb替换auto_run.rb

## 实现方法
编译中有三种语句  
gcc -o xxx.o xxx.c|s 说明 xxx.o依赖xxx.c|s文件  
ld -o xx x1.o x2.o ... 或ar rcsD xx x1.o x2.o ...说明xx依赖x1.o,x2.o...即xx依赖x1.o的依赖文件和x2.o的依赖文件  
采用字典的方式表示他们的依赖关系，这样就可以一层层地推导出内核依赖的文件。例如
```
gcc -o net.o net1.c net2.c
gcc -o fs.o fs1.c fs2.c
ld -o vmlinux net.o fs.o
```
根据前两条语句可以得到如下字典  
{net.o:[net1.c,net2.c],fs.o:[fs1.c,fs2.c]}  
根据第三条可知vmlinux依赖net.o和fs.o，即vmlinux:[net1.c,net2.c,fs1.c,fs2.c]