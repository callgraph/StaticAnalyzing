package com.wuz.serv.core.ws.impl;

import java.awt.Desktop;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLConnection;

import org.apache.commons.lang.StringUtils;

public class getTaintTrace {
	public String getTaintTraceUrl(String v,String a,String f,String path0,String path1,String d){
		getTaintTrace showSvg=new getTaintTrace();
		
		String fn="";
		int timeN=0;
		Object waitLock = new Object();
		
		
		if(path0.toString().equals("*")){
	    	
	    	 fn="root.svg"; //Ban
	      }
		else if(path1.toString().equals("")){
	    	
	    	 fn=path0+".svg"; //Ban
	      }
	      else{
	    	 fn=path0+"-"+path1+"-"+d+"-trace.svg";
	      }
		
		if(f.equals("real")){
			fn="real-"+fn;
		}
		else{
			fn="virtual-"+fn;
		}
		fn=fn.replaceAll("/", "_");
			
		if(!showSvg.FileisExit(v,a,fn)){
		showSvg.Calculate4Svg(v,a,f,path0,path1,d);
	
		while(!showSvg.FileisExit(v,a,fn)){

			timeN++;
			try {
				Thread.sleep(2000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			System.out.println("It still computing,Please wait....");
			
		  }
		}
		System.out.println("The total time of computing is "+timeN*2+"s!");
		//showSvg.ShowSvgImg(fn);
		return "http://124.16.141.130/lxr/source1/"+v+"/"+a+"/"+fn;	
	}
	
	public  void  Calculate4Svg(String v,String a,String f,String path0,String path1,String d) {
      
		//��������ű�����ҳ
		String fn=null;   
	    String inputUrl="http://124.16.141.130/lxr/taintrace?v="+v+"&f="+f+"&a="+a+"&path0="+path0+"&path1="+path1+"&depth="+d;
		
		URL calculateUrl = null;
		
		URLConnection conn = null;
		
		
		try {
			calculateUrl = new URL(inputUrl);
			conn = calculateUrl.openConnection();
			conn.getInputStream();
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
	
		System.out.println(calculateUrl.getAuthority());
	}   
		
	public boolean FileisExit(String v,String a,String filename){   //�ļ���
	      
		//�鿴������Ŀ¼���Ƿ������svg�ļ�
		String urlString="http://124.16.141.130/lxr/source1/"+v+"/"+a+"/"+filename;
	
		URL url = null;
	
		try {
			url = new URL(urlString);
		
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		URLConnection conn = null;
		try {
			conn = url.openConnection();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  
		
	
	     HttpURLConnection urlcon = null;
		try {
			urlcon = (HttpURLConnection) url.openConnection();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}


	     String message = urlcon.getHeaderField(0);//�ļ����ڡ�HTTP/1.1 200 OK�� �ļ������� ��HTTP/1.1 404 Not Found��
	     if (StringUtils.isNotEmpty(message) && message.startsWith("HTTP/1.1 200")) {
	   //����
	    	 System.out.println("exit");
				return true;
	     }
		
		else{
			System.out.println("not exit");
			return false;
		}
	}	
}