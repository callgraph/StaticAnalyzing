output_location=$1
echo "Output location: ${output_location}"
port=1401
location="solaris.cs.tsinghua.edu.cn"
ssh root@${location} -p ${port} 'sh /home/wjbang/ftrace/get_binder.sh' &
sleep 20
echo "wait.."
sleep 100
ssh root@${location} -p ${port} 'sh /home/wjbang/ftrace/reboot_phone.sh'
sleep 15
ssh root@${location} -p ${port} 'sh /home/wjbang/ftrace/pull_binder.sh'

scp -P $port root@${location}:/home/wjbang/ftrace/binder_ftrace.txt ${output_location}/
ssh root@${location} -p ${port} 'rm /home/wjbang/ftrace/binder_ftrace.txt'
python /home/wjbang/binder/sec1.py ${output_location}/binder_ftrace.txt
#python sec2.py ${lower} ${upper} > ${output_location}/index-${lower}-${upper}.html
touch $output_location/sec.done
