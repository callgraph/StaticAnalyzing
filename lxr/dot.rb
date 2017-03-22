require 'find'

$head = ""
$name = Array.new()
$attr = Array.new()
$tail = ""
$file = ""


filename=""
filename=Array.new(10)
i=0
ARGV.each do|arg|
filename[i]=arg
i=i+1
end


dotFile = File.new(filename[0],"r")

regex = /=/ 

while line=dotFile.gets
#head
if ( !line.index("[") && !line.index("}"))
  $head=$head.concat(line)
  #tail
elsif ( line.index("}"))
  $tail=$tail.concat(line)

else 
  temp = line.split("[")
  s=""
  $name.push( temp[0])
  for i in 1..temp.size-1
    temp[i]=temp[i][0,temp[i].index(']')]
    s= s.concat(temp[i])
    s= s.concat(",")
  end
  s=s[0...-1]
  $attr.push(s)
end
end

wfile=File.new(filename[1],"w") 
wfile.puts $head
for i in 0..$attr.size-1
wfile.puts $name[i]+"["+$attr[i]+"]"
end  
wfile.puts $tail

dotFile.close()
wfile.close()