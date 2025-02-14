#!/bin/bash

sudo su;

DATE=`date +%Y%m%d_%H:%M`

if [ ! -d "serverOnOffLog/" ]; then 
	mkdir -p "serverOnOffLog/";
fi

if [ "$(ps aux | grep 'java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar' | grep 'Sl' | awk '{print $2}' | sed 'N;s/\n/ /')null" == "null" ]; then
	echo '    ' >> ./serverOnOffLog/off.log
	echo '    ' >> ./serverOnOffLog/off.log
	echo '该服务器没有启动！！！！！！' >> ./serverOnOffLog/off.log
	echo '    ' >> ./serverOnOffLog/off.log
	cat serverOnOffLog/off.log
	rm -rf serverOnOffLog
	exit;
fi

> /mnt/data/java/logs/ServerLog.log

kill $(ps aux | grep 'java -jar -Xms1024m -Xmx3072m -XX:PermSize=64m -XX:MaxPermSize=256m game.jar' | grep 'Sl' | awk '{print $2}' | sed 'N;s/\n/ /')

k=1;
rs=0;
while :
do
	if [ $k == 300 ]; then
		echo '    ' >> ./serverOnOffLog/off.log
		echo '    ' >> ./serverOnOffLog/off.log
		echo '服务器关闭超时' >> ./serverOnOffLog/off.log;
		echo '    ' >> ./serverOnOffLog/off.log
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
		echo '    ' >> ./serverOnOffLog/off.log
		echo '    ' >> ./serverOnOffLog/off.log
		echo '出故障了，无法停服！！！！！！' >> ./serverOnOffLog/off.log
		echo '    ' >> ./serverOnOffLog/off.log
		cat serverOnOffLog/off.log
		rm -rf serverOnOffLog
		exit;
	fi
fi

echo '结束时间' >> ./serverOnOffLog/off.log
echo `date +%Y%m%d_%H:%M` >> ./serverOnOffLog/off.log
cat /mnt/data/java/logs/ServerLog.log

echo "    "
echo "-------服务器：$1 ，成功关服-------"
cat serverOnOffLog/off.log
echo "    "

mv serverOnOffLog/off.log serverOnOffLog/off.log_$DATE

exit;
