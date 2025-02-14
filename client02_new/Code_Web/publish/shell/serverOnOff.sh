#!/bin/bash

# 加载系统配置文件
source "./config/system.sh";

# 执行开停服
function execServerOnOffQueue() {
	# 队列格式：游戏名称 版本 区服 服务器web目录 任务状态 服务器用户名 服务器ip 服务器端口号(lol release s2 /www/wwwroot/demacia/qimi/release/s2/ on root 127.0.0.1 22)

	#echo "    " >> ${SERVER_ON_OFF_LOG}
	#echo "    " >> ${SERVER_ON_OFF_LOG}
	#echo "-------服务器： $3 -------" >> ${SERVER_ON_OFF_LOG}
	#echo "    " >> ${SERVER_ON_OFF_LOG}

	if [[ "${8}null" == "null" ]]; then
		SSH_PORT='22';
	else
		SSH_PORT=$8;
	fi

	# 判断当前是开服还是关服
	if [[ "${5}" == "on" ]]; then
		ssh -p $SSH_PORT $6@$7 "cd $4;sudo ./serverOn.sh $3" >> ${SERVER_ON_OFF_LOG} < /dev/null 

		#echo "-------服务器：$3 ，成功开服-------" >> ${SERVER_ON_OFF_LOG}
	elif [[ "${5}" == "off" ]]; then
		ssh -p $SSH_PORT $6@$7 "cd $4;sudo ./serverOff.sh $3" >> ${SERVER_ON_OFF_LOG} < /dev/null

		#echo "-------服务器：$3 ，成功关服-------" >> ${SERVER_ON_OFF_LOG}
	else
		ssh -p $SSH_PORT $6@$7 "cd $4;sudo ./serverRestart.sh $3" >> ${SERVER_ON_OFF_LOG} < /dev/null

		#echo "-------服务器：$3 ，成功无缝重启服-------" >> ${SERVER_ON_OFF_LOG}
	fi

}

# 守护进程
while :
do

	# 开停服队列存在才能执行
	if [ -f "$SERVER_ON_OFF_QUEUE" ]; then 

		if [ -f "${SERVER_ON_OFF_LOG}" ]; then 
			touch ${SERVER_ON_OFF_LOG};
			chown www:www ${SERVER_ON_OFF_LOG};
		fi

		echo "    " >> ${SERVER_ON_OFF_LOG}
		echo "监控到开停服任务" >> ${SERVER_ON_OFF_LOG}
		echo "    " >> ${SERVER_ON_OFF_LOG}

		# 计数器，用于记录当前同时有几个队列在开停服中，每次同时最多能开停服100个平台
		i=0;

		# 循环开停服队列逐个执行
		while read line 
		do 
			{
			# $line格式：游戏名称 版本 区服 服务器web目录 任务状态 服务器用户名 服务器ip 服务器端口号(lol release s2 /www/wwwroot/demacia/qimi/release/s2/ on root 127.0.0.1 22)
			execServerOnOffQueue $line;
			}&
			if [ $i == $MAX_PUBLISH_QUEUE_NUMBER ]; then
				i=0;
				wait;
			else
				i=$(($i+1));
			fi
			
		done < $SERVER_ON_OFF_QUEUE;
		wait;

		rm -f $SERVER_ON_OFF_QUEUE;

		if [ -f "$SERVER_ON_OFF_LOG" ]; then 
			echo "开停服执行完成" >> ${SERVER_ON_OFF_LOG}
			echo "SUCCESS" >> ${SERVER_ON_OFF_LOG}
			echo "共执行服务器数：" >> ${SERVER_ON_OFF_LOG}
			cat ${SERVER_ON_OFF_LOG} | grep "服务器：" | wc -l >> ${SERVER_ON_OFF_LOG}
			echo "服务器执行列表：" >> ${SERVER_ON_OFF_LOG}
			cat ${SERVER_ON_OFF_LOG} | grep "服务器：" >> ${SERVER_ON_OFF_LOG}
			sleep 4;
			mv -f $SERVER_ON_OFF_LOG $SERVER_ON_OFF_HISTORY_LOG;
			echo `date +%Y%m%d_%H:%M` >> $SERVER_ON_OFF_HISTORY_LOG;
			chown www:www $SERVER_ON_OFF_HISTORY_LOG;
		fi

	fi

	# 30s后再次监控是否有开停服任务
	sleep $MONITOR_SLEEP_TIME;
done