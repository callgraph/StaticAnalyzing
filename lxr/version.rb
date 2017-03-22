#!/usr/bin/ruby  -w
require 'soap/rpc/driver'
require 'rubygems'
require 'soap/wsdlDriver'
	wsdl_url_auth='http://192.168.2.113:8080/axis2/services/chooseService?wsdl'
	factory=SOAP::WSDLDriverFactory.new(wsdl_url_auth)	
	driver=factory.create_rpc_driver
	url='http://192.168.2.113'
	result=driver.getPost("url"=>"http://192.168.2.113")
	version=result.inspect.split('return=')[1]
	version=version[1..version.length-3]
	$perplatform=Array.new
	$perplatform=version.split('#new_tree\n')
	$remoteform=Array.new
	$remote=Array.new
	$remote2=Array.new
	$remoteformnum=$perplatform.length	
	i=0
	while i<$remoteformnum do
	$remoteform[i]="version:"
	$remote[i]=$perplatform[i].split('\n')
	
	for j in 0..$remote[i].length
	if($remote[i][j]!=nil)
	$remote2[j]=$remote[i][j].split('=')
	if($remote2[j][1]!=nil)
	$remoteform[i]+=$remote2[j][1]+"&&"
	end
	j=j+1
	end
	end
	$remoteform[i]=$remoteform[i][8..$remoteform[i].length-1]
#	puts $remoteform[i]
	i=i+1
	end
#get local version
	filename="/usr/local/share/cg-rtl/lxr/templates/html/html_head_btn_files/plat.js"
	filename2="/usr/local/share/cg-rtl/lxr/lib/LXR/Common.pm"
	afile2=File.new(filename2)
	$commonline="common"
	while line=afile2.gets
	$commonline=$commonline+line+"!!!!!!!!!!"
	end
	$common=Array.new
	$commonline=$commonline[6..$commonline.length-1]
	$common=$commonline.split"!!!!!!!!!!"
	
	afile=File.new(filename)
	$platline="plat"
	while	line=afile.gets
		$platline=$platline+line+"%%"
		if(line.include?'dsy.add("0",')
		$localversionline=line
	#	puts $localversionline
		end
	end
#	puts $localversionline
	$plat=Array.new
	$platline=$platline[4..$platline.length-1]
	$plat=$platline.split("%%")
#	puts $plat
	$arr=Array.new
	$localversion=Array.new
        $localversion2=Array.new
#	if $localversionline!=nil
	$arr=$localversionline.split('[')
	$arr[1]=$arr[1][0..$arr[1].length-5]
	$localversion=$arr[1].split(',')
#	end
	i=0
	$localnum=$localversion.length
	$remoteformnum=$remoteform.length
        while i<$localnum do
 	$localversion2[i]=$localversion[i][1..$localversion[i].length-2]
#	puts $localversion2[i]      
	i=i+1
        end
#add remote version
	i=0
	$remote3=Array.new
	$remotenum=0
	while i<$remoteformnum do
		$remote3[i]=$remoteform[i].split('&&')
		$remote3[i][3]=-1
		$remote3[i][4]=0
	i+=1
	end
	$dsy='dsy.add("0_'
        $first='",["'
        $end='"]);'
        $middle='","'
        $puts1=Array.new
	$puts2=Array.new
	$remoteversion=Array.new
	$sameversion=Array.new
	$count=1
	$samelength=$sameversion.length
#puts $remote3
	i=0
	b=0
	while i<$remoteformnum do
		if($remote3[i][3]==-1)	
		$remote3[i][3]=$remotenum
		$remoteversion[$remotenum]='"'+"#{$remote3[i][0]}"+'"'
#		puts $remoteversion[$remotenum]
			for a in 0..$localnum
				if $remoteversion[$remotenum]==$localversion[a]
					$sameversion[b]=$remoteversion[$remotenum]
					b=b+1
					#if b>0&&$sameversion[b]==$sameversion[b-1]
					#end
				end				
			a=a+1
			end
#		$puts1[$remotenum]=$dsy+"#{$localnum+$remotenum}"+$first+"#{$remote3[i][1]}"	
		j=i
		num=0
			while j<$remoteformnum do
				if $remote3[i]!=nil&&$remote3[j]!=nil
					if $remote3[i][0]==$remote3[j][0]&&$remote3[i][1]!=$remote3[j][1]
						$remote3[j][3]=$remote3[i][3]
						$count=$count+1
						num+=1
						$remote3[j][4]=num
#						puts $count
			#			puts $remote3[j][1]
#						$puts1[$remote3[i][3]]=$puts1[$remote3[i][3]]+$middle+$remote3[j][1]
			#			puts $remotenum
					end
				end
				j=j+1
			end
		else $remotenum=i-$count+2
		end
	#puts $count
	#puts $remote3[i]
	i=i+1
	end
#puts $sameversion	
	$samelength=$sameversion.length
	i=0
	while i<$remoteformnum
	#puts i
		for j in 0..$samelength
			if $sameversion[j]!=nil&&$remote3[i]!=nil
#			puts $remote3[i][1]
#			puts $sameversion[j][1..$sameversion[j].length-2]
			if $remote3[i][0]==$sameversion[j][1..$sameversion[j].length-2]
	#		puts $remote3[i]
			tmp=Array.new
                        tmp=$remote3[i]
			for m in i..$remoteformnum
			$remote3[m]=$remote3[m+1]
			if $remote3[m]!=nil
				if $remote3[m][4]==0&&tmp[4]==0
				#puts $remote3[m][3]
				$remote3[m][3]=$remote3[m][3]-1
				#puts $remote3[m][3]
				for k in 0..$remoteformnum
					if $remote3[k]!=nil&&$remote3[m][0]==$remote3[k][0]&&$remote3[m][1]!=$remote3[k][1]
						$remote3[k][3]=$remote3[k][3]-1
					end
				end
				end
			end
			end
			$remoteformnum=$remoteformnum-1
			i=i-1
			end
			end
		end
	i=i+1
	end
	i=0
	while i<$remotenum
	#	if $remote3[i][4]==-1
		for j in 0..$samelength
			if $sameversion[j]!=nil&&$remoteversion[i]!=nil
			if $remoteversion[i]==$sameversion[j]
			for m in i..$remotenum
			$remoteversion[m]=$remoteversion[m+1]
			end
			$remotenum=$remotenum-1
			i=i-1
			end
			end
		end
	i=i+1
	end
#	puts $remoteversion
#	puts $remote3
#	puts $remotenum
#add to common.pm
$commonlength=$common.length
$add=Array.new
wfile2=File.new(filename2,'w')
for i in 0..991
	wfile2.puts $common[i]
end

	$add1="$ENV{'QUERY_STRINGSID'}='"
for i in 0..$remotenum
	if $remoteversion[i]!=nil
	$add[i]=$add1+"#{$remoteversion[i][1..$remoteversion[i].length-2]}"+"' if substr($value[0],2) eq '""#{$remoteversion[i][1..$remoteversion[i].length-2]}"+"';"
	wfile2.puts $add[i]
	end
end

for i in 992..$commonlength-1
	wfile2.puts $common[i]
end
	
	
#add to plat.js
for i in 0..$remoteformnum
	if $remote3[i]!=nil
		if $remote3[i][4]==0
#		puts $remote3[i]
		$puts1[$remote3[i][3]]=$dsy+"#{$localnum+$remote3[i][3]}"+$first+"#{$remote3[i][1]}" 
		else $puts1[$remote3[i][3]]=$puts1[$remote3[i][3]]+$middle+$remote3[i][1]
		end
	end
end
        $puts3='dsy.add("0",['
	$localdsy=Array.new
        $localfu=Array.new
 wfile=File.new(filename,'w')
	if $remotenum==0
	$remoteformnum=0
	end
#if $remotenum!=0
#	 wfile=File.new(filename,'w')
	        $puts3='dsy.add("0",['
        for i in 0..$localnum
                if $localversion[i]!=nil
                $puts3+="#{$localversion[i]}"+","
                end
        end
        for i in 0..$remotenum
                $puts3+="#{$remoteversion[i]}"+","
        end
        $puts3=$puts3[0..$puts3.length-6]+$end
#end
	ds=0
	fu=0
	for i in 0..$plat.length-1
		if "#{$plat[i]}".include?'dsy.add'
		$localdsy[ds]=$plat[i]
		ds+=1
		else
		$localfu[fu]=$plat[i]
		fu+=1
		end
	end
        i=0
	while i<$localfu.length
               # if $localfu[i]==nil
		wfile.puts $localfu[i]
		i+=1
	end
		wfile.puts $puts3
	i=0
	while i<$localdsy.length
		if $localdsy[i]==nil
		$localdsy[i]="kong"
		else
		if $localdsy[i]!=$localversionline
		wfile.puts $localdsy[i]
		end
		end
		i+=1
	end
	
	if($puts1.length>0)
	for i in 0..$puts1.length
		if($puts1[i]!=nil)
		$puts1[i]=$puts1[i]+$end
	#	puts $puts1[i]
	wfile.puts $puts1[i]
		end
	end
	end
	for i in 0..$remoteformnum
		if $remote3[i]!=nil
		$puts2[i]=$dsy+"#{$localnum+$remote3[i][3]}"+'_'+"#{$remote3[i][4]}"+$first+"#{$remote3[i][2]}"+$end
	#	puts $puts2[i]
		wfile.puts $puts2[i]	
		end	
	end
