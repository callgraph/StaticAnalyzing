#!/usr/bin/ruby
require 'mysql'

`find . -name "*.sched2"|xargs grep -e ';; Function' -e return_internal -h>retline`

mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
kernel=ARGV[0]+'_R_'+ARGV[1]+'_FDLIST'

a=mydb.query("select f_name,f_dfile,f_rline,f_id from `#{kernel}` ")
a.each do |value|
        res=`grep '\s#{value[0]}\s' retline -A 1`
        regex=Regexp.new(/\s#{value[1]}:(\d+)/)
        tt=regex.match(res)
        if(tt)
		if(tt[1]!=value[2])
	                mydb.query("update `#{kernel}` set f_rline=\"#{tt[1]}\"  where f_id=\"#{value[3]}\" ")
        	end
	end
end
