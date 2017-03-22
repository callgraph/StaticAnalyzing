<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1" import="java.io.*"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<meta http-equiv="Access-Control-Allow-Origin" content="*">
  <head runat="sever">
  </head>

  <body>
    <form method="post" enctype="multipart/form-data" action="test.jsp">
        <tr>
        Version:
    <select onchange="isSelected(this.value);" id="v">
          <option value="1">linux-3.5.4</option>
          <option value="2">linux-2.6.39.4</option>
          <option value="3">linux-3.8</option>
    </select> <br/>

        Architecture:
        <input type="text" id="a"><br/>
        Folder:
        <input type="text" id="f"><br/>
        Path0:
        <input type="text" id="path0"><br/>
        Path1:
        <input type="hidden" name="path1" id="path1" value="texttext"><br/>
        SVG:
        <input type="text" id="svg"><br/>
        ShowSVG:
        <br/>
        </form>
        <div id="data1"></div>
    <div id="data"></div>
<script type="text/javascript">
        var text="<%=request.getParameter("path1")%>";
      alert(text);
</script>
  </body>
</html>
<%
	String spath="/usr/local/share/cg-rtl/lxr/source1/linux-3.5.4/x86_32/test.svg";
	PrintWriter pw=new PrintWriter(new FileOutputStream(spath));
	String text=request.getParameter("path1");
	pw.println(text);
	pw.close();
	
%>
