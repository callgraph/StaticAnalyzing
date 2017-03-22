#!/usr/bin/ruby w
require 'find'

tempSvg = ""
# 将原始SVG图分解为一下几个部分
$svgInfo = ""
$svgHead = ""
$svgtail = "</svg>"
$graphHead = ""
$graphTail = "</g>"
$title = ""
$polygon = ""
#节点元素数组
$nodeArray = Array.new()
#边元素数组
$edgeArray = Array.new()

module Svg

      #分解原始SVG图
      def Svg.hre(filename)

                tempSvg=File.new(filename,"r") # temp.svg
                line = ""
                flag = "info"
                temp = ""
                file = ""
                while line = tempSvg.gets
                  if flag == "info"
                        if line.index("<svg")
                                flag = "svg"
                        else
                                $svgInfo += line
                        end
                  end
                  if flag == "svg"
                    if line.index("<g") and line.index("class=\"graph\"")
                      flag = "graph"
                    else
                      $svgHead+=line
                    end
                  end
                  if flag == "graph"
                        if line.index("<title")
                                flag = "title"
                        else
 $graphHead += line
                        end
                  end
                  if flag == "title"
                        if line.index("<polygon fill=\"white\"")
                                flag = "polygon"
                        else
                                $title += line
                        end
                  end
                  if flag == "polygon"
                    if line.index("\<g") and line.index("class=\"node\"\>")
                      flag = "node"
                    elsif line.index("\<g") and line.index("class=\"edge\"\>")
                      flag = "edge"
                        elsif line.index("<!--")
                    else
                      $polygon += line
                    end
                  end
                  if line.index("\<g") and line.index("class=\"node\"\>")
                    flag = "node"
                    temp = line
                  elsif line.index("\<g") and line.index("class=\"edge\"\>")
                    flag = "edge"
                    temp = line
                  elsif line.index("\</g\>")
                    if flag == "node"
                      temp += line
                      $nodeArray << temp
                    elsif flag == "edge"
                      temp += line
                      $edgeArray << temp
                    end
                    flag = ""
                  else
                    temp += line
                  end
                end
      end
end
