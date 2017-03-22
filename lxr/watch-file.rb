#!/usr/bin/ruby  -w
require 'find'


inputpath=""
inputpath=Array.new(10)
i=0
ARGV.each do|arg|
inputpath[i]=arg
i=i+1
end
s_dir=inputpath[1]  #相对源路径
d_dir=inputpath[2]  #相对调用路径
sou_dir=inputpath[0] #根路径
$sou_dir=sou_dir
#puts sou_dir
#$d2sort=[]
################added 20121217
note_dir=inputpath[3]# added 20121217  html文件所在路径
$note_dir=""
$note_dir=note_dir
$d=""
$coname="" #the name of the list
$noteline="NULL"
$ss=""
$path=$note_dir.sub(/files\.html/,"")
$file_namex="dir_b2f783fb6f7ffe4cb4eca096cf72d607.html"
$c_inf1=[] #不重复的被调用的函数
$c_inf2=[] #对应被调用的函数调用的次数
$c_inf3=[] #调用函数定义的位置
$c_inf4=[] #被调用函数注释位置及链接
$key=[] #与目的路径相同的函数名、函数定义位置、行号
$num=1  #调用函数总的次数
$out_source="" #全局的外部函数调用关系列表
###############获取函数注释###############
#added 20130627
$dnum=0  #动态调用函数总的次数
$dfnum=0
$dc_inf1=[] #动态不重复的被调用的函数
$dc_inf2=[] #动态对应被调用的函数调用的次数
$dc_inf3=[] #动态调用函数定义的位置
$dc_inf4=[] #动态被调用函数注释位置及链接
#added 20130703
$sd=[] #既有静态调用又有动态调用
$static=[] #只有静态被调用
$dynamic=[] #只有动态被调用
#$dsort=[]
#added 20130725
module Creatfile
        def Creatfile.writein()
           wfile=File.new($sou_dir+"/.."+"/"+$coname,"w") 
           wfile.puts $sum_inf
           wfile.puts  $call_inf
           wfile.puts  $temp_s
           wfile.close
        end
       def Creatfile.writeout()
          bsfile=File.new($sou_dir+"/"+$coname,"r")
             while line=bsfile.gets
                print line			
             end
       end
end
#added 20130814 creat the name of the list
 $coname+=s_dir+"-"+d_dir+".list"
 $coname=$coname.gsub(/\/+/,"_")
 $coname=$coname.gsub(/\.c/,"_c")

#if !File.exist?($sou_dir+"/"+$coname)
#puts "*****************"
#added 20130627
module Readhtml
   def Readhtml.readfile(path_name,file_name)
      file_name="#{$path}/#{file_name}"
       #####added 20130102 ###########
      file_name=file_name.gsub(/\/\//,"/")
       #####added 20130102 ###########
      # puts file_name
      postion=path_name.index"/"   #search first /
     if !postion
         indexname=path_name
     else
      indexname=path_name[0..postion-1]  #before first / is index name
      path_name.slice!(0,postion+1)      # after / is next input path  name
     end
      if indexname.index(".S")
         return "NULL"
      end
      afile=File.new(file_name)
      while line=afile.gets
            postion1=line.index(">#{indexname}<")  ##between href and index name is next time read file name 
            postion2=line.index("href=\"")
           if postion1 and postion2
              file_of_name=line[postion2..postion1].sub("href=\"","").sub("\">","")   # get next time  need read file name  
             break
           end
      end
      afile.close
     # puts "##### #{file_of_name}  #{path_name}" 
       if !postion  ## if end of path name file name is wo need 
           return file_of_name
        end
      Readhtml.readfile(path_name,file_of_name)
   end
end

module Note
     def Note.get(new_dir,fuc_name)
                sfile=File.new("#{new_dir}","r")
#                 puts "********************************"
		lines=[]
                flag1=1          
		 while line=sfile.gets
			   # puts line
			 lines=lines.concat([line])      
                         if line.index("\<td class\=\"memname\"\>") and line.index(" #{fuc_name}")   
                             flag=0
                             flag1=0
                         while line=sfile.gets
                              if line.index("\<p\>") and flag==0
                                  #puts line
                                   $noteline=line
                                   flag=1
                              end
                              break if line.index("\<td class\=\"memname\"\>")
                          end 


                        end
                    end
                 sfile.close
if flag1==0
  if flag==0
   $noteline="NULL"
  end
                ex_line=lines
                s=-1
		for i in 0..ex_line.size-1
		    if ex_line[i].index("Functions</h2")
                      # puts ex_line[i]
                         s=i		 
		    end
		end 
              if s==-1
                 for i in 0..ex_line.size-1
                    if ex_line[i].index("the name of a register</h2")
                       s=i
                    end
                end
              end
     for i in s-1..ex_line.size-1
          postion1=ex_line[i].index(">#{fuc_name}</a>")
         if postion1
     t_line=ex_line[i][0..postion1]
          postion2=t_line.rindex("href=\"")
            t_line=t_line[postion2..postion1].sub("href=\"","").sub("\">","")
           $ss=t_line    
        end

     end
else
 $noteline="NULL"
 $ss=" "
end
end

end
###############获取函数注释###############
###############对表的操作################
module Table
      def Table.head()
          #第一个表的表头
     $sum_inf="<table  style=\"border-collapse: collapse\"  border=\"1\">"
     $sum_inf=$sum_inf+"<tr><td width=300px><center>source path</center></td><td width=300px><center>called path</center></td><td width=300px><center>static called numbers</center></td><td width=300px><center>static called function numbers</center></td><td width=300px><center>dynamic called numbers</center></td><td width=300px><center>dynamic called function numbers</center></td></tr>"
	 #第二个表的表头
	 $call_inf= "<table  style=\"border-collapse: collapse\"  border=\"1\">"
	 $call_inf=$call_inf+"<tr><td>Sequence Number</td><td>called function </td><td>static numbers</td><td>dynamic numbers</td><td> the Path</td><td>the fuction note</td></tr>"
       	 #第三个表的表头
	 $temp_s="<table  style=\"border-collapse: collapse\"  border=\"1\">"
	 $temp_s=$temp_s+"<tr><td>Sequence Number</td><td>Defined Functions</td><td>Path</td><td>Line Number</td><td>Called Functions</td><td>the Called Path</td><td>the Called Line Number </td><td>the defined path of the called</td><td>Defined line numbers</td></tr>"
       end
       
    def Table.body2()
	for i in 0..$c_inf1.size-1
	   $c_inf3[i]=$c_inf3[i]+" #{i}"
	end
	$c_inf3=$c_inf3.sort
	for i in 0..$c_inf1.size-1
	 k=$c_inf3[i].split(" ")[2].to_i
	$call_inf+="<tr><td>"+"#{i+1}"+"</td><td><a href=\"https://github.com/xyongcn/Kernel3.5.4Analysis/tree/master/"+"#{$c_inf3[i].split(" ")[0]}\#L#{$c_inf3[i].split(" ")[1].to_i}\""+">"+"#{$c_inf1[k]}"+"</a></td><td>"+"#{$c_inf2[k]}"+"</td><td>"+"#{$c_inf3[i].split(" ")[0]}"+"</td><td><a href=\"http://os.cs.tsinghua.edu.cn:280/doxy/"+"#{$c_inf4[k].split("&&")[1]}\""+">"+"#{$c_inf4[k].split("&&")[0]}"+"</a></td></tr>"  
    end
          
    end

#既有静态调用又有动态调用被调用函数表 added 20130703
def Table.sbody()
	for i in 0..$sd.size-1
	$call_inf+="<tr><td>"+"#{i+1}"+"</td><td><a href=\"https://github.com/xyongcn/Kernel3.5.4Analysis/tree/master/"+"#{$sd[i].split(",,")[3].split(" ")[0]}\#L#{$sd[i].split(",,")[3].split(" ")[1].to_i}\""+">"+"#{$sd[i].split(",,")[0]}"+"</a></td><td>"+"#{$sd[i].split(",,")[2]}"+"</td><td>"+"#{$sd[i].split(",,")[5]}"+"</td><td>"+"#{$sd[i].split(",,")[3].split(" ")[0]}"+"</td><td><a href=\"http://os.cs.tsinghua.edu.cn:280/doxy/"+"#{$sd[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$sd[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>"  
        end       
end

#只有静态被调用函数表 added 20130703
def Table.stbody()
 	for i in 0..$static.size-1
	$call_inf+="<tr><td>"+"#{$sd.size+1+i}"+"</td><td><a href=\"https://github.com/xyongcn/Kernel3.5.4Analysis/tree/master/"+"#{$static[i].split(",,")[3].split(" ")[0]}\#L#{$static[i].split(",,")[3].split(" ")[1].to_i}\""+">"+"#{$static[i].split(",,")[0]}"+"</a></td><td>"+"#{$static[i].split(",,")[2]}"+"</td><td>"+"0"+"</td><td>"+"#{$static[i].split(",,")[3].split(" ")[0]}"+"</td><td><a href=\"http://os.cs.tsinghua.edu.cn:280/doxy/"+"#{$static[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$static[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>"  
        end   

end

#只有动态被调用函数表 added 20130703
def Table.dybody()
        for i in 0..$dynamic.size-1
        $call_inf+="<tr><td>"+"#{$sd.size+$static.size+1+i}"+"</td><td><a href=\"https://github.com/xyongcn/Kernel3.5.4Analysis/tree/master/"+"#{$dynamic[i].split(",,")[3].split("&&")[0]}\#L#{$dynamic[i].split(",,")[3].split("&&")[1].to_i}\""+">"+"#{$dynamic[i].split(",,")[0]}"+"</a></td><td>"+"0"+"</td><td>"+"#{$dynamic[i].split(",,")[2]}"+"</td><td>"+"#{$dynamic[i].split(",,")[3].split("&&")[0]}"+"</td><td><a href=\"http://os.cs.tsinghua.edu.cn:280/doxy/"+"#{$dynamic[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$dynamic[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>"

#+"</td><td>"+"NULL"+"</td></tr>"
        end
end
     
       def Table.tail(sdir,ddir)
         #第一个表
         $sum_inf=$sum_inf+"<tr><td><center>"+"#{sdir}"+"</center></td><td><center>"+"#{ddir}"+"</center></td><td><center>"+"#{$num-1}"+"</center></td><td><center>"+"#{$c_inf1.size}"+"</center></td><td><center>"+"#{$dnum}"+"</center></td><td><center>#{$dfnum}</center></td></tr>"    #调用函数总的次数和调用的总的函数数
         $sum_inf=$sum_inf+"</table>"
          #动态被调用函数表    #added 20130627
        # $dcall_inf=$dcall_inf+"</table>"
         #第二个表
         $call_inf=$call_inf+"</table>"
         $temp_s=$temp_s+"</table>"   
        #  print $sum_inf
         # print $call_inf
         #print $temp_s
       end
end

###############对表的操作################

#比较静态调用与动态调用 added 20130703
module Sdsort  
       def Sdsort.arr()
com=[]
for i in 0..$c_inf1.size-1
   sjoin=$c_inf1[i]+"\,\,X\,\,"+$c_inf2[i].to_s+"\,\,"+$c_inf3[i]+"\,\,"+$c_inf4[i]
   com=com.concat(["#{sjoin}"])
end

for i in 0..$dc_inf1.size-1
   djoin=$dc_inf1[i]+"\,\,XX\,\,"+$dc_inf2[i].to_s+"\,\,"+$dc_inf3[i]+"\,\,"+$dc_inf4[i]
   com=com.concat(["#{djoin}"])
end
com.sort!
#puts com
#puts $dc_inf1

i=0
while i<=com.size-1 
  if i<com.size-1 and com[i].split(",,")[0]==com[i+1].split(",,")[0] 
    sd=com[i]+",,"+com[i+1].split(",,")[2]
    $sd=$sd.concat(["#{sd}"])
      i=i+2
  else
     if com[i].split(",,")[1]=="X"
       static=com[i]+",,"+"0"
       $static=$static.concat(["#{static}"])
     else
       dynamic=com[i]+",,"+"0"
       $dynamic=$dynamic.concat(["#{dynamic}"])
     end
     i=i+1
  end
 
end
#puts $sd
       end

end
#added 20130719

module D2handle  
        def D2handle.doutlst(out,dd)
                $dsort=[]
                $d2sort=[]
		flag=0
               # puts out
		bsfile=File.new("#{out}","r")
                     ex_line=bsfile.readlines
                     bsfile.close
              # puts ex_line
      # a=Time.now.to_f
             # puts "**************#{out}******"
            #   puts ex_line
               if "#{dd}"=="full" 
      
                 ex_line.each do |x|
                  D2handle.ccat(x)
                 end
                  
               else
                 # puts "*******"
                   regex=/\sTO\:\w*\,\/#{dd}\S*\:\d*\s+AT\:/
                   # puts regex
                   ex_line.each do |x|
                      if regex.match(x)
                       # puts "***************"
                        D2handle.ccat(x)
                      # else
                       # puts "**11*"
                     end 
                                  
                   end
                   
               end
       # puts $dsort
      # b=Time.now.to_f
      # p b-a
                
                D2handle.pre_sort()
      # c=Time.now.to_f
      # p c-b
                D2handle.sort()
      # d=Time.now.to_f
      # p d-c
               # $dnum=$dnum+$dsort.size
               # $dfnum=$dfnum+$dc_inf1.size     
                D2handle.note()
                # e=Time.now.to_f
     # p e-d
	end


def D2handle.ccat(x)
      f=x.split(" ")  #把"dynoutlst" 或者"dynDoutlst"每一行用空格隔开
      #def_fun_name=f[4].split(",")[0].split(":")[1]
      #def_fun_path=f[4].split(",")[1].split(":")[0]
      call_fun_name=f[5].split(",")[0].split(":")[1]
      call_def_path=f[5].split(",")[1].split(":")[0]
      call_def_line_num=f[5].split(",")[1].split(":")[1] #added 20130710
      dsort="#{call_def_path}\,"+"#{call_def_line_num}\,"+"#{call_fun_name}"
      $dsort=$dsort.concat(["#{dsort}"])
end

def D2handle.pre_sort()
$dsort.sort!
i=0
while i<=$dsort.size-1
    if i==$dsort.size-1
        $d2sort=$d2sort.concat(["#{$dsort[i]}"+"\,1"])
      break
    end
     for j in (i+1)..($dsort.size-1)
           if $dsort[i]!=$dsort[j]
              $d2sort=$d2sort.concat(["#{$dsort[i]}"+"\,"+"#{j-i}"])
              i=j
              break         
           end
        if j==($dsort.size-1)
            $d2sort=$d2sort.concat(["#{$dsort[i]}"+"\,"+"#{j-i+1}"])
              i=j+1
        end

     end
end
end


def D2handle.sort()#added 20130710
	for i in 0..$d2sort.size-1
                if !$dc_inf1.index("#{$d2sort[i].split(",")[2]}")
             #    puts $dc_inf1.index("#{$d2sort[i].split(",")[2]}")
		$dc_inf1=$dc_inf1.concat(["#{$d2sort[i].split(",")[2]}"])
		$dc_inf2=$dc_inf2.concat(["#{$d2sort[i].split(",")[3]}"])
		$dc_inf3=$dc_inf3.concat(["#{$d2sort[i].split(",")[0]}&&#{$d2sort[i].split(",")[1]}"]) 
                else
                  $dc_inf2[$dc_inf1.index("#{$d2sort[i].split(",")[2]}")]="#{$dc_inf2[$dc_inf1.index("#{$d2sort[i].split(",")[2]}")]}".to_i+"#{$d2sort[i].split(",")[3]}".to_i
                end
          end
end

def D2handle.note()
     for i in 0..$dc_inf1.size-1
       # puts $dc_inf1[i]
       # puts "****#{$dc_inf3[i].split("&&")[0]}****************"
       if "#{$dc_inf3[i].split("&&")[0]}"!="NULL"
       $temp_d=Readhtml.readfile("#{$dc_inf3[i].split("&&")[0].sub(/\//,"")}",$file_namex) ##modify 20121226
               $d=$temp_d
              if $d=="NULL"
                 $noteline="NULL"
                 $ss=""
                # puts "#{$noteline}*****#{$ss}"
                 $dc_inf4[i]="#{$noteline}&&#{$ss}"
              else
                new_dir=$note_dir.sub(/files\.html/,"")+"#{$d}"
                # puts "*******#{new_dir}%%%%%%%%%%"
                Note.get(new_dir,"#{$dc_inf1[i]}")
                $dc_inf4[i]="#{$noteline}&&#{$ss}"
               # puts "#{$noteline}*****#{$ss}"
             end
      end
     end
end


end

                                            
###############对fillist和outlst#######################
module Handle  
        def Handle.fillist(fill,dd)
               d_size=dd.chop.split("/").size
                bsfile=File.new("#{fill}","r")
               ex_line=bsfile.readlines
                #puts ex_line  #这时ex_line有空的情况
		bsfile.close 
                pp=[]  #"fillDudfctlst" 或者"filludfctlst"里不重复的函数名
		$key=[] #与目的路径相同的函数名、函数定义位置、行号
		lines_size=ex_line.size
                #puts lines_size
		for i in 0..ex_line.size-1
			f=ex_line[i].split(" ")  #把"fillDudfctlst" 或者"filludfctlst"每一行用空格隔开
		      if pp.index("#{f[0]}")
			 else
			  pp=pp.concat(["#{f[0]}"]) #加上不重复的函数名
			 s=f[1].split("/")  #对于调用外部函数定义的路径，用"/"隔开
			match="#{s[0]}"  #先把第一个赋值
			 
			for j in 1..d_size-1
			   match="#{match}"+"/"+"#{s[j]}"  #选与调用路径相同的数目赋予"match",使与调用路径数相同
			end

		    
		       if "#{match.chomp}"=="#{dd.chomp}"    #如果这个函数名的“match”与调用路径相同，则把函数名、函数定义路径、行号放在$key里
			  #if $key.index("#{f[0]}")
			  #else
			     $key=$key.concat(["#{f[0]}"]).concat(["#{f[1]}"]).concat(["#{f[2]}"])
                             #added 20121217                           
                            $temp_d=Readhtml.readfile("#{f[1]}",$file_namex) ##modify 20121226
                            $d=$temp_d
                            if $d=="NULL"
                               $noteline="NULL"
                               $ss=""
                            else
                           new_dir=$note_dir.sub(/files\.html/,"")+"#{$d}"
                            # puts "*******#{new_dir}%%%%%%%%%%"
                            Note.get(new_dir,"#{f[0]}")
                            #puts $noteline
                            #puts $ss
                            end
                            $key=$key.concat(["#{$noteline}"])
	                    $key=$key.concat(["#{$ss}"])
                            
                             #added 20121217 
			 # end  
		       end
		   end
		end
        end

    def  Handle.outlst(out)
             sfile=File.new("#{out}","r")
              tflag=0
              temp_fun=""
		while line=sfile.gets                 #打开源路径的外部调用关系列表
			pos1=line.index("FUNCTION")
			  while pos1 and line
				 # $num=$num+1
				  s1=line.chop.split(" ")   #对于fuction用空格隔开
				   fuc_line="<tr><td>"+"#{$num}"+"</td><td>"+"#{s1[1]}"+"</td><td>"+"#{s1[2]}"+"</td><td>"+"#{s1[3]}"+"</td>" #函数定义行，包括sequence、定义函数等
				if tflag>0
			       # print "#{temp_fun}"
		$temp_s=$temp_s+"#{temp_fun}"  #如果有函数调用行则加入
				    tflag=0
				 end
				 temp_fun=fuc_line  #把行数定义行给"temp_fun"
				 #puts fuc_line
		  
				 while line=sfile.gets 
				      call_line="" #函数调用行
				    break if line.index("FUNCTION")  #如果遇到函数调用行
				       
				      s2=line.chop.split(" ")  #函数调用行用空格隔开
				      a=line.split(" ")[1]     #a为被调用的函数名字
				       call_line+=line
				                    
				         if $key.index("#{a}")  #$key里找到被调用函数的位置
                           
				                   if  $c_inf1.index("#{a}") 
				                           $c_inf2[$c_inf1.index("#{a}")]+=1  #如果$c_inf1里已经有了这个函数，被调用次数加1
				                     else
				                        $c_inf1=$c_inf1.concat(["#{a}"])
				                        $c_inf2=$c_inf2.concat([1])  #如果$c_inf1里没有这个函数，被调用次数赋值为1
				                        $c_inf3=$c_inf3.concat(["#{$key[($key.index("#{a}")+1)]} #{$key[($key.index("#{a}")+2)]}"])   #调用函数定义的位置
				                        $c_inf4=$c_inf4.concat(["#{$key[($key.index("#{a}")+3)]}&&#{$key[($key.index("#{a}")+4)]}"])   #added 20121217 调用函数函数注释          
				                    end

				                 tflag=tflag+1

				               if tflag>1
				               temp_fun+="<tr><td>"+"#{$num}"+"</td><td></td><td></td><td></td><td>"+"#{s2[1]}"+"</td><td>"+"#{s2[3]}"+"</td><td>"+"#{s2[4]}"+"</td><td>"+$key.at($key.index("#{a}")+1)+"</td><td>"+$key.at($key.index("#{a}")+2)+"</td></tr>" # #call_line.chop+
				               else
				               temp_fun+="<td>"+"#{s2[1]}"+"</td><td>"+"#{s2[3]}"+"</td><td>"+"#{s2[4]}"+"</td><td>"+$key.at($key.index("#{a}")+1)+"</td><td>"+$key.at($key.index("#{a}")+2)+"</td></tr>"
				              end     
				          $num=$num+1
				          
				        end
				 end
		  if(line!=nil)
		       pos1=line.index("FUNCTION")
		     end

			 end
		  if tflag>0
		    #  print "#{temp_fun}"
		 $temp_s=$temp_s+"#{temp_fun}"
		       tflag=0
		  end

                    end
                sfile.close
	end

 end  
###############对fillist和outlst#######################

if "#{s_dir}"=="full"
#$sou_dir=sou_dir
$ARGV=d_dir
$module=[]
Table.head() #三个表的表头
module Read
       def Read.modules(dir_dir)  #找到除被调用模块以外的其他模块
      # print dir_dir
       d_size=dir_dir.split("/").size
      # print d_size
       dir=dir_dir.split("/")
       dir0=dir[0]
      # puts dir0
             Dir.foreach($sou_dir) do |file| 
        if file!="." and file!=".." and file!=".tmp_versions" and file!=".git" and file!="#{dir0}"
              if File.directory?($sou_dir+"/"+file)
                 $module=$module.concat([file])
              #else 保留对文件的处理，以便于以后的扩展  
              end
        end
       end
       end
end
Read.modules($ARGV)
#puts $module
for i in 0..$module.size-1
       src0=$sou_dir+"/"+$module[i]+"/"+$module[i]+".Doutlst"
       src1=$sou_dir+"/"+$module[i]+"/"+$module[i]+".fillDudfctlst"
       src2=$sou_dir+"/"+$module[i]+"/"+$module[i]+".dynDoutlst"
      # puts src1
       #puts src2
       if File.exist?(src0) and File.exist?(src1) #and File.exist?(src2)
       if !File.new(src0).stat.zero? and !File.new(src1).stat.zero? # and !File.new(src2).stat.zero?
       Handle.fillist(src1,$ARGV)
       Handle.outlst(src0)   
       end
       end
       if File.exist?(src2)
      #  puts "****************"
      D2handle.doutlst(src2,d_dir)
      #  puts src2
       $dnum=$dnum+$dsort.size
      # puts $dnum
      # puts $dc_inf2
       end
      # puts $dc_inf1
      # puts $c_inf1
     # Sdsort.arr()

end
 #$dnum=$dnum+$dsort.size
 $dfnum=$dfnum+$dc_inf1.size
Sdsort.arr()
#puts $c_inf1
#Table.body2()

Table.sbody()
Table.stbody()
Table.dybody()
Table.tail("",$ARGV)
Creatfile.writein()
#Creatfile.writeout()
#######转折点
else     
########转折点

####20121206###
s_size=s_dir.split("/").size  #源路径的路径数
#d_size=d_dir.split("/").size   #调用路径的路径数
 if "#{d_dir}"=="full"
       d_size=0
  else
       d_size=d_dir.split("/").size   #调用路径的路径数
  end
#####20121206

src_dir="#{sou_dir}"+"/"+"#{s_dir}"  #+s_dir.split("/")[s_size-1] #源路径
src_d=src_dir+"/"+"#{s_dir.split("/")[s_size-1]}"+"."+"Doutlst"
src_dd=src_dir+"/"+"#{s_dir.split("/")[s_size-1]}"+"."+"fillDudfctlst" #源路径为目录时，使用文件
src_dyn=src_dir+"/"+"#{s_dir.split("/")[s_size-1]}"+"."+"dynDoutlst"
src_f=src_dir.sub(/\.c/,"")+"."+"outlst"
src_ff=src_dir.sub(/\.c/,"")+"."+"filludfctlst"  #源路径为文件时，使用文件
src_ddyn=src_dir.sub(/\.c/,"")+"."+"dynoutlst"

if File.directory?("#{src_dir}")
        
       bsfile=File.new("#{src_dd}","r")  #判断源路径为目录还是文件？
      else
      # puts src_ff
       bsfile=File.new("#{src_ff}","r")
end


#lines=" "
#    while line=bsfile.gets
#           lines+=line           #把"fillDudfctlst" 或者"filludfctlst"放在一个数组里
#    end
ex_line=bsfile.readlines
bsfile.close     
pp=[]  #"fillDudfctlst" 或者"filludfctlst"里不重复的函数名
$key=[] #与目的路径相同的函数名、函数定义位置、行号
#ex_line=lines.split("\n")
for i in 0..ex_line.size-1
        f=ex_line[i].split(" ")  #把"fillDudfctlst" 或者"filludfctlst"每一行用空格隔开
      if pp.index("#{f[0]}")
         else
          pp=pp.concat(["#{f[0]}"]) #加上不重复的函数名
       #######20121206
          if "#{d_dir}"=="full" # added 20121206
              $key=$key.concat(["#{f[0]}"]).concat(["#{f[1]}"]).concat(["#{f[2]}"]) 
               #added 20121217
                        if f[1]!="NULL"
                             $temp_d=Readhtml.readfile("#{f[1]}",$file_namex) ##modify 20121226
  #  puts "*** #{$d}  #{$temp_d}"

                             $d=$temp_d
                              new_dir=$note_dir.sub(/files\.html/,"")+"#{$d}"
                            if $d=="NULL"
                              $noteline="NULL"
                              $s=""
                            else
                              Note.get(new_dir,"#{f[0]}")
                            end
                            $key=$key.concat(["#{$noteline}"])
	                    $key=$key.concat(["#{$ss}"])
                      end
                             #added 20121217
           else       
       ######20121206
              s=f[1].split("/")  #对于调用外部函数定义的路径，用"/"隔开
              match="#{s[0]}"  #先把第一个赋值
         
              for j in 1..d_size-1
                 match="#{match}"+"/"+"#{s[j]}"  #选与调用路径相同的数目赋予"match",使与调用路径数相同
              end

    
              if "#{match}"=="#{d_dir}"    #如果这个函数名的“match”与调用路径相同，则把函数名、函数定义路径、行号放在$key里
                   $key=$key.concat(["#{f[0]}"]).concat(["#{f[1]}"]).concat(["#{f[2]}"])
  #added 20121217          
                     if f[1]!="NULL"
                          $temp_d=Readhtml.readfile("#{f[1]}",$file_namex) ##modify 20121226 
# puts "*** #{$d}  #{$temp_d}"

                          $d=$temp_d 
                           if $d=="NULL"
                             $noteline="NULL"
                             $ss=""
                            else       
                           new_dir=$note_dir.sub(/files\.html/,"")+"#{$d}"
                             Note.get(new_dir,"#{f[0]}")
                          end
                            $key=$key.concat(["#{$noteline}"])
	                    $key=$key.concat(["#{$ss}"])
                   end
                             #added 20121217
              end  
           end
       end
end
Table.head() #三个表的表头
   #puts src_dyn
   #puts d_dir
if File.directory?("#{src_dir}")
    Handle.outlst(src_d)
    if File.exist?(src_dyn)
    D2handle.doutlst(src_dyn,d_dir)
     else
         $dsort=[]
         $d2sort=[]
    end
    #puts src_dyn
    #puts d_dir
   else
    Handle.outlst(src_f)
   if File.exist?(src_ddyn)
    D2handle.doutlst(src_ddyn,d_dir)
    else
     $dsort=[]
     $d2sort=[]
   end
end
    $dnum=$dnum+$dsort.size
    $dfnum=$dfnum+$dc_inf1.size
					
#puts $dc_inf1
Sdsort.arr()
#D2handle.note()
#puts $sd.size
#puts $static.size
#puts $dynamic.size
#Table.body2()
Table.sbody()
Table.stbody()
Table.dybody()
Table.tail(s_dir,d_dir)
Creatfile.writein()
#Creatfile.writeout()
#D2handle.note()
end
#else
#Creatfile.writeout()
#end

