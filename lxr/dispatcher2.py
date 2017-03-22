from mod_python import apache,Session
import re
def raise404(logmsg):
    """Log an explanatory error message and send 404 to the client"""
    apache.log_error(logmsg,apache.APLOG_ERR)
    raise apache.SERVER_RETURN,apache.HTTP_NOT_FOUND
def gethandlerfunc(modname):        #获取相应的handler()
    """Given a module name from a URL,obtain the handler function from
    it and return the function object"""
    try:
        #Import the module
        mod=__import__(modname)
    except ImportError:
        #No module with this name
        raise404("Couldn't import module "+modname)
    try:
        #Find the handler function
        handler=mod.handler
    except AttributeError:
        #No handler function
        raise404("Couldn't find handler function in module "+modname)
    if not callable(handler):
        #It's not a function
        raise404("Couldn't find handler function in module "+modname)
    return handler
def gethandlername(URL):  #从所请求的URL获取要请求的py脚本，然后从gethandlerfunc()获取相应的handler()处理相应的请求
    """"Given a URL,find the handler module name"""
    match=re.search("/([a-zA-Z0-9_-]+)\.py($|/|\?)",URL)
    if not match:
        #Couldn't find the requested module
        raise404("Couldn't find a module name in URL "+URL)
    return match.group(1)
def handler(req):
    """Main entry point to the program.Find the handler function,
       call it,and return the result."""
    name=gethandlername(req.uri)
    if name=="dispatcher2":     #不能请求dispatcher2
       raise404("Can't display the dispatcher")
    handlerfunc=gethandlerfunc(name)
    #因为ChangeParameter.py ，UploadFile.py ，ImportSymbolTable.py  ，ExcuteTestScript.py 需要用到Session对象，所以分开处理
    if name=="ChangeParameter" or name=="UploadFile" or name=="ImportSymbolTable" or name=="ExcuteTestScript":
           session=Session.Session(req)
           return handlerfunc(req,session)
    else:
           return handlerfunc(req)    
