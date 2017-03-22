#!/usr/bin/ruby -w

#引入所需的模块
require 'find'
#以下模块为同目录下的svg.rb node.rb edge.rb脚本
require File.dirname(__FILE__)+'/svg'
require File.dirname(__FILE__)+'/node'
require File.dirname(__FILE__)+'/edge'

$dirPath=File.dirname(__FILE__)
args=""
args=Array.new(10)
i=0

#获取命令行参数
ARGV.each do|arg|
args[i]=arg
i=i+1
end

#处理后的SVG图形文件
svgDone = File.new(args[1],"w")
#一些相关参数
$code_path=args[2] 
$ver_v=args[3]
$note_path=args[4]
$make_zoom="&amp;checkbox1=1" 

#加工后所有的节点代码
$nodeCode = ""
#加工后所有的边代码
$edgeCode = ""
#加工后所有的JS代码
$scriptCode = ""
#加工后所有的交互菜单元素代码
$layerCode = ""

#调用svg.rb脚本的SVG.hre方法，分离出svg图的各个元素
Svg.hre(args[0])


# node
# attr_str为属性模板语句 此处添加了oncllick onmouseout onmouseover三个属性
# 属性模板语句的编写规则如下：
# js方法无参数时
# attr_str = "\"onclick=\"+%Q(\"createmenu()\")"
# js方法参数需要在从节点元素中读取
# attr_str = "\"onclick=\"+%Q(\"createmenu(\#{posY},\'\#{attr1}\')\")"
# 处理后的效果为 onclick=createmenu（22,'aaa')
# 注意此处参数只能用单引号包裹
# 其中posY attr1 是从节点元素中读取的值，在Node.hre中处理
# 一定要严格按照要求写属性语句
attr_str = "\"onclick=\"+%Q(\"creatmenu(evt\,"+"\#{posX}"+"\,"+"\#{posY}+20"+"\,\'"+"\#{url}"+"\'\,\'"+$code_path+"\#{name}\?v\=#{$ver_v}"+"\'\,\'"+$note_path+"\/\#{name}\(#{$ver_v}\)"+"\'\,\'"+"\#{url}"+$make_zoom+"\'\,\'\#{nodeId}\')\")  \" 
onmouseout=\"+%Q(\"mouseout()\") \" 
onmouseover=\"+%Q(\"mouseover(evt,\#{posX},\#{posY},\'\#{attr1}\',\'\#{attr2}\',\'\#{attr3}\',\'\#{attr4}\')\")"
for item in 0..$nodeArray.size-1
	print "#{$nodeArray[item]}"
        $nodeCode += Node.hre($nodeArray[item], attr_str)#把属性算命的放进node中处理，节点内容来自分解后的svg
end

# edge
# attr_str为属性模板语句 此处添加了oncllick一个属性

attr_str = "\"onclick = \"+%Q(\"edgemenu(evt\,"+"\#{posX}"+"\,"+"\#{posY}"+"\,\'"+"\#{url}"+"\'\,\'"+"\#{url_call}"+"\'\,\'"+"\#{url_call}"+$make_zoom+"\'\,\'"+"\#{edgeId}"+"\')\") "
for item in 0..$edgeArray.size-1
        $edgeCode += Edge.hre($edgeArray[item], attr_str)
end

# 读入scriptX文件内容，这里读入了两个script文件 script1和script3
# deal with script file
puts $polygon
eeline=$polygon.split(",")
XXXXA=eeline[2].split(" ")[0].to_i
XXXXB=eeline[2].split(" ")[1].to_i
# script file
script1 = File.new($dirPath+"/th_plugin/script1","r")
while line = script1.gets
        if line.index("XXXA")
       line.gsub!("XXXA",XXXXA.to_s)
    end
    if line.index("XXXB")
       line.gsub!("XXXB",XXXXB.to_s)
    end
        $scriptCode += line
end
script1.close()

$scriptCode+="\n"

# script file
script3 = File.new($dirPath+"/th_plugin/script3","r")
while line = script3.gets
        $scriptCode += line
end
script3.close()

# 读入layoutX文件内容，这里读入了两个layout文件 layout1和layout3
# layout
layer3 = File.new($dirPath+"/th_plugin/layer3","r")
$layerCode +="\<g\nid\=\"plugin_layer3\"\>\n"
while line = layer3.gets
        $layerCode += line
end
layer3.close()
$layerCode +="\</g\>\n"

layer1 = File.new($dirPath+"/th_plugin/layer1","r")
$layerCode +="\<g\nid\=\"plugin_layer1\"\>\n"
while line = layer1.gets
        $layerCode += line
end
layer1.close()
$layerCode +="\</g\>\n"

y=[]
t=[]
for i in 0..6
     y[i]=XXXXA
     t[i]=XXXXA+20
     XXXXA=XXXXA+32
end
y[7]=XXXXA
t[7]=XXXXA+20




# 按照需要写处理好的SVG图
# 下面的部分变量有可能出现在svg.rb等引入的脚本中
# SVG图的头部信息
svgDone.puts $svgInfo
svgDone.puts $svgHead

# js代码信息
svgDone.puts $scriptCode

# 点边图形元素信息
svgDone.puts $graphHead
svgDone.puts $title
svgDone.puts $polygon
svgDone.puts $nodeCode
svgDone.puts $edgeCode

# 交互功能菜单元素信息
svgDone.puts $layerCode

# SVG图的尾部信息
svgDone.puts $graphTail
svgDone.puts $svgtail

svgDone.close()
