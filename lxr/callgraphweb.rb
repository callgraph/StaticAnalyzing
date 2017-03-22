#!/usr/bin/ruby -w
require 'find'
require 'mysql'

$number=0
$number_in=Array.new(10000) ##the nodes in one path
$sline=""#nodes
$sline_time=Array.new(1000001) 
$n_sline=""
$fill_line=""#function name and where it is define
$node_color=["cyan1","orchid2","gray","red","green","yellow","thistle","lightcoral","cyan4","orange"]
$edge_color=["black","red","blue","green","lightsalmon4","deepskyblue4","indigo","gray","chocolate","magenta"]



$num=Array.new(1000001)  ###between two path ->call functions numbers
$num_d=Array.new(1000001)
$dirpath_si=""
for i in 0..1000000
 $num[i]=0
 $num_d[i]=0
 $sline_time[i]=0
end
lnum=0
snum=0
module Vulnermap
   def Vulnermap.map()
##################
     $mydb=Mysql.connect('localhost', 'cppcheck', '123456', 'cppcheck354') #connect vulnerabilities sql
     sort_vuln=""

     rsid=$mydb.query("SELECT * FROM cppcheck354")
     rsid.each_hash do |row|
         if row['functionname']!="NULL"
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
end
module Runtime
    def Runtime.run(name_path)
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
       

    end
end



module Step
   def Step.three() #begin step.three
 
$number_in[0]=0
#if File.directory? dirpath
  #creat nodes and save the node in $sline
#puts "tttttttttrrrrrrr"
#####if no path creat node in the root path
  if $number_path ==0
      dirpath=$output[1]
     dirpath=dirpath.gsub(/\/+/,"/")
      Creatnode.creat1(dirpath,dirpath,0)#in  the path creat node
      $number_in[1]=$number
  end
#puts $number_in
###at least one path 
  for i in 1..$number_path

      dirpath=$output[1]+"/"+$output[i+2]
      Creatnode.creat1(dirpath,$output[1],0)#in  the path creat node
      $number_in[i]=$number
  end
# puts $number_in
  for i in 1..$number_path
     dirpath=$output[1]+"/"+$output[i+2]
    Creatnode.dg1(dirpath,$output[1]+"/",dirpath)# out the path creat node
   
  end

  $sline=$sline.gsub(/\/+/,"/")
  $number_in[$number_path+1]=$number
  $sline=$sline.split("\n")
# puts $number_in 
 for i in 0..($sline.size-1)
      $n_sline=$n_sline.concat("#{$sline[i]} X #{i} \n")
  end
  $n_sline=$n_sline.split("\n")


## #file_line ( function-name x function-name-number-in-$sline )
for i in 0..($number-1)
    path=$output[1]+"/"+$sline[i].sub(/[\s]+/,"")
    path=path.gsub(/\/+/,"/")
    if File.directory? path ###decide the node is a file or a path
      ####node is a path
       size=$sline[i].split("/").size
       name=path+"/"+$sline[i].split("/")[size-1].sub(/[\s]+/,"")+".Ddfctlst"
       $fill_line=""
         Creatnode.readfile(name)  ###read define function list and function push in $fill_line  
       name=path+"/"+$sline[i].split("/")[size-1].sub(/[\s]+/,"")+".fillDudfctlst"
       Creatnode.readfile(name)  ###read undefine function list and function push in $fill_line,these functions had being flag the path where it is define  
       $fill_line=$fill_line.split("\n")
#######20121122###############   give each function the nodes number, like : function-name X nodes-number ,will replace $fill_line
       f_size=$fill_line.size
       for j in 0..(f_size-1)  
             call_w=" "+$fill_line[j].split(" ")[1]          
         for k in 0..($number-1)
             if call_w.index($sline[k])
                   snum=k
                   break
             end
          end  
        $fill_line[j]=$fill_line[j].split(" ")[0]+" X "+"#{snum}"+" "+"\n"
        end
        $fill_line=$fill_line.uniq  ### sort and  deduplication
########20121122##############   

  
       name=path+"/"+$sline[i].split("/")[size-1].sub(/[\s]+/,"")+".Doutlst"
       f_name=" "+$sline[i].sub(/[\s]+/,"")+" "
       Creatnode.function(name,1,f_name)
    # puts name
########20130402 read dynamic file
       name=path+"/"+$sline[i].split("/")[size-1].sub(/[\s]+/,"")+".dynDoutlst"
       f_name=" "+$sline[i].sub(/[\s]+/,"")+" "
#puts f_name    
   Creatnode.dynsystapfunction(name,0,f_name,0,0,0,0)
########20130402
    else  ####the node is a file

     if !path.index(".c/")   
       name=path.sub(/\.c/,".dfctlst") 
       $fill_line=""
       Creatnode.readfile(name)  

       name=path.sub(/\.c/,".filludfctlst") 
       Creatnode.readfile(name)  
       $fill_line=$fill_line.split("\n")
#######20121122###############
       f_size=$fill_line.size
       for j in 0..(f_size-1)  
             call_w=" "+$fill_line[j].split(" ")[1]          
            for k in 0..($number-1)
             if call_w.index($sline[k])
                   snum=k
                   break
             end
          end  
           $fill_line[j]=$fill_line[j].split(" ")[0]+" X "+"#{snum}"+" "+"\n"

       end
     $fill_line=$fill_line.uniq
########20121122##############  
       name=path.sub(/\.c/,".outlst")  
       f_name=" "+$sline[i].sub(/[\s]+/,"")+" "
       Creatnode.function(name,1,f_name)  
########20130402 read dynamic file
       name=path.sub(/\.c/,".dynoutlst")
       f_name=" "+$sline[i].sub(/[\s]+/,"")+" "
#puts f_name
       Creatnode.dynsystapfunction(name,0,f_name,0,0,0,0)
########20130402

     else ###20130327
        tname=path.slice(0..path.rindex("/")-3)        
        name=tname+".dfctlst"
      $fill_line=""
       Creatnode.readfile(name)

       name=tname+".filludfctlst"
       Creatnode.readfile(name)
       $fill_line=$fill_line.split("\n")



       f_size=$fill_line.size
       for j in 0..(f_size-1)
             call_w=" "+$fill_line[j].split(" ")[1]
             call_ww=" "+$fill_line[j].split(" ")[1]+"/"+$fill_line[j].split(" ")[0]
         for k in 0..($number-1)
             if call_w.index($sline[k])
                   snum=k
                   break
             end
            if call_ww==$sline[k]
                   snum=k
                   break
             end

          end
           $fill_line[j]=$fill_line[j].split(" ")[0]+" X "+"#{snum}"+" "+"\n"

       end
       $fill_line=$fill_line.uniq
       name=tname+".fctrlt"
       name11=$output[1]+"functionnodetemp.txt"
       functionname=" #{$sline[i].slice($sline[i].rindex("/")+1..$sline[i].size-1)} "
  
       wafile=File.new(name11,"w")
       afile=File.new(name,"r")


       afile_flag=0
       while line=afile.gets
          if line.index("FUNCTION")
             if line.index(functionname)
                afile_flag=1
             else
               afile_flag=0
             end
          end 
          if afile_flag==1
            wafile.puts line
         #  puts line
          end
       end

       afile.close
      wafile.close
       name=name11       
       f_name=" "+$sline[i].sub(/[\s]+/,"")+" "
      Creatnode.function(name,1,f_name)
# puts "11111#{name}2222"

######read dynamic file
       name=tname+".dynfctrlt"
       name11=$output[1]+"functionnodetemp.txt"
       functionname=$sline[i].slice($sline[i].rindex("/")+1..$sline[i].size-1)

       if File.exist?name
       wafile=File.new(name11,"w")
       afile=File.new(name,"r")


       afile_flag=0
       while line=afile.gets
           t_call=line.split(" ")[4]
           t_beg=t_call.index(":")+1
           t_end=t_call.rindex(",")-1
           t_func=t_call.slice(t_beg..t_end)
          if t_func==functionname
             wafile.puts line
          end 
       end

       afile.close
      wafile.close
       name=name11       
       f_name=" "+$sline[i].sub(/[\s]+/,"")+" "
#      Creatnode.function(name,1,f_name)
      Creatnode.dynsystapfunction(name,1,f_name,0,0,0,0)
      end
       


     end
# end
################20130327 
   end
end

if $output[2].index("linux-3.5.4") and $output[2].index("x86")
Runtime.run("/mnt/freenas/lxr-callgraph/lxr-callgraph/source/linux-3.5.4/i386/linux/runtime.dat")
end
#Vulnermap.map()

#begin print output file with the style in graph
wfile=File.new($output[2],"w")
#wfile=File.new("/usr/local/share/lxr/source/android-4.0.4-arm/net.graph","w")
##20130117 begin
c_num1=($graph_moudle%2)
c_num2=(($graph_moudle/2)%2)
c_num3=(($graph_moudle/4)%2)
c_num4=(($graph_moudle/8)%2)
c_num5=(($graph_moudle/16)%2)
c_num6=(($graph_moudle/32)%2)
##20130117 end
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
#       wfile.print %Q{"#{i}"}+"[label="+%Q{"#{$sline[i]}"}+"," ###20121206
#      wfile.puts "color=#{$node_color[j-1]},style=filled];"
      wfile.print %Q{"#{$sline[i]}"}+"[tooltip="+%Q{"#{$sline[i]} #{$sline_time[i]}"}+"]"+"[label="+%Q{"#{$sline[i]}"}+","
       watch=$url_call+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[i].strip}"+"&path1="
      wfile.puts "color=#{$node_color[j-1]},style=filled,URL="+%Q{"#{watch}"}+"];" 
   end
end
for i in $number_in[$number_path]..($number_in[$number_path+1]-1)
#     wfile.print %Q{"#{i}"}+"[label="+%Q{"#{$sline[i]}"}+","###20121206
#     wfile.puts "color=#{$node_color[9]},style=filled];"
    wfile.print %Q{"#{$sline[i]}"}+"[tooltip="+%Q{"#{$sline[i]} #{$sline_time[i]}"}+"]"+"[label="+%Q{"#{$sline[i]}"}+","
       watch=$url_call+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[i].strip}"+"&path1="
     wfile.puts "color=#{$node_color[9]},style=filled,URL="+%Q{"#{watch}"}+"];"
end
#puts "number====#{$number_path}"
###print edges include edges color,edges weights,URL=watchfuc-link. 
for i in 0..100000
  if $num[i]!=0 or $num_d[i]!=0
    s_j=i/$number
   
    b_number=(i%($number))    
    
    t_flag=0
    if s_j>=0 and s_j<$number_in[$number_path] and b_number >=$number_in[$number_path] and b_number<$number_in[$number_path+1]
#       wfile.puts %Q{"#{s_j}"}+"->"+%Q{"#{b_number}"}+"[label="+%Q{"#{$num[i]}"}+",color=#{$edge_color[0]}]" ###20121206
#      if c_num4==1
        watch=$url+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
          title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
    title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
       wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[0]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
#      end
       t_flag=1
    end
    if b_number>=0 and b_number<$number_in[$number_path] and s_j >=$number_in[$number_path] and s_j<$number_in[$number_path+1]
 #      wfile.puts %Q{"#{s_j}"}+"->"+%Q{"#{b_number}"}+"[label="+%Q{"#{$num[i]}"}+",color=#{$edge_color[1]}]"###20121206
 #     if c_num5==1
      watch=$url+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
       wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[1]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"  
 #     end
     t_flag=1
    end

   # for j in 1..($number_path+1)
      if $number_path>=0
        j=1
       if s_j>=$number_in[j-1] and s_j<$number_in[j] and b_number>=$number_in[j-1] and b_number<$number_in[j]
#           wfile.puts %Q{"#{s_j}"}+"->"+%Q{"#{b_number}"}+"[label="+%Q{"#{$num[i]}"}+",color=#{$edge_color[j+1]}]"###20121206
 #        if c_num1==1
        watch=$url+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
         
          if $number_path==0
           wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[3]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
          else
          wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[2]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
          end
 #        end
          t_flag=1
       end
    end
     if $number_path>=1
        j=2
       if s_j>=$number_in[j-1] and s_j<$number_in[j] and b_number>=$number_in[j-1] and b_number<$number_in[j]
#           wfile.puts %Q{"#{s_j}"}+"->"+%Q{"#{b_number}"}+"[label="+%Q{"#{$num[i]}"}+",color=#{$edge_color[j+1]}]"###20121206
 #        if c_num3==1
        watch=$url+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
         if $number_path==1
          wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[3]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
         else
           wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[4]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
          end
 #        end
          t_flag=1
       end
    end
     if $number_path>=2
        j=3
       if s_j>=$number_in[j-1] and s_j<$number_in[j] and b_number>=$number_in[j-1] and b_number<$number_in[j]
#           wfile.puts %Q{"#{s_j}"}+"->"+%Q{"#{b_number}"}+"[label="+%Q{"#{$num[i]}"}+",color=#{$edge_color[j+1]}]"###20121206
#         if c_num2==1
        watch=$url+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"

          wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[3]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
#         end
          t_flag=1
       end
    end

   if t_flag==0
 #     if c_num6==1
    #       wfile.puts %Q{"#{s_j}"}+"->"+%Q{"#{b_number}"}+"[label="+%Q{"#{$num[i]}"}+",color=#{$edge_color[$number_path+1]}]"
        watch=$url+"v="+$version+"&a="+$a_ver+"&path0="+"#{$sline[s_j].strip}"+"&path1="+"#{$sline[b_number].strip}"
title="[tooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"
title1="[labeltooltip="+%Q{"#{$sline[s_j]}->#{$sline[b_number]}:#{$num[i]},#{$num_d[i]}"}+"]"

          wfile.puts %Q{"#{$sline[s_j]}"}+"->"+%Q{"#{$sline[b_number]}"}+"[label="+%Q{"#{$num[i]},#{$num_d[i]}"}+",color=#{$edge_color[8]},URL="+%Q{"#{watch}"}+"]#{title}#{title1}"
  #    end
   end

  end
end

wfile.puts "}"
#end print graph file
#wfile.close
   end #end step.three
end 

$dfctline=""
$udfctline=""
 

module Creatnode
  def Creatnode.readfile(name)
     if File.exist?name
      afile=File.new(name)
      dline=""
      while line=afile.gets
       dline.concat("#{line}")
      end
      $fill_line.concat("#{dline}")       
      afile.close 
    end
  end
#=begin  #20130402 add with the need of dynamic call graph
 def Creatnode.seachnodenum(f_name)
         tlnum=-1
     for i in 0..($number-1)
        if f_name.index($sline[i])
           lnum=i
        end
        if f_name==($sline[i]+" ")
           tlnum=i       
        end
      end   
      if tlnum!=-1
       lnum=tlnum
      end
    # puts lnum
      return lnum  
  end
  def Creatnode.dynsystapfunction(name,flag,f_name,c_time,r_time,pid,tid)
     lnum=Creatnode.seachnodenum(f_name)

     #    if File.exist?(name)
     if File.exist?name
#    puts "xxx #{name}"
         afile=File.new(name,"r")
         s_line=""
         while line=afile.gets
            t_call=line.split(" ")[5]
            t_beg=t_call.index("/")+1
            t_end=t_call.rindex(":")-1
            t_func=t_call.slice(t_call.index(":")+1..t_beg-3)
            t_line=t_call.slice(t_beg..t_end)
            if flag==1 
               t_line=t_line+"/"+t_func
            end
            s_line.concat(" #{t_line} XX \n")
         end
        afile.close
         s_line=s_line.split("\n")+$n_sline
         s_line=s_line.sort
         s_size=s_line.size
         i=0
     # if s_line.size>3000
     #     puts s_line
     # end
 #      puts $n_sline
       while i<=s_size-1
            for j in (i+1)..(s_size-1)
           #     if s_line[j].split(" ")[0]!=s_line[i].split(" ")[0]
                 sline_temp=s_line[j].split(" ")[0]
          #       if s_line[i].index(" X ")
          #       puts "**#{sline_temp}**#{s_line[i].split(" ")[0]}**#{sline_temp.index("gggg")}"
           #      end
                if !sline_temp.index(s_line[i].split(" ")[0])
            #     puts "#{sline_temp.index(s_line[i].split(" ")[0])}#{s_line[j].split(" ")[0]}"
                  if (j-i)>1
                    snum=s_line[i].split(" ")[2].to_i
                   # puts "#{snum} #{s_line[i]} #{j-i}"
  #                  puts "X #{snum} #{s_line[i]}"
          #          puts "y #{snum} #{s_line[j-1]}"

                    allnum=lnum*$number+snum
                    $num_d[allnum]=$num_d[allnum]+j-i-1
                  end
                  i=j
                  break
                end
     
            end      
            if j==(s_size-1)
              if (j-i)>1
                 snum=s_line[i].split(" ")[2].to_i
                 allnum=lnum*$number+snum
                 $num_d[allnum]=$num_d[allnum]+j-i-1              
              end
              i=j+1
            end
         end
      end      
  end
#=end
  ###call_function include $fill_line(with the information of number of the nodes) and the CALL_F
  ###in this function know begin nodes ;call_function we can know end nodes and can calculate the numbers 
  ###sort call_function
  ###if neighbor have same function-name continue 
  ###else calculate call_f numbers
  ### name:read file name,f_name:node name
  def Creatnode.function(name,flag,f_name)##seach nodes and the same time count the weight of the edges

        fun_node=f_name
      tlnum=-1
     for i in 0..($number-1)
        if fun_node.index($sline[i])
           lnum=i
        end
        if fun_node==($sline[i]+" ")
           tlnum=i
       
        end
      end   
      if tlnum!=-1
       lnum=tlnum
      end
   ##read function outlist file only select CALL_F 
   if !File.exist?name
     return
   end
   afile=File.new(name)
   call_function=""
       
######20121206

     line=afile.readlines
    if line.size==0
       return
    end
     line.each do |x|
        if x.index("CALL_F")
             call_function.concat("#{x.split(" ")[1]} XX\n")
        end
     end 
      call_function=call_function.split("\n")+$fill_line
      call_function=call_function.sort
      call_size=call_function.size
      i=0
      while i<=call_size-1
          for j in (i+1)..(call_size-1)
               if call_function[j].split(" ")[0]!=call_function[i].split(" ")[0] #or call_function[j].split(" ")[1]=="X"
                 
                 if (j-i)>1 
                  snum=call_function[i].split(" ")[2].to_i
                  if call_function[i].split(" ")[1]=="X" and call_function[i+1].split(" ")[1]=="X"                        
                     if (j-i)>2
                       allnum=lnum*$number+snum
                       $num[allnum]=$num[allnum]+j-i-2
                     end
                  else

                  allnum=lnum*$number+snum
                  $num[allnum]=$num[allnum]+j-i-1
                  end
                 end
                 i=j
                 break                 
              end
          end
         if j==(call_size-1)
           if (j-i)>1
               snum=call_function[i].split(" ")[2].to_i
               allnum=lnum*$number+snum
               $num[allnum]=$num[allnum]+j-i-1        
             end
            i=j+1
         end
      end
      afile.close
  end

  def Creatnode.creat1(path,subpath,pre_path)# creat node
      path=(path+"/").gsub(/\/+/,"/")
    if File.directory? path 
      Dir.foreach(path) do |next_path|
        if next_path!="." and next_path!=".."   and (path+"/"+next_path+"/").gsub(/\/+/,"/")!=pre_path  
          if File.directory?(path+"/"+next_path)
            t_line=(path+"/"+next_path).gsub(/\/+/,"/")
          
            name=path+"/"+next_path+"/"+next_path+".Dudfctlst" #in path and path ,path is a node
            name1=path+"/"+next_path+"/"+next_path+".Ddfctlst" #in path and path ,path is a node
            name2=path+"/"+next_path+"/"+next_path+".dynDoutlst" #in path and path ,path is a node
            if File.exist?name and File.exist?name1  
             if (!(File.new(name).stat.zero?)) ||(!(File.new(name1).stat.zero?))
              t1_line=(" "+(t_line).sub(subpath,"")+"\n").gsub(/\/+/,"/")
         
              if (!($sline.index(t1_line))) and (!($dirpath_si.index(t1_line.chomp)))
                $sline+=t1_line
                $number=$number+1
              end
            end
           else
             
             if (!(File.new(name2).stat.zero?))               
              t1_line=(" "+(t_line).sub(subpath,"")+"\n").gsub(/\/+/,"/")
       
              if (!($sline.index(t1_line))) and (!($dirpath_si.index(t1_line.chomp)))
                $sline+=t1_line
                $number=$number+1
              end
            end
           end
          else
            if next_path.index(".dfclst") || next_path.index(".udfctlst") #|| next_path.index(".dynfctrlt")                        #in file and file ,file is a node
              name=path+"/"+next_path
              t1_line=(" "+((path+"/"+next_path).sub(subpath,"")).sub(/\.[du]+fctlst/,".c")+"\n").gsub(/\/+/,"/")
              if !($sline.index(t1_line)) and (!($dirpath_si.index(t1_line.chomp)))
                $sline+=t1_line
                $number=$number+1
              end
            end
          end
        end
      end
#=begin
    else ##if input if file need read file ,the same time node is a function /20130325 function is node
      
      n_path=path.chop.chop+"fctrlt"
  
      afile=File.new(n_path)
      lines=afile.readlines
      lines.each do |x|
        if x.index("FUNCTION")
          t1_line=" "+(path.chop).sub(subpath,"")+"/"+x.split(" " )[1]+"\n"
          $sline+=t1_line
          $number=$number+1
        end
      end
     
      afile.close      
#=end     
   end
  end 
  def Creatnode.dg1(path,subpath,pre_path)
      path=(path+"/").gsub(/\/+/,"/")
subpath=subpath.gsub(/\/+/,"/")     
 leng=path.split("/").size
      leng1=subpath.gsub(/\/+/,"/").split("/").size
      if leng>(leng1)
     lpath=path.gsub("/"," ")
         lsize=lpath.split(" ").size
         lpath=lpath.split(" ").slice(0,lsize-1) 
         lpath="/"+lpath.join("/")              
         Creatnode.creat1(lpath,subpath,path)
         Creatnode.dg1(lpath,subpath,path)
      end
  end
end


module Read# read the path from the screen -o output file name -d path -w write path
     def Read.function(s)
  
         a=s.split(" ")
         if a[0]!="-0" and a[0]!="-1" and a[0]!="-2"
            puts "please input like this:"
            puts "*.rb -0 <path> -w <path> -d <path> ...<path> [-o filename]"
            puts "*.rb -1 <path> -w <path> "
            puts "*.rb -2 <path> -d <path> ...<path> [-o filename] "
            
            exit(1)
         end
         $step_number=a[0]
        # puts a.index("-2")
         a.slice!(0,1)
         $output=$output.concat([a.at(0)])
          w_index=a.index("-w")
         if $step_number=="-0" or $step_number=="-1"
          if !w_index
            puts "please input like this:"
            puts "*.rb -0 <path> -w <path> -d <path> ...<path> [-o filename]"
            puts "*.rb -1 <path> -w <path> "
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
            puts "please input like this:"
            puts "*.rb -1 <path> -w <path> "
            exit(1)
          end
       elsif $step_number=="-2"
              if w_index
               puts "please input like this:"
               puts "*.rb -2 <path> -d <path> ...<path> [-o filename] "
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
             $graph_moudle=a[o_index+6].to_i
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

                puts "notice: input path can not include anothe path"
                puts "\n"
                flag=1
                print "please input like follow"
 #               puts " goldfish -   w root/result_goldfish -d arch/arm/kernel  arch/arm/mm ...... -o ......"
                 puts "*.rb -0 <path> -w <path> -d <path> ...<path> [-o filename]"
                 puts "*.rb -1 <path> -w <path> "
                 puts "*.rb -2 <path> -d <path> ...<path> [-o filename] "
                exit(1) 
      
             end
           end 
         end
       end
     end
 end
end
######main function
####file name and path input from screen
$output=[]
$step_number=""
inputpath=""
ARGV.each do|arg|
inputpath+=arg+" "
end

Read.function(inputpath)

$number_path=$output.size-3
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
for i in 1..$number_path
  $dirpath_si+=" "+$output[i+2]
end
$dirpath_si=$dirpath_si.gsub(/\/+/,"/")



directory_path =$output[0]

write_path =$output[1]


Step.three()


#exec "dot -Tjpg /usr/share/lxr/http/temp/#{$output[2]} -o #{/([a-zA-Z0-9_-]+)\.graph/.match(/usr/share/lxr/http/temp/$output[2])}.jpg"

#end


######


