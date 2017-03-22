#! /bin/bash
KEYWORD=(version platform)
for line in $(cat conf) 
do
	if [ $line = "#new_tree" ] ;
	then
		echo -e "is done \n"
	else 
		for ((i=0;i<2;i++));
		do
			OFFSET=$(expr match "$line" .*${KEYWORD[$i]})
			if [ $OFFSET != "0" ]; 
			then 
				DATA=${line:($OFFSET+1)}
				TYPE=${line:0:$OFFSET}
				case $TYPE in version )
					KEYWORDS[0]=$DATA
					echo -e "${KEYWORDS[0]} on \c" 
				;;
				esac
				case $TYPE in platform )
					KEYWORDS[1]=$DATA
					echo -e "${KEYWORDS[1]} \c"
				;;
				esac
			fi
		done
	fi
done

