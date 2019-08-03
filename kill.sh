
pid=`ps aux|grep "./bmw.sh"|grep -v "grep"|awk '{print $2}'`
kill -9 $pid
