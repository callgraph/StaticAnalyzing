<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>

<%
	String vtext=request.getParameter("vv");
	String atext=request.getParameter("aa");
	String ftext=request.getParameter("ff");
	String p0text=request.getParameter("path00");
	String p1text=request.getParameter("path11");
	String spath="";
	if (p1text=="")
//	  String spath="/usr/local/share/cg-rtl/lxr/source1/";
	  spath="/usr/local/share/cg-rtl/lxr/source1/"+vtext+"/"+atext+"/"+ftext+"-"+p0text+".svg";
	else
	  spath="/usr/local/share/cg-rtl/lxr/source1/"+vtext+"/"+atext+"/"+ftext+"-"+p0text+"-"+p1text+".svg";
//	out.println(spath);
	out.println(vtext);
	out.println(atext);
	out.println(ftext);
	out.println(p0text);
	out.println(p1text);
//	String spath="/usr/local/share/cg-rtl/lxr/source1/"+vtext;
	out.println(spath);
	PrintWriter pw=new PrintWriter(new FileOutputStream(spath));
        File file= new File(spath);
        String text=request.getParameter("svg");
        if (text!=null){
        	text=text.replace("Enter","\n");
	        text=text.replace("&lt;","<");
        	text=text.replace("&gt;",">");
//	        text=text.replace("&amp;","&");
	        String newtext=text.substring(0,text.length()-5);
	        pw.println(newtext);
//		pw.println(text);
	}
	else {
		text="YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY";
		pw.println("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
	}
        pw.close();
//      out.println(text);
/*
out.println("<html>");
out.println("<head>");
out.println("</head>");
out.println("<body>");
out.println(text);
out.println("</body>");
out.println("</html>");
*/
%>

