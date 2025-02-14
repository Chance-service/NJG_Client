#!/bin/bash

sudo su;

DATE=`date +%Y%m%d_%H:%M`

if [ ! -d "serverOnOffLog/" ]; then 
	mkdir -p "serverOnOffLog/";
fi

if [ "$(ps aux | grep 'java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar' | grep 'Sl' | awk '{print $2}' | sed 'N;s/\n/ /')null" == "null" ]; then
	echo '    ' >> ./serverOnOffLog/restart.log
	echo '    ' >> ./serverOnOffLog/restart.log
	echo '该服务器没有启动！！！！！！' >> ./serverOnOffLog/restart.log
	echo '    ' >> ./serverOnOffLog/restart.log
	cat serverOnOffLog/restart.log
	rm -rf serverOnOffLog
	exit;
fi

> /mnt/data/java/logs/ServerLog.log

kill -12 $(ps aux | grep 'java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar' | grep 'Sl' | awk '{print $2}' | sed 'N;s/\n/ /')

k=1;
rs=0;
while :
do
	if [ $k == 300 ]; then
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '服务器重启超时' >> ./serverOnOffLog/restart.log;
		echo '    ' >> ./serverOnOffLog/restart.log
		break;
	fi

	if [ "$(grep 'shutting down complete' /mnt/data/java/logs/ServerLog.log)null" != "null" ]; then
		rs=1;
		break;
	fi

	k=$(($k+1));
	sleep 1;
done

if [ $rs == 0 ]; then
	if [ "$(ps aux | grep 'java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar' | grep 'Sl' | awk '{print $2}' | sed 'N;s/\n/ /')null" != "null" ]; then
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '出故障了，无法重启服务器！！！！！！' >> ./serverOnOffLog/restart.log
		echo '    ' >> ./serverOnOffLog/restart.log
		cat serverOnOffLog/restart.log
		rm -rf serverOnOffLog
		exit;
	fi
fi

> /mnt/data/java/logs/ServerLog.log
nohup java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar > /dev/null &

echo '结束时间' >> ./serverOnOffLog/restart.log
echo `date +%Y%m%d_%H:%M` >> ./serverOnOffLog/restart.log

j=1;

while :
do
	if [ $j == 180 ]; then
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '服务器启动超时' >> ./serverOnOffLog/restart.log;
		echo '    ' >> ./serverOnOffLog/restart.log
		break;
	fi

	if [ "$(grep 'server start ok' /mnt/data/java/logs/ServerLog.log)null" != "null" ]; then
		break;
	fi

	if [ "$(grep 'server start failed' /mnt/data/java/logs/ServerLog.log)null" != "null" ]; then
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '    ' >> ./serverOnOffLog/restart.log
		echo '服务器启动失败' >> ./serverOnOffLog/restart.log;
		echo '    ' >> ./serverOnOffLog/restart.log
		break;
	fi

	j=$(($j+1));
	sleep 1;
done

tail -10 /mnt/data/java/logs/ServerLog.log

echo "    "
echo "-------服务器：$1 ，成功无缝重启服-------"
cat serverOnOffLog/restart.log
echo "    "

mv serverOnOffLog/restart.log serverOnOffLog/restart.log_$DATE

exit;
