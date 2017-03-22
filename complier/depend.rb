#!/usr/bin/ruby -w

#wname="/home/twd/linux-3.5.4/compile11.sh"
#rtlname="/home/twd/linux-3.5.4/complire_rtl_sche.txt"

inputpath=Array.new(10)
i=0
ARGV.each do|arg|
	inputpath[i]=arg
	i=i+1
end
name=inputpath[0]
wname=inputpath[1]

tmp="-o "
fc={}#file depend relation
fn=[]#files needed by kernel
File.open(name,"r") do |file|
	while line = file.gets
		if line[0]=='+'
			line=line[1..-1]
		end
		line=line.lstrip
        if line.index("gcc ")==0#gcc -o xxx.o xxx.c|s => xxx.o<-xxx.c|s
			a=line[line.index(tmp)+tmp.length..-1].split()
			if a[1].include?"." 
				fc[a[0]]=[a[1]]
			end
        else
			str=nil
			if line.index("ld ")==0#ld -o xx x1.o x2.o ... => xx<-x1.o,x2.o...
				str=tmp
			elsif line.index" ar "#ar rcsD xx x1.o x2.o ... => xx<-x1.o,x2.o...
				str="rcsD "
			end
			if str
				a=line[line.index(str)+str.length..-1].split()
				w=[]
				for b in a[1..-1]
					if fc.key?(b)
						w+=fc[b]
					end
				end
				fc[a[0]]=w#x1<-x1.o,x2.o x2<-x3.o,x4.o xx<-x1,x2 => xx<-x1.o,x2.o,x3.o,x4.o
				if a[0].include?".ko" or a[0]=="vmlinux"#fn is vmlinux+Kernel Loadable Modules
					fn+=fc[a[0]]
				end
			end
        end
	end
end

afile=File.new(name,"r")
wfile=File.new(wname,"w")
 
wfile.puts"#!/bin/sh"    
while line=afile.gets
	if line.index("gcc")
		if line.index(" -fno-delete-null-pointer-checks ")
			line=line.sub(" -fno-delete-null-pointer-checks "," -fno-delete-null-pointer-checks -aux-info=aux_info.txt -fdump-rtl-sched2 ")
            postion=line.index(" -o ")
			if postion
				length=line.size
				line1=line[postion+4..length].split(" ")[1]
				line2=line1
				if fn.include? line2
					rleng=line1.rindex("/")
					sleng=line1.size
					line1=line1[rleng+1..sleng]
					wfile.puts line
					wfile.puts("./little.rb #{line1} #{line2}")
				end
			end
		elsif line.index(" -c -o ") and line.index".S" and !line.index"/.S"
			line=line.sub(" -c -o ","-Wa,-adhlns -c -o ")
			wfile.puts line
		end
	end
end
afile.close
wfile.close
