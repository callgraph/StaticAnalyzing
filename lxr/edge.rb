module Edge
      def Edge.hre(t, onclick)

          url = ""
          url_call = ""
          posX = ""
          posY = ""
          name = ""
          edgeId = ""
          color = ""
          locG = 0
          result = ""
          regex = /href="(\S*)?"/
          edgeLines = t.split("\n")
          for i in 0..edgeLines.size-1
            if edgeLines[i].index("<a")
              url = edgeLines[i].scan(regex)
              if url.size > 0
                edgeLines[i]=edgeLines[i].gsub(" xlink:href=\""+url.to_s+"\"","")
              end
            elsif edgeLines[i].index("<text")
              /x=\"([-+]?[1-9]\d*\.\d+|-?0\.\d*[1-9]\d*|-?\d*)\" y=\"([-+]?[1-9]\d*\.\d+|-?0\.\d*[1-9]\d*|-?\d*)\"?/.match(edgeLines[i])
              posX = $1
              posY = $2
            elsif edgeLines[i].index("class=\"edge\">")
              /id=\"([\s\S]*?)\"/.match(edgeLines[i])
              edgeId=$1
              locG = i
            end
            if edgeLines[i].index("<title>")
              /\<title\>([\s\S]*?)\</.match(edgeLines[i])
              name = $1
            end
          end
          url_call = url.to_s.gsub("watchlist","call")
          onclick = String.class_eval(%Q(#{onclick}))
          edgeLines[locG]= edgeLines[locG].gsub("class=\"edge\"","class=\"edge\" "+onclick)
          edgeLines.each{|i|
            result = result.concat(i)+"\n"
          }
 result = "<!-- #{name} -->\n"+result
         /stroke=\"([\s\S]*?)\"/.match(result)
         color = $1
        return result
      end
end
