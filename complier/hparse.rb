#!/usr/bin/ruby -w
dir_prefix=ARGV[0]
elf_name=ARGV[1]
log=ARGV[2]
result=ARGV[3]

`nm #{elf_name} -n -l > nm.txt`
h={}

File.open("nm.txt","r") do |file|  
	while line = file.gets  
		arr=line.split(" ")
		if(arr[1]=="t" or arr[1]=="T" or arr[1]=="w" or arr[1]=="W")
			pos=arr[3]
			if(!arr[3])
				pos=`addr2line -e #{elf_name} -i "#{arr[0]}"`.split("\n")[-1]
			end
			cnum=pos.index(dir_prefix)
			if(cnum)
				sleng=dir_prefix.size
				pos.slice!(0..cnum+sleng)
				h[arr[0]]=arr[2]+":"+pos
			end			
		end
	end  
end  

fh=File.new(result,"w")
File.open(log,"r") do |file|  
	while line = file.gets 
		arr=line.chomp.split(",")
		tid=(arr[2].to_i(16)&0xffffe000).to_s(16)
		if(arr[3])
			if(arr[3]=="")
				fh.puts arr[0]+","+arr[1]+",0x"+tid+",0x"+arr[2]+","+arr[3]+","+arr[4]
			else
				if(arr[3]=="kernel")
					res=h[arr[4]]
					if(res)
						fh.puts arr[0]+","+arr[1]+",0x"+tid+",0x"+arr[2]+","+arr[3]+","+res
					else
						fh.puts arr[0]+","+arr[1]+",0x"+tid+",0x"+arr[2]+","+arr[3]+","+arr[4]
					end
				else
					fh.puts arr[0]+","+arr[1]+",0x"+tid+",0x"+arr[2]+","+arr[3]+","+arr[4]
				end
			end
		else
			fh.puts arr[0]+","+arr[1]+",0x"+tid+",0x"+arr[2]
		end
	end  
end  
fh.close
