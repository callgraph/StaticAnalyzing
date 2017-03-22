<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1" import="java.io.*"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<meta http-equiv="Access-Control-Allow-Origin" content="*">
  <head runat="sever">
  </head>

  <body>
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
