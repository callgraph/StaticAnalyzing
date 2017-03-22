#! /bin/bash
KEYWORD=(version platform)
flag=0;
k=0;
for line in $(cat confall) 
do
	echo "$k "
	case $k in 3)
		dir=$line
	;;
	4)
		com=$line
	;;
	5)
		link=$line
	;;
	6)
		web1=$line
	;;
	7)
		web2=$line
	;;
	esac
	if [ $line = "#new_tree" ];
	then
		if [ $flag = 0 ];
		then	
			echo "$ver" >> confnew
			echo "$pla" >> confnew
			echo "$dir" >> confnew
			echo "$com" >> confnew
			echo "$link" >> confnew
			echo "$web1" >> confnew
			echo "$web2" >> confnew
			echo "$line" >> confnew
		fi
		#echo -e "is done \n"
		flag=0;
		flag0=0;
		flag1=0;
		k=0;
	else
		for((i=0;i<2;i++));
		do
			OFFSET=$(expr match "$line" .*${KEYWORD[$i]})
			if [ $OFFSET != "0" ]; 
			then 
				DATA=${line:($OFFSET+1)}
				TYPE=${line:0:$OFFSET}
				case $TYPE in version )
					KEYWORDS[0]=$DATA
					ver=$line
					#echo -e "${KEYWORDS[0]} on \c" 
				;;
				esac
				
				case $TYPE in platform )
					KEYWORDS[1]=$DATA
					pla=$line
					#echo -e "${KEYWORDS[1]} \c"

					flag0=0;
					flag1=0;
					for line1 in $(cat conf) 
					do
						
						for((j=0;j<2;j++));
						do
							OFFSET1=$(expr match "$line1" .*${KEYWORD[$j]})
							if [ $OFFSET1 != "0" ]; 
							then
								DATA1=${line1:($OFFSET1+1)}
								TYPE1=${line1:0:$OFFSET1}
								case $TYPE1 
								in version )
						
									if [ ${KEYWORDS[0]} = $DATA1 ];
									then flag0=1;
									#echo -e "$flag0 $flag1 on \c"
									fi
								;;
								platform )
							
									if [ ${KEYWORDS[1]} = $DATA1 ];
									then flag1=1;
									#echo -e "$flag0 $flag1 on \c"
									fi
								;;
								esac
							fi		
						done
						
						if [ $flag0 = 1 ];
						then
							if [ $flag1 = 1 ];
							then	
								flag=1;
								
							fi
						fi
					done
				;;
				esac
			fi
		done
	fi
	#echo "$line" >> newfile
	((k=k+1))
done
mv conf confold
mv confall conf