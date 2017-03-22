#!/usr/bin/ruby -w
require 'mysql'

$kernel_version=ARGV[0]#"linux-3.5.4"
$directory_type1="V"
$directory_type2="R"
$platform=ARGV[1]#"x86_32"

$option1=$kernel_version+"_"+$directory_type1+"_"+$platform+"_"
$option2=$kernel_version+"_"+$directory_type2+"_"+$platform+"_"

#$primary_path="/usr/local/share/lxr/source/linux-3.5.4/code/linux/"

module Vlists
        def Vlists.sqlexist(sqltablename)
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

	def Vlists.vfdlist()
		# Connect to MySQL
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
puts("#{Time.now}\tVFDLIST BEGIN")		
		mydb.query("DROP TABLE IF EXISTS `#{$option1+"FDLIST"}`")
		mydb.query("CREATE TABLE `#{$option1+"FDLIST"}` SELECT * FROM `#{$option2+"FDLIST"}`")
				
		mydb.query("ALTER TABLE `#{$option1+"FDLIST"}` ADD INDEX (f_dfile)")
		
		#replace the f_dfile in FDLIST by the V_path in VLIST
		rs=mydb.query("SELECT DISTINCT f_dfile FROM `#{$option1+"FDLIST"}`")
		rs.each_hash do |row|
			rsV=mydb.query("SELECT * FROM `#{$option1+"LIST"}` WHERE P_path='#{row['f_dfile']}'")
			rsV.each_hash do |rowV|
				mydb.query("UPDATE `#{$option1+"FDLIST"}` SET f_dfile=\"#{rowV['V_path']}\" WHERE f_dfile='#{row['f_dfile']}'")
			end
		end
		mydb.query("ALTER TABLE `#{$option1+"FDLIST"}` DROP INDEX f_dfile")
		mydb.query("ALTER TABLE `#{$option1+"FDLIST"}` ADD INDEX (f_name, f_dfile)")
		mydb.query("ALTER TABLE `#{$option1+"FDLIST"}` ADD INDEX (f_id)")
puts("#{Time.now}\tVFDLIST END")			
	end	#end def Vlists.vfdlist

	def Vlists.vslist()
		# Connect to MySQL
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
puts("#{Time.now}\tVSLIST BEGIN")			
		mydb.query("DROP TABLE IF EXISTS `#{$option1+"SLIST"}`")
		mydb.query("CREATE TABLE `#{$option1+"SLIST"}` SELECT * FROM `#{$option2+"SLIST"}`")
		
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` ADD INDEX (F_dfile)")
		rs=mydb.query("SELECT DISTINCT F_dfile FROM `#{$option1+"SLIST"}`")
		rs.each_hash do |row|
			rsV=mydb.query("SELECT * FROM `#{$option1+"LIST"}` WHERE P_path='#{row['F_dfile']}'")
			rsV.each_hash do |rowV|
				mydb.query("UPDATE `#{$option1+"SLIST"}` SET F_dfile=\"#{rowV['V_path']}\" WHERE F_dfile='#{row['F_dfile']}'")
			end
		end
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` DROP INDEX F_dfile")
		
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` ADD INDEX (C_dfile)")
		rs=mydb.query("SELECT DISTINCT C_dfile FROM `#{$option1+"SLIST"}`")
		rs.each_hash do |row|
			rsV=mydb.query("SELECT * FROM `#{$option1+"LIST"}` WHERE P_path='#{row['C_dfile']}'")
			rsV.each_hash do |rowV|
				mydb.query("UPDATE `#{$option1+"SLIST"}` SET C_dfile=\"#{rowV['V_path']}\" WHERE C_dfile='#{row['C_dfile']}'")
			end
		end
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` DROP INDEX C_dfile")
		
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` ADD INDEX (Cd_file)")
		rs=mydb.query("SELECT DISTINCT Cd_file FROM `#{$option1+"SLIST"}`")
		rs.each_hash do |row|
			rsV=mydb.query("SELECT * FROM `#{$option1+"LIST"}` WHERE P_path='#{row['Cd_file']}'")
			rsV.each_hash do |rowV|
				mydb.query("UPDATE `#{$option1+"SLIST"}` SET Cd_file=\"#{rowV['V_path']}\" WHERE Cd_file='#{row['Cd_file']}'")
			end
		end
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` DROP INDEX Cd_file")
		
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` ADD INDEX (F_point)")
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` ADD INDEX (C_point)")
		mydb.query("ALTER TABLE `#{$option1+"SLIST"}` ADD INDEX (SLIST_id)")

puts("#{Time.now}\tVSLIST END")
	end	#end def Vlists.vslist
	
	def Vlists.vsolist()
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
puts("#{Time.now}\tVSOLIST BEGIN")			
		mydb.query("DROP TABLE IF EXISTS `#{$option1+"SOLIST"}`")
		mydb.query("CREATE TABLE IF NOT EXISTS `#{$option1+"SOLIST"}`
				(F_path VARCHAR(150),
				C_path VARCHAR(150),
				COUNT INT,
				INDEX(F_path, C_path))")
		
		vsolist_everyvalue=[]
		
		tempFname=""	#主调函数名
		tempCname=""	#被调函数名
		tempFdfile=""	#主调函数定义路径
		tempCdfile=""	#被调函数定义路径
		tempFnode=""	#主调函数节点
		tempCnode=""	#被调函数节点


		rs=mydb.query("SELECT DISTINCT F_point, C_point FROM `#{$option1+"SLIST"}` WHERE C_point IS NOT NULL")
		rs.each_hash do |row|
			rsF = mydb.query("SELECT f_name, f_dfile FROM `#{$option1+"FDLIST"}` WHERE f_id=#{row['F_point']}") #search the F_dfile in the FDLIST by F_point
			rsF.each_hash do |rowF|
				tempFname=rowF['f_name']
				tempFdfile=rowF['f_dfile']
				tempFnode=tempFdfile+"/"+tempFname
			end

			rsC = mydb.query("SELECT f_name, f_dfile FROM `#{$option1+"FDLIST"}` WHERE f_id=#{row['C_point']}") #search the C_dfile in the FDLIST by C_point
			rsC.each_hash do |rowC|
				tempCname=rowC['f_name']
				tempCdfile=rowC['f_dfile']
				tempCnode=tempCdfile+"/"+tempCname
			end

			if tempFnode!="" and tempCnode!="" and tempFnode!=tempCnode	#若不为空且不是自己调用自己
				count=0	#用于记录函数与函数间的调用次数
				rscount=mydb.query("SELECT count(*) FROM `#{$option1+"SLIST"}` WHERE F_point=#{row['F_point']} AND C_point=#{row['C_point']}")	#统计函数间调用了多少次
				rscount.each_hash do |rowcount|
					count=rowcount['count(*)'].to_i
					vsolist_everyvalue.concat(["(\"#{tempFnode}\",\"#{tempCnode}\",#{count}),"])
				end

				#2. the file's VSOLIST
				if tempFdfile!=tempCdfile	#若主调函数与被调函数不在一个文件中
					vsolist_everyvalue.concat(["(\"#{tempFdfile}\",\"#{tempCnode}\",#{count}),"])
				end

				#3. the directory's VSOLIST
				dir=File.dirname(tempFdfile).gsub(/\s+/,"").concat("/")
				while dir and dir!="/"
					dpath=" "+dir
					spath=" "+tempCnode
					if !(spath.index(dpath))
						vsolist_everyvalue.concat(["(\"#{dir}\",\"#{tempCnode}\",#{count}),"])
						if dir.rindex("/",dir.rindex("/")-1)
							dir=dir.slice(0..dir.rindex("/",dir.rindex("/")-1))
						else
							break
						end
					else
						break
					end
				end	
			end
				
			if vsolist_everyvalue.size>1000	#insert into SLIST , 1000 as a group
				vsolist_values=""
				vsolist_everyvalue.each do |row|
					vsolist_values += row
				end
				vsolist_values=vsolist_values.gsub(/,$/,'')

				mydb.query("INSERT INTO `#{$option1+"SOLIST"}` (F_path, C_path, COUNT) VALUES#{vsolist_values}")
				vsolist_everyvalue.clear
			end
		end

		if vsolist_everyvalue.size>0
			vsolist_values=""
			vsolist_everyvalue.each do |row|
				vsolist_values += row
			end
			vsolist_values=vsolist_values.gsub(/,$/,'')
			mydb.query("INSERT INTO `#{$option1+"SOLIST"}` (F_path, C_path, COUNT) VALUES#{vsolist_values}")
			vsolist_everyvalue.clear
		end
puts("#{Time.now}\tVSOLIST END")			
	end	#end def Vlists.vsolist

	def Vlists.vdolist()
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
puts("#{Time.now}\tVDOLIST BEGIN")			
		mydb.query("DROP TABLE IF EXISTS `#{$option1+"DOLIST"}`")
		mydb.query("CREATE TABLE IF NOT EXISTS `#{$option1+"DOLIST"}`
				(F_path VARCHAR(150),
				C_path VARCHAR(150),
				COUNT INT,
				INDEX(F_path, C_path))")
		
		vdolist_everyvalue=[]
		
		tempFname=""	#主调函数名
		tempCname=""	#被调函数名
		tempFdfile=""	#主调函数定义路径
		tempCdfile=""	#被调函数定义路径
		tempFnode=""	#主调函数节点
		tempCnode=""	#被调函数节点


		rs=mydb.query("SELECT DISTINCT F_point, C_point FROM `#{$option1+"DLIST"}` WHERE C_point IS NOT NULL")
		rs.each_hash do |row|
			rsF = mydb.query("SELECT f_name, f_dfile FROM `#{$option1+"FDLIST"}` WHERE f_id=#{row['F_point']}") #search the F_dfile in the FDLIST by F_point
			rsF.each_hash do |rowF|
				tempFname=rowF['f_name']
				tempFdfile=rowF['f_dfile']
				tempFnode=tempFdfile+"/"+tempFname
			end

			rsC = mydb.query("SELECT f_name, f_dfile FROM `#{$option1+"FDLIST"}` WHERE f_id=#{row['C_point']}") #search the C_dfile in the FDLIST by C_point
			rsC.each_hash do |rowC|
				tempCname=rowC['f_name']
				tempCdfile=rowC['f_dfile']
				tempCnode=tempCdfile+"/"+tempCname
			end

			if tempFnode!="" and tempCnode!="" and tempFnode!=tempCnode	#若不为空且不是自己调用自己
				count=0	#用于记录函数与函数间的调用次数
				rscount=mydb.query("SELECT count(*) FROM `#{$option1+"DLIST"}` WHERE F_point=#{row['F_point']} AND C_point=#{row['C_point']}")	#统计函数间调用了多少次
				rscount.each_hash do |rowcount|
					count=rowcount['count(*)'].to_i
					vdolist_everyvalue.concat(["(\"#{tempFnode}\",\"#{tempCnode}\",#{count}),"])
				end

				#2. the file's VDOLIST
				if tempFdfile!=tempCdfile	#若主调函数与被调函数不在一个文件中
					vdolist_everyvalue.concat(["(\"#{tempFdfile}\",\"#{tempCnode}\",#{count}),"])
				end

				#3. the directory's VDOLIST
				dir=File.dirname(tempFdfile).gsub(/\s+/,"").concat("/")
				while dir and dir!="/"
					dpath=" "+dir
					spath=" "+tempCnode
					if !(spath.index(dpath))
						vdolist_everyvalue.concat(["(\"#{dir}\",\"#{tempCnode}\",#{count}),"])
						if dir.rindex("/",dir.rindex("/")-1)
							dir=dir.slice(0..dir.rindex("/",dir.rindex("/")-1))
						else
							break
						end
					else
						break
					end
				end	
			end
				
			if vdolist_everyvalue.size>1000	#insert into DOLIST , 1000 as a group
				vdolist_values=""
				vdolist_everyvalue.each do |row|
					vdolist_values += row
				end
				vdolist_values=vdolist_values.gsub(/,$/,'')

				mydb.query("INSERT INTO `#{$option1+"DOLIST"}` (F_path, C_path, COUNT) VALUES#{vdolist_values}")
				vdolist_everyvalue.clear
			end
		end

		if vdolist_everyvalue.size>0
			vdolist_values=""
			vdolist_everyvalue.each do |row|
				vdolist_values += row
			end
			vdolist_values=vdolist_values.gsub(/,$/,'')
			mydb.query("INSERT INTO `#{$option1+"DOLIST"}` (F_path, C_path, COUNT) VALUES#{vdolist_values}")
			vdolist_everyvalue.clear
		end
puts("#{Time.now}\tVDOLIST END")			
	end	#end def Vlists.vdolist
end	#end module Vlists

Vlists.vfdlist()
Vlists.vslist()
Vlists.vsolist()
if Vlists.sqlexist($option2+"DLIST")==0
	Vlists.vdolist()
end
