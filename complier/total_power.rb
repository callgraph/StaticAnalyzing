#!/usr/bin/ruby -w
require 'mysql'

$kernel_version=ARGV[0] #"Android-4.4.3"
$directory_type=ARGV[1] #"R"
$platform=ARGV[2] #"arm-Nexus"
#$testcase=ARGV[3]	#"N5"
if $directory_type == "real"
	$directory_type="R"
else
	$directory_type="V"
end

#$option=$kernel_version+"_"+$directory_type+"_"+$platform+"_"+$testcase+"_"
$option=$kernel_version+"_"+$directory_type+"_"+$platform+"_"

mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')	#connect to mysql

#Create Table N5_PowerLIST 
mydb.query("DROP TABLE IF EXISTS `#{$option+"N5_PowerLIST"}` ")
mydb.query("CREATE TABLE IF NOT EXISTS `#{$option+"N5_PowerLIST"}` 
	(f_point INT,
	f_power DOUBLE UNSIGNED)")


powerlist_everyvalue=[]
rsD=mydb.query("SELECT C_point, SUM(E_consumption) FROM `#{$option+"DLIST"}` WHERE F_point!=0 AND C_point!=0 GROUP BY C_point")	#DLIST数据库表中挑出被调函数指针，被调函数被调用时刻，被调函数返回时刻
rsD.each_hash do |rowD|
	tempfid=rowD['C_point'].to_i
	tempfpower=rowD['SUM(E_consumption)']
	powerlist_everyvalue.concat(["(#{tempfid},#{tempfpower}),"])
	if powerlist_everyvalue.size==1000	#insert into N5_PowerLIST  , 1000 as a group
		powerlist_values=""
		powerlist_everyvalue.each do |row|
			powerlist_values += row
		end
		powerlist_values=powerlist_values.gsub(/,$/,'')
		mydb.query("INSERT INTO `#{$option+"N5_PowerLIST"}`(f_point, f_power) VALUES#{powerlist_values}")
		powerlist_everyvalue.clear
	end
end

if powerlist_everyvalue.size>0	#insert into N5_PowerLIST
	powerlist_values=""
	powerlist_everyvalue.each do |row|
		powerlist_values += row
	end
	powerlist_values=powerlist_values.gsub(/,$/,'')
	mydb.query("INSERT INTO `#{$option+"N5_PowerLIST"}`(f_point, f_power) VALUES#{powerlist_values}")
	powerlist_everyvalue.clear
end



