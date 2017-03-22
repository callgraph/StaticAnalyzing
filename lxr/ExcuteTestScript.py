#!/usr/bin/python
from mod_python import apache,util,Session
from subprocess import call
def handler(req,sess):
      v_version=sess["version"]    从session中获取version，platform，和测试用例的路径  ，和在UploadFile.py存的dirname
      v_platform=sess["platform"]
      v_testcase=sess["testcase"]
      v_filename=sess["dirname"]
      runfile=""
      req.content_type='text/html'
      req.write("""<html><head><title> Excute TestCase</title></head><body><br>""")
      try:
      	   if v_testcase.find("testcase1")!=-1:      #对于不同的测试用例，赋予runfile不同的值
      	       runfile = "/home/crdong/main/a.sh"
      	   elif v_testcase.find("testcase2")!=-1:
               dirname=v_filename[:v_filename.find(".tar.gz")] 
               runfile="/usr/local/share/cg-rtl/lxr/remote.sh"
               #runfile="/usr/local/apache-tomcat-7.0.57/webapps/ROOT/remote.sh"
               #util.redirect(req,"http://124.16.141.184:8080/mym_test/"+dirname+"/index_page.html")
           else:                      
               runfile = "/home/jdi/JSPUploadFile/ExcuteFile/helloworld.sh"
           cmd=["/bin/sh",runfile]   #将要运行的命令 
           exitValue=call(cmd)      #调用subprocess模块的call，运行命令cmd。结束命令时，返回一个值给exitValue，成功运行则返回0       
           if exitValue!=0:           
           	   req.write("""<h2>Error to excute!</h2><br></body></html>""")
           else:                      
           	   req.write("""<h2>Success to excute!</h2><br>""")
      except Exception,e:
      	   req.write("""Error!""")
      finally:
           req.write("""<h2>Finish!</h2><br>
                  the cmd is %s<br>click "Change" button to go back</body></html>"""%cmd)
      return apache.OK
