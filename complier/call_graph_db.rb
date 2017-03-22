#!/usr/bin/ruby -w
require 'find'
require 'mysql'
require 'pathname'

$kernel_version=ARGV[1] #"linux-3.5.4"
$directory_type=ARGV[2] #"R"
$platform=ARGV[3] #"arm"
if $directory_type == "real"
	$directory_type="R"
else
	$directory_type="V"
end

$option=$kernel_version+"_"+$directory_type+"_"+$platform+"_"
		
$exclude_vmlinux_path="/usr/local/share/cg-rtl/source/"+$kernel_version+"/"	#arm-pandaboard
#$exclude_vmlinux_path="/usr/local/share/lxr/source/linux-3.5.42/"	#x86_32

##add begin 20121227
module Postion
        def Postion.pathslice(temppath)
            cnum=temppath.index($kernel_version)
            sleng=$kernel_version.size
            temppath.slice!(0..cnum+sleng)
            return temppath
        end
	#read -aux-info result and the same time get the function define in input file
	def Postion.fileread(directory_path,path,file_name)
		name=/([a-zA-Z0-9_-]+)\.c\.[0-9a-zA-Z]+\.sched2/.match(file_name)[1] 
		indexname=(path+"/"+name+".c").sub(directory_path,"")
		name=name+".c.aux_info"
		$define_function=[]
		if File.exist?(path+"/"+name)
			file=File.new(path+"/"+name,"r")
			while line=file.gets
				if line.index("\/* #{indexname}")  # only get the function define in file.c
					$define_function.concat([line])
				end
			end
			file.close
		end
		return indexname
	end
	
	#search the postion funtion name wiht func_name defined
	def Postion.functiondef(func_name)
		dotpos=func_name.index(".") #20150327 crd
		if(dotpos)
			func_name=func_name[0,dotpos]	
		end
		name=" "+func_name+" "
		name1=" *"+func_name+" "
		size=$define_function.size
		for i in 0..size-1
			line=$define_function[i]
			pos2=line.index(":NF")
			if line.index(name) and pos2 and line.index(name)<line.index("(") #20150327 crd
				pos1=line.index(":")    #get define function the numbers 
				postion=line[pos1+1..pos2-1]
				return postion               
			end
			if line.index(name1) and pos2
				pos1=line.index(":")    #get define function the numbers 
				postion=line[pos1+1..pos2-1]
				return postion               
			end
		end
		return "NULL"
	end
end

##add begin 2013/08/09
module Database
	
	def Database.enterdata(directory_path)
		directory_path=(directory_path+"/").gsub(/\/+/,"/")
		
		puts("#{Time.now}\tREAD .sched2 AND .aux_info BEGIN")
		
		fdlist_everyvalue=[]
		slist_everyvalue=[]
		#rline_everyvalue=[]
		
		# Connect to MySQL
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
		
		#Create Table FDLIST
		mydb.query("DROP TABLE IF EXISTS `#{$option+"FDLIST"}`")
		mydb.query("CREATE TABLE IF NOT EXISTS `#{$option+"FDLIST"}`
			(f_name VARCHAR(70),
			f_dfile VARCHAR(150),
			f_dline INT,
			f_rline INT,
			f_saddress VARCHAR(20),
			f_eaddress VARCHAR(20),
			INDEX(f_name,f_dfile))")
		
		#Create Table SLIST 
		mydb.query("DROP TABLE IF EXISTS `#{$option+"SLIST"}`")
		mydb.query("CREATE TABLE IF NOT EXISTS `#{$option+"SLIST"}`
			(F_point INT,
			F_dfile VARCHAR(150),
			C_point INT,
			C_name VARCHAR(70),
			C_id VARCHAR(20),
			C_dfile VARCHAR(150),
			Cd_file VARCHAR(150),
			Cd_line INT,
			INDEX(C_name))")
		
		#####Enter data from sched2 or aux_info to FDLIST and SLIST		
		Find.find(directory_path) do |path|
			if File.directory? path
				Dir.foreach(path) do |filename|
					if !filename.index(".sched2")
						next
					end
					
					index_def_name=Postion.fileread(directory_path,path,filename)	#read -aux-info result and the same time get the function define in input file modify 20121227
					
					file =File.new(path+"/"+filename,"r") 

					while line=file.gets
						pos2=line.index(";; Function")
						while pos2 && line # search funtion name
							flag1=0
							strline=line.split(/ /)       #split string wiht space
							
							tempFpoint=0
							tempFname=""
							tempFdfile=""
							tempFdline=0
							repeat=0
							
							while line=file.gets 
								if( ((line.index("(insn/f")==0 ||(line.index("(insn")==0) ||(line.index("(call_insn")==0) ) && flag1==0) ||(line.index("(jump_insn")==0) ||(line.index("call_insn") ) ) # search first insn/f find the function define lines
									line1=line.chomp.strip
									num1=line.count"("  #calculat numners "("
									num2=line.count")" 
									
									while(num1!=num2 && line=file.gets)
										line1.concat("#{line.chomp.strip}")
										line1=line1.chomp.strip
										num1+=line.count"("
										num2+=line.count")"
									end
									
									if(num1==num2)
										line=line1
										
										while pos=line1.index(")")
											pos1=line1.rindex("(",pos)
											line2=line1.slice(pos1,pos-pos1+1)
											line1=line1.sub(line2,"")#replace line2 to null
										end
										
										line2=line2.gsub(/(\s+)/," ")	
										regex1=line2.split(/ /)[5].index(":")
										
										if line2.index("insn/f") or line2.index("(insn") or line2.index("(jump_insn") or line2.index("(call_insn") and flag1==0	
											if regex1
												flag1=1
												defunction_file=line2.split(/ /)[5][0,regex1].sub(directory_path,"")# define function filename,delete @directory path and /..
												while ttleng=defunction_file.index("/..")
													ttleng1=defunction_file.size
													tempfun=defunction_file.slice(0,ttleng-1)
													if tempfun.rindex("/") 
														tempfun=tempfun.slice(0,((tempfun.rindex("/"))))
														defunction_file=tempfun+defunction_file.slice(ttleng+3,ttleng1-1)
													else
														defunction_file=defunction_file.slice(ttleng+4,ttleng1-1)
													end
												end
												
												postion_27=Postion.functiondef(strline[2])
																								
												if postion_27=="NULL"	#the information of .sched2
													
													if defunction_file.index($kernel_version)
#														defunction_file=defunction_file.sub(Pathname.new(directory_path).realpath.to_s.concat("/"),"")
#														defunction_file=defunction_file.sub($exclude_path,"")
                                                                                                                defunction_file=Postion.pathslice(defunction_file)
													end
													
													if defunction_file.index("./")
														defunction_file=defunction_file.gsub("./","")
													end
													
													#judge if the function information has been repeated
													if fdlist_everyvalue.index("(\"#{strline[2]}\",\"#{defunction_file}\",#{line2.split(/ /)[5][regex1+1,10]})")
														repeat=1
													end

													if repeat!=1	#if the function information has not been repeated
														tempFname="#{strline[2]}"
														tempFdfile="#{defunction_file}"
														tempFdline=line2.split(/ /)[5][regex1+1,10].to_i
														
														fdlist_everyvalue.concat(["(\"#{tempFname}\",\"#{tempFdfile}\",#{tempFdline}),"])
														
														tempFpoint=fdlist_everyvalue.index("(\"#{tempFname}\",\"#{tempFdfile}\",#{tempFdline}),")+1

													elsif repeat==1	#if the function information has been repeated
														while line=file.gets
															break if line.index(";; Function")
														end
														break	#don't do the Call_F of the repeated F
													end

												else	#the information of aux_info
													if index_def_name.index($kernel_version)
#														index_def_name=index_def_name.sub(Pathname.new(directory_path).realpath.to_s.concat("/"),"")
#														index_def_name=index_def_name.sub($exclude_path,"")
                                                                                                                index_def_name=Postion.pathslice(index_def_name)

													end
													
													if index_def_name.index("./")
														index_def_name=index_def_name.gsub("./","")
													end
													
													#judge if the function information has been repeated
													if fdlist_everyvalue.index("(\"#{strline[2]}\",\"#{index_def_name}\",#{postion_27})")
														repeat=1
													end
								
													if repeat!=1	#if the function information has not been repeated
														tempFname="#{strline[2]}"
														tempFdfile="#{index_def_name}"
														tempFdline=postion_27.to_i
														
														fdlist_everyvalue.concat(["(\"#{tempFname}\",\"#{tempFdfile}\",#{tempFdline}),"])
														tempFpoint=fdlist_everyvalue.index("(\"#{tempFname}\",\"#{tempFdfile}\",#{tempFdline}),")+1
												
													elsif repeat==1	#if the function information has been repeated
														while line=file.gets
															break if line.index(";; Function")
														end
														break	#don't do the Call_F of the repeated F
													end
												end
											end
										end
									
										if line2.index("call_insn")
											regex=/function_decl[\s](\w+)[\s]([a-zA-Z.0-9]+)/
											if regex.match(line) and regex1
												#templine=regex.match(line)[2]+" "
												defunction_file=line2.split(/ /)[5][0,regex1].sub(directory_path,"")# call function filename,delete @directory path and /..
												while ttleng=defunction_file.index("/..")
													ttleng1=defunction_file.size
													tempfun=defunction_file.slice(0,ttleng-1)
													if tempfun.rindex("/") 
														tempfun=tempfun.slice(0,((tempfun.rindex("/"))))
														defunction_file=tempfun+defunction_file.slice(ttleng+3,ttleng1-1)
													else
														defunction_file=defunction_file.slice(ttleng+4,ttleng1-1)
													end
												end
												
												#add from 20140813	解决Cd_file中有/mnt/free……的问题（原来只解决了F_dfile和C_dfile）										
												if defunction_file.index($kernel_version)
                                                                                                               defunction_file=Postion.pathslice(defunction_file)
												end
												
												if defunction_file.index("./")
													defunction_file=defunction_file.gsub("./","")
												end										
												
												slist_everyvalue.concat(["(#{tempFpoint},\"#{tempFdfile}\",\"#{regex.match(line)[2]}\",\"#{regex.match(line)[1]}\",\"#{defunction_file}\",#{line2.split(/ /)[5][regex1+1,10].to_i}),"])

												if slist_everyvalue.size==4000	#insert into SLIST , 1000 as a group
													slist_values=""
													slist_everyvalue.each do |row|
														slist_values += row
													end
													slist_values=slist_values.gsub(/,$/,'')

													mydb.query("INSERT INTO `#{$option+"SLIST"}` (F_point, F_dfile, C_name, C_id, Cd_file, Cd_line) VALUES#{slist_values}")
													slist_everyvalue.clear
												end
											end
										end
=begin										
										#the return line number----add from 20131114
										if line2.index("jump_insn") and line2.index("return")
											if regex1
												postion_end=line2.split(/ /)[5][regex1+1,10].to_i	#postion_end is the return line number
												if postion_end>tempFdline
													rline_everyvalue[tempFpoint]=postion_end
												end
											end
										end
=end										
									end
								end
								break if line.index(";; Function")
							end
							if(line!=nil)
								pos2=line.index(";; Function")
							end
						end 
					end 
				end
			end
		end
		
		#insert the rest data into SLIST
		if slist_everyvalue.size>0
			slist_values=""
			slist_everyvalue.each do |row|
				slist_values += row
			end
			slist_values=slist_values.gsub(/,$/,'')
			mydb.query("INSERT INTO `#{$option+"SLIST"}` (F_point, F_dfile, C_name, C_id, Cd_file, Cd_line) VALUES#{slist_values}")
			slist_everyvalue.clear
		end
		
		puts("#{Time.now}\tREAD .sched2 AND .aux_info END")


		#####Enter data from .S to FDLIST
		puts("#{Time.now}\tREAD .S BEGIN")
		filename=directory_path+"/goldfish_s.txt"
		rfile=File.new(filename,"r")
		assmber_flag=0
		while line=rfile.gets
			if line.index("DEFINED SYMBOLS") and !line.index("UNDEFINED SYMBOLS")
				assmber_flag=1
			elsif line.index("UNDEFINED SYMBOLS")
				assmber_flag=0
			else
				if assmber_flag==1
					if line.index(".text") and !line.index("$") and !line.index("L0\001") #20150327 crd
						templine=line.chomp.strip.gsub(/\s+/," ")
						templine=templine.split(/ /)
						if templine[2]
							defunction_file=templine[0].split(":")[0]
							defunction_file=defunction_file.gsub("./","")
							if defunction_file.index($kernel_version)
                                                                defunction_file=Postion.pathslice(defunction_file)
                 					end
							
							repeat=0
							
							if fdlist_everyvalue.index("(\"#{templine[2]}\",\"#{defunction_file}\",#{templine[0].split(":")[1]}),")
								repeat=1
							end

							if repeat!=1
								while ttleng=defunction_file.index("/..")
									ttleng1=defunction_file.size
									tempfun=defunction_file.slice(0,ttleng-1)
									if tempfun.rindex("/") 
										tempfun=tempfun.slice(0,((tempfun.rindex("/"))))
										defunction_file=tempfun+defunction_file.slice(ttleng+3,ttleng1-1)
									else
										defunction_file=defunction_file.slice(ttleng+4,ttleng1-1)
									end
								end								

								fdlist_everyvalue.concat(["(\"#{templine[2]}\",\"#{defunction_file}\",#{templine[0].split(":")[1]}),"])
							end
						end
					end 
				end
			end
		end
		puts("#{Time.now}\tREAD .S END")
		
		#insert all data into FDLIST
		fdlist_values=""
		fdlist_everyvalue.each do |row|
			fdlist_values += row
		end
		fdlist_values=fdlist_values.gsub(/,$/,'')
		mydb.query("INSERT INTO `#{$option+"FDLIST"}` (f_name, f_dfile, f_dline) VALUES#{fdlist_values}")	#将函数定义信息插入VLIST
		fdlist_everyvalue.clear
=begin
		#update the return line number from FDLIST
		for i in 1..rline_everyvalue.size
			if rline_everyvalue[i]
				mydb.query("UPDATE `#{$option+"FDLIST"}` SET f_rline=#{rline_everyvalue[i]} WHERE f_id=#{i}")
			end
		end
		rline_everyvalue.clear
=end

		puts("#{Time.now}\tCOMPLETION RETURN LINE NUMBER & FUNCTION ADDRESS BEGIN")
		#read vmlinux to update the return line of the function
		`readelf -s -W #{directory_path}vmlinux 1>#{directory_path}readelf.txt`
		#`nm -l #{directory_path}vmlinux 1>#{directory_path}nm.txt`
		
		File.open("#{directory_path}readelf.txt","r") do |file|  
			while line = file.gets  
				arr=line.split(" ")
				if(arr[3]=="FUNC")
					#tmp1=`grep #{arr[1]} #{directory_path}nm.txt | grep -w #{arr[7]}`
					#w1=tmp1.split(" ")
					#startline=w1[3].split(":")[1]	#开始行号,暂不需要此信息
					#startline=`addr2line "0x#{arr[1]}" -e vmlinux`
					endaddr="0x"+("0x#{arr[1]}".to_i(16)+arr[2].to_i(10)-1).to_s(16)	#结束地址
					tmp2=(`addr2line "#{endaddr}" -e #{directory_path}vmlinux`).split()[0]
					w2=tmp2.split(":")
					endline=w2[1]	#结束行号
#					fdfile=w2[0].sub($exclude_vmlinux_path,"")	#函数路径
                                        if w2[0].index($kernel_version)
                                           fdfile=Postion.pathslice(w2[0])
                                        else
                                          fdfile=w2[0]
                                        end

					#arr[1]         开始地址
					#arr[7]         函数名 
					mydb.query("UPDATE `#{$option+"FDLIST"}` SET f_rline=#{endline}, f_saddress=\"#{arr[1]}\", f_eaddress=\"#{endaddr}\" WHERE f_name=\"#{arr[7]}\" AND f_dfile=\"#{fdfile}\"")
				end
			end
		end
		puts("#{Time.now}\tCOMPLETION RETURN LINE NUMBER & FUNCTION ADDRESS END")
		
		mydb.query("ALTER TABLE `#{$option+"FDLIST"}` ADD f_id INT PRIMARY KEY AUTO_INCREMENT")	#add this column at this moment is to boot the update speed
		puts("#{Time.now}\tFDLIST & SLIST END")

	end	#end def Database.enterdata

	def Database.repeatfunction()
		
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph') 
		
		$repeatnamelist=""	#the repeated name of funtion in FDLIST
		tempfname=""
		rsF=mydb.query("SELECT f_name FROM `#{$option+"FDLIST"}` ORDER BY f_name")
		rsF.each_hash do |rowF|
			if rowF['f_name']==tempfname and !$repeatnamelist.index(" #{rowF['f_name']} ")
				$repeatnamelist+=" #{rowF['f_name']} \n"
			end
		end
	end	#end def Database.repeatfunction
	
	#####UPDATE SLIST
	#uptade C_point, C_dfile from slist
	def Database.updateslist(directory_path)
		
		`nm -g -l #{directory_path}vmlinux 1>#{directory_path}sytab.txt`
				
		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
		
		puts("#{Time.now}\tFIRST SLIST UPDATE BEGIN")
		
		#method 3: get line from file
		file=File.open("#{directory_path}sytab.txt","r")
		while tmp=file.gets
			arr=tmp.split(" ")
			if arr[3]
#				exactfun=arr[3].sub($exclude_vmlinux_path,"").split(":")
                                if arr[3].index($kernel_version)
                                    exactfun=Postion.pathslice(arr[3]).split(":")
                                else
                                    exactfun=arr[3].split(":")
                                end

				rsF=mydb.query("SELECT * FROM `#{$option+"FDLIST"}` WHERE f_name='#{arr[2]}' and f_dfile='#{exactfun[0]}' and f_dline='#{exactfun[1]}'")
				rsF.each_hash do |rowF|	
					mydb.query("UPDATE `#{$option+"SLIST"}` SET C_point=#{rowF['f_id']}, C_dfile='#{rowF['f_dfile']}' WHERE C_name='#{arr[2]}'")
				end
			end
		end
		
		rsS=mydb.query("SELECT DISTINCT F_dfile, C_name FROM `#{$option+"SLIST"}` WHERE C_point IS NULL")	
		rsS.each_hash do |rowS|
			rsF=mydb.query("SELECT * FROM `#{$option+"FDLIST"}` WHERE f_name='#{rowS['C_name']}' and f_dfile='#{rowS['F_dfile']}'")
			rsF.each_hash do |rowF|
				mydb.query("UPDATE `#{$option+"SLIST"}` SET C_point=#{rowF['f_id']}, C_dfile='#{rowF['f_dfile']}' WHERE C_name='#{rowS['C_name']}' AND F_dfile='#{rowS['F_dfile']}'")
			end
		end
		
		rsS=mydb.query("SELECT DISTINCT C_name FROM `#{$option+"SLIST"}` WHERE C_point IS NULL")	
		rsS.each_hash do |rowS|
			rsF=mydb.query("SELECT * FROM `#{$option+"FDLIST"}` WHERE f_name='#{rowS['C_name']}'")
			rsF.each_hash do |rowF|
				mydb.query("UPDATE `#{$option+"SLIST"}` SET C_point=#{rowF['f_id']}, C_dfile='#{rowF['f_dfile']}' WHERE C_name='#{rowS['C_name']}'")
			end
		end	

		puts("#{Time.now}\tFIRST SLIST UPDATE END")


		puts("#{Time.now}\tSECOND SLIST UPDATE BEGIN")		
		tempCname=""
		rsS=mydb.query("SELECT DISTINCT * FROM `#{$option+"SLIST"}` WHERE C_point IS NULL ORDER BY C_name")
		rsS.each_hash do |rowS|
			if tempCname!=rowS['C_name']
				
				if rowS['C_name'].index("builtin")	#change the compiler function to C function
					convertname=rowS['C_name'].sub("__builtin_","")
					rsF=mydb.query("SELECT DISTINCT * FROM `#{$option+"FDLIST"}` WHERE f_name=\"#{convertname}\" ORDER BY f_name")
				else
					convertname="%".concat(rowS['C_name']).concat("%")
					rsF=mydb.query("SELECT DISTINCT * FROM `#{$option+"FDLIST"}` WHERE f_name like \"#{convertname}\" ORDER BY f_name")
				end
				
				rsF.each_hash do |rowF|
					mydb.query("UPDATE `#{$option+"SLIST"}` SET C_point=#{rowF['f_id']}, C_dfile=\"#{rowF['f_dfile']}\" WHERE C_name=\"#{rowS['C_name']}\"")
					break
				end
					
				tempCname=rowS['C_name']
			end
		end
		
		mydb.query("ALTER TABLE `#{$option+"SLIST"}` ADD SLIST_id INT PRIMARY KEY AUTO_INCREMENT")	#add this column at this moment is to boot the update speed
		puts("#{Time.now}\tSECOND SLIST UPDATE END")
	end	#def Database.updateslist()
	
	#Enter SOLIST's data by SLIST
	def Database.entersolist()	#通过SLIST生成SOLIST
		solist_everyvalue=[]

		mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')

		puts("#{Time.now}\tSOLIST BEGIN")

		#Create Table SOLIST
		mydb.query("DROP TABLE IF EXISTS `#{$option+"SOLIST"}`")
		mydb.query("CREATE TABLE IF NOT EXISTS `#{$option+"SOLIST"}`
				(F_path VARCHAR(150),
				C_path VARCHAR(150),
				COUNT INT,
				INDEX(F_path, C_path))")

		# modify from 20150521

		tempFname=""	#主调函数名
		tempCname=""	#被调函数名
		tempFdfile=""	#主调函数定义路径
		tempCdfile=""	#被调函数定义路径
		tempFnode=""	#主调函数节点
		tempCnode=""	#被调函数节点


		rs=mydb.query("SELECT DISTINCT F_point, C_point FROM `#{$option+"SLIST"}` WHERE C_point IS NOT NULL")
		rs.each_hash do |row|
			rsF = mydb.query("SELECT f_name, f_dfile FROM `#{$option+"FDLIST"}` WHERE f_id=#{row['F_point']}") #search the F_dfile in the FDLIST by F_point
			rsF.each_hash do |rowF|
				tempFname=rowF['f_name']
				tempFdfile=rowF['f_dfile']
				tempFnode=tempFdfile+"/"+tempFname
			end

			rsC = mydb.query("SELECT f_name, f_dfile FROM `#{$option+"FDLIST"}` WHERE f_id=#{row['C_point']}") #search the C_dfile in the FDLIST by C_point
			rsC.each_hash do |rowC|
				tempCname=rowC['f_name']
				tempCdfile=rowC['f_dfile']
				tempCnode=tempCdfile+"/"+tempCname
			end

			if tempFnode!="" and tempCnode!="" and tempFnode!=tempCnode	#若不为空且不是自己调用自己
				count=0	#用于记录函数与函数间的调用次数
				rscount=mydb.query("SELECT count(*) FROM `#{$option+"SLIST"}` WHERE F_point=#{row['F_point']} AND C_point=#{row['C_point']}")	#统计函数间调用了多少次
				rscount.each_hash do |rowcount|
					count=rowcount['count(*)'].to_i
					solist_everyvalue.concat(["(\"#{tempFnode}\",\"#{tempCnode}\",#{count}),"])
				end

				#2. the file's SOLIST
				if tempFdfile!=tempCdfile	#若主调函数与被调函数不在一个文件中
					solist_everyvalue.concat(["(\"#{tempFdfile}\",\"#{tempCnode}\",#{count}),"])
				end

				#3. the directory's SOLIST
				dir=File.dirname(tempFdfile).gsub(/\s+/,"").concat("/")
				while dir and dir!="/"
					dpath=" "+dir
					spath=" "+tempCnode
					if !(spath.index(dpath))
						solist_everyvalue.concat(["(\"#{dir}\",\"#{tempCnode}\",#{count}),"])
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

			if solist_everyvalue.size>1000	#insert into SLIST , 1000 as a group
				solist_values=""
				solist_everyvalue.each do |row|
					solist_values += row
				end
				solist_values=solist_values.gsub(/,$/,'')

				mydb.query("INSERT INTO `#{$option+"SOLIST"}` (F_path, C_path, COUNT) VALUES#{solist_values}")
				solist_everyvalue.clear
			end
		end

		if solist_everyvalue.size>0
			solist_values=""
			solist_everyvalue.each do |row|
				solist_values += row
			end
			solist_values=solist_values.gsub(/,$/,'')
			mydb.query("INSERT INTO `#{$option+"SOLIST"}` (F_path, C_path, COUNT) VALUES#{solist_values}")
			solist_everyvalue.clear
		end
		puts("#{Time.now}\tSOLIST END")	
	end	#end def Database.entersolist()


	
end	#end module Database

####main function####
if ARGV[0]
	directory_path=(ARGV[0]+"/").gsub(/\/+/,"/")
else
	directory_path=$exclude_vmlinux_path
end
Database.enterdata(directory_path)	#read .sched2 and .aux_info, #read assmber *.S by KBUILD_AFLAGS	+=  -Wa,-adhlns 
#Database.repeatfunction()
Database.updateslist(directory_path)	#update some cow where the value is null form slist
Database.entersolist()	#the out reference of slist
