#!/usr/bin/ruby -w
require 'mysql'

mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
kernel=ARGV[0]+'_R_'+ARGV[1]+'_FDLIST'

#mydb.query("BEGIN")
a=mydb.query("select f_name,f_dfile from `#{kernel}` where f_saddress=\"\" ")
a.each do |value|
	funcinfo=`grep -w #{value[0]} func.txt`
	funcinfo=funcinfo.gsub("./","")
	
	tmp=funcinfo.split("\n")
	if(tmp.size==1)
		res=tmp[0].split()[0]
	else
		res=`grep #{value[0]} func.txt | grep #{value[1]}`.split()[0]
	end
	if(res=="")
		puts value[0]+" "+value[1]
	else
       		mydb.query("update `#{kernel}` set f_saddress=\"#{res}\"  where f_name=\"#{value[0]}\" and f_dfile=\"#{value[1]}\" ")
	end
end
#mydb.query("COMMIT")
