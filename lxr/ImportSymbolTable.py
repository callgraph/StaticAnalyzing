from mod_python import apache,util,Session
from subprocess import call
def handler(req,sess):
      v_version=sess["version"]                   #从session中获取version，platform，和测试用例的路径   
      v_platform=sess["platform"]
      v_testcase=sess["testcase"]
      runfile = "/home/jdi/JSPUploadFile/ExcuteFile/helloworld.sh"    #运行文件的路径
      req.content_type='text/html'
      req.write("""<html><head><title>Import Symbol Table</title></head><body>""")
      try:
      	  cmd=["/bin/sh",runfile]      #将要运行的命令  
          exitValue=call(cmd)          #调用subprocess模块的call，运行命令cmd。结束命令时，返回一个值给exitValue，成功运行则返回0
          req.write(runfile)        
          req.write("""<br>""")
          if exitValue !=0:          
          	  req.write("""<h2>Error to excute!</h2><br>""")
          else:                      
          	  req.write("""<h2>Success to excute!</h2><br>""")
      except Exception,e:
      	  req.write("""Error!""")
      finally:
      	  req.write("""<h2>Finish!</h2>
      	      <br>click "Change" button to go back
      	  	</body>
      	  	</html>""")
      return apache.OK
