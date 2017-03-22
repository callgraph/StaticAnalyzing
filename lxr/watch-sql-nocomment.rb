#!/usr/bin/ruby -w
require 'find'
require'mysql'
require 'net/http'
require 'base64'
require 'uri'
require 'timeout'

inputpath=""
inputpath=Array.new(20)
i=0
ARGV.each do|arg|
	inputpath[i]=arg
	i=i+1
end
$s_dir=inputpath[1]  #相对源路径
$d_dir=inputpath[2]  #相对调用路径
sou_dir=inputpath[0] #根路径
$version=inputpath[4] #source version
$f_vir=inputpath[5]   #real path or virtual path
$a_ver=inputpath[6]   #platform
$code_url=inputpath[8]
$note_url=inputpath[7]
$doxygen_flag=inputpath[9]
#$code_url="https://github.com/xyongcn/Kernel3.5.4Analysis/tree/master/"
#$note_url="http://os.cs.tsinghua.edu.cn:280/doxy/"
####isac
$w_path=[]
$w_note=[]
$web_source="http://124.16.141.160/mediawiki-0401/ApiForCG-RTL.php"
####
######路径的输入
$sou_dir=sou_dir

################added 20121217
note_dir=inputpath[3]# added 20121217  html文件所在路径
$note_dir=""
$note_dir=note_dir
$d=""
$coname="" #the name of the list
$noteline="NULL"
$ss=""
$path=$note_dir.sub(/files\.html/,"")
$file_namex="files.html"
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

$static_time=0
$dynamic_time=0


########added20131017 translate the virtual path to the real ################
module Virtual2real
        def Virtual2real.only_file(vpath1)
               mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')  #added 20131017 mysq connect
                rpath1=vpath1
                rs1=mydb.query("SELECT * FROM `#{$sql_vlist}` WHERE V_path=\"#{vpath1}\"")
                rs1.each_hash do |row1|
                        rpath1=row1['P_path']
                end
                        return rpath1
        end
        def Virtual2real.select_real_file(vpath0)
                rs=mydb.query("SELECT count(*) FROM PLIST WHERE P_path='#{vpath0}'")
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
		wfile=File.new($sou_dir+"/"+$coname,"w") 
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
	$coname+=$f_vir+"-"+$s_dir+"-"+$d_dir+".list"
	$coname=$coname.gsub(/\/+/,"_")
	$coname=$coname.gsub(/\.c/,"_c")
#added 20130627
module Readhtml
=begin
   def Readhtml.readfile(path_name,file_name)
	file_name="#{$path}/#{file_name}"
       #####added 20130102 ###########
      file_name=file_name.gsub(/\/\//,"/")
       #####added 20130102 ###########
        puts file_name
        puts path_name
     # postion=path_name.index"/"   #search first /
	 if !postion
         indexname=path_name
     else
	index[]=path_name.split("/")
	
    	indexname=path_name[0..]
	 # indexname=path_name[0..postion-1]  #before first / is index name
	 path_name.slice!(0,postion+1)      # after / is next input path  name
     end
      if indexname.index(".S")
         return "NULL"
      end
      afile=File.new(file_name)
	 while line=afile.gets
#		puts line
        	postion1=line.index(">/usr/local/share/cg-rtl/source/linux-3.5.4/#{path_name}<")
		postion3=line.index() 
#	   postion1=line.index(">[#{indexname}]<")  ##between href and index name is next time read file name 
            postion2=line.index("<a href=\"")
            
#            puts postion1
         #   puts postion2 
           if postion1 and postion2
              file_of_name=line[postion2..postion1].sub("<a href=\"","").sub("\">","")   # get next time  need read file name
	#	puts file_of_name 
             break
           end
      end
      afile.close
     # puts "##### #{file_of_name}  #{path_name}" 
       if !postion  ## if end of path name file name is wo need 
           return file_of_name
        end
    #  Readhtml.readfile(path_name,file_of_name)
   end
end
=end
  def Readhtml.readfile(path_name,file_name)
	file_name="#{$path}/#{file_name}"
	file_name=file_name.gsub(/\/\//,"/")
	#puts file_name
	#puts path_name
	postion=path_name.index"/"
	 if !postion
	  indexname=path_name
	else
	  indexname=path_name[0..postion-1]
	 # path_name.slice!(0,postion+1)
	end
	if indexname.index(".S")
	  return "NULL"
	end
	  index=Array.new
	  index=path_name.split("/")
	  num=index.size
	  filename=index[num-1]
	  #puts filename
	  indexlength=path_name.length-filename.length
	  indexname=path_name[0..indexlength-1]
	  #puts indexname
	  afile=File.new(file_name)
	  while line=afile.gets
		postion1=line.index(">/usr/local/share/cg-rtl/source/linux-3.5.4/#{indexname}<")
		#puts ">/usr/local/share/cg-rtl/source/linux-3.5.4/#{indexname}<"
		postion2=line.index(">#{filename}<")
		#puts ">#{filename}<"
		#puts postion1
		#puts postion2
	  	if postion1 and postion2
		fnarray=Array.new
		fnarray=line.split(" href=\"")
		file_of_name=fnarray[1].sub("\">#{filename}</a> <a","")
		puts file_of_name
		break
		end
	    end
	return file_of_name
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
                         if line.index("\<td class\=\"memname\"\>") and line.index("#{fuc_name}")
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
	    tt=Array.new
	    tt=t_line.split("#")
	   #        $ss="http://192.168.1.35/doxygen-kernel/"+$version+"/html/"+tt[0]
        $ss="http://192.168.1.35/doxygen-kernel/html1/html/"+tt[0]
        end
	
     end
else
 $noteline="NULL"
 $ss=" "
end
puts $noteline
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
                        if $doxygen_flag=="1"
		           $call_inf+="<tr><td>"+"#{i+1}"+"</td><td><a href=\""+"#{$code_url}"+"#{$c_inf3[i].split(" ")[0]}\#L#{$c_inf3[i].split(" ")[1].to_i}\""+">"+"#{$c_inf1[k]}"+"</a></td><td>"+"#{$c_inf2[k]}"+"</td><td>"+"#{$c_inf3[i].split(" ")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$c_inf4[k].split("&&")[1]}\""+">"+"#{$c_inf4[k].split("&&")[0]}"+"</a></td></tr>"  
                        else
                           $call_inf+="<tr><td>"+"#{i+1}"+"</td><td><a href=\""+"#{$code_url}"+"#{$c_inf3[i].split(" ")[0]}"+"\?v\=#{$ver_v}"+"\##{Loadm.change($c_inf3[i].split(" ")[1].to_i)}\""+">"+"#{$c_inf1[k]}"+"</a></td><td>"+"#{$c_inf2[k]}"+"</td><td>"+"#{$c_inf3[i].split(" ")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$c_inf4[k].split("&&")[1]}\""+">"+"#{$c_inf4[k].split("&&")[0]}"+"</a></td></tr>"
                        end
		end
	end

	#既有静态调用又有动态调用被调用函数表 added 20130703
	def Table.sbody()
		for i in 0..$sd.size-1
                        if $doxygen_flag=="1"
		            $call_inf+="<tr><td>"+"#{i+1}"+"</td><td><a href=\""+"#{$code_url}"+"#{$sd[i].split(",,")[5]}\#L#{$sd[i].split(",,")[3].split(" ")[1].to_i}\""+">"+"#{$sd[i].split(",,")[0]}"+"</a></td><td>"+"#{$sd[i].split(",,")[2]}"+"</td><td>"+"#{$sd[i].split(",,")[-1]}"+"</td><td>"+"#{$sd[i].split(",,")[3].split(" ")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$sd[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$sd[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>" 
 
                        else

#                             $call_inf+="<tr><td>"+"#{i+1}"+"</td><td><a href=\""+"#{$code_url}"+"#{$sd[i].split(",,")[5]}"+"\?v\=#{$ver_v}"+"\##{Loadm.change($sd[i].split(",,")[3].split(" ")[1].to_i)}\""+">"+"#{$sd[i].split(",,")[0]}"+"</a></td><td>"+"#{$sd[i].split(",,")[2]}"+"</td><td>"+"#{$sd[i].split(",,")[5]}"+"</td><td>"+"#{$sd[i].split(",,")[3].split(" ")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$sd[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$sd[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>" 

                             $call_inf+="<tr><td>"+"#{i+1}"+"</td><td><a href=\""+"#{$code_url}"+"#{$sd[i].split(",,")[5]}"+"\?v\=#{$ver_v}"+"\##{Loadm.change($sd[i].split(",,")[3].split(" ")[1].to_i)}\""+">"+"#{$sd[i].split(",,")[0]}"+"</a></td><td>"+"#{$sd[i].split(",,")[2]}"+"</td><td>"+"#{$sd[i].split(",,")[-1]}"+"</td><td>"+"#{$sd[i].split(",,")[3].split(" ")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$sd[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$sd[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>" 
                        end
		end       
	end

	#只有静态被调用函数表 added 20130703
	def Table.stbody()
		for i in 0..$static.size-1
                      if $doxygen_flag=="1"
			$call_inf+="<tr><td>"+"#{$sd.size+1+i}"+"</td><td><a href=\""+"#{$code_url}"+"#{$static[i].split(",,")[5]}\#L#{$static[i].split(",,")[3].split(" ")[1].to_i}\""+">"+"#{$static[i].split(",,")[0]}"+"</a></td><td>"+"#{$static[i].split(",,")[2]}"+"</td><td>"+"0"+"</td><td>"+"#{$static[i].split(",,")[3].split(" ")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$static[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$static[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>"  
                      else

			$call_inf+="<tr><td>"+"#{$sd.size+1+i}"+"</td><td><a href=\""+"#{$code_url}"+"#{$static[i].split(",,")[5]}"+"\?v\=#{$ver_v}"+"\##{Loadm.change($static[i].split(",,")[3].split(" ")[1].to_i)}\""+">"+"#{$static[i].split(",,")[0]}"+"</a></td><td>"+"#{$static[i].split(",,")[2]}"+"</td><td>"+"0"+"</td><td>"+"#{$static[i].split(",,")[3].split(" ")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$static[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$static[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>" 
                      end
		end   
	end

	#只有动态被调用函数表 added 20130703
	def Table.dybody()
		for i in 0..$dynamic.size-1
                     if $doxygen_flag=="1"
			$call_inf+="<tr><td>"+"#{$sd.size+$static.size+1+i}"+"</td><td><a href=\""+"#{$code_url}"+"#{$dynamic[i].split(",,")[5]}\#L#{$dynamic[i].split(",,")[3].split("&&")[1].to_i}\""+">"+"#{$dynamic[i].split(",,")[0]}"+"</a></td><td>"+"0"+"</td><td>"+"#{$dynamic[i].split(",,")[2]}"+"</td><td>"+"#{$dynamic[i].split(",,")[3].split("&&")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$dynamic[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$dynamic[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>"
                      else
                        $call_inf+="<tr><td>"+"#{$sd.size+$static.size+1+i}"+"</td><td><a href=\""+"#{$code_url}"+"#{$dynamic[i].split(",,")[5]}"+"\?v\=#{$ver_v}"+"\##{Loadm.change($dynamic[i].split(",,")[3].split("&&")[1].to_i)}\""+">"+"#{$dynamic[i].split(",,")[0]}"+"</a></td><td>"+"0"+"</td><td>"+"#{$dynamic[i].split(",,")[2]}"+"</td><td>"+"#{$dynamic[i].split(",,")[3].split("&&")[0]}"+"</td><td><a href=\""+"#{$note_url}"+"#{$dynamic[i].split(",,")[4].split("&&")[1]}\""+">"+"#{$dynamic[i].split(",,")[4].split("&&")[0]}"+"</a></td></tr>"

                      end
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
		temp_path3=""
                for i in 0..$c_inf1.size-1
			if $f_vir=="real"
				temp_path3=$c_inf3[i].split(" ")[0]
			else
#puts $c_inf3[i].split(" ")[0]
#puts temp_path3
#				temp_path3=$c_inf3[i].split(" ")[0]
				temp_path3=Virtual2real.only_file($c_inf3[i].split(" ")[0])
			end

                        sjoin=$c_inf1[i]+"\,\,X\,\,"+$c_inf2[i].to_s+"\,\,"+$c_inf3[i]+"\,\,"+"NULL"+"\,\,"+temp_path3
                        com=com.concat(["#{sjoin}"])
                end

                for i in 0..$dc_inf1.size-1
#puts $f_vir
			if $f_vir=="real"
				temp_path3=$dc_inf3[i].split(" ")[0]
			else
				temp_path3=Virtual2real.only_file($dc_inf3[i].split(" ")[0])
			end

                        djoin=$dc_inf1[i]+"\,\,XX\,\,"+$dc_inf2[i].to_s+"\,\,"+$dc_inf3[i]+"\,\,"+"NULL"+"\,\,"+temp_path3
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
#puts "#{com[i]}"
					$static=$static.concat(["#{static}"])
				else
					dynamic=com[i]+",,"+"0"
#puts "#{com[i]}"
					$dynamic=$dynamic.concat(["#{dynamic}"])
				end
				i=i+1
			end
		end
#puts $sd.size
#puts $static.size
#puts $dynamic.size
	end
end
#added 20130719

module D2Handle
        def D2Handle.sqlexist(sqltablename)
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
		rsEX=mydb.query("SELECT count(*) FROM information_schema.TABLES WHERE TABLE_NAME=\"#{sqltablename}\"")
		rsEX.each_hash do |row|
			rsEXcount=row['count(*)']
#puts "#{rsEXcount} ****"
			if rsEXcount.to_i==0
				return 1
			else
				return 0
			end
		end
	end
    
	def D2Handle.common(s_dir, d_dir)
                if s_dir.index(".c") or s_dir.index(".h") or s_dir.index(".S")
			s_dir=s_dir.gsub(/\/+/,"/")
                else
                        s_dir=(s_dir+"/").gsub(/\/+/,"/")
                end
		
                if d_dir!=""
#			if d_dir.index(".c") or d_dir.index(".h") or d_dir.index(".S")
#				d_dir=d_dir.gsub(/\/+/,"/")
#			else
				d_dir=(d_dir+"/").gsub(/\/+/,"/")
#			end
                end

	#	s_dir=(s_dir+"/").gsub(/\/+/,"/")
	#	d_dir=(d_dir+"/").gsub(/\/+/,"/") if d_dir!=""	
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
                if(D2Handle.sqlexist($sql_dolist)==1)
			return 1
                end
                if($f_vir!="virtual" && D2Handle.sqlexist($sql_dlist)==1)
			return 1
                end
                if(D2Handle.sqlexist($sql_fdlist)==1)
			return 1
                end
			
		fC_name=""
		fC_dfile=""
		fC_dline=0
#	puts Virtual2real.only_file(s_dir)
		rsDO=mydb.query("SELECT C_path, COUNT FROM `#{$sql_dolist}` WHERE F_path=\"#{s_dir}\" AND C_path LIKE \"#{d_dir}%\"")
		rsDO.each_hash do |rowDO|
			fC_name=File.basename(rowDO['C_path'])	#获得被调函数名
			fC_dfile=File.dirname(rowDO['C_path'])	#获得被调函数定义路径
			if  $dc_inf1.index("#{fC_name}") 
				$dc_inf2[$dc_inf1.index("#{fC_name}")]+=rowDO['COUNT'].to_i #如果$c_inf1里已经有了这个函数，累加被调用次数
			else	
				rsC=mydb.query("SELECT f_dline FROM `#{$sql_fdlist}` WHERE f_name=\"#{fC_name}\" AND f_dfile=\"#{fC_dfile}\"")
				rsC.each_hash do |rowC|
					fC_dline=rowC['f_dline']	#获得被调函数定义行号
				end
				$dc_inf1=$dc_inf1.concat(["#{fC_name}"])
				$dc_inf2=$dc_inf2.concat([rowDO['COUNT'].to_i])	#如果$c_inf1里没有这个函数，获取被调用次数
				$dc_inf3=$dc_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
			end
			$dnum=$dnum+rowDO['COUNT'].to_i
		end
		return 0
	end

	def D2Handle.full(d_dir)
#puts d_dir
                if d_dir!=""
			d_dir=(d_dir+"/").gsub(/\/+/,"/")		
		end
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
                if(D2Handle.sqlexist($sql_dolist)==1)
                    return 1
                end
		
                if($f_vir!="virtual" && D2Handle.sqlexist($sql_dlist)==1)
                    return 1
                end
                if(D2Handle.sqlexist($sql_fdlist)==1)
                    return 1
                end

		fC_name=""
		fC_dfile=""
		fC_dline=0

		rsDO=mydb.query("SELECT C_path, COUNT FROM `#{$sql_dolist}` WHERE C_path LIKE \"#{d_dir}%\"")
		rsDO.each_hash do |rowDO|
			fC_name=File.basename(rowDO['C_path'])	#获得被调函数名
			fC_dfile=File.dirname(rowDO['C_path'])	#获得被调函数定义路径
			
			if  $dc_inf1.index("#{fC_name}") 
				$dc_inf2[$dc_inf1.index("#{fC_name}")]+=rowDO['COUNT'].to_i #如果$c_inf1里已经有了这个函数，累加被调用次数
			else	
				rsC=mydb.query("SELECT f_dline FROM `#{$sql_fdlist}` WHERE f_name=\"#{fC_name}\" AND f_dfile=\"#{fC_dfile}\"")
				rsC.each_hash do |rowC|
					fC_dline=rowC['f_dline']	#获得被调函数定义行号
				end
				$dc_inf1=$dc_inf1.concat(["#{fC_name}"])
				$dc_inf2=$dc_inf2.concat([rowDO['COUNT'].to_i])	#如果$c_inf1里没有这个函数，获取被调用次数
				$dc_inf3=$dc_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
			end
			$dnum=$dnum+rowDO['COUNT'].to_i
		end
		return 0
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
            temp_path3=""
            for i in 0..c_temp_inf1.size-1
               if "#{c_temp_inf3[i].split(" ")[0]}"!="NULL"
                   if $f_vir=="real"
                     temp_path3=c_temp_inf3[i].split(" ")[0]
                  else
                     temp_path3=Virtual2real.only_file(c_temp_inf3[i].split(" ")[0])
                  end
	#	puts temp_path3
                  $temp_d=Readhtml.readfile("#{temp_path3}",$file_namex) ##modify 20121226

                  $d=$temp_d
                  if $d=="NULL"
                     $noteline="NULL"
                     $ss=""
                     c_temp_inf4[i]="#{$noteline}&&#{$ss}"
                  else
                     new_dir=$note_dir.sub(/files\.html/,"")+"#{$d}"
                     Note.get(new_dir,"#{$c_inf1[i]}")
                     c_temp_inf4[i]="#{$noteline}&&#{$ss}"
                  end
               end
            end
            return c_temp_inf4
       end
end

module Handle
	def Handle.common(s_dir, d_dir)	#主调路径不为full(*)
                if s_dir.index(".c") or s_dir.index(".h") or s_dir.index(".S")	#若主调路径为文件
			s_dir=s_dir.gsub(/\/+/,"/")
                else
	        	s_dir=(s_dir+"/").gsub(/\/+/,"/")
                end
                if d_dir!=""
#			if d_dir.index(".c") or d_dir.index(".h") or d_dir.index(".S")	#若被调路径为文件
#				d_dir=d_dir.gsub(/\/+/,"/")
#			else
				d_dir=(d_dir+"/").gsub(/\/+/,"/")
#			end
                end
		
                mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
		if(D2Handle.sqlexist($sql_solist)==1)
			return 1
                end
                if(D2Handle.sqlexist($sql_slist)==1)
			return 1
                end
                if(D2Handle.sqlexist($sql_fdlist)==1)
			return 1
                end

		temp_fun=""
		fF_name=""
		fF_dfile=""
		fF_dline=0
		fC_name=""
		fCd_file=""
		fCd_line=0
		fC_dfile=""
		fC_dline=0
#$c_inf1.clear
#$c_inf2.clear
#$c_inf3.clear
		t3sernum=1	#第三个表的序列号
		rsSO=mydb.query("SELECT C_path, COUNT FROM `#{$sql_solist}` WHERE F_path=\"#{s_dir}\" AND C_path LIKE \"#{d_dir}%\"")
		rsSO.each_hash do |rowSO|
			
			fC_name=File.basename(rowSO['C_path'])	#获得被调函数名
			fC_dfile=File.dirname(rowSO['C_path'])	#获得被调函数定义路径

#if fC_name=="memset" and fC_dfile=="arch/x86/lib/memcpy_32.c"
#puts temp_fun
#puts ("#{fC_dfile}/#{fC_name}:#{fC_dline}")
#end
			if rowSO['C_path'] != temp_fun
				nostrangefunflag=0	#特殊函数标记，例如__builtin_XXXX函数及FDLIST中没有直接给出的其他怪函数，默认为奇怪函数，1代表普通函数，2代表__builtin_XXXX函数
			#	rsSO2=mydb.query("SELECT DISTINCT F_path, C_path FROM `#{$sql_solist}` WHERE F_path=\"#{s_dir}\" AND C_path LIKE \"#{d_dir}%\"")
				rsS=mydb.query("SELECT F_point, C_point, Cd_file, Cd_line FROM `#{$sql_slist}` WHERE C_name=\"#{fC_name}\" AND C_dfile=\"#{fC_dfile}\" AND F_dfile LIKE \"#{s_dir}%\"")
				rsS.each_hash do |rowS|
					nostrangefunflag=1
					fCd_file=rowS['Cd_file']	#获得被调用路径
					fCd_line=rowS['Cd_line']	#获得被调用行号
				
					rsC=mydb.query("SELECT f_dline FROM `#{$sql_fdlist}` WHERE f_id=#{rowS['C_point'].to_i}")
					rsC.each_hash do |rowC|
						fC_dline=rowC['f_dline']	#获得被调函数定义行号
					end
					
					#第三个表
					rsF=mydb.query("SELECT f_name, f_dfile, f_dline FROM `#{$sql_fdlist}` WHERE f_id=#{rowS['F_point'].to_i}")
					rsF.each_hash do |rowF|
						fF_name=rowF['f_name']	#获得主调函数函数名
						fF_dfile=rowF['f_dfile']	#获得主调函数定义路径
						fF_dline=rowF['f_dline']	#获得主调函数定义行号
					end
#					t3sernum+=1
#					if t3sernum!=2	#防止无静态调用也生成表3的情况
					temp_fun="<tr><td>#{t3sernum}</td><td>#{fF_name}</td><td>#{fF_dfile}</td><td>#{fF_dline}</td><td>#{fC_name}</td><td>#{fCd_file}</td><td>#{fCd_line}</td><td> #{fC_dfile}</td><td>#{fC_dline}</td></tr>"
					$temp_s=$temp_s+temp_fun
					t3sernum+=1
#					end
#if fC_name=="memset" and fC_dfile=="arch/x86/lib/memcpy_32.c"
#puts ("#{fC_dfile}/#{fC_name}:#{fC_dline}")
#end
				end

				if nostrangefunflag==0	#若被调函数为__builtin_XXXXX
					rsS=mydb.query("SELECT F_point, C_point, Cd_file, Cd_line FROM `#{$sql_slist}` WHERE C_name=\"__builtin_#{fC_name}\" AND C_dfile=\"#{fC_dfile}\" AND F_dfile LIKE \"#{s_dir}%\"")
					rsS.each_hash do |rowS|
						nostrangefunflag=2
						fCd_file=rowS['Cd_file']	#获得被调用路径
						fCd_line=rowS['Cd_line']	#获得被调用行号
					
						rsC=mydb.query("SELECT f_dline FROM `#{$sql_fdlist}` WHERE f_id=#{rowS['C_point'].to_i}")
						rsC.each_hash do |rowC|
							fC_dline=rowC['f_dline']	#获得被调函数定义行号
						end
					
						#第三个表
						rsF=mydb.query("SELECT f_name, f_dfile, f_dline FROM `#{$sql_fdlist}` WHERE f_id=#{rowS['F_point'].to_i}")
						rsF.each_hash do |rowF|
							fF_name=rowF['f_name']	#获得主调函数函数名
							fF_dfile=rowF['f_dfile']	#获得主调函数定义路径
							fF_dline=rowF['f_dline']	#获得主调函数定义行号
						end


#						t3sernum+=1
#						if t3sernum!=2
#puts t3sernum
#puts("#{fC_name} #{fC_dfile}")						
						temp_fun="<tr><td>#{t3sernum}</td><td>#{fF_name}</td><td>#{fF_dfile}</td><td>#{fF_dline}</td><td>#{fC_name}</td><td>#{fCd_file}</td><td>#{fCd_line}</td><td> #{fC_dfile}</td><td>#{fC_dline}</td></tr>"
						$temp_s=$temp_s+temp_fun
						t3sernum+=1
#						end
					end
				end
=begin
				if nostrangefunflag==0
puts("STRANGE\n")
					rsS=mydb.query("SELECT * `#{$sql_slist}` WHERE C_name=\"#{fC_name}\" AND C_dfile=\"#{fC_dfile}\" AND F_dfile LIKE \"#{s_dir}%\"")
					rsS.each_hash do |rowS|
puts("#{rowS['C_name']}")
					end
				end
=end
#puts("#{fC_dfile}/#{fC_name} #{fC_dline} #{rowSO['COUNT'].to_i}")					
				#第二个表
			#	$c_inf1=$c_inf1.concat(["#{fC_name}"])
			#	$c_inf2=$c_inf2.concat([rowSO['COUNT'].to_i])	#如果没有这个函数，获取被调用次数
			#	$c_inf3=$c_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置

				if $c_inf3.index("#{fC_dfile} #{fC_dline}") and $c_inf1.index("#{fC_name}")	#如果$c_inf1&$c_inf3中的信息指示里已经有了这个函数
					$c_inf2[$c_inf3.index("#{fC_dfile} #{fC_dline}")]+=rowSO['COUNT'].to_i #累加被调用次数
				else
					$c_inf1=$c_inf1.concat(["#{fC_name}"])
					$c_inf2=$c_inf2.concat([rowSO['COUNT'].to_i])	#如果没有这个函数，获取被调用次数
					$c_inf3=$c_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
#					temp_fun="<tr><td>#{t3sernum}</td><td>#{fF_name}</td><td>#{fF_dfile}</td><td>#{fF_dline}</td><td>#{fC_name}</td><td>#{fCd_file}</td><td>#{fCd_line}</td><td> #{fC_dfile}</td><td>#{fC_dline}</td></tr>"
#					$temp_s=$temp_s+temp_fun
#					t3sernum+=1
				end
				temp_fun=rowSO['C_path']
			end
			$num=$num+rowSO['COUNT'].to_i
		end
#puts $c_inf1.size
#puts $c_inf2.size
#puts $c_inf3.size		
		return 0
	end

	def Handle.full(d_dir)	#主调路径为full(*)
		if d_dir!=""
			d_dir=(d_dir+"/").gsub(/\/+/,"/")
		end
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
                if(D2Handle.sqlexist($sql_solist)==1)
			return 1
                end
                if(D2Handle.sqlexist($sql_slist)==1)
			return 1
                end
                if(D2Handle.sqlexist($sql_fdlist)==1)
			return 1
                end

		fF_name=""
		fF_dfile=""
		fF_dline=0
		fC_name=""
		fCd_file=""
		fCd_line=0
		fC_dfile=""
		fC_dline=0
		
		rsSO=mydb.query("SELECT C_path, COUNT FROM `#{$sql_solist}` WHERE C_path LIKE \"#{d_dir}%\"")
		rsSO.each_hash do |rowSO|
			fC_name=File.basename(rowSO['C_path'])	#获得被调函数名
			fC_dfile=File.dirname(rowSO['C_path'])	#获得被调函数定义路径

			rsS=mydb.query("SELECT F_point, C_point FROM `#{$sql_slist}` WHERE C_dfile=\"#{fC_dfile}\"")
			rsS.each_hash do |rowS|
				fCd_file=rowS['Cd_line']	#获得被调用路径
				fCd_line=rowS['Cd_file']	#获得被调用行号
				
				rsC=mydb.query("SELECT f_dline FROM `#{$sql_fdlist}` WHERE f_id=#{rowS['C_point'].to_i}")
				rsC.each_hash do |rowC|
					fC_dline=rowC['f_dline']	#获得被调函数定义行号
				end
				
				#第二个表
				if  $c_inf1.index("#{fC_name}") 
					$c_inf2[$c_inf1.index("#{fC_name}")]+=rowSO['COUNT'].to_i #如果$c_inf1里已经有了这个函数，累加被调用次数
				else
#puts fC_name
					$c_inf1=$c_inf1.concat(["#{fC_name}"])
					$c_inf2=$c_inf2.concat([rowSO['COUNT'].to_i])	#如果$c_inf1里没有这个函数，获取被调用次数
					$c_inf3=$c_inf3.concat(["#{fC_dfile} #{fC_dline}"])   #调用函数定义的位置
#puts fC_dfile
				#	$c_inf4=$c_inf4.concat(["NULL&&NULL"])   #added 20121217 调用函数函数注释
				end
				$num=$num+1
				
				#第三个表
				rsF=mydb.query("SELECT f_name, f_dfile, f_dline FROM `#{$sql_fdlist}` WHERE f_id=#{rowS['F_point'].to_i}")
				rsF.each_hash do |rowF|
					fF_name=rowF['f_name']	#获得主调函数函数名
					fF_dfile=rowF['f_dfile']	#获得主调函数定义路径
					fF_dline=rowF['f_dline'].to_i	#获得主调函数定义行号
					
					temp_fun="<tr><td>#{$num-1}</td><td>#{fF_name}</td><td>#{fF_dfile}</td><td>#{fF_dline}</td><td>#{fC_name}</td><td>#{fCd_file}</td><td>#{fCd_line}</td><td> #{fC_dfile}</td><td>#{fC_dline}</td></tr>"
					$temp_s=$temp_s+temp_fun
				end
			end
		end
		return 0
	end

end

module Loadm
       def Loadm.get(path)
        passwd="123qwe"
        passwd=Base64.encode64(passwd).chomp
        passwd=passwd.reverse
        url =  URI.parse('http://124.16.141.171:81/mediawiki/ApiForCG-RTL.php') 
        req = Net::HTTP::Post.new(url.path)  
        temp={''=>'',''=>''}
        temp.store('username','cgrtl_wiki')
        temp.store('password',passwd)
        for i in 0..path.size-1  #added 20130401
          temp.store(i,path[i])
        end
        req.set_form_data(temp)    
        http=Net::HTTP.new(url.host, url.port)
	http.open_timeout=500
	http.read_timeout=500
	http.start {|http|  
          res = http.request(req)
          s=res.body
          return s.to_a
         } 

       end
########ŽŠÀíÊý×ÖÊ¹78±äÎª0078#########
   def Loadm.change(t)
        t=t.to_i
        if t > 999
           t=t.to_s
        elsif 1000 > t and t > 99
            t=t.to_s
            t="0"+"#{t}"
        elsif 100 > t and t > 9
            t=t.to_s
            t="00"+"#{t}"
        else
            t=t.to_s
            t="000"+"#{t}"
        end     
        return t
      end
end

#######added 20130328#############
module Che   
      def Che.cheal(path,function,linenum)
            temp_num=Loadm.change(linenum)
            z_path="\/#{path}\/#{function}\(#{temp_num}\)\("+'linux-3.5.4'+"\)"
           
            if $w_path.index("#{z_path}")
            else
               $w_path=$w_path.concat(["#{z_path}"])
            end
       end
       def Che.change(cc_temp)
          arr=Loadm.get($w_path)
          c_temp=cc_temp
          for i in 2..arr.size-2
            test_num=arr[i].split(" ")[0].sub("[","").sub("]","").to_i       #added 20130401
            test_arr=arr[i].split(" ")[2]  #20130401 added
            c_temp[test_num]="#{test_arr} &&#{cc_temp[test_num].split("&&")[1]}"  #20130401 added
           end

           return c_temp
      end
      def Che.getisacnote(type_t)
		c_temp_inf1=[]
		c_temp_inf3=[]
		c_temp_inf4=[]
		c_temp=[]
		f_path=""
		if type_t==1
			c_temp_inf1=$c_inf1
			c_temp_inf3=$c_inf3
		else
			c_temp_inf1=$dc_inf1
			c_temp_inf3=$dc_inf3
		end

		for i in 0..c_temp_inf1.size-1
			f_function=c_temp_inf1[i]
			if $f_vir=="real"
				f_path=c_temp_inf3[i].split(" ")[0]
			else
				f_path=Virtual2real.only_file(c_temp_inf3[i].split(" ")[0])
			end

#               f_path=c_temp_inf3[i].split(" ")[0]
			f_line=c_temp_inf3[i].split(" ")[1]
			Che.cheal(f_path,f_function,f_line)
		end
		
		for j in 0..$w_path.size-1
			c_temp[j]="NULL &&#{$w_path[j]}"
		end
		c_temp_inf4=Che.change(c_temp)
		return c_temp_inf4
      end
end

if $f_vir=="real"
   vir_temp="R"
else
   vir_temp="V"
end
 $sql_vlist=$version+"_"+vir_temp+"_"+$a_ver+"_LIST"
  $sql_fdlist=$version+"_"+vir_temp+"_"+$a_ver+"_FDLIST"
  $sql_solist=$version+"_"+vir_temp+"_"+$a_ver+"_SOLIST"
  $sql_dolist=$version+"_"+vir_temp+"_"+$a_ver+"_DOLIST"
   $sql_dlist=$version+"_"+vir_temp+"_"+$a_ver+"_DLIST"
   $sql_slist=$version+"_"+vir_temp+"_"+$a_ver+"_SLIST"
#  $sql_fdlist="FDLIST"
#  $sql_solist="SOLIST"
#  $sql_dolist="DOLIST"
#   $sql_dlist="DLIST"
#   $sql_slist="SLIST"

begin_time=Time.now()
#### main ####
if "#{$s_dir}"=="full" ####若源路径为*的情况下
	$ARGV=$d_dir
	Table.head() #三个表的表头
	
#sbegin=Time.now()	
	staticexist=Handle.full($d_dir)
#send=Time.now()
#$static_time+=send-sbegin

#dbegin=Time.now()
	dynexist=D2Handle.full($d_dir)
#dend=Time.now()
#$dynamic_time+=dend-dbegin	

        if staticexist==1 and dynexist==1
           ##return error mysql table may be not exit 
        end
       $ts_dir=""
       $td_dir=$d_dir

else     
        Table.head()
	if "#{$d_dir}"=="full"
#sbegin=Time.now()		
		staticexist=Handle.common($s_dir, "")
#send=Time.now()
#$static_time+=send-sbegin

#dbegin=Time.now()		
		dynexist=D2Handle.common($s_dir, "")
#dend=Time.now()
#$dynamic_time+=dend-dbegin

	else
#sbegin=Time.now()		
		staticexist=Handle.common($s_dir, $d_dir)
#send=Time.now()
#$static_time+=send-sbegin		

#dbegin=Time.now()
		dynexist=D2Handle.common($s_dir, $d_dir)
#dend=Time.now()
#$dynamic_time+=dend-dbegin
	end
       if staticexist==1 and dynexist==1
           ##return error mysql table may be not exit 
        end

        $ts_dir=$s_dir
        $td_dir=$d_dir
end

 if $doxygen_flag=="0"
#   $c_inf4=Che.getisacnote(1)
#   $dc_inf4=Che.getisacnote(0)
   $c_inf4="NULL"
   $dc_inf4="NULL"
 else
   $c_inf4=D2Handle.note(1)
   $dc_inf4=D2Handle.note(0)
 end
 if $version.index("-iscas")
    $ver_v=$version.sub("-iscas","")
 else
    $ver_v=$version
 end
Sdsort.arr()

Table.sbody()
Table.stbody()
Table.dybody()
Table.tail($ts_dir,$td_dir)
Creatfile.writein()
end_time=Time.now()
#puts end_time-begin_time
#file=File.open("/home/jdi/source1/watchlist-timeinfo_e.txt","a")
#file=File.open("watchlist-timeinfo_e.txt","a")
#file.puts("#{$static_time}  #{$dynamic_time}  #{end_time-begin_time}")d

