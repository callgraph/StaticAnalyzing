#!/usr/bin/ruby -w
require 'find'
require 'mysql'
$kernel_version=ARGV[1]#"linux-3.5.4"
$directory_type="V"
$platform=ARGV[2]#"x86"
puts ARGV[2]
if !ARGV[2].index("x86") and !ARGV[2].index("arm")
exit
end
$option=$kernel_version+"_"+$directory_type+"_"+$platform+"_"

module Traverse
	def Traverse.primary(primary_path)	#遍历原始路径。primary_path为运行此ruby程序时传入的第一个参数
puts("#{Time.now}\tPLIST BEGIN")		
		# Connect to MySQL
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph') #链接mysql数据库
		
		#Create Table PLIST 创建原始目录列表
		mydb.query("DROP TABLE IF EXISTS `#{$kernel_version+"PLIST"}`")
		mydb.query("CREATE TABLE IF NOT EXISTS `#{$kernel_version+"PLIST"}`
			(P_path VARCHAR(100))")

		Find.find(primary_path) do |path|	#从源代码所在路径递归查找，path中存放从源代码所在路径开始递归获得的当前绝对路径：目录/文件名称	#Find.find() 用每个文件名和目录的列表作为参数调用相关联的块， 然后递归地在他们的子目录中
			if File.directory? path	#如果path是一个目录	#File.directory() 如果参数是一个目录，返回true，否则返回false
				Dir.foreach(path) do |filename|	#对于path目录中的每个文件filename进行
					if filename!="." and filename!=".." and !(File.directory?(path+"/"+"#{filename}"))	#果不是‘.’或".."
						name=(path+"/"+"#{filename}").sub(primary_path,"")	#name被赋值为当前路径的绝对路径/文件名，并除去源代码所在路径的绝对路径，也就是每个文件的相对路径	#sub()替换字符串中第一次遇到的匹配项
						#puts(name)	#测试行
						mydb.query("INSERT INTO `#{$kernel_version+"PLIST"}` (P_path) VALUES(\"#{name}\")")	#将函数定义信息插入PLIST
					end
				end
			end
		end
puts("#{Time.now}\tPLIST END")		
	end
	
	def Traverse.virtual(virtual_path)	#遍历虚目录路径。virtual_path为运行此ruby程序时传入的第一个参数
puts("#{Time.now}\tVLIST BEGIN")		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph') #链接mysql数据库
		
		#Create Table VLIST 创建虚目录列表
		mydb.query("DROP TABLE IF EXISTS `#{$option+"LIST"}`")
		mydb.query("CREATE TABLE IF NOT EXISTS `#{$option+"LIST"}`
			(P_path VARCHAR(100),
			V_path VARCHAR(150),
			INDEX(P_path, V_path))")
		
		
		everyvalue=[]
		values=""
	
		Find.find(virtual_path) do |path|	#从源代码所在路径递归查找，path中存放从源代码所在路径开始递归获得的当前绝对路径：目录/文件名称	#Find.find() 用每个文件名和目录的列表作为参数调用相关联的块， 然后递归地在他们的子目录中
			if File.directory? path	#如果path是一个目录	#File.directory() 如果参数是一个目录，返回true，否则返回false
				Dir.foreach(path) do |filename|	#对于path目录中的每个文件filename进行
					if filename!="." and filename!=".." and !(File.directory?(path+"/"+filename)) and filename.index(".txt")	#果不是‘.’或".."，并且是个文件而不是目录
						file=File.open(path+"/"+filename,"r")	#打开虚目录文件
						while line=file.gets and line.chomp!=""	#获得文件的一行，如果这行不为空
							line=line.sub("#{$kernel_version}\\","").gsub("\\","/").gsub(/\s+\n/,"").chomp
#puts path+filename
#puts line
							name=(path+"/"+filename).sub(virtual_path,"").gsub(/\s+\n/,"").sub(".txt","").concat("/"+line.split('/')[-1])	#虚目录文件名。name被赋值为当前路径的绝对路径/文件名/原始目录路径，并除去源代码所在路径的绝对路径	#sub()替换字符串中第一次遇到的匹配项
                                                        if name.index("/")==0
                                                                name.sub!("/","")
                                                        end
							#puts("#{line}"+"\t"+"#{name}")	#测试行
							everyvalue.concat(["(\"#{line}\",\"#{name}\"),"]) if !everyvalue.index("(\"#{line}\",\"#{name}\"),")
=begin							
							if everyvalue.size==100
								values=""
								everyvalue.each do |row|
									values += row
								end
								values=values.gsub(/,$/,'')
	#puts values
								mydb.query("INSERT INTO `#{$option+"VLIST"}` (P_path, V_path) VALUES#{values}")	#将函数定义信息插入VLIST
								everyvalue.clear
							end
=end
						end
					end
				end
			end
		end

		everyvalue.each do |row|
			values += row
		end
		values=values.gsub(/,$/,'')
	#puts values
		mydb.query("INSERT INTO `#{$option+"LIST"}` (P_path, V_path) VALUES#{values}")	#将函数定义信息插入VLIST		

		tempP=""
		tempV=""
		rs=mydb.query("SELECT * FROM `#{$option+"LIST"}` ORDER BY P_path,V_path")
		rs.each_hash do |row|
			puts("#{tempP}  #{tempV}") if row['P_path']==tempP and row['V_path']==tempV
			tempP=row['P_path']
			tempV=row['V_path']
		end

puts("#{Time.now}\tVLIST END")		
	end
end

Traverse.virtual(ARGV[0]) if ARGV[0]
#Traverse.primary(ARGV[1]) if ARGV[1]
