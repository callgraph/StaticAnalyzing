#!/bin/bash

SOURCE=/usr/local/share/cg-rtl/source
linkpath=/usr/local/share/cg-rtl
KEYWORD=(version platform directory comment)
for line in $(cat conf) 
do
	if [ $line = "#new_tree" ] ;	then 
		echo ++++++++++++
		DATA_TYPE=-1
		if [ $(expr match "${KEYWORDS[0]}" ".*linux-") != "0" ]; then
			DATA_TYPE=0
		elif [ $(expr match "${KEYWORDS[0]}" ".*Android-") != "0" ]; then
			DATA_TYPE=1
		elif [ $(expr match "${KEYWORDS[0]}" ".*ucore") != "0" ]; then
			DATA_TYPE=2
		fi
		if [ $DATA_TYPE = "0" ] ; then 
			case ${KEYWORDS[1]} in
							mips )
				cd $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/create_vlists.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/traversePV.rb $SOURCE/${KEYWORDS[0]}

				tempsword=mips
				sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm
				
				if [ ${KEYWORDS[2]} == "real" ]; then
					make mrproper
					make clean
					export ARCH=mips
					export CROSS_COMPILE=mips-linux-gnu-
					export PATH=/opt/mips_linux_toolchain/bin:$PATH
					make malta_defconfig
					make >makeinfo.txt
				fi
			;;
			esac

			case ${KEYWORDS[1]} in
							x86_32 )
				cd $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/create_vlists.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/traversePV.rb $SOURCE/${KEYWORDS[0]}
				
				
				tempsword=x86
			   	sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm
				
				if [ ${KEYWORDS[2]} == "real" ]; then
					make mrproper
					make clean
					export ARCH=i386
					export CROSS_COMPILE=
					make i386_defconfig
					echo CONFIG_DEBUG_INFO=y >> .config
					make oldnoconfig
					make >makeinfo.txt 2>&1
				fi
			;;
			esac

			case ${KEYWORDS[1]} in
							x86_64 )
				cd $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/create_vlists.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/traversePV.rb $SOURCE/${KEYWORDS[0]}

				tempsword=x86
				sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm

				if [ ${KEYWORDS[2]} == "real" ]; then
					make mrproper
					make clean
					export ARCH=x86_64
					export CROSS_COMPILE=
					make x86_64_defconfig
					echo CONFIG_DEBUG_INFO=y >> .config
					make oldnoconfig
					make >makeinfo.txt 2>&1
				fi
			;;
			esac
		
		elif [ $DATA_TYPE = "1" ] ; then 
			case ${KEYWORDS[1]} in
							arm-pandaboard )
				cd $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/create_vlists.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/traversePV.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/arm-pandaboard_defconfig $SOURCE/${KEYWORDS[0]}/.config

				tempsword=arm
				sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm
				
				if [ ${KEYWORDS[2]} == "real" ]; then
					make mrproper
					make clean
					export ARCH=arm
					export SUBARCH=arm
					export CROSS_COMPILE=arm-linux-gnueabihf-
					make  omap2plus_defconfig
					make >makeinfo.txt
				fi
			;;
			esac
			
			case ${KEYWORDS[1]} in
							arm-Raspberrypi)
				cd $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/create_vlists.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/traversePV.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/arm-Raspberrypi_defconfig $SOURCE/${KEYWORDS[0]}/arch/arm/configs/arm-Raspberrypi_defconfig
				
				tempsword=arm
			 	sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm

				if [ ${KEYWORDS[2]} == "real" ]; then
					make mrproper
					make clean
					export ARCH=arm
					export SUBARCH=arm
					export CROSS_COMPILE=arm-linux-gnueabihf-
					make arm-Raspberrypi_defconfig
					make >makeinfo.txt
				fi
			;;
			esac
			
			case ${KEYWORDS[1]} in
							arm-galaxy-nexus )
				cd $SOURCE/${KEYWORDS[0]}
				
				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/create_vlists.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/traversePV.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/arm-galaxy-nexus_defconfig $SOURCE/${KEYWORDS[0]}/arch/arm/configs/arm-galaxy-nexus_defconfig
				
				tempsword=arm
				
				sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm

				if [ ${KEYWORDS[2]} == "real" ]; then
					make mrproper
					make clean
					export ARCH=arm
					export SUBARCH=arm
					export CROSS_COMPILE=arm-linux-gnueabihf-
					make  arm-galaxy-nexus_defconfig
					make   >makeinfo.txt
				fi
			;;
			esac

			case ${KEYWORDS[1]} in
							arm-Nexus5 )
				cd $SOURCE/${KEYWORDS[0]} 
				cp $SOURCE/db-rtl-callgraph/complier/little-Android.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run-Android.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/create_vlists.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/traversePV.rb $SOURCE/${KEYWORDS[0]}
		   		cp $SOURCE/db-rtl-callgraph/complier/arm-hammerhead_defconfig $SOURCE/${KEYWORDS[0]}/arch/arm/configs/arm-hammerhead_defconfig
				
				tempsword=arm
				sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm
				if [ ${KEYWORDS[2]} == "real" ]; then
					make mrproper
					make clean
					export ARCH=arm
					export SUBARCH=arm
					export PATH=$PATH:/usr/local/share/cg-rtl/source/db-rtl-callgraph/auto_install/arm-2010q1/bin	#add from 20141010 by jiadi
					export CROSS_COMPILE=arm-none-linux-gnueabi-
					make arm-hammerhead_defconfig
					make >makeinfo.txt
				fi
			;;
			esac 
	
			case ${KEYWORDS[1]} in
							arm )
				cd $SOURCE/${KEYWORDS[0]}
				
				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				# sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm

				make mrproper
				make clean
				export ARCH=arm
				export CROSS_COMPILE=arm-linux-gnueabihf-
				make ARCH=arm defconfig
				make ARCH=arm >makeinfo.txt
			;;
			esac
		elif [ $DATA_TYPE = "2" ] ; then
			cd $SOURCE/${KEYWORDS[0]}
                        cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
                        cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
                        cp $SOURCE/db-rtl-callgraph/complier/ucore_auto_run.rb $SOURCE/${KEYWORDS[0]}
                        sed -i "s/=@/=/" Makefile
			find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
                        find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm
                        make mrproper
                        make clean

                        case ${KEYWORDS[1]} in
                                               	x86_32 )
                                if [ ${KEYWORDS[2]} == "real" ]; then
                                        export ARCH=i386
                                        export CROSS_COMPILE=
                                        make defconfig
                                        make >makeinfo.txt
                                fi
                        ;;
                        esac

			case ${KEYWORDS[1]} in
                                                x86_64 )
                                if [ ${KEYWORDS[2]} == "real" ]; then
                                        export ARCH=amd64
                                        export CROSS_COMPILE=
                                        make defconfig
                                        make >makeinfo.txt
                                fi
                        ;;
                        esac

			case ${KEYWORDS[1]} in
                                                mips )
                                if [ ${KEYWORDS[2]} == "real" ]; then
                                        export ARCH=mips
                                        export CROSS_COMPILE=mips-sde-elf-
                                        make defconfig
					#make sfsimg
                                        make >makeinfo.txt
                                fi
                        ;;
                        esac

			case ${KEYWORDS[1]} in
                                                arm-Raspberrypi )
                                if [ ${KEYWORDS[2]} == "real" ]; then
                                        export ARCH=arm
					export BOARD=raspberrypi
					export CROSS_COMPILE=arm-none-eabi-
                                        make defconfig
					make sfsimg
                                        make >makeinfo.txt
                                fi
                        ;;
                        esac

		else 
			case ${KEYWORDS[1]} in
							arm )
				cd $SOURCE/${KEYWORDS[0]} 

				cp $SOURCE/db-rtl-callgraph/complier/little.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/call_graph_db.rb $SOURCE/${KEYWORDS[0]}
				cp $SOURCE/db-rtl-callgraph/complier/auto_run.rb $SOURCE/${KEYWORDS[0]}
				# sed -i "48c   KBUILD_VERBOSE = 1" Makefile
				find  $SOURCE/${KEYWORDS[0]} -name "*.sched2" | xargs rm
				find  $SOURCE/${KEYWORDS[0]} -name "*.expand" | xargs rm
				find   $SOURCE/${KEYWORDS[0]} -name "*.aux_info" | xargs rm

				make mrproper
				make clean
				export ARCH=arm
				export SUBARCH=arm
				export CROSS_COMPILE=arm-none-linux-gnueabi-
				make goldfish_defconfig   
				make >makeinfo.txt
			;;
			esac 
		fi

		cd $SOURCE
		sudo chmod -R 777 ${KEYWORDS[0]}
		cd $SOURCE/${KEYWORDS[0]}
		echo _________________+++++++++++
		if [ ${KEYWORDS[2]} == "real" ]; then
			if [ ${KEYWORDS[1]} = "arm-Nexus5" ]; then		#add from 20141010 by jiadi
				./auto_run-Android.rb makeinfo.txt re_compiler.sh
			elif [ ${KEYWORDS[0]} = "ucore" ]; then
				./ucore_auto_run.rb makeinfo.txt re_compiler.sh
			else
				./auto_run.rb makeinfo.txt re_compiler.sh
			fi
			chmod -R 777 re_compiler.sh
			./re_compiler.sh >goldfish_s.txt
			chmod +x call_graph_db.rb
			unset ARCH
			unset CROSS_COMPILE
			./call_graph_db.rb   $SOURCE/${KEYWORDS[0]} ${KEYWORDS[0]} ${KEYWORDS[2]} ${KEYWORDS[1]}
		fi
		 
		if [ ${KEYWORDS[2]} == "virtual" ]; then
			./traversePV.rb   $SOURCE/db-rtl-callgraph/complier/virtual-linux-3.5.4/$tempsword ${KEYWORDS[0]} ${KEYWORDS[1]}
			./create_vlists.rb ${KEYWORDS[0]} ${KEYWORDS[1]}
		fi
		mkdir $linkpath/lxr/source1
		mkdir $linkpath/lxr/source1/${KEYWORDS[0]}
		mkdir $linkpath/lxr/source1/${KEYWORDS[0]}/${KEYWORDS[1]}
		chmod -R 777 $linkpath/lxr/source1/${KEYWORDS[0]}/${KEYWORDS[1]}
	else
		for ((i=0;i<4;i++)); do
			OFFSET=$(expr match "$line" ".*${KEYWORD[$i]}")
			if [ $OFFSET != "0" ]; then 
				DATA=${line:($OFFSET+1)}
				TYPE=${line:0:$OFFSET}
				case $TYPE in 
						version )
					KEYWORDS[0]=$DATA
					echo acquire a version 
				;;
				esac

				case $TYPE in 
						platform )
					KEYWORDS[1]=$DATA
					echo acquire a platform 
				;;
				esac
	 
				case $TYPE in 
						directory )
					KEYWORDS[2]=$DATA
				;;
				esac
				
				case $TYPE in 
						comment )
					KEYWORDS[3]=$DATA
				;;
				esac
			fi
		done
	fi
done
