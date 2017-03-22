#!/usr/bin/ruby -w
require 'power'
require 'mysql'

$kernel_version=ARGV[0] #"Android-4.4.3"
$directory_type=ARGV[1] #"R"
$platform=ARGV[2] #"arm-Nexus"
#$testcase=
if $directory_type == "real"
	$directory_type="R"
else
	$directory_type="V"
end

$option=$kernel_version+"_"+$directory_type+"_"+$platform+"_"

file1=File.open("file1.txt","a")

include Power
puts load_PowerData("power.dat");

	power_begin=(`cat power.dat | head -n 1`).split(" ")[0].to_i
	power_end=(`cat power.dat | tail -n 1`).split(" ")[0].to_i

fname=""
ctime=""
rtime=""

mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')	#connect to mysql
rsD=mydb.query("SELECT C_point, C_time, R_time, DLIST_id FROM `#{$option+"DLIST"}` WHERE F_point!=0 AND C_point!=0")	#DLIST数据库表中挑出被调函数指针，被调函数被调用时刻，被调函数返回时刻
rsD.each_hash do |rowD|
	ctime=rowD['C_time'].to_i
	rtime=rowD['R_time'].to_i
 	
	if (ctime>power_begin or ctime==power_begin) and (ctime<power_end or ctime==power_end)	#如果数据库中的记录在power.dat文件有数据的范围内
		rsF=mydb.query("SELECT f_name FROM `#{$option+"FDLIST"}` WHERE f_id=\"#{rowD['C_point']}\"")	#从FDLIST数据库表中查找被调函数函数名
		rsF.each_hash do |rowF|
			fname=rowF['f_name']
		end
		consum_all=get_Power(0, "#{fname}", "#{ctime}", "#{rtime}");	#何兴诗的接口，根据函数名、被调用时刻、返回时刻计算函数整体执行能耗

		consum_fun=consum_all	#consum_fun变量用于存放函数纯能耗（函数本体减去子函数调用的能耗）

                rsI=mydb.query("SELECT C_point, C_time, R_time, DLIST_id FROM `#{$option+"DLIST"}` WHERE F_point!=0 AND C_point!=0 AND C_time>#{rowD['C_time']} AND R_time<#{rowD['R_time']} ORDER BY C_time")#DLIST数据库表中挑出被调函数指针，被调函数被调用时刻，被调函数返回时刻
                fname_in=""
		tempctime_in=0
		temprtime_in=0
                rsI.each_hash do |rowI|
			ctime_in=rowI['C_time'].to_i
			rtime_in=rowI['R_time'].to_i
						
			if !(ctime_in>tempctime_in and rtime_in<temprtime_in)
				#减去
				rsFI=mydb.query("SELECT f_name FROM `#{$option+"FDLIST"}` WHERE f_id=\"#{rowI['C_point']}\"")   #select f_name from FDLIST
				rsFI.each_hash do |rowFI|
					fname_in=rowFI['f_name']	#从FDLIST数据库表中查找被调函数（子函数）函数名
				end
				consum_in=get_Power(0, "#{fname_in}", "#{ctime_in}", "#{rtime_in}")	#何兴诗的接口，根据函数名、被调用时刻、返回时刻计算函数（子函数）整体执行能耗
				consum_fun=consum_fun-consum_in

#file1.puts "#{consum_all} #{fname_in} #{ctime_in} #{rtime_in} #{consum_in} #{rowI['DLIST_id']}"

				tempctime_in=ctime_in
				temprtime_in=rtime_in	
			end
                end
#puts "#{consum_all} #{consum_fun} #{rowD['DLIST_id']}\n" if consum_fun<0 and consum_all!=consum_fun	#调试输出---打印【函数整体能耗 函数纯能耗】  如果函数纯能耗为负值才打印
#file1.puts "#{consum_all} #{consum_fun} #{rowD['DLIST_id']}\n" if consum_fun<0 and consum_all!=consum_fun	#调试输出---打印【函数整体能耗 函数纯能耗】  如果函数纯能耗为负值才打印
#file1.puts "#{consum_all} #{consum_fun} #{rowD['DLIST_id']}\n" if consum_fun<0 and consum_all!=consum_fun	#调试输出---打印【函数整体能耗 函数纯能耗】  如果函数纯能耗为负值才打印
		mydb.query("UPDATE `#{$option+"DLIST"}` SET E_consumption=#{consum_fun} WHERE DLIST_id=#{rowD['DLIST_id']}")
	end
end
