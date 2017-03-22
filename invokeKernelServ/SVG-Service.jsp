<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1" import="java.io.*"%>
<%
String spath1="/usr/local/share/cg-rtl/lxr/source1/linux-3.5.4/x86_32/test.svg";
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<meta http-equiv="Access-Control-Allow-Origin" content="*">
  <head runat="sever">
  </head>
  
  <body>
	<form>    
<div>	
	<form>
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
	<input type="text" id="path1">
	<input type="button" value="Change" onclick="Change()"/>
	<br/>
	ShowSVG:	
	<br/>	
	<input id="One" type="button" value="ShowSVG" onclick="RequestWebService()"/>	
	<input id="two" type="button" value="Show" onclick="showSVG()"/>
	</form>    	
    </div>
	<div>
	<form action="SaveSvg.jsp" method="post" target="flush">
	<input type="hidden" id="vv" name="vv">
	<input type="hidden" id="aa" name="aa">
        <input type="hidden" id="ff" name="ff">
        <input type="hidden" id="path00" name="path00">
        <input type="hidden" id="path11" name="path11">
	<input type="hidden" id="svg" name="svg"/>
	<input type="submit" value="Submit"/>
	</form>
	<iframe name="flush" style="display:none;"></iframe>
	</div>
	<div id="data1"></div>
    <div id="data"></div>
    </form>
  </body>
<script type="text/javascript">
   var xmlhttp=null;   
        var src=null;
        function  showSVG(){    
        var object = document.createElement("object");
	if(document.getElementById('path1').value!="")          
         object.data="http://192.168.1.35/lxr/source1/"+document.getElementById('vv').value+"/"+document.getElementById('a').value+"/"+document.getElementById('f').value+"-"+document.getElementById('path0').value+"-"+document.getElementById('path1').value+".svg";
	else 
	 object.data="http://192.168.1.35/lxr/source1/"+document.getElementById('vv').value+"/"+document.getElementById('a').value+"/"+document.getElementById('f').value+"-"+document.getElementById('path0').value+".svg"; 
           // alert(""+src);
                object.type="image/svg+xml";
                object.codebase="http://www.adobe.com/svg/viewer/install/";
                
                var myDiv = document.getElementById('data'); 
                myDiv.appendChild(object);                      
        }
	 var host=location.href;
	 var v;
            var a;
            var f;
            var path0;
            var path1;
            var state;
arra=host.split("?")
       var array1=[]
if(arra[1]!=null)
{
        array1=arra[1].split("&")
      var arrurlv=array1[0].split("=")
        var arrurla=array1[2].split("=")
        var arrurlf=array1[1].split("=")
        var arrurlpath0=array1[3].split("=")
        var arrurlpath1;

        if(array1[4]==null)
        {
                path1="";
        }
        else
        {
                arrurlpath1=array1[4].split("=")
                path1=arrurlpath1[1];
}
            var version=document.getElementById("v");
              for(i=0;i<version.length;i++){
                  if(version[i].selected==true){
            //             vv=version[i].text;
                         // alert("The version is:"+v);
                  }
              }
                v=arrurlv[1];
                a=arrurla[1];
                f=arrurlf[1];
                path0=arrurlpath0[1];

                document.getElementById("v").value=v;
                document.getElementById("a").value=a;
                document.getElementById("f").value=f;
                document.getElementById("path0").value=path0;
                document.getElementById("path1").value=path1;
		
		document.getElementById("vv").value=v;
		document.getElementById("aa").value=a;
		document.getElementById("ff").value=f;
		document.getElementById("path00").value=path0;
		document.getElementById("path11").value=path1;
}


function Change()
{
        var version=document.getElementById("v");
              for(i=0;i<version.length;i++){
                  if(version[i].selected==true){
                      v=version[i].text;
                         // alert("The version is:"+v);
                  }
              }


         a=document.getElementById("a").value;
         f=document.getElementById("f").value;
         path0=document.getElementById("path0").value;
         path1=document.getElementById("path1").value;
       	 document.getElementById("vv").value=document.getElementById("v").value;
                document.getElementById("aa").value=document.getElementById("a").value;
                document.getElementById("ff").value=document.getElementById("f").value;
                document.getElementById("path00").value=document.getElementById("path0").value;
                document.getElementById("path11").value=document.getElementById("path1").value;
        if(path1=="")     
        location.href=location.href+"?v="+v+"&f="+f+"&a="+a+"&path0="+path0+"&path1="
        else
{
        location.href=location.href+"?v="+v+"&f="+f+"&a="+a+"&path0="+path0+"&path1="+path1
	document.getElementById("path1").value=path1
}
	document.getElementById("a").value=a;
	document.getElementById("f").value=f;
	document.getElementById("path0").value=path0;
}
	function RequestWebService(){
	ip="192.168.1.35";
	RequestWeb(ip);
	while(xmlhttp.readyState!=4||xmlhttp.status!=200)
	{
	  alert("Please wait......")
	}
	if(src=="NOTINSTALL")
	{
		alert("This server dosen't hava this version!")
		ip2="192.168.1.37";
		src=null
		alert("We are connenting server"+ip2+"......")
		RequestWeb(ip2);
		while(xmlhttp.readyState!=4||xmlhttp.status!=200||src==null)
 	       {
        	  alert("Please wait......")
	       }
	
	}
	document.getElementById("svg").value=src;
}
  function RequestWeb(ip){
        //      var URL="http://locaohost:8080/axis2/services/getSVGImg?wsdl";
                var URL="http://"+ip+":8080/axis2/services/getSVGImg";
                var data;
                var dataa;       
                data = '<?xml version="1.0" encoding="utf-8"?>';
                data = data + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
                data = data + '<soap12:Body>';
                data = data + '<getSVGUrl xmlns="http://impl.ws.core.serv.wuz.com"><args0>'+v+'</args0><args1>'+a+'</args1><args2>'+f+'</args2><args3>'+path0+'</args3><args4>'+path1+'</args4></getSVGUrl>';
                data = data + '</soap12:Body>';
                data = data + '</soap12:Envelope>';
//		alert(data);
//	      data = '<?xml version="1.0" encoding="utf-8"?>';
  //          data = data + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
    //        data = data + '<soap12:Body>';
      //      data = data + '<getSVGUrl xmlns="http://impl.ws.core.serv.wuz.com"><args0>'+vv+'</args0><args1>'+aa+'</args1><args2>'+ff+'</args2><args3>'+pp0+'</args3><args4>'+pp1+'</args4></getSVGUrl>';
        //    data = data + '</soap12:Body>';
          //  data = data + '</soap12:Envelope>'; 
		if(window.ActiveXObject){  
                        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
                }
                else if(window.XMLHttpRequest){
		xmlhttp = new XMLHttpRequest();
                }else{
                       // alert("not supported!");
                }
                if(xmlhttp!=null){
                //      alert("Browser runs success");
                }                
//		alert(processResult);     
	   xmlhttp.onreadystatechange=processResult;
            xmlhttp.open("POST",URL,true);                                              
	xmlhttp.setRequestHeader("Content-type","application/soap");                                    
            xmlhttp.send(data);
           // alert("where is the problem");    
        }

	
        function processResult(){ 
	if(xmlhttp.readyState==4&&xmlhttp.status==200){ 
//alert(xmlhttp.readyState+"&&"+xmlhttp.status)
//alert(xmlhttp.response)
		var result=xmlhttp.responseText;
                 xmlDoc=toXML(result);
		if(navigator.userAgent.indexOf("Firefox")>0){
   			//firefox
//			src=result;
			src=xmlDoc.getElementsByTagName("ns:return")[0].textContent;

//alert(src);
//		src=xmlDoc.getElementsByTagName("ns:return")[0].childNodes[0].nodeValue;
//	src="<?xml version=1.0 encoding=UTF-8PUBLIC ";
//document.write(src);
		}else if(navigator.userAgent.indexOf("Chrome")>0){
			//chrome
			src=xmlDoc.getElementsByTagName("return")[0].innerHTML;
		}else if(navigator.userAgent.indexOf("Safari")>0){
   			//safari
		}
//alert("svg is"+src); 
        }
//alert(xmlhttp.responseText)
}
//	document.getElementById("data1").innerHTML="/usr/local/share/cg-rtl/lxr/source1/linux-3.5.4/x86_32/test.svg";//20150309
//	document.forms[1].svg.value=src;
//	function formSubmit()
//	{
//		alert(document.getElementById("svg").value);
//		var formObj=document.getElementById("form2");
//		formObj.submit();
  //      }


	function toXML(strxml){ 
                try{ 
                xmlDoc = new ActiveXObject("Microsoft.XMLDOM"); 
                xmlDoc.loadXML(strxml);         
                 
                //alert("Type is IE");
                } 
        catch(e){ 
     var oParser=new DOMParser(); 
     xmlDoc=oParser.parseFromString(strxml,"text/xml"); 
        //alert("Type is FF or Chrome");
     } 
  return xmlDoc; 
        } 
  </script>
</html>
