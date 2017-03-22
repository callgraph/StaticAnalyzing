#!/usr/bin/ruby -w
require 'mysql'

mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
kernel=ARGV[0]+'_R_'+ARGV[1]+'_FDLIST'

mydb.query("BEGIN")
a=mydb.query("select f_dfile,f_dline,f_id from `#{kernel}` where f_rline is null")
a.each do |value|
	mydb.query("update `#{kernel}` a set a.f_rline=(select b.line from (select min(c.f_dline) as line from `#{kernel}` c where c.f_dfile=\"#{value[0]}\" and c.f_dline>#{value[1]}) b)-1  where a.f_id=#{value[2]}")
end
mydb.query("COMMIT")

mydb.query("BEGIN")
a=mydb.query("select f_dfile,f_id from `#{kernel}` where f_rline is null")
a.each do |value|
	retline=`wc -l #{value[0]}`.split()[0]
        mydb.query("update `#{kernel}` set f_rline=#{retline} where f_id=#{value[1]}")
end
mydb.query("COMMIT")
