#!/bin/bash

sudo su;

DATE=`date +%Y%m%d_%H:%M`

if [ ! -d "serverOnOffLog/" ]; then 
	mkdir -p "serverOnOffLog/";
fi

if [ ! -d "../console_logs/" ]; then 
	mkdir -p "../console_logs/";
fi

if [ "$(ps aux | grep 'java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar' | grep 'Sl' | awk '{print $2}' | sed 'N;s/\n/ /')null" != "null" ]; then
	echo '    ' >> ./serverOnOffLog/on.log
	echo '    ' >> ./serverOnOffLog/on.log
	echo '该服务器已经启动' >> ./serverOnOffLog/on.log
	echo '    ' >> ./serverOnOffLog/on.log
	cat serverOnOffLog/on.log
	rm -rf serverOnOffLog
	exit;
fi

> /mnt/data/java/logs/ServerLog.log
nohup java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar > /dev/null &

echo '结束时间' >> ./serverOnOffLog/on.log
echo `date +%Y%m%d_%H:%M` >> ./serverOnOffLog/on.log

k=1;

while :
do
	if [ $k == 180 ]; then
		echo '    ' >> ./serverOnOffLog/on.log
		echo '    ' >> ./serverOnOffLog/on.log
		echo '服务器启动超时' >> ./serverOnOffLog/on.log;
		echo '    ' >> ./serverOnOffLog/on.log
		break;
	fi

	if [ "$(grep 'server start ok' /mnt/data/java/logs/ServerLog.log)null" != "null" ]; then
		break;
	fi

	if [ "$(grep 'server start failed' /mnt/data/java/logs/ServerLog.log)null" != "null" ]; then
		echo '    ' >> ./serverOnOffLog/on.log
		echo '    ' >> ./serverOnOffLog/on.log
		echo '服务器启动失败' >> ./serverOnOffLog/on.log;
		echo '    ' >> ./serverOnOffLog/on.log
		break;
	fi

	k=$(($k+1));
	sleep 1;
done

tail -10 /mnt/data/java/logs/ServerLog.log

echo "    "
echo "-------服务器：$1 ，成功开服-------"
cat serverOnOffLog/on.log
echo "    "

mv serverOnOffLog/on.log serverOnOffLog/on.log_$DATE

exit;
