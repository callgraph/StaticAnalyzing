#!/usr/bin/ruby -w
require 'find'
require 'mysql'
inputpath=Array.new(20)
i=0
ARGV.each do|arg|
inputpath[i]=arg
i=i+1
end



$mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')    #connect mysql

module Taint
   def Taint.trace(depth,function,functionpath,calltrace)
       if depth==$maxdepth
          return 1
       end
    #mysql   search-"function"->id 
    id=0    #function id number ，init       
    rsid=$mydb.query("SELECT f_id FROM `#{$sql_fdlist}` WHERE f_name=\"#{function}\" and f_dfile=\"#{functionpath}\"")    # search function name is “function”，index the function's id in all function define list
    rsid.each_hash do |row|
       id=row['f_id']
    end
#puts id  
    #mysql   search-"id"->callfunction
    rsc=$mydb.query("SELECT * FROM `#{$sql_slist}` WHERE F_point=#{id}")    #find calls function in static function define list  
        numdepth=$maxdepth-depth
        rsc.each_hash do |row|
          callfunction=row['C_name']    #search result maybe more，cname save every result
          cfunctionpath=row['C_dfile']
#puts cfunctionpath   
       if $old_define.index(":#{function};#{functionpath}:->:#{callfunction};#{cfunctionpath}:")   #if the function has been search next other insert the function into $old_define 
             temp_id=$old_define.index(":#{function};#{functionpath}:->:#{callfunction};#{cfunctionpath}:")
             temp_fc=$old_define.slice(temp_id+1..$old_define.size)
             temp_f_c=temp_fc.slice(0..temp_fc.index("\n")-1)

             l_depth=temp_f_c.split("->")[3].strip.to_i
             if numdepth+l_depth>=$maxdepth
                next
             else
                if numdepth>l_depth
                  temp_f_c_1=temp_f_c.sub("->->#{l_depth}","->->#{numdepth}")
                  $old_define.sub(temp_f_c,temp_f_c_1)
                end
             end
          else
             tempfunction=" "+callfunction+" "
             $old_define.concat(":#{function};#{functionpath}:->:#{callfunction};#{cfunctionpath}:->->#{numdepth}\n")
          end

          if callfunction == $destinationfunction and cfunctionpath == $destfuncpath
              calltrace.split(":").each do |tempfunction|
                tempfunction_1=" "+tempfunction+" \n"
                if !$node_list.index(tempfunction_1)
                  $node_list.concat(tempfunction_1)
                end
              end             
          else
             calltrace_c=calltrace+":#{callfunction};#{cfunctionpath}"
             Taint.trace(depth+1,callfunction,cfunctionpath,calltrace_c)   
          end
       end
   end
end
$f_vir=inputpath[6]
$version=inputpath[4]
$a_ver=inputpath[5]
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


#    rsid=$mydb.query("SELECT * FROM FDLIST WHERE f_name=\"#{inputpath[1]}\"")    # search function name is “function”，index the function's id in all function define list
#    rsid.each_hash do |row|
#       id=row['f_id']
#       path=row['f_dfile']
      $old_define=""
      path=inputpath[1]
      functionname=path.slice(path.rindex("/")+1..path.length)
      functionpath=path.slice(0..path.rindex("/")-1)
      destpath=inputpath[2]
      destname=destpath.slice(destpath.rindex("/")+1..destpath.length)
      dest_path=destpath.slice(0..destpath.rindex("/")-1)
      $node_list=" #{functionname};#{functionpath} \n"       #######
      $maxdepth=inputpath[0].to_i          #######
      $destinationfunction=destname #######
      $destfuncpath=dest_path
      Taint.trace(0,functionname,functionpath,"#{destname};#{dest_path}")
      afile=File.new(inputpath[3],"w")
      afile.puts "digraph root{\nrankdir=HR\nnode [style=rounded]\n"
      $node_list.split("\n").each do |x|
        afile.print %Q{"#{x.slice(0..x.index(";")-1)}"}+"[tooltip="+%Q{"#{x.slice(x.index(";")+1..x.length)}"}+"];\n"
  #      afile.puts "\"#{x}\";"
      end
#      puts $node_list
#      puts "****"
      $old_define.split("\n").each do |x|
         x=x.gsub(/:+/,"")
         a=x.split("->")
 #  puts "#{a[0]} ->#{a[1]} ***"
         if $node_list.index(" #{a[0]} ") and $node_list.index(" #{a[1]} ")
#           afile.puts "\"#{a[0]}\"->\"#{a[1]}\";"
           afile.print %Q{" #{a[0].slice(0..a[0].index(";")-1)}"}+"->"+%Q{" #{a[1].slice(0..a[1].index(";")-1)}"}+"\n"
          end
      end
     afile.puts "}"
    #  puts "#{id} #{path}" 
#    end


#Taint.trace(0,"e1000_set_spd_dplx","drivers/net/ethernet/intel/e1000/e1000_main.c","e1000_set_spd_dplx")







