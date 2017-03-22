from mod_python import apache,util,Session
import os
def changeparameter(sess,para):     #修改参数函数，替代了以前ChangeParameter.py，具体代码基本不变，注释可以去看ChangeParameter.py
    try:
       	basePath="/usr/local/share/cg-rtl/testcase/"
	v_version=para["v"]            
        v_platform=para["a"]
        v_testcase=para["t"]
        filePath=basePath + v_testcase + "/"           
        if not os.path.exists(basePath):               
      	     os.mkdir(basePath)                  
        sess["version"]=v_version                     
        sess["platform"]=v_platform                   
        sess["testcase"]=filePath
        sess.save()
        return "change parameter successfully!"
    except KeyError,e:
    	return "change paremeter correctly first,please"
def uploadfile(req,sess):     #暂时无用
	pass
def importsymboltable(req,sess): #暂时无用
	pass
def excutetest(req,sess):        #暂时无用
	pass
def handler(req,sess):           #处理器函数，当调用uploadpage.py时，这个函数就会被调用
    req.content_type="text/html"  #规定返回给客户端的MIME是"text/html"
    url=req.headers_in[Referer]   #由于uploadpage.py被那个import-perl文件引用，所以这个语句的作用是取客户端请求import文件的url，具体是
    para=dict()                   #接着上一行的注释，http://os.cs.tsinghua.edu.cn:280/lxr/import  后面加点GET的搜索条件
    if url.find("?")==-1:      #如果url是http://os.cs.tsinghua.edu.cn:280/lxr/import
    	feedback=""
    else:                       #如果url是http://os.cs.tsinghua.edu.cn:280/lxr/import？blablabla
    	for velement in url.split("?")[1].split("&"):  #url中“？后面的v，a，t
    		aftersplit=velement.split("=")
    		para.setdefault(aftersplit[0],aftersplit[1])
        feedback=changeparameter(req,sess,para)    #调用changeparameter()改变参数，因为你已经摁了上面Change的按钮
    req.write("""<HTML><HEAD><TITLE>Upload File</TITLE></HEAD>
    	         <BODY>
    	         <P>%s
    	         <BR>
    	         <CENTER>
       	                   <H3>Upload File<H3>
       	         <CENTER>
       	            <FORM ACTION="" METHOD="post" ENCTYPE="multipart/form-data">
       	                <BR>
       	                <INPUT TYPE="file" name="file" size="50"/>
       	                <INPUT TYPE="submit" VALUE="Upload File"/>
       	            </FORM>
       	            <FORM ACTION="" METHOD="post">
       	                <BR>
       	                <INPUT TYPE="submit" VALUE="Import Symbol Table"/>Import Symbol Table
       	            </FORM>
       	            <FORM ACTION="" METHOD="post">
       	                <BR>
       	                <INPUT TYPE="submit" VALUE="Excute Test Script"/>Excute Test Script
       	            </FORM>
       	            <BR>
       	         </BODY></HTML>"""%feedback)
    return apache.OK
