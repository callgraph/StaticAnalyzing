<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<meta http-equiv="Access-Control-Allow-Origin" content="*">
  <head runat="sever">
  <script type="text/javascript;charset=utf-8">
    var xmlhttp=null;   
	var src=null;
	function  showList(){	
	var object = document.createElement("object");		
		object.data=src; 
		object.width="100%";
		object.height="100%";
		object.codebase="http://www.adobe.com/svg/viewer/install/";		
		var myDiv = document.getElementById('data'); 
		myDiv.appendChild(object);  			
	}
  	function RequestWebService(){
  		var URL="http://localhost:8080/axis2/services/ListService";
  		var data;
  		
            var v;
            var a;
  			var path0;
            var path1;
            var state;
            var version=document.getElementById("v");
              for(i=0;i<version.length;i++){
            	  if(version[i].selected==true){
            		  v=version[i].text;
            		 // alert("The version is:"+v);
            	  }
              }
            
            a=document.getElementById("a").value;
            path0=document.getElementById("path0").value;
			path1=document.getElementById("path1").value;          
            data = '<?xml version="1.0" encoding="UTF-8"?>';
            data = data + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
            data = data + '<soap12:Body>';
            data = data + '<getListFileUrl xmlns="http://impl.ws.core.serv.wuz.com"><args0>'+v+'</args0><args1>'+a+'</args1><args2>'+path0+'</args2><args3>'+path1+'</args3></getListFileUrl>';
            data = data + '</soap12:Body>';
            data = data + '</soap12:Envelope>';   
                  
            if(window.ActiveXObject){                  
     			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
     		}
     		else if(window.XMLHttpRequest){
     			xmlhttp = new XMLHttpRequest();
     		}else{
     			//alert("not supported!");
     		}
     		if(xmlhttp!=null){
     		//	alert("Browser runs success");
     		}     		 
     		xmlhttp.onreadystatechange=processResult;     					   
            xmlhttp.open("POST",URL,true);                				
            xmlhttp.setRequestHeader("Content-type","application/soap"); 					  
            xmlhttp.send(data);     
            //alert("where is the problem"); 	
  	}
  	function processResult(){  		
  		if(xmlhttp.readyState==4&&xmlhttp.status==200){  		
  		var result=xmlhttp.responseText;
  		//alert("Return value="+result);
		var xmlDoc=toXML(result); 
		src=xmlDoc.getElementsByTagName("ns:return")[0].childNodes[0].nodeValue;
		//document.write(xmlDoc.getElementsByTagName("ns:return")[0].chileNodes[0].nodeType);
  		document.getElementById("data1").innerHTML =src; 		
  		}	
  	}
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
  </head>
  
  <body>
    <form id="form1" runat="server">
    <div>	
    <form> 
	<tr> 
	Version: 
    <select onchange="isSelected(this.value);" id="v"> 
          <option value="1">linux-3.5.4</option> 
          <option value="2">android-4.0.4</option> 
    </select> <br/>

	Architecture:
	<input type="text" id="a"><br/>
	Path0:
	<input type="text" id="path0"><br/>
	Path1:
	<input type="text" id="path1"><br/>
	ShowListFileUrl:	
	<br/>	
	<input id="One" type="button" value="ListFileUrl" onclick="RequestWebService()"/>	
	<input id="two" type="button" value="ShowList" onclick="showList()"/>	
	</form>    	
    </div>
	<div id="data1"></div>
    <div id="data"></div>
    </form>
  </body>
</html>
