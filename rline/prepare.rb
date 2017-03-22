#!/usr/bin/ruby -w
$kernel_version=ARGV[0]

`nm vmlinux -n -l > nm.txt`
fh=File.new("func.txt","w")
File.open("nm.txt","r") do |file|  
	while line = file.gets  
		arr=line.split(" ")
		if(arr[1]=="t" or arr[1]=="T" or arr[1]=="w" or arr[1]=="W")
			pos=arr[3]
			if(!arr[3])
				pos=`addr2line -e vmlinux -i "#{arr[0]}"`.split("\n")[-1]
			end
			cnum=pos.index($kernel_version)
			if(cnum)
				sleng=$kernel_version.size
				pos.slice!(0..cnum+sleng)
				fh.puts arr[0]+" "+arr[2]+":"+pos
			end
			
		end
	end  
end  
fh.close
