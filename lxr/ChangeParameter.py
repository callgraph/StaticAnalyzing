from mod_python import apache,util,Session
import os
def handler(req,sess):
      basePath="/usr/local/share/cg-rtl/testcase/"   #定义所有测试用例的一个目录
      form = util.FieldStorage(req)                  #获取表单字典，以便存取在uploadpage.htm选择的version，platform，testcase。如下
      v_version=form["version"].value             
      v_platform=form["platform"].value
      v_testcase=form["testcase"].value
      filePath=basePath + v_testcase + "/"           #比如当选中testcase1时filePath的值为 /usr/local/share/cg-rtl/testcase/testcase1/
      if not os.path.exists(basePath):               #如果/usr/local/share/cg-rtl/testcase/不存在，创建这个目录。要想这个命令执行成功，
      	    os.mkdir(basePath)                   #/usr/local/share/cg-rtl/testcase/目录的权限必须是777
      req.content_type="text/html"                   #响应uploadpage.htm的changparameter按钮，返回一个页面
      req.write("""<html><head><title>change parameter</title></head>
               <body>change parameter successfully!</body></html>""")
      sess["version"]=v_version                     #把version，platform，testcase值存到session中，以便UploadFile.py, ImportSymbolTable.py,     
      sess["platform"]=v_platform                   #ExcuteTestScript.py访问，实现跨请求存取
      sess["testcase"]=filePath
      sess.save()
      return apache.OK
