#!/usr/bin/ruby -w
require 'savon'

message=""
message=Array.new(5)
i=0
ARGV.each do|arg|
	message[i]=arg
	i=i+1
end
$ver_v=message[0]
$ver_a=message[1]
$ver_f=message[2]
$path0=message[3]
$path1=message[4]
client = Savon.client(wsdl:'http://192.168.2.113:8080/axis2/services/getSVGImg?wsdl')
client.operations
response = client.call(:get_svg_url,message:{v: $ver_v,a: $ver_a,f: $ver_f,path0: $path0,path1: $path1})
$svg=response.body
$svgline=Array.new
$svg_path="/usr/local/share/cg-rtl/lxr/source1/"+$ver_v
$svg_path2="/usr/local/share/cg-rtl/lxr/source1/"+$ver_v+"/"+$ver_a
if($path1!="NULL")
$filename="/usr/local/share/cg-rtl/lxr/source1/"+$ver_v+"/"+$ver_a+"/"+$ver_f+"-"+$path0+"-"+$path1+".svg"
else
$filename="/usr/local/share/cg-rtl/lxr/source1/"+$ver_v+"/"+$ver_a+"/"+$ver_f+"-"+$path0+".svg"
end
Dir.mkdir($svg_path) unless File.exists?($svg_path)
Dir.mkdir($svg_path2) unless File.exists?($svg_path2)
wfile=File.open($filename,'w+')
$svg="#{$svg}"
$svg=$svg[0..$svg.length-60]
$svgline=$svg.split('\n')
$svgline[0]='<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
for i in 1..$svgline.length
if $svgline[i]!=nil
if $svgline[i][0..5].include?('\t\t\t')
        $svgline[i]=$svgline[i][6..$svgline.length-1]
elsif
$svgline[i][0..3].include?('\t\t')
       $svgline[i]=$svgline[i][4..$svgline.length-1]
elsif $svgline[i][0..1].include?('\t')
        $svgline[i]=$svgline[i][2..$svgline.length-1]

end
$svgline[i]=$svgline[i].gsub(/\\/,'')
end
i+=1
end
wfile.puts $svgline
wfile2=File.open("/usr/local/share/cg-rtl/lxr/svglog",'a')
$time1=Time.new
$log=$time1.inspect+"_"+$filename
wfile2.puts $log

