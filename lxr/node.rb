module Node
      def Node.hre(node, onclick)
        # 从节点元素中读取的值
          url = ""
          posX = ""
          posY = ""
          locG = 0
          name = ""
          nodeId = ""
          result = ""
          regex = /href="(\S*)?"/
          attr1 = ""
          attr2 = ""
          attr3 = ""
          attr4 = ""
          #下面是从节点元素中读取值的过程
          nodeLines = node.split("\n")
          for i in 0..nodeLines.size-1
            if nodeLines[i].index("<a")
              url = nodeLines[i].scan(regex)
              if url.size > 0
                nodeLines[i]=nodeLines[i].gsub(" xlink:href=\""+url.to_s+"\"","")
              end
            elsif nodeLines[i].index("<ellipse")
              /cx=\"([-+]?[1-9]\d*\.\d+|-?0\.\d*[1-9]\d*|-?\d*)\" cy=\"([-+]?[1-9]\d*\.\d+|-?0\.\d*[1-9]\d*|-?\d*)\"?/.match(nodeLines[i])
              posX = $1
              posY = $2
            elsif nodeLines[i].index("<polygon")
              /points=\"([\s\S]*)?\"/.match(nodeLines[i])
              point=$1.split(" ")
              posX=point[3].split(",")[0].to_i
              posY=point[3].split(",")[1].to_i
              posY-=20
            elsif nodeLines[i].index("class=\"node\">")
              /id=\"([\s\S]*?)\"/.match(nodeLines[i])
              nodeId=$1
              locG = i
            end
            if nodeLines[i].index("<title>")
              /\<title\>([\s\S]*?)\</.match(nodeLines[i])
              name = $1
            end
            if nodeLines[i].index("xlink:title")
              /xlink:title=\"([\s\S]*?)\"/.match(nodeLines[i])
               #nodeLines
              temp_str = $1
              attrArray=temp_str.split(",")
              attr1=attrArray[0]
              attr2=attrArray[1]
              attr3=attrArray[2]
              attr4=attrArray[3]

              nodeLines[i]=nodeLines[i].gsub("xlink:title=\""+temp_str+"\"","xlink:title=\"\"")
            end
          end

          #填充属性模板语句
          onclick =  String.class_eval(%Q(#{onclick}))
          #将属性语句添加到节点元素中
          nodeLines[locG]= nodeLines[locG].gsub("class=\"node\"","class=\"node\" "+onclick)
          #将数组转换成一个字符串
          nodeLines.each{|i|
          result = result.concat(i)+"\n"
          }
         result  = "<!-- #{name} -->\n"+result
         return result
 end
end
