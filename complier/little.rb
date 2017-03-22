#!/usr/bin/ruby -w

inputpath=""
inputpath=Array.new(10)
i=0
ARGV.each do|arg|
inputpath[i]=arg
i=i+1
end
name=inputpath[0]
mvname=inputpath[1]
if FileTest::exist?("aux_info.txt") 
             # puts line1
   system "mv aux_info.txt #{mvname}.aux_info "
  #  system"mv #{name}.128r.expand #{mvname}.128r.expand "
end

#if FileTest::exist?("#{name}.128r.expand")
             # puts line1
#   exec "mv #{name}.128r.expand #{mvname}.128r.expand "
#end
if FileTest::exist?("#{name}.190r.sched2")
             # puts line1
   exec "mv #{name}.190r.sched2 #{mvname}.190r.sched2 "
end

