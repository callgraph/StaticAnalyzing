def generate_url(dlist_id,kernel_version,directory_type,cpu_platform):
#    url = 'http://os.cs.tsinghua.edu.cn:280/lxr/systrace-perl?v=linux-3.19.1&amp;\
#f=&amp;a=x86_64&amp;path0=' + str(dlist_id-250)+'&amp;path1='+str(dlist_id+250)
    url = 'http://os.cs.tsinghua.edu.cn:280/lxr/systrace-perl?v='+kernel_version+'&amp;\
f=&amp;a='+cpu_platform+'&amp;path0=' + str(dlist_id-250)+'&amp;path1='+str(dlist_id+250)
    return url
#####
def generateLink(pic_name,dlistid_set_per_second,runtime_percentage_per_pid,loc_max,kernel_version,directory_type,cpu_platform):
    path_name = 'dcg/'
    rect_width =85
    fp=open(path_name + 'link.xml','r')
    i=0;
    line=["","","","","","",""]
    for lines in fp.readlines():
        line[i]=lines
        i=i+1
    fp.close()
    js_fp= open(path_name + "click.js",'r')
    js_lines=js_fp.readlines()
    
    fp=open(path_name+'pic/' + pic_name,'r')
    newfp = open(path_name+'pic/' + 'result_'+pic_name,'wt')
    list_of_all_the_lines = fp.readlines()
    tag = 1###is not <use>
    id_index = 0
    lines_write=[]
###we need to get the width and height information of the picture,and we can find them in the fourth row from the bottom
    len_lines = len(list_of_all_the_lines)
    fourth_line_bottom = list_of_all_the_lines[len_lines-4]
    pos_info = fourth_line_bottom.split('"')
    xn = int(float(pos_info[3])+float(pos_info[5]))
    yn = int(float(pos_info[1])+float(pos_info[7]))
    ytemp = int(float(pos_info[7]))
#####
##############################################################
### sort the runtime_percentage_per_pid by the percetange 
###percentages may like the type of [0.1,0.2,0.3,0.4]
    for i in range(0,len(runtime_percentage_per_pid)):
	runtime_percentage_per_pid[i].sort(reverse = True)

##############################################################


    count = 0### add a count ,to find the max_loc
    for row in list_of_all_the_lines:
        if tag==1:
            if '<use' in row:
    	    	tag=0
            else:
     	    	newfp.write(row)
    	        if '<svg' in row:
    		    newfp.writelines(js_lines)
        if tag==0:
            if '<use' not in row:
    	    	tag=2
    	    	newfp.writelines(lines_write)
    	    	newfp.write(row)
    	    else:
    	        x_index= row.find('x=')
    	        for i in range(x_index+3,x_index+20):  ###max length of position x is less than 20
    		    if row[i]=='"':
    		        pos_x = row[x_index+3:i]
    		        break
    	        y_index= row.find('y=')
    	    	for i in range(y_index+3,y_index+20):  ###max length of position x is less than 20
    		    if row[i]=='"':
    		    	pos_y = row[y_index+3:i]
    		    	break
    	    	#x=float(pos_x)+20
		x=float(pos_x)
    	    	y=float(pos_y)
    #######################
	    	dlistid_num_per_pid = len(dlistid_set_per_second[id_index])
		###find the pid set which belongs to the same time(1s)
		if dlistid_num_per_pid:
		    pid_list = []
	    	    for i in range(0,dlistid_num_per_pid):
		        if dlistid_set_per_second[id_index][i][1] not in pid_list:
			    pid_list.append(dlistid_set_per_second[id_index][i][1])
		
		    len_pid_list = len(pid_list)
		##### we need to calculate postion of the list,for solve the screeen overflow
		    num_in_pid_list = [0 for i in range(0,len_pid_list)]
			
		    for i in range(0,dlistid_num_per_pid):
			temp_index = pid_list.index(dlistid_set_per_second[id_index][i][1])
			num_in_pid_list[temp_index] = num_in_pid_list[temp_index] + 1
		    
		    y0 = y
		    x0 = x + 10				
		    #xn = 1220###accurate value is 1228
		    #xn =972 
		    #yn = 640###accurate value is 648
		    #yn = 648 
		    m = len_pid_list
		    n = max(num_in_pid_list)
		    #print n,'@@@@@@@@@@@@@@',y
		    n_max = int(yn/14)
		    #if n > yn/14:
		    if n > 30:
			y =ytemp#####change 
			### set the max number of dlist is int(yn/14)
		    else:
			if n >(yn-y)/14-1:
			    y = yn-14*(n+1)
		    #	    print y,'########'
		    #if m<=(xn-x-10)/rect_width or x>xn/2:   ###change
		    if x<xn/2:
			x = x+10
		    else:
			###display at most 5 pid 
			if m>5:
			    m=5
			x = (x-rect_width*m-10)
		########################################################
			
    	    	    line0 = line[0].replace('@id',str(id_index))
		    ### if this point is the max_loc ,in order to show the difference,we show the dlist_id list 
		    if count==loc_max:
			line0 = line0.replace('hidden','visible')
	
		    ##############################################
		    ### for there are too much function call,in order to show probobaly,we show at most 5 pid ,and at most 30 dlist_id
		    ### who contribute most to the performance
		    
		    pid_count_most = 0
	 	    ##############################################	
    	    	    lines_write.append(line0)
		    for i in range(0,len_pid_list):
			###############
			if pid_count_most>4:
			    break
			pid_count_most=pid_count_most+1
			###########################
    	    	        line1 = line[1].replace('@x',str(x+(i*rect_width)))
    	    	        line1 = line1.replace('@color','#EFE9CE')
    	    	        line1 = line1.replace('@y',str(y))
    	    	        lines_write.append(line1)
    	    	        line2 = line[2].replace('@x',str(x+(i*rect_width)))
    	    	        line2 = line2.replace('@y',str(y+10))
			
			runtime_temp = round(runtime_percentage_per_pid[count][i][0],4)*100
	    	        #line2 = line2.replace('@pid',pid_list[i]+","+str(runtime_temp)+'%')####pid+%
	    	        line2 = line2.replace('@pid',runtime_percentage_per_pid[count][i][1]+","+str(runtime_temp)+'%')####pid+%
		        line2 = line2.replace('<a xlink:show="new" xlink:href="@href">','')
		        line2 = line2.replace('</a>','')
    	    	        lines_write.append(line2)
			j_count=0
	    	    	for j in range(0,dlistid_num_per_pid):
			    #if dlistid_set_per_second[id_index][j][1]==pid_list[i]:
			    if dlistid_set_per_second[id_index][j][1]==runtime_percentage_per_pid[count][i][1]:
    	                        line3=line[1].replace('@x',str(x+(i*rect_width)))
    	                        line3=line3.replace('@color','#AAD5EF')
    	                        line3 = line3.replace('@y',str(y+(j_count+1)*14))
    	                        lines_write.append(line3)
    	                        line4 =line[2].replace('@x',str(x+(i*rect_width)))
    	                        line4 = line4.replace('@y',str(y+(j_count+2)*14-4))
    	                        line4 = line4.replace('@pid',str(dlistid_set_per_second[id_index][j][0]))
			        line4 = line4.replace('@href',generate_url(dlistid_set_per_second[id_index][j][0],kernel_version,directory_type,cpu_platform));
    	                        lines_write.append(line4)
				j_count = j_count+1 
				#if j_count >=n_max:### there are too many function call to display on the screen,we just display n_max
				if j_count>=30:
				    break;
    	            lines_write.append(line[3])
    ######################
    	            temp = line[4].replace('@id1',str(id_index)+'g')###d is stand for the blue dot ,which will become green when we click it	
    	            newfp.write(line[4].replace('@id2',str(id_index)))
    	            temp = line[5].replace('@id',str(id_index)+'t')
    	            temp = temp.replace('@x',str(x0-14))
		    if count ==loc_max:
			temp = temp.replace('0000ff','00ff00') 
			temp = temp.replace('30px','40px')
    	            newfp.write(temp.replace('@y',str(y0+2)))
    	            newfp.write(line[6])

    	        id_index=id_index+1
	    count =count+1
    	    continue;
        if tag==2:
    	    newfp.write(row)
    fp.close()
    newfp.close()
    
