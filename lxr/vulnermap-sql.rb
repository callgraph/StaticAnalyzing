#!/usr/bin/ruby -w
require 'mysql'

$number_path #one path or two or is root(==0)	#存放用户输入的路径个数 $number_path==0，输入为*；$number_path==1，输入一个路径；$number_path==2，输入两个路径
$number=0 #the node's number
$number_in=[] #every path's node's numbers
$num=Array.new(1000001,0)
$num_d=Array.new(1000001,0)
$sline="" #the node list
$sline_time=Array.new(1000001,0)
$n_sline=""
$pre_top=""
$vulnodecolor=Array.new(10000,"gray")
$vnodecolor=["brown1","darkorange","yellow","dodgerblue","seagreen3","gray"]
$tempsort=Array.new(1000){Array.new(2,0)}

$node_color=["cyan1","orchid2","gray","red","green","yellow","thistle","lightcoral","cyan4","orange"]
$edge_color=["black","red","blue","green","lightsalmon4","deepskyblue4","indigo","gray","chocolate","magenta"]
module Vulnermap
   def Vulnermap.map() ##read vulner map if vulner's is in function calu ,else can not calu
##################
     $mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph') #connect vulnerabilities sql
     sort_vuln=""

     rsid=$mydb.query("SELECT * FROM cppcheck354")
     rsid.each_hash do |row|
         if row['functionname']!="NULL" ##if function name is not null
              t_path=row['filename'].slice(row['filename'].index("/")+1..row['filename'].length)
              t_fun=row['functionname']
              number_vulner=1
              sort_vuln.concat(" #{t_path}/#{t_fun} #{number_vulner} \n")
         end
     end
#################
        sort_vuln=sort_vuln.split("\n")
        sort_vuln=sort_vuln.sort
        sort_size=sort_vuln.size
        for i in 0..$number_in[$number_path+1]-1
           vuln_number=0
           for j in 0..sort_size-1
              if sort_vuln[j].index($sline[i])
                vuln_number=vuln_number+sort_vuln[j].split(" ")[1].to_i
              end
           end
           $sline_time[i]=vuln_number.to_s
        end

   end
  def Vulnermap.selectcolor()## node select color
      allnode=$number_in[$number_path+1]
      for i in 0..allnode-1
          $tempsort[i]=[$sline_time[i].to_i,i]
      end
          $tempsort=$tempsort.sort{|x,y|y[0]<=>x[0]}
      vulnumber=0
      for i in 0..allnode-1
         if $tempsort[i][0]>0
            vulnumber=vulnumber+1
         end
      end
      if vulnumber<5
         for i in 0..vulnumber-1
            $vulnodecolor[$tempsort[i][1]]=$vnodecolor[i]
         end
      else
         if (vulnumber%5)!=0
            sknode=vulnumber/5+1
         else
            sknode=vulnumber/5
         end
         k=0
        i=0
        while i<vulnumber-1
            for j in i..i+sknode-1
               if j>vulnumber
                  break
                end
               $vulnodecolor[$tempsort[j][1]]=$vnodecolor[k]
#               puts"--#{$tempsort[j][1]}**#{k}&&#{$vulnodecolor[$tempsort[j][1]]}!!"
            end
            k=k+1
            i=j+1
         end
      end
     for i in 0..allnode-1
         if $sline_time[i].to_i==0
         $vulnodecolor[i]=$vnodecolor[5]
         end
      end

   end
end


module Creat
	def Creat.node(path,pre_path) #path include "/" like a/b/ or a/b/c.c	#确定用户输入路径内部的节点
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
                if(Creat.sqlexist($sql_fdlist)==1)
                   return 1
                end

	# select mysql f_dfile include path
	# in path creat node
		if !path.index(".c") and !path.index(".S") and !path.index(".h")	#如果path不是具体到.c或.S的文件（即，可能的情况有 "/" 或 a/b/）
			if path!="root"	#me!	#如果输入路径不是*（即，不是根目录，而是a/b/的情况），如kernel或kernel/trace
				path=(path+"/").gsub(/\/+/,"/")	#对用户输入路径进行规范处理，统一在输入路径后加“/”，然后合并多余的“/”，如kernel→kernel/或kernel/trace→kernel/trace/
				rs=mydb.query("SELECT DISTINCT f_dfile FROM `#{$sql_fdlist}` WHERE f_dfile LIKE \"#{path}%\"")	#在全部函数定义列表中查找所有路径以#{path}打头的记录
				rs.each_hash do |row|
					atemp=row['f_dfile'].sub(path,"")	#me！	#将输入路径去除，如kernel/trace/trace_clock.c→trace/trace_clock.c或kernel/trace/trace_clock.c →trace_clock.c
					anum=atemp.index("/")	#对于输入路径下的文件具体是.c文件或仍是一个目录进行判断
					if anum	#如果有“/”，说明其子是个目录；如果没有"/"了，说明其子是.c文件，那就是它了；
						atemp=atemp.slice(0..anum)	#对子目录atemp进行截取（不带“/”），如trace（而不是trace/）
					end
					atemp=path+atemp
					if !$sline.index(" #{atemp} ") and atemp!=pre_path	#如果此节点在节点列表中不存在
						$sline+=" #{atemp} \n"	#将atemp加入节点列表
						$number=$number+1	#将节点编号+1
					end
				end
			else	#如果输入路径是*（根目录，"/" ）
				$pre_top+=pre_path+"\n"
				rs=mydb.query("SELECT DISTINCT f_dfile FROM`#{$sql_fdlist}`")
				rs.each_hash do |row|
					atemp=row['f_dfile']
					anum=atemp.index("/")
					if anum
						atemp=atemp.slice(0..anum)	#对子目录atemp进行截取（不带“/”），如截取到net（而不是net/）
					end
					if !$pre_top.index(atemp) and !$sline.index(" #{atemp} ")# and atemp!=pre_path	#如果此节点在节点列表中不存在
						$sline+=" #{atemp} \n"	#将atemp加入节点列表
						$number=$number+1	#将节点编号+1
					elsif $pre_top.index(atemp) and $sline.index(" #{atemp} ")
						$sline.sub!(" #{atemp} \n","")
						$number=$number-1	#将节点编号+1
					end
				end
			end
		else	#如果用户输入的是具体的.c文件
			rsc=mydb.query("SELECT f_name, f_dfile FROM `#{$sql_fdlist}` WHERE f_dfile='#{path}'")	#精确查找用户输入路径中的所有函数
			rsc.each_hash do |row|
#				$sline+=row['f_name']+"/"+row['f_dfile']+"\n"	#twdong
        			atemp=row['f_dfile']+"/"+row['f_name']
        			if !$sline.index(" #{atemp} ") and atemp!=pre_path
          				$sline+=" #{atemp} \n"	#me！#将函数文件路径/函数名作为节点加入到节点列表中
          				$number=$number+1	#将节点编号+1
        			end
			end
		end
                return 0
	end	#end Creat.node()

	#me
	def Creat.pathdg(path)	#确定与用户输入路径平级的节点
		path=path.slice(0..(path+"/").gsub(/\/+/,"/").rindex("/")-1)	#规范path路径，#如path=arch/x86/boot/main.c→path=arch/86/boot/main.c，或path=arch/x86/boot/→path=arch/x86/boot，或path=arch/x86/boot/→path=arch/x86/boot
		pre_path=path
		if path.rindex("/")	#确定path中最右边"/"的位置（即，path不是根目录，也不是一级目录）
			path=path.slice(0..path.rindex("/"))	#截取path上级目录	#如path=arch/x86/boot/main.c→path=arch/x86/boot/，或path=arch/x86/boot→path=arch/x86/
			Creat.node(path,pre_path)		#确定path的内部节点	#想办法排除输入模块本身！！！！！！
			Creat.pathdg(path)	#递归确定path的上级节点
		else
			Creat.node("root",path)
		end
	end	#end Creat.pathdg()
	
	def Creat.nodes()
path=[]
#path[1]="arch/x86/boot"
#path[1]="mm"
#path[2]="init/boot"
		$number=0
		$number_in[0]=0
		if $number_path==0	#如果用户输入的是*
			Creat.node("root","")	#以“root”为参数，创建节点
			$number_in[1]=$number
		end
		for i in 1..$number_path	#如果用户输入的是1个路径，或2个路径
                        path[i]=$output[i+2]
			Creat.node(path[i],"")	#确定每个路径中用户输入的节点内部的节点
			$number_in[i]=$number	#$number_in[i]:路径i内部的节点个数
		end
		for i in 1..$number_path	#如果用户输入的是1个路径，或2个路径
			Creat.pathdg(path[i])	#确定每个路径中用户输入的节点平级和上级的节点
		end
                $number_in[$number_path+1]=$number
=begin		
#		$sline=$sline.gsub(/\/+/,"/")	
		$number_in[$number_path+1]=$number
		$sline=$sline.split("\n")
		for i in 0..($sline.size-1)
			$n_sline=$n_sline.concat("#{$sline[i]} X #{i} \n")
		end
		$n_sline=$n_sline.split("\n")
=end		
	end	#Creat.nodes()
	
	def Creat.slinenum()	#add from 20131214
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
                fidt=-1
                cidt=-1
          	$sline=$sline.gsub(/ /,"").split("\n")
	#	$calltime[][]=0
		for i in 0..($sline.size-1)
             #puts $sline[i]
	           for j in 0..($sline.size-1)
                       knum=i*$number+j
	         	if i==j
		             $num[knum]=0
			else
                            tflag=0
                            if $sline[i].index(".c/") || $sline[i].index(".S/") || $sline[i].index(".h/")
                                 tflag=1
                                 fpatht=$sline[i].slice(0..$sline[i].rindex("/")-1)
                                 fname=$sline[i].slice($sline[i].rindex("/")+1..$sline[i].size)
                                 rsid=mydb.query("SELECT f_id FROM `#{$sql_fdlist}` WHERE f_dfile='#{fpatht}' AND f_name='#{fname}'")
 #                                puts "#{fpatht} #{fname}"
                                 rsid.each_hash do |row|
                                     fidt=row['f_id'].to_i
  #                                   puts fidt
                                 end
   #                              puts fidt

                            end
                            if $sline[j].index(".c/") || $sline[j].index(".S/") || $sline[j].index(".h/")
                                 tflag=tflag|2
                                 cpatht=$sline[j].slice(0..$sline[j].rindex("/")-1)
                                 cname=$sline[j].slice($sline[j].rindex("/")+1..$sline[j].size)
                                 rsid=mydb.query("SELECT f_id FROM `#{$sql_fdlist}` WHERE f_dfile='#{cpatht}' AND f_name='#{cname}'")
                                 rsid.each_hash do |row|
                                     cidt=row['f_id'].to_i
                                 end

                            end
    #         puts "ccccccccc#{tflag} #{$sline}"
                            if tflag==0
                                     if(Creat.sqlexist($sql_solist)==1)
                                        return 1
                                     end
                 	             rs=mydb.query("SELECT count(*) FROM `#{$sql_solist}` WHERE F_path='#{$sline[i]}' AND C_path like '#{$sline[j]}%'")
		        	     rs.each_hash do |row|
		                       $num[knum]=row['count(*)'].to_i
		                     end
                                     if(Creat.sqlexist($sql_dolist)==0)
                                         rsd=mydb.query("SELECT count(*) FROM `#{$sql_dolist}` WHERE F_path='#{$sline[i]}' AND C_path like '#{$sline[j]}%'")
                                         rsd.each_hash do |row|
                                            $num_d[knum]=row['count(*)'].to_i
                                         end
                                      end
                            elsif tflag==1
                 # puts "xxxxxxxxxxxx"
                                     rs=mydb.query("SELECT count(*) FROM `#{$sql_slist}` WHERE F_point ='#{fidt}' AND C_dfile like '#{$sline[j]}%'")
                                     rs.each_hash do |row|
                                       $num[knum]=row['count(*)'].to_i
                                     end
                                     ksnum=0
                                    if(Creat.sqlexist($sql_dlist)==0 and Creat.sqlexist($sql_dolist)==0)
                                      rsd=mydb.query("SELECT DLIST_id FROM `#{$sql_dlist}` WHERE F_point='#{fidt}'")
                                      rsd.each_hash do |row|
                                        rs=mydb.query("SELECT count(*) FROM `#{$sql_dolist}` WHERE F_path='#{fpatht}' AND  C_path like '#{$sline[i]}%' AND DLIST_point='#{row['DLIST_id']}'")
                                        rs.each_hash do |row|
                                          ksnum=ksnum+row['count(*)'].to_i
                                        end
                                      end
                                     end
                  #           puts " #{knum} #{ksnum}"
                                     $num_d[knum]=ksnum
                            elsif tflag==2
                                     rs=mydb.query("SELECT count(*) FROM `#{$sql_slist}` WHERE F_dfile like '#{$sline[i]}%' AND C_point='#{cidt}'")
                                     rs.each_hash do |row|
                                       $num[knum]=row['count(*)'].to_i
                                     end
                                     ksnum=0
                                     if(Creat.sqlexist($sql_dolist)==0 and Creat.sqlexist($sql_dlist)==0)
                                      rsd=mydb.query("SELECT DLIST_id FROM `#{$sql_dlist}` WHERE C_point='#{cidt}'")
                                      rsd.each_hash do |row|
                                        rs=mydb.query("SELECT count(*) FROM `#{$sql_dolist}` WHERE F_path='#{$sline[i]}' AND DLIST_point='#{row['DLIST_id']}'")
                                        rs.each_hash do |row|
                                          ksnum=ksnum+row['count(*)'].to_i
                                        end
                                      end
                                     end
                                     $num_d[knum]=ksnum
                            else
                               
                                     rs=mydb.query("SELECT count(*) FROM `#{$sql_slist}` WHERE F_point='#{fidt}' AND C_point='#{cidt}'")
                                     rs.each_hash do |row|
                                       $num[knum]=row['count(*)'].to_i
                                     end
                           #puts $num[knum]
                                    if(Creat.sqlexist($sql_dlist)==0)
                                     rsd=mydb.query("SELECT count(*) FROM `#{$sql_dlist}` WHERE F_point='#{fidt}' AND C_point='#{cidt}'")
                                     rsd.each_hash do |row|
                                       $num_d[knum]=row['count(*)'].to_i
                                     end
                                    end

                            end
         
                            
#                           puts "#{$sline[i]} #{$sline[j]} #{$num[knum]} #{$num_d[knum]}"
		      end
		    end
		end
	end
       def Creat.sqlexist(sqltablename)
            mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
            rsEX=mydb.query("SELECT count(*) FROM information_schema.TABLES WHERE TABLE_NAME=\"#{sqltablename}\"")
            rsEX.each_hash do |row|
              rsEXcount=row['count(*)']
              if rsEXcount.to_i==0
                  return 1
              else
                 return 0
              end
            end
        end

        def Creat.handle()
           for i in 0..$sline.size-1
              
              if $sline[i]!=""
               if $sline[i].rindex("/")+1==$sline[i].length
                  $sline[i]=$sline[i].slice(0..$sline[i].length-2)
               end
              end
           end
        end
        def Creat.graph()
           wfile=File.new($output[2],"w")
            graphname=$output[2]
            graphname.slice!(0..$output[2].rindex("/"))
            graphname=graphname.slice(0..graphname.rindex(".")-1)
            graphname=graphname.gsub(/-/,"_")
            graphname=graphname.gsub(".","_")
            wfile.puts "digraph #{graphname}{"
            wfile.puts "rankdir=LR"
            wfile.puts "node [style=rounded]"
####print include nodes color ,URL=callgraph-link,each node with one special color
            for j in 1..($number_path)
              for i in $number_in[j-1]..($number_in[j]-1)
                wfile.print %Q{"#{$sline[i]}"}+"[tooltip="+%Q{"#{$sline[i]} #{$sline_time[i]}"}+"]"+"[label="+%Q{"#{$sline[i]}"}+","
                watch=$url_call+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[i].strip}"+"&path1="
                wfile.puts "color=#{$vulnodecolor[i]},style=filled,URL="+%Q{"#{watch}"}+"];" 
              end
            end
            for i in $number_in[$number_path]..($number_in[$number_path+1]-1)
               wfile.print %Q{"#{$sline[i]}"}+"[tooltip="+%Q{"#{$sline[i]} #{$sline_time[i]}"}+"]"+"[label="+%Q{"#{$sline[i]}"}+","
               watch=$url_call+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[i].strip}"+"&path1="
               wfile.puts "color=#{$vulnodecolor[i]},style=filled,URL="+%Q{"#{watch}"}+"];"
            end
###print edges include edges color,edges weights,URL=watchfuc-link. 
           for i in 0..100000
             if $num[i]!=0 or $num_d[i]!=0
                s_j=i/$number
                b_number=(i%($number))    
                t_flag=0
                if s_j>=0 and s_j<$number_in[$number_path] and b_number >=$number_in[$number_path] and b_number<$number_in[$number_path+1]
                    watch=$url+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
                    title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                    title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                    wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[0]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
                    t_flag=1
                end
                if b_number>=0 and b_number<$number_in[$number_path] and s_j >=$number_in[$number_path] and s_j<$number_in[$number_path+1]
                  watch=$url+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
                  title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                  title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                  wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[1]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"  
                  t_flag=1
                end

               if $number_path>=0
                 j=1
                 if s_j>=$number_in[j-1] and s_j<$number_in[j] and b_number>=$number_in[j-1] and b_number<$number_in[j]
                   watch=$url+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
                   title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                   title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
         
                   if $number_path==0
                      wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[3]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
                   else
                      wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[2]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
                   end
                  t_flag=1
                end
             end
             if $number_path>=1
                j=2
                if s_j>=$number_in[j-1] and s_j<$number_in[j] and b_number>=$number_in[j-1] and b_number<$number_in[j]
                   watch=$url+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
                   title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                   title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                   if $number_path==1
                      wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[3]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
                   else
                      wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[4]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
                   end
                      t_flag=1
                end
             end
             if $number_path>=2
               j=3
               if s_j>=$number_in[j-1] and s_j<$number_in[j] and b_number>=$number_in[j-1] and b_number<$number_in[j]
                 watch=$url+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
                 title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                 title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                 wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[3]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
                 t_flag=1
               end
             end

             if t_flag==0
                watch=$url+"v="+$version+"&f="+$f_vir+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
                title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
                wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[8]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
             end

          end
        end

        wfile.puts "}"
     end
end
module Runtime
    def Runtime.run()

       mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
       if(Creat.sqlexist($sql_tlist)==1)
            return 1
       end
# f_point | f_time 
       sort_time=""
       rs=mydb.query("SELECT * FROM `#{$sql_tlist}`")
       rs.each_hash do |row|
           f_idt=row['f_point']
           f_time=row['f_time']
           rst=mydb.query("SELECT * FROM `#{$sql_fdlist}` where f_id=\"#{f_idt}\"")
           rst.each_hash do |row1|
              sort_time.concat(" #{row1['f_dfile']}/#{row1['f_name']} #{f_time} \n")
           end
       end
=begin
        sort_time=""
        afile=File.new(name_path)
        while lines=afile.gets
           if lines.index("/")
#              puts lines
              temps=lines.split(" ")
              t_beg=temps[0].index(":")
              t_end=temps[0].rindex(":")
              t_fun=temps[0].slice(0..t_beg-1)
              t_path=temps[0].slice(t_beg+1..t_end-1)
              sort_time.concat(" #{t_path}/#{t_fun} #{temps[1]} \n")
           end

        end
        afile.close
=end
        sort_time=sort_time.split("\n")
        sort_time=sort_time.sort
        sort_size=sort_time.size
#       puts $number_in[$number_path+1]
        for i in 0..$number_in[$number_path+1]-1
 #          puts "---- #{$sline[i]} ---"
           alltime=0
           for j in 0..sort_size-1
              if sort_time[j].index($sline[i])
                alltime=alltime+sort_time[j].split(" ")[1].to_i
              end
           end
  #         puts alltime
           $sline_time[i]=alltime.to_s
        end
#        $sline_time=$sline_time.split("\n")

        return 0
    end
end


module Read# read the path from the screen -o output file name -d path -w write path
     def Read.function(s)
  
         a=s.split(" ")
         $step_number=a[0]
        # puts a.index("-2")
         a.slice!(0,1)
         $output=$output.concat([a.at(0)])
          w_index=a.index("-w")
         if $step_number=="-0" or $step_number=="-1"
          if !w_index
           exit(1)
          else
             output=a[w_index+1]
             a.slice!(w_index,2)
          end
          $output=$output.concat(["#{output}"])
        else 
         $output=$output.concat(["#{$output[0]}"])
 
        end
       d_index=a.index("-d")
       o_index=a.index("-o")
       if $step_number=="-1"
          if d_index or o_index
            exit(1)
          end
       elsif $step_number=="-2"
              if w_index
               exit(1)
             end    
       end
     
        if o_index 
           if !a[o_index+1]
             output="temp.graph"
             a.slice!(o_index,1)
            else
             output=a[o_index+1]
            $url=a[o_index+2]
            $version=a[o_index+3]
            $a_ver=a[o_index+4]
            $url_call=a[o_index+5]
             $f_vir=a[o_index+6]
    a.slice!(o_index,7)
            end
           else
           output="temp.graph"
          end
  
         $output=$output.concat(["#{output}"])
        if $step_number!="-1"
         ## puts "*****"
         num_of_dir=a.size-1-d_index
         if num_of_dir==0
         temp=""
         else
           temp=a[d_index+1..a.size-1]
        # end
         $output=$output.concat(temp)
     #    puts "*****输入的目录数为#{num_of_dir}******"
         b=temp.sort {|x,y| x.split("/").size <=> y.split("/").size}.reverse
         size_of_b=b.size-1
         b.collect! {|x| a.at(0)+"/"+x}
         for i in 0..size_of_b-1
          for j in i+1..size_of_b
             if b[i].index(b[j])
                flag=1
                exit(1) 
      
             end
           end 
         end
       end
     end
 end
end
puts Time.now()

$output=[]
$step_number=""
inputpath=""
ARGV.each do|arg|
inputpath+=arg+" "
end

Read.function(inputpath)

$number_path=$output.size-3
$number_in[0]=0
if $output[2].index("temp.graph")
  tempname=""
   for i in 1..($number_path-1)
     tempname+=$output[i+2].gsub(/\/+/,"-")+"_"
   end
     tempname+=$output[$number_path+2].gsub(/\/+/,"-")+".graph"
   $output[2]=tempname  
end
#puts $output
dirpath=""
$dirpath_si=""
if $number_path==1
   if $output[3]=="0"
     $number_path=0
   end
end

if $f_vir=="real" 
   vir_temp="R"
else
   vir_temp="V"
end
  $sql_fdlist=$version+"_"+vir_temp+"_"+$a_ver+"_FDLIST"
  $sql_solist=$version+"_"+vir_temp+"_"+$a_ver+"_SOLIST"
  $sql_dolist=$version+"_"+vir_temp+"_"+$a_ver+"_DOLIST"
   $sql_dlist=$version+"_"+vir_temp+"_"+$a_ver+"_DLIST"
   $sql_slist=$version+"_"+vir_temp+"_"+$a_ver+"_SLIST"
   $sql_tlist=$version+"_"+vir_temp+"_"+$a_ver+"_S2ETimeLIST"
#$number_path=0
Creat.nodes()
#puts $sline
Creat.slinenum()
#Runtime.run()
Creat.handle()
Vulnermap.map()
Vulnermap.selectcolor()

Creat.graph()
#puts $sline
=begin
for i in 0..$number*$number
    if $num[i]!=0 ||$num_d[i]!=0
      k=i/$number
      j=i%($number)
      puts "#{$sline[k]}->#{$sline[j]} #{$num[i]} #{$num_d[i]}"
    end
end
=end

puts Time.now()
