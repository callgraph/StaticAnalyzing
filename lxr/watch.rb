#!/usr/bin/ruby  -w
require 'find'
require'mysql'

inputpath=""
inputpath=Array.new(10)
i=0
ARGV.each do|arg|
	inputpath[i]=arg
	i=i+1
end
$s_dir=inputpath[1]  #相对源路径
$d_dir=inputpath[2]  #相对调用路径
sou_dir=inputpath[0] #根路径

######路径的输入
$sou_dir=sou_dir

################added 20121217
note_dir=inputpath[3]# added 20121217  html文件所在路径
$mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')  #added 20131017 mysq connect
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
$temp_s=""
########added20131017 translate the virtual path to the real ################
module Virtual2real
	def Virtual2real.only_file(vpath1)
		path1list=[]
		rs1=$mydb.query("SELECT * FROM VLIST WHERE V_path LIKE \"#{vpath1}%\"")
		rs1.each_hash do |row1|
			rpath1=row1['P_path']
			path1list.push(rpath1)
			return path1list[0]
		end
	end
	def Virtual2real.select_real_file(vpath0)
		rs=$mydb.query("SELECT count(*) FROM PLIST WHERE P_path='#{vpath0}'")
		rscount=0
		rs.each_hash do |row|
			rscount=row['count(*)']
		end
		if rscount.to_i!= 0 
			vpath0=vpath0        #the current path is in the Real Code
		else    #the current path is not in the Real Code
			vpath0=Virtual2real.only_file(vpath0)
		end
		return vpath0
	end
end

#added 20130725 把函数列表写到文件里
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
	$coname+=$s_dir+"-"+$d_dir+".list"
	$coname=$coname.gsub(/\/+/,"_")
	$coname=$coname.gsub(/\.c/,"_c")
=begin
#added 20130627
module Readhtml
	def Readhtml.readfile(path_name,file_name)   # 所读函数文件路径以及文件名字
		file_name="#{$path}/#{file_name}"
		
		#####added 20130102 ###########
		file_name=file_name.gsub(/\/\//,"/")
		
		#####added 20130102 ###########
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
		if !postion  ## if end of path name file name is wo need 
			return file_of_name
		end
		Readhtml.readfile(path_name,file_of_name)
	end
end

module Note
	def Note.get(new_dir,fuc_name) ###在所在路径的Html地方去找函数的注释
		sfile=File.new("#{new_dir}","r")
		lines=[]
		flag1=1          
		while line=sfile.gets
			lines=lines.concat([line])      
			if line.index("\<td class\=\"memname\"\>") and line.index(" #{fuc_name}")   
				flag=0
				flag1=0
				while line=sfile.gets
					if line.index("\<p\>") and flag==0
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
=end
#added 20130627
module Readhtml
   def Readhtml.readfile(path_name,file_name)
      file_name="#{$path}/#{file_name}"
       #####added 20130102 ###########
      file_name=file_name.gsub(/\/\//,"/")
       #####added 20130102 ###########
      # puts file_name
      #  puts path_name
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
            
       #    puts postion1
        #   puts postion2 
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
                         lines=lines.concat([line])
                         if line.index("\<td class\=\"memname\"\>") and line.index(" #{fuc_name}")
                             flag=0
                             flag1=0
                         while line=sfile.gets
                              if line.index("\<p\>") and flag==0
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
         if postion1 and fuc_name!=""
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
			k=$c_inf3[i].split(" ")[2].to_i	#k中存放着函数定义位置的序号
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
		end
	end
     
	def Table.tail(sdir,ddir)
		#第一个表
		$sum_inf=$sum_inf+"<tr><td><center>"+"#{sdir}"+"</center></td><td><center>"+"#{ddir}"+"</center></td><td><center>"+"#{$num-1}"+"</center></td><td><center>"+"#{$c_inf1.size}"+"</center></td><td><center>"+"#{$dnum}"+"</center></td><td><center>#{$dc_inf1.size}</center></td></tr>"    #调用函数总的次数和调用的总的函数数
		$sum_inf=$sum_inf+"</table>"
          
		#动态被调用函数表    #added 20130627
		#第二个表
		$call_inf=$call_inf+"</table>"
		$temp_s=$temp_s+"</table>"   
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
	end
end
#added 20130719

module D2Handle
	def D2Handle.common(s_dir, d_dir)
		s_dir=(s_dir+"/").gsub(/\/+/,"/")
		d_dir=(d_dir+"/").gsub(/\/+/,"/") if d_dir!=""	
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
			
		fC_name=""
		fC_dfile=""
		fC_dline=0
=begin	此方法缓慢，已废弃
		rsF=mydb.query("SELECT DISTINCT f_name,f_dfile,f_dline,f_id FROM FDLIST, DLIST WHERE FDLIST.f_dfile LIKE \"#{$s_dir}%\" AND FDLIST.f_id=DLIST.F_point")
		rsF.each_hash do |rowF|
			rsC=mydb.query("SELECT DISTINCT f_name,f_dfile,f_dline FROM FDLIST, DLIST WHERE DLIST.F_point=\"rowF['f_id']\" AND FDLIST.f_dfile LIKE \"#{$d_dir}%\" AND FDLIST.f_id=DLIST.C_point")
			rsC.each_hash do |rowC|
					fC_name=rowC['f_name']
					fC_dfile=rowC['f_dfile']
					fC_dline=rowC['f_dline'].to_i

					if  $dc_inf1.index(" #{fC_name} ") 
						$dc_inf2[$dc_inf1.index(" #{fC_name} ")]+=1  #如果$c_inf1里已经有了这个函数，被调用次数加1
					else
						$dc_inf1=$dc_inf1.concat([" #{fC_name} "])
						$dc_inf2=$dc_inf2.concat([1])	#如果$c_inf1里没有这个函数，被调用次数赋值为1
						$dc_inf3=$dc_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
		#				$dc_inf4=$dc_inf4.concat(["#{$noteline}&&#{$ss}"])   #added 20121217 调用函数函数注释
					end
					$dnum=$dnum+1
			end

=end
		rsDO=mydb.query("SELECT DLIST_point FROM DOLIST WHERE F_path=\"#{s_dir}\" AND C_path LIKE \"#{d_dir}%\"")
		rsDO.each_hash do |rowDO|
			dlist_point=rowDO['DLIST_point'].to_i

#单表-通过指针关联查找
			rsD=mydb.query("SELECT C_point FROM DLIST WHERE DLIST_id=#{dlist_point}")
			rsD.each_hash do |rowD|
				c_point=rowD['C_point']
				rsC=mydb.query("SELECT f_name, f_dfile, f_dline FROM FDLIST WHERE f_id=#{c_point}")
				rsC.each_hash do |rowC|
					fC_name=rowC['f_name']
					fC_dfile=rowC['f_dfile']
					fC_dline=rowC['f_dline'].to_i
					if  $dc_inf1.index(" #{fC_name} ")
						$dc_inf2[$dc_inf1.index(" #{fC_name} ")]+=1  #如果$dc_inf1里已经有了这个函数，被调用次数加1
					else
						$dc_inf1=$dc_inf1.concat([" #{fC_name} "])
						$dc_inf2=$dc_inf2.concat([1])	#如果$dc_inf1里没有这个函数，被调用次数赋值为1
						$dc_inf3=$dc_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
#puts("DOLIST:#{fC_name}\t#{fC_dfile}")
			#			$dc_inf4=$dc_inf4.concat(["#{$noteline}&&#{$ss}"])   #调用函数函数注释
#                                         $dc_inf4=$dc_inf4.concat(["NULL&&NULL}"])   #调用函数函数注
					end
                                  
					$dnum=$dnum+1
				end
			end
		end
		for i in 0..$dc_inf1.size-1
			$dc_inf1[i]=$dc_inf1[i].gsub(/\s+/,"")
		end	

=begin	#多表-联合查找
			rsD=mydb.query("SELECT f_name,f_dfile,f_dline FROM FDLIST,DLIST WHERE DLIST_id=#{dlist_point} AND FDLIST.f_id=DLIST.C_point")			
			rsD.each_hash do |rowD|
				fC_name=rowD['f_name']
				fC_dfile=rowD['f_dfile']
				fC_dline=rowD['f_dline'].to_i
				if  $dc_inf1.index(" #{fC_name} ") 
					$dc_inf2[$dc_inf1.index(" #{fC_name} ")]+=1  #如果$c_inf1里已经有了这个函数，被调用次数加1
				else
					$dc_inf1=$dc_inf1.concat([" #{fC_name} "])
					$dc_inf2=$dc_inf2.concat([1])	#如果$c_inf1里没有这个函数，被调用次数赋值为1
					$dc_inf3=$dc_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
		#			$dc_inf4=$dc_inf4.concat(["#{$noteline}&&#{$ss}"])   #added 20121217 调用函数函数注释
				end
				$dnum=$dnum+1
			end
		end
=end


	end
	
	def D2Handle.full(d_dir)
#puts d_dir
		d_dir=(d_dir+"/").gsub(/\/+/,"/")		
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
			
		fC_name=""
		fC_dfile=""
		fC_dline=0
		
		rsDO=mydb.query("SELECT DISTINCT DLIST_point FROM DOLIST WHERE C_path LIKE \"#{d_dir}%\"")
		rsDO.each_hash do |rowDO|
			dlist_point=rowDO['DLIST_point'].to_i

#单表-通过指针关联查找
			rsD=mydb.query("SELECT C_point FROM DLIST WHERE DLIST_id=#{dlist_point}")
			rsD.each_hash do |rowD|
				c_point=rowD['C_point']
				rsC=mydb.query("SELECT f_name, f_dfile, f_dline FROM FDLIST WHERE f_id=#{c_point}")
				rsC.each_hash do |rowC|
					fC_name=rowC['f_name']
					fC_dfile=rowC['f_dfile']
					fC_dline=rowC['f_dline'].to_i
					if  $dc_inf1.index(" #{fC_name} ") 
						$dc_inf2[$dc_inf1.index(" #{fC_name} ")]+=1  #如果$dc_inf1里已经有了这个函数，被调用次数加1
					else
						$dc_inf1=$dc_inf1.concat([" #{fC_name} "])
						$dc_inf2=$dc_inf2.concat([1])	#如果$dc_inf1里没有这个函数，被调用次数赋值为1
						$dc_inf3=$dc_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
			#			$dc_inf4=$dc_inf4.concat(["#{$noteline}&&#{$ss}"])   #调用函数函数注释
#				            $dc_inf4=$dc_inf4.concat(["NULL&&NULL"])   #调用函数函数注释
	
                                       end
					$dnum=$dnum+1
				end
			end
		end
		for i in 0..$dc_inf1.size-1
			$dc_inf1[i]=$dc_inf1[i].gsub(/\s+/,"")
		end		
	end

   def D2Handle.note(type_t)
       c_temp_inf1=[]
       c_temp_inf3=[]
       c_temp_inf4=[]
     if type_t==1
        c_temp_inf1=$c_inf1
        c_temp_inf3=$c_inf3
    
     else
       c_temp_inf1=$dc_inf1
       c_temp_inf3=$dc_inf3
     end

     for i in 0..c_temp_inf1.size-1
       if "#{c_temp_inf3[i].split(" ")[0]}"!="NULL"
       $temp_d=Readhtml.readfile("#{c_temp_inf3[i].split(" ")[0]}",$file_namex) ##modify 20121226
               $d=$temp_d
              if $d=="NULL"
                 $noteline="NULL"
                 $ss=""
                 c_temp_inf4[i]="#{$noteline}&&#{$ss}"
              else
                new_dir=$note_dir.sub(/files\.html/,"")+"#{$d}"
                Note.get(new_dir,"#{$dc_inf1[i]}")
                c_temp_inf4[i]="#{$noteline}&&#{$ss}"
             end
      end
     end
     return c_temp_inf4
 end


end

module Handle
	def Handle.common(s_dir, d_dir)
        	puts s_dir
		puts d_dir
		s_dir=(s_dir+"/").gsub(/\/+/,"/")
		d_dir=(d_dir+"/").gsub(/\/+/,"/") if d_dir!=""
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
		
		temp_fun=""
		
		fF_name=""
		fF_dfile=""
		fF_dline=0
		fC_name=""
		fCd_file=""
		fCd_line=0
		fC_dfile=""
		fC_dline=0
=begin	使用SLIST查找--可以查到同目录间的调用
		rsS=mydb.query("SELECT * FROM SLIST WHERE F_dfile like \"#{$s_dir}\/%\" AND C_dfile LIKE \"#{$d_dir}\/%\"")	#遍历SLIST
		rsS.each_hash do |rowS|	#对于SLIST中的每一行
			fCd_file=rowS['Cd_file']
			fCd_line=rowS['Cd_line'].to_i
		
			##从数据库中查找第二个表的内容
			if rowS['C_point']
				rsF=mydb.query("SELECT * FROM FDLIST WHERE f_id=#{rowS['C_point']}")	#根据SLIST中的F_point在FDLIST中查找f_name
				rsF.each_hash do |rowF|
					fC_name=rowF['f_name']
					fC_dfile=rowF['f_dfile']
					fC_dline=rowF['f_dline'].to_i
				end
			else
				fC_name=rowS['C_name']		
			end
			
			if  $c_inf1.index(" #{fC_name} ") 
				$c_inf2[$c_inf1.index(" #{fC_name} ")]+=1  #如果$c_inf1里已经有了这个函数，被调用次数加1
			else
				$c_inf1=$c_inf1.concat([" #{fC_name} "])
				$c_inf2=$c_inf2.concat([1])	#如果$c_inf1里没有这个函数，被调用次数赋值为1
				$c_inf3=$c_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
#				$c_inf4=$c_inf4.concat(["#{$noteline}&&#{$ss}"])   #added 20121217 调用函数函数注释
			end
			$num=$num+1
			
			##从数据库中查找第三个表的内容
			rsF=mydb.query("SELECT * FROM FDLIST WHERE f_id=#{rowS['F_point']}")	#根据SLIST中的F_point在FDLIST中查找f_name
			rsF.each_hash do |rowF|
				fF_name=rowF['f_name']
				fF_dfile=rowF['f_dfile']
				fF_dline=rowF['f_dline'].to_i
				
				temp_fun="#{fF_name} #{fF_dfile} #{fF_dline} #{fC_name} #{fCd_file} #{fCd_line} #{fC_dfile} #{fC_dline}"
puts temp_fun
			end
		end
=end
		rsSO=mydb.query("SELECT SLIST_point FROM SOLIST WHERE F_path=\"#{s_dir}\" AND C_path LIKE \"#{d_dir}%\"")
		rsSO.each_hash do |rowSO|
			slist_point=rowSO['SLIST_point'].to_i
#   puts slist_point
			rsS=mydb.query("SELECT F_point, C_point, Cd_file, Cd_line FROM SLIST WHERE SLIST_id=#{slist_point}")
			rsS.each_hash do |rowS|
				fCd_file=rowS['Cd_file']
				fCd_line=rowS['Cd_line']
				if rowS['C_point']
					rsF=mydb.query("SELECT * FROM FDLIST WHERE f_id=#{rowS['C_point']}")	#根据SLIST中的F_point在FDLIST中查找f_name
					rsF.each_hash do |rowF|
						fC_name=rowF['f_name']
						fC_dfile=rowF['f_dfile']
						fC_dline=rowF['f_dline'].to_i
					end
				else
					fC_name=rowS['C_name']		
				end
			
				if  $c_inf1.index(" #{fC_name} ") 
					$c_inf2[$c_inf1.index(" #{fC_name} ")]+=1  #如果$c_inf1里已经有了这个函数，被调用次数加1
				else
#puts fC_name
					$c_inf1=$c_inf1.concat([" #{fC_name} "])
					$c_inf2=$c_inf2.concat([1])	#如果$c_inf1里没有这个函数，被调用次数赋值为1
					$c_inf3=$c_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
#puts fC_dfile
				#	$c_inf4=$c_inf4.concat(["NULL&&NULL"])   #added 20121217 调用函数函数注释
				end
				$num=$num+1
			
				##从数据库中查找第三个表的内容
				rsF=mydb.query("SELECT * FROM FDLIST WHERE f_id=#{rowS['F_point']}")	#根据SLIST中的F_point在FDLIST中查找f_name

				rsF.each_hash do |rowF|
					fF_name=rowF['f_name']
					fF_dfile=rowF['f_dfile']
					fF_dline=rowF['f_dline'].to_i

					temp_fun="<tr><td>#{$num-1}</td><td>#{fF_name}</td><td>#{fF_dfile}</td><td>#{fF_dline}</td><td>#{fC_name}</td><td>#{fCd_file}</td><td>#{fCd_line}</td><td> #{fC_dfile}</td><td>#{fC_dline}</td></tr>"
                                      $temp_s=$temp_s+temp_fun
				end				
			end
		end
		for i in 0..$c_inf1.size-1
			$c_inf1[i]=$c_inf1[i].gsub(/\s+/,"")
		end		
	end
	
	def Handle.full(d_dir)
		d_dir=(d_dir+"/").gsub(/\/+/,"/")
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
		
		temp_fun=""
		
		fF_name=""
		fF_dfile=""
		fF_dline=0
		fC_name=""
		fCd_file=""
		fCd_line=0
		fC_dfile=""
		fC_dline=0

		rsSO=mydb.query("SELECT DISTINCT SLIST_point FROM SOLIST WHERE C_path LIKE \"#{d_dir}%\"")
		rsSO.each_hash do |rowSO|
			slist_point=rowSO['SLIST_point'].to_i

			rsS=mydb.query("SELECT F_point, C_point, Cd_file, Cd_line FROM SLIST WHERE SLIST_id=#{slist_point}")
			rsS.each_hash do |rowS|
                                fCd_file=rowS['Cd_file']
                                fCd_line=rowS['Cd_line']

				if rowS['C_point']
					rsF=mydb.query("SELECT * FROM FDLIST WHERE f_id=#{rowS['C_point']}")	#根据SLIST中的F_point在FDLIST中查找f_name
					rsF.each_hash do |rowF|
						fC_name=rowF['f_name']
						fC_dfile=rowF['f_dfile']
						fC_dline=rowF['f_dline'].to_i
					end
				else
					fC_name=rowS['C_name']		
				end
			
				if  $c_inf1.index(" #{fC_name} ") 
					$c_inf2[$c_inf1.index(" #{fC_name} ")]+=1  #如果$c_inf1里已经有了这个函数，被调用次数加1
				else
					$c_inf1=$c_inf1.concat([" #{fC_name} "])
					$c_inf2=$c_inf2.concat([1])	#如果$c_inf1里没有这个函数，被调用次数赋值为1
					$c_inf3=$c_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
	#				$c_inf4=$c_inf4.concat(["#{$noteline}&&#{$ss}"])   #added 20121217 调用函数函数注释
                               # $c_inf4=$c_inf4.concat(["NULL&&NULL"])   #added 20121217 调用函数函数注释
				end
				$num=$num+1
			
				##从数据库中查找第三个表的内容
				rsF=mydb.query("SELECT * FROM FDLIST WHERE f_id=#{rowS['F_point']}")	#根据SLIST中的F_point在FDLIST中查找f_name

				rsF.each_hash do |rowF|
					fF_name=rowF['f_name']
					fF_dfile=rowF['f_dfile']
					fF_dline=rowF['f_dline'].to_i
					
					temp_fun="<tr><td>#{$num-1}</td><td>#{fF_name}</td><td>#{fF_dfile}</td><td>#{fF_dline}</td><td>#{fC_name}</td><td>#{fCd_file}</td><td>#{fCd_line}</td><td> #{fC_dfile}</td><td>#{fC_dline}</td></tr>"
                                      	$temp_s=$temp_s+temp_fun

					#temp_fun="#{fF_name} #{fF_dfile} #{fF_dline} #{fC_name} #{fCd_file} #{fCd_line} #{fC_dfile} #{fC_dline}"
#					puts temp_fun
				end				
			end
		end
		for i in 0..$c_inf1.size-1
			$c_inf1[i]=$c_inf1[i].gsub(/\s+/,"")
		end
	end
end

begin_time=Time.now().to_i
#### main ####
if "#{$s_dir}"=="full" ####若源路径为*的情况下
	$ARGV=$d_dir
       # puts $ARGV
	Table.head() #三个表的表头
	
	Handle.full($d_dir)
	D2Handle.full($d_dir)
     # $c_inf4=D2Handle.note(1)
     # $dc_inf4=D2Handle.note(0) 
       $ts_dir=""
       $td_dir=$d_dir
 #找到除被调用模块$d_dir以外的其他模块读取$c_inf1、$c_inf2、$c_inf3、$c_inf4以及$dc_inf1、$dc_inf2、$dc_inf3、$dc_inf4以及
 #$num、$dfnum调用函数总的次数
 ###第三个表中内容 $temp_d $temp_s=$temp_s+$temp_d
 
#	Sdsort.arr()  ####静态与动态调用比较
#	Table.sbody() #既有静态调用又有动态调用被调用函数表
#	Table.stbody() #只有静态被调用函数表
#	Table.dybody() #只有动态被调用函数表
#	Table.tail("",$ARGV)  #函数列表结尾
#	Creatfile.writein()   #把函数调用列表写入文件

else     
        Table.head()
	if "#{$d_dir}"=="full"
		Handle.common($s_dir, "")
		D2Handle.common($s_dir, "")
	else
		Handle.common($s_dir, $d_dir)
		D2Handle.common($s_dir, $d_dir)
	end
        $ts_dir=$s_dir
        $td_dir=$d_dir
 #      $c_inf4=D2Handle.note(1)
 #     $dc_inf4=D2Handle.note(0)


 #读取$c_inf1、$c_inf2、$c_inf3、$c_inf4以及$dc_inf1、$dc_inf2、$dc_inf3、$dc_inf4以及
 #$num、$dfnum调用函数总的次数
 ###第三个表中内容
    
#	Sdsort.arr()
#	Table.sbody()
#	Table.stbody()
#	Table.dybody()
#	Table.tail($s_dir,$d_dir)
#	Creatfile.writein()
end
$c_inf4=D2Handle.note(1)
$dc_inf4=D2Handle.note(0)
Sdsort.arr()
Table.sbody()
Table.stbody()
Table.dybody()
Table.tail($ts_dir,$td_dir)
Creatfile.writein()
end_time=Time.now().to_i

#puts end_time-begin_time
