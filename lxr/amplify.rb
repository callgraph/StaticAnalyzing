#!/usr/bin/ruby -w
require 'find'

filename=""
filename=Array.new(10)
i=0
ARGV.each do|arg|
	filename[i]=arg
	i=i+1
end

$moudle=filename[2].to_i
$path0=filename[3]+"/"
$path1=filename[4]+"/"

s_flag=0
if filename[4]=="full"
	s_flag=1	#只有一个路径的单节点放大
end

r_filename=filename[0]
w_filename=filename[1]

afile=File.new(r_filename,"r")
wfile=File.new(w_filename,"w")

 while line=afile.gets
	if !line.index("label")
		wfile.puts line
	else
		t_flag=0
		pos=line.index("[label=")
		a_line=line
		a_temp=a_line.slice(0..pos-1)	#例如"ipc/ipcns_notifier.c"[tooltip="ipc/ipcns_notifier.c 0,0"][label=，或"ipc/ipcns_notifier.c"->"ipc/msg.c"[label=
		if a_temp.index("->")	#若为边的信息
			b_temp=a_temp.split("->")	#例如b_temp[0]="ipc/ipcns_notifier.c"，b_temp[1]="ipc/msg.c"[label=
			if b_temp[0].index($path0) and b_temp[1].index($path0)	#path0或path1的内部节点边的关系，保留
				t_flag=1
			end
			if s_flag==0	#若两个节点均需要放大
				if b_temp[0].index($path1) and b_temp[1].index($path1)	#path1的内部节点边的关系，保留
					t_flag=1
				end
				if b_temp[0].index($path0) and b_temp[1].index($path1)	#path0的内部节点→path1内部节点边的关系，保留
					t_flag=1
				end
				if b_temp[0].index($path1) and b_temp[1].index($path0)	#path1内部节点→path0内部节点边的关系，保留
					t_flag=1
				end
			end
		else	#若为节点的信息
			if a_temp.index($path0)	#path0或path1的内部节点调用，保留
				t_flag=1
			end    
			if s_flag==0	#若两个节点均需要放大
				if a_temp.index($path1)	#path1的内部节点调用，保留
					t_flag=1
				end
			end
		end
		
		if t_flag==1
			wfile.puts line
		end
	end
end

afile.close
wfile.close