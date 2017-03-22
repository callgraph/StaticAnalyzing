#!/bin/bash
scriptpath=`pwd`
linkpath=/usr/local/share/cg-rtl
KEYWORD=(version platform directory comment link code_url note_url)
do_index(){
	local version=$1
	exist_version=`mysql -u cgrtl -p9-410 linux_3_5_4  << EOF | tail -n +2
			select distinct releaseid from lxr_releases 
			EOF`
	if [ $exist_version'x' = ''x ] ; then
		cd $linkpath/lxr
		echo $exist_version
		echo "0000"
		./genxref --url=http://localhost/lxr --version=$version
	else 
		flag=0
		for d in $exist_version;	do
			if [ $d = $version ] ; then
				flag=1
				echo "11111"
				#   cd $linkpath/lxr
				#sed -i '/, 'range' /a\ $DATA' lxr.conf
				#  ./genxref --url=http://localhost/lxr --version=$version
			fi
		done
		if [ $flag = 0 ] ; then
			echo "2222"
			cd $linkpath/lxr
			./genxref --url=http://localhost/lxr --version=$version
		fi
	fi
}

getvalue(){
	local data_line=$1
	for ((i=0;i<7;i++)); do
		OFFSET=$(expr match "$data_line" .*${KEYWORD[$i]})
		if [ $OFFSET != "0" ]; then 
			DATA=${data_line:($OFFSET+1)}
			TYPE=${data_line:0:$OFFSET}
			case $TYPE in 
					version )
				tree_data[0]=$DATA
				do_index ${tree_data[0]}
			;;
			esac
			
			case $TYPE in 
					platform )
				tree_data[1]=$DATA
			;;
			esac
			
			case $TYPE in 
					directory )
				tree_data[2]=$DATA
			;;
			esac
			
			case $TYPE in 
					comment )
				tree_data[3]=$DATA
			;;
			esac
			
			case $TYPE in
					link )
				tree_data[4]=$DATA
			;;
			esac
			
			case $TYPE in
					code_url )
				tree_data[5]=$DATA
			;;
			esac
			
			case $TYPE in
					note_url )
				tree_data[6]=$DATA
			;;
			esac
		fi
	done
}

editlxr(){
	xline=`sed 's/range.*/&''/' $linkpath/lxr/lxr.conf`
	compare=$(expr match "$xline" ".*${tree_data[0]}")
	if [ $compare -eq 0 ];then
		sed -i 's/range.*/& '${tree_data[0]}'/g' $linkpath/lxr/lxr.conf 
	fi
}

editjs(){
##############
	ALL=(`bash $scriptpath/from_file`)
	ALL_LEN=${#ALL[@]}
	for((i=0; i<$ALL_LEN-1;i=i+2)); do
		if [[ ${tree_data[0]} != ${ALL[$i]} || ${tree_data[1]} != ${ALL[$i+1]} || ${tree_data[2]} != ${ALL[$i+2]} ]];then 
			ALL=("${ALL[@]}" "${tree_data[0]}" "${tree_data[1]}" "${tree_data[2]}")
			#echo ${ALL[@]} 

			sed -i '/dsy.add/d' $linkpath/lxr/templates/html/html_head_btn_files/plat.js
			bash $scriptpath/to_file ${ALL[@]}
		fi
	done
}

edit(){
##########
	filedir=$linkpath/lxr/"$1"
	#    if [ ${tree_data[3]} = "doxygen" ];then
	sed -i 's#docxygen=.*#&,\"'${tree_data[0]}'\",\"'${tree_data[1]}'\",\"'${tree_data[2]}'\",\"'${tree_data[3]}'\",\"'${tree_data[5]}'\",\"'${tree_data[6]}'\"#' $filedir
	#    fi
}

compile(){
	asdasd=1
}

read_tree(){
	for conline in $(cat conf) 
	do
		if [ $conline = "#new_tree" ] ; then 
			editlxr
			editjs
			edit call
			edit watchlist
			compile
		fi
		getvalue $conline
	done
}

read_tree