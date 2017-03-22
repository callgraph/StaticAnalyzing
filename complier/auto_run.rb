#!/usr/bin/ruby -w

inputpath=Array.new(10)
i=0
ARGV.each do|arg|
	inputpath[i]=arg
	i=i+1
end
name=inputpath[0]
wname=inputpath[1]

afile=File.new(name,"r")
wfile=File.new(wname,"w")
 
wfile.puts"#!/bin/sh"    
while line=afile.gets
	if line.index("gcc") and !line.index"scripts" and !line.index"\"gcc"
		if line.index(" -fno-delete-null-pointer-checks ")
			line=line.sub(" -fno-delete-null-pointer-checks "," -fno-delete-null-pointer-checks -aux-info=aux_info.txt -fdump-rtl-sched2 ")
			wfile.puts line
			postion=line.index(" -o ")
			if postion
				length=line.size
				line1=line[postion+4..length].split(" ")[1]
				line2=line1
				rleng=line1.rindex("/")
				sleng=line1.size
				line1=line1[rleng+1..sleng]
				wfile.puts("./little.rb #{line1} #{line2}")
			end
		elsif line.index(" -c -o ") and line.index".S" and !line.index"/.S"
			line=line.sub(" -c -o ","-Wa,-adhlns -c -o ")
			wfile.puts line
		end      
	end
end
afile.close
wfile.close
