from mod_python import apache,util,Session
import os
def handler(req,sess):
      maxFileSize = 5000 * 1024 
      maxMemSize = 5000 * 1024
      v_version=sess["version"]        #从session中获取version，platform，和测试用例的路径
      v_platform=sess["platform"]
      filePath=sess["testcase"]
      position=filePath.rfind("/")     #新改动，应贾荻要求，在文件名前加相应的测试用例目录名
      what_testcase=filePath[position-9:position] #新改动，应贾荻要求，在文件名前加相应的测试用例目录名
      if not os.path.exists(filePath):
      	    os.mkdir(filePath)
      try:                             #如果从windows上传时，要设置一下              
          import msvcrt
          msvcrt.setmode(0,O_BINARY)
          msvcrt.setmode(1,O_BINARY)
      except ImportError:
          pass
      form = util.FieldStorage(req)    #获取表单字典，以便存取在uploadpage.htm获取将要上传的文件名
      fileitem=form['file']	        
      fileName=fileitem.filename     
      if fileName.rfind("\\")>=0:     ##处理从windows上传文件时文件名的“\”问题
          fileName=fileName[fileName.rfind("\\")+1:]
      #else:     无用，新改动
          #fileName=fileName[fileName.rfind("\\")+1:]  
      req.content_type='text/html'
      req.write("""<html><head><title>File upload</title></head><body>""")
      if fileName:
      	  dirname=fileName
      	  fileName=fileName.replace("-", "_")
      	  #新改动，应贾荻要求，在文件名前加相应的测试用例目录名，此注释对应下一语句
      	  fileName="V-"+v_version+"P-"+v_platform+"T-"+what_testcase+"-"+fileName  #标准化文件名
      	  sess["dirname"]=dirname                                                   
      	  sess["dirname"]=dirname
      	  sess.save()
      	  #fname=os.path.basename(fileitem.filename无用，新改动
          fout=open(os.path.join(filePath,fileName),'wb')  #新改动，不要fname，这样会导致从windows上传文件时文件名不当
          while True:                                               #开始从客户端读取文件，然后在本地写
              chunk=fileitem.file.read(100000)
              if not chunk:break
              fout.write(chunk)
          fout.close()
          v=filePath +fileName
          req.write("""<h2>Success to upload!</h2><br>   Uploaded Filename: %s<br>"""%v)
          req.write("""click "Change" button to go back</body></html>""")
      else:
          req.write("""No file was selected!<br>click "Change" button to go back</body></html>""") 
      return apache.OK

