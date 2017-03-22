#!/usr/bin/ruby -w


#wname="/home/twd/linux-3.5.4/compile11.sh"
#rtlname="/home/twd/linux-3.5.4/complire_rtl_sche.txt"

inputpath=""
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
     if line.index("gcc")
        if line.index(" -nostdinc ") and !line.index"-D__ASSEMBLY__"
           line=line.sub(" -nostdinc "," -nostdinc -aux-info=aux_info.txt -O2 -fdump-rtl-sched2  ")
           #wfile.puts line
           postion=line.index(" -o ")
           if postion
            length=line.size
            tmp =line[postion+4..length].split(" ")[0]
            replaced=line[postion+4..length].split(" ")[1]
            tmp=tmp.sub("obj/kernel","src/kern-ucore")
            rleng=tmp.rindex("/")
            line=line.sub(replaced,tmp[0..rleng]+replaced)
            wfile.puts line

            length=line.size
            line1=line[postion+4..length].split(" ")[1]
            line2=line1

            line2=line2.sub("src/kern-ucore","obj/kernel")

            rleng=line1.rindex("/")
            sleng=line1.size
            line1=line1[rleng+1..sleng]
            wfile.puts("./little.rb #{line1} #{line2}")
           end
        end
