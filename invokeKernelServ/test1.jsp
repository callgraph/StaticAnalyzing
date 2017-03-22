<%@page language="java" import="java.util.*" pageEncoding="ISO-8859-1" import="java.io.*"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<meta http-equiv="Access-Control-Allow-Origin" content="*">
  <head runat="sever">
  </head>

  <body>
    <form method="post" action="test1.jsp" id="form1" name="form1" enctype="application/x-www-form-urlencoded">
	<input id="test2" type="hidden" name="test2">
	<input type="button" onclick="formSubmit()" value="Submit">
    </form>       
 <script type="text/javascript">
        var test1="123456789012345678901234567890";
        document.forms[0].test2.value=test1;    
	function formSubmit()
	{
        var formObj=document.getElementById("form1");
        formObj.submit();
	}
        </script>
  </body>
</html>
<%
        String spath="/usr/local/share/cg-rtl/lxr/source1/linux-3.5.4/x86_32/test.svg";
        PrintWriter pw=new PrintWriter(new FileOutputStream(spath));
        String text=request.getParameter("test2");
        pw.println(text);
        pw.close();
        out.println(text);
%>

