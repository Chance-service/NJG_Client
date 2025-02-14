#!/bin/bash

# 加载系统配置文件
source "./config/system.sh";

# 需要发布的代码压缩包名称
PUBLISH_CODE_PACKAGE_NAME="";

# 执行初始化服务器
function execInitServerQueue() {
	# 队列格式：游戏 区服 服务器web目录 服务器用户名 服务器ip 服务器端口号(lol s2 /www/wwwroot/demacia/qimi/release/s2/ root 127.0.0.1 22)

	echo "    " >> ${INIT_SERVER_LOG}
	echo "    " >> ${INIT_SERVER_LOG}
	echo "-------服务器： $1 $2 -------" >> ${INIT_SERVER_LOG}
	echo "    " >> ${INIT_SERVER_LOG}
	echo "正在连接服务器" >> ${INIT_SERVER_LOG}
	echo "    " >> ${INIT_SERVER_LOG}

	if [[ "${5}null" == "null" ]]; then
		SSH_PORT='22';
	else
		SSH_PORT=$6;
	fi
	#/mnt/data/java/jar
	ssh -p $SSH_PORT $4@$5 "sudo mkdir -p $3;sudo chown -R $4:$4 $3;" >> ${INIT_SERVER_LOG}

	if [[ $1 == "lz" ]]; then
		tar zcvf lz_soft.tar.gz lz_soft >> ${INIT_SERVER_LOG}

		rsync -av --progress -e "ssh -c arcfour -p ${SSH_PORT}" lz_soft.tar.gz $4@$5:$3 >> ${INIT_SERVER_LOG}

		echo "    " >> ${INIT_SERVER_LOG}
		echo "初始化代码推送线上服务器完成，正在进行解压缩，并执行初始化流程" >> ${INIT_SERVER_LOG}
		echo "    " >> ${INIT_SERVER_LOG}

		ssh -p $SSH_PORT $4@$5 "cd ${3};sudo tar zxvf lz_soft.tar.gz;sudo rm -f lz_soft.tar.gz;cd lz_soft;sudo chown root:root start.sh;sudo chmod +rx start.sh;sudo sh start.sh;cd ../;sudo rm -rf lz_soft;" >> ${INIT_SERVER_LOG}

		rm -f lz_soft.tar.gz;
	else
		tar zcvf soft.tar.gz soft >> ${INIT_SERVER_LOG}

		rsync -av --progress -e "ssh -c arcfour -p ${SSH_PORT}" soft.tar.gz $4@$5:$3 >> ${INIT_SERVER_LOG}

		echo "    " >> ${INIT_SERVER_LOG}
		echo "初始化代码推送线上服务器完成，正在进行解压缩，并执行初始化流程" >> ${INIT_SERVER_LOG}
		echo "    " >> ${INIT_SERVER_LOG}

		ssh -p $SSH_PORT $4@$5 "cd ${3};sudo tar zxvf soft.tar.gz;sudo rm -f soft.tar.gz;cd soft;sudo chown root:root start.sh;sudo chmod +rx start.sh;sudo sh start.sh;cd ../;sudo rm -rf soft;" >> ${INIT_SERVER_LOG}

		rm -f soft.tar.gz;
	fi

	echo "-------服务器： $1 $2 初始化完成-------" >> ${INIT_SERVER_LOG}
}

# 检出代码
function checkoutCode() {

	echo "    " >> ${PUBLISH_LOG}
	echo "代码检出" >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}

	if [[ -d ${CODE_CHECKOUT_DIR}$1/$2/trunk ]]; then
		if [ "$(ls ${CODE_CHECKOUT_DIR}$1/$2/trunk)null" == "null" ]; then
			echo ${CODE_CHECKOUT_DIR}$1/$2/ >> ${PUBLISH_LOG}
			cd ${CODE_CHECKOUT_DIR}$1/$2/
			echo svn co $4 >> ${PUBLISH_LOG}
			svn co $4 --username=$5 --password=$6 >> ${PUBLISH_LOG}
		else
			echo cd ${CODE_CHECKOUT_DIR}$1/$2/trunk >> ${PUBLISH_LOG}
			cd ${CODE_CHECKOUT_DIR}$1/$2/trunk
			#git pull origin master
			svn up >> ${PUBLISH_LOG}
			cd ${CODE_CHECKOUT_DIR}$1/$2/
		fi
	else
		echo mkdir -p ${CODE_CHECKOUT_DIR}$1/$2 >> ${PUBLISH_LOG}
		mkdir -p ${CODE_CHECKOUT_DIR}$1/$2
		echo cd ${CODE_CHECKOUT_DIR}$1/$2 >> ${PUBLISH_LOG}
		cd ${CODE_CHECKOUT_DIR}$1/$2
		#git clone $3 origin master
		echo svn co $4 >> ${PUBLISH_LOG}
		svn co $4 --username=$5 --password=$6 --non-interactive >> ${PUBLISH_LOG}
	fi

	# 创建打包目录
	if [ ! -d "${CODE_TAR_DIR}$1/$2" ]; then
		echo mkdir -p ${CODE_TAR_DIR}$1/$2 >> ${PUBLISH_LOG}
		mkdir -p ${CODE_TAR_DIR}$1/$2;
	fi

	# 打包的文件名
	PUBLISH_CODE_PACKAGE_NAME="${3}.tar.gz";

	echo rm -rf ${CODE_TAR_DIR}$1/$2/* >> ${PUBLISH_LOG}
	rm -rf ${CODE_TAR_DIR}$1/$2/*;
	
	echo cp -rf ./trunk/* ${CODE_TAR_DIR}$1/$2 >> ${PUBLISH_LOG}
	cp -rf ./trunk/* ${CODE_TAR_DIR}$1/$2;

	echo cd ${CODE_TAR_DIR}$1/$2 >> ${PUBLISH_LOG}
	cd ${CODE_TAR_DIR}$1/$2;

	#去掉.git或.svn文件夹命令
	#find . -type d -name ".git"|xargs rm -rf
	find . -type d -name ".svn"|xargs rm -rf
}

# 替换所发布平台的配置文件
function changeConfigFile() {

	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "-------服务器： $1_$3 -------    开始替换配置文件" >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}

	cd ${CODE_TAR_DIR}$1/$2;
	
	# 创建打包目录
	if [ ! -d "${CODE_TAR_PLATFORM_DIR}$1/$2/$3" ]; then
		echo mkdir -p ${CODE_TAR_PLATFORM_DIR}$1/$2/$3 >> ${PUBLISH_LOG}
		mkdir -p ${CODE_TAR_PLATFORM_DIR}$1/$2/$3;
	fi

	echo rm -rf ${CODE_TAR_PLATFORM_DIR}$1/$2/$3/* >> ${PUBLISH_LOG}
	rm -rf ${CODE_TAR_PLATFORM_DIR}$1/$2/$3/*;

	echo cp -rf ./* ${CODE_TAR_PLATFORM_DIR}$1/$2/$3 >> ${PUBLISH_LOG}
	cp -rf ./* ${CODE_TAR_PLATFORM_DIR}$1/$2/$3;

	echo cd ${CODE_TAR_PLATFORM_DIR}$1/$2/$3 >> ${PUBLISH_LOG}
	cd ${CODE_TAR_PLATFORM_DIR}$1/$2/$3;

	if [[ $1 == "lz" ]]; then
		if [[ "$(echo $3 | grep 'appstore')null" != "null" ]]; then
			echo "-------服务器： $3 -------    Appstore配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_appstore/* xml/;
			cp -f jar_appstore/game.jar game.jar;
			cp -rf script_v1.4/* script/;
			if [[ "$(echo $3 | grep 'appstore_new')null" != "null" ]]; then
				echo "-------服务器： $3 -------    Appstore_new配置rechagreConfig覆盖成功" >> ${PUBLISH_LOG}
				cp -f xml/rechargeConfig/rechargeConfig_ios_appstore_new.xml xml/rechargeConfig/rechargeConfig_ios_appstore.xml
				cp -f xml/monthlyCardConfig_new.xml xml/monthlyCardConfig.xml
			fi
		fi
		
		if [[ "$(echo $3 | grep 'android_ios_test')null" != "null" ]]; then
			echo "-------服务器： $3 -------    测试服配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_test/* xml/;
			cp -f jar_test/game.jar game.jar;
			cp -rf script_v1.4/* script/;
		fi

		if [[ "$(echo $3 | grep 'test_v1.5_1')null" != "null" ]]; then
			echo "-------服务器： $3 -------    测试服V1.5配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_test_v1.5/* xml/;
			cp -f jar_test_v1.5/game.jar game.jar;
			cp -rf script_v1.5/* script/;
		fi

		if [[ "$(echo $3 | grep 'ios_all')null" != "null" ]]; then
			echo "-------服务器： $3 -------    IOS服配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_android/* xml/;
			cp -f jar_android/game.jar game.jar;
			cp -rf script_v1.5/* script/;
		fi

		if [[ "$(echo $3 | grep 'android_all')null" != "null" ]]; then
			echo "-------服务器： $3 -------    Android服配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_android/* xml/;
			cp -f jar_android/game.jar game.jar;
			cp -rf script_v1.5/* script/;
		fi

		if [[ "$(echo $3 | grep 'tw_all')null" != "null" ]]; then
			echo "-------服务器： $3 -------    海外tw服配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_tw/* xml/;
			cp -f jar_tw/game.jar game.jar;
			cp -rf script_v1.5/* script/;
		fi

		if [[ "$(echo $3 | grep 'tw_test')null" != "null" ]]; then
			echo "-------服务器： $3 -------    海外tw测试服配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_test_tw/* xml/;
			cp -f jar_test_tw/game.jar game.jar;
			cp -rf script_v1.5/* script/;
		fi

		if [[ "$(echo $3 | grep 'tw_app_test')null" != "null" ]]; then
			echo "-------服务器： $3 -------    海外twapp测试服配置覆盖" >> ${PUBLISH_LOG}
			cp -rf xml_test_tw_app/* xml/;
			cp -f jar_test_tw_app/game.jar game.jar;
			cp -rf script_v1.5/* script/;
		fi
		
		cp -f dbconfig/${3}.xml cfg/config.xml;
		cp -f serverConfig/${3}.xml xml/serverConfig.xml;

		rm -rf dbconfig/ serverConfig/ xml_test_tw_app/ jar_test_tw_app/ xml_appstore/ xml_ios/ xml_android/ xml_test/ jar_appstore/ jar_test/ jar_ios/ jar_android/ xml_test_v1.5/ jar_test_v1.5/ script_v1.5/ script_v1.4/ xml_tw/ jar_tw/ xml_test_tw/ jar_test_tw/ ;
	elif [[ $1 == "hwgj" ]]; then
		echo "-------服务器： $1 ------- 目录筛选" >> ${PUBLISH_LOG}		
		
		if [[ "$(echo $3 | grep 'Efun_test_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Efun_test_all配置覆盖" >> ${PUBLISH_LOG}
			mv Efun_test_all/* ../$3;
			mv game.jar game_efun.jar;
		elif [[ "$(echo $3 | grep 'R2_test_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    R2_test_all配置覆盖" >> ${PUBLISH_LOG}
			mv R2_test_all/* ../$3;
			mv game.jar game_r2.jar;
		elif [[ "$(echo $3 | grep 'gNetop_test_android')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    gNetop_test_android配置覆盖" >> ${PUBLISH_LOG}
			mv gNetop_test_android/* ../$3;
			mv game.jar game_jp_and.jar;	
		elif [[ "$(echo $3 | grep 'R2_dev_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    R2_dev_all配置覆盖" >> ${PUBLISH_LOG}
			mv R2_dev_all/* ../$3;
			mv game.jar game_R2_dev_all.jar;		
		elif [[ "$(echo $3 | grep 'gNetop_test_ios')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    gNetop_test_ios配置覆盖" >> ${PUBLISH_LOG}
			mv gNetop_test_ios/* ../$3;
			mv game.jar game_jp_ios.jar;		
		elif [[ "$(echo $3 | grep 'Efun_dev_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Efun_dev_all配置覆盖" >> ${PUBLISH_LOG}
			mv Efun_dev_all/* ../$3;
			mv game.jar game_Efun_dev_all.jar;
		elif [[ "$(echo $3 | grep 'Entermate_test_android')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Entermate_test_android配置覆盖" >> ${PUBLISH_LOG}
			mv Entermate_test_android/* ../$3;
			mv game.jar game_entermate_and.jar;	
		elif [[ "$(echo $3 | grep 'Entermate_test_ios')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Entermate_test_ios配置覆盖" >> ${PUBLISH_LOG}
			mv Entermate_test_ios/* ../$3;
			mv game.jar game_entermate_ios.jar;	
		elif [[ "$(echo $3 | grep 'Entermate_dev_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Entermate_dev_all配置覆盖" >> ${PUBLISH_LOG}
			mv Entermate_dev_all/* ../$3;
		        #mv game.jar game_entermate_developing.jar;		
		elif [[ "$(echo $3 | grep 'Efun_online_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Efun_online_all配置覆盖" >> ${PUBLISH_LOG}
			mv Efun_online_all/* ../$3;
		elif [[ "$(echo $3 | grep 'Entermate_online_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Entermate_online_all配置覆盖" >> ${PUBLISH_LOG}
			mv Entermate_online_all/* ../$3;
		elif [[ "$(echo $3 | grep 'Entermate_test_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Entermate_test_all配置覆盖" >> ${PUBLISH_LOG}
			mv Entermate_test_all/* ../$3;
			mv game.jar game_Entermate_test_all.jar;		
		elif [[ "$(echo $3 | grep 'gNetop_online_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    gNetop_online_all配置覆盖" >> ${PUBLISH_LOG}
			mv gNetop_online_all/* ../$3;
		elif [[ "$(echo $3 | grep 'R2_online_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    R2_online_all配置覆盖" >> ${PUBLISH_LOG}
			mv R2_online_all/* ../$3;
		elif [[ "$(echo $3 | grep 'Entermate_shen_ios')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Entermate_shen_ios配置覆盖" >> ${PUBLISH_LOG}
			mv Entermate_shen_ios/* ../$3;
		elif [[ "$(echo $3 | grep 'R2_shen_ios')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    R2_shen_ios配置覆盖" >> ${PUBLISH_LOG}
			mv R2_shen_ios/* ../$3;
		elif [[ "$(echo $3 | grep 'gNetop_dev_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    gNetop_dev_all配置覆盖" >> ${PUBLISH_LOG}
			mv gNetop_dev_all/* ../$3;
			mv game.jar game_gNetop_dev_all.jar;
		elif [[ "$(echo $3 | grep 'Efun_shen_ios')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    Efun_shen_ios配置覆盖" >> ${PUBLISH_LOG}
			mv Efun_shen_ios/* ../$3;
		elif [[ "$(echo $3 | grep 'gNetop_shen_ios')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    gNetop_shen_ios" >> ${PUBLISH_LOG}
			mv gNetop_shen_ios/* ../$3;
		elif [[ "$(echo $3 | grep 'gNetop_online_ios')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    gNetop_online_ios配置覆盖" >> ${PUBLISH_LOG}
			echo mv gNetop_online_ios/* ../$3 >> ${PUBLISH_LOG}
			mv gNetop_online_ios/* ../$3;
		elif [[ "$(echo $3 | grep 'R2AR_online_all')null" != "null" ]]; then
			echo "-------服务器： $1_$3 -------    R2AR_online_all配置覆盖" >> ${PUBLISH_LOG}
			mv R2AR_online_all/* ../$3;
		fi
		
	        #rm -rf lib/;
		echo rm -rf All_* Efun_* Entermate_* gNetop_* R2_* R2multLang_* readme.txt t_* >> ${PUBLISH_LOG}
		rm -rf All_* Efun_* Entermate_* gNetop_* R2_* R2multLang_* readme.txt t_*; 
	fi
}

# 代码压缩打包
function packageTar() {

	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "-------服务器： $3 -------    开始打包压缩" >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}

	echo cd ${CODE_TAR_PLATFORM_DIR}$1/$2/$3 >> ${PUBLISH_LOG}
	cd ${CODE_TAR_PLATFORM_DIR}$1/$2/$3;

	#压缩
	echo tar zcf ${PUBLISH_CODE_PACKAGE_NAME} ./* >> ${PUBLISH_LOG}
	tar zcf ${PUBLISH_CODE_PACKAGE_NAME} ./*

	# 创建打包目录
	if [ ! -d "${PUBLISH_PACKAGE_DIR}$1/$2/$3" ]; then
		echo mkdir -p ${PUBLISH_PACKAGE_DIR}$1/$2/$3 >> ${PUBLISH_LOG}
		mkdir -p ${PUBLISH_PACKAGE_DIR}$1/$2/$3;
	fi

	# 把压缩包移到推送目录
	echo mv ${PUBLISH_CODE_PACKAGE_NAME} ${PUBLISH_PACKAGE_DIR}$1/$2/$3/${PUBLISH_CODE_PACKAGE_NAME} >> ${PUBLISH_LOG}
	mv ${PUBLISH_CODE_PACKAGE_NAME} ${PUBLISH_PACKAGE_DIR}$1/$2/$3/${PUBLISH_CODE_PACKAGE_NAME};
}

# 执行发布
function execPublishQueue() {
	# 队列格式：游戏名称 发布版本 区服 服务器web目录 服务器用户名 服务器ip 服务器端口号(lol release s2 /www/wwwroot/demacia/qimi/release/s2/ root 127.0.0.1 22)
	
	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "-------服务器： $3 -------    正在向线上服务器推送代码" >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}

	if [[ "${7}null" == "null" ]]; then
		SSH_PORT='22';
	else
		SSH_PORT=$7;
	fi
	ssh -p $SSH_PORT $5@$6 "sudo mkdir -p $4;sudo chown -R $5:$5 $4;" >> ${PUBLISH_LOG} < /dev/null
	cd ${PUBLISH_PACKAGE_DIR}$1/$2/$3;
	rsync -av --progress -e "ssh -c arcfour -p ${SSH_PORT}" $PUBLISH_CODE_PACKAGE_NAME $5@$6:$4 >> ${PUBLISH_LOG} < /dev/null
	echo "    " >> ${PUBLISH_LOG}
	echo "-------服务器： $3 -------    代码推送线上服务器完成，进行解压缩覆盖线上代码" >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	
	ssh -p $SSH_PORT $5@$6 "sudo chown -R root:root ${4};cd ${4};sudo tar zxf $PUBLISH_CODE_PACKAGE_NAME;sudo rm -f $PUBLISH_CODE_PACKAGE_NAME;" >> ${PUBLISH_LOG} < /dev/null
	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "-------服务器： $3 发布完成-------" >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
	echo "    " >> ${PUBLISH_LOG}
}

# 守护进程
while :
do

	# 初始化服务器队列存在则进行部署线上服务器
	if [ -f "$INIT_SERVER_QUEUE" ]; then 

		if [ -f "${INIT_SERVER_LOG}" ]; then 
			touch ${INIT_SERVER_LOG};
			chown www:www ${INIT_SERVER_LOG};
		fi

		echo "    " >> ${INIT_SERVER_LOG}
		echo "监控到部署服务器任务" >> ${INIT_SERVER_LOG}
		echo "    " >> ${INIT_SERVER_LOG}

		while read line 
		do 
			{
			execInitServerQueue $line;
			}&
		done < $INIT_SERVER_QUEUE;
		wait;

		rm -f $INIT_SERVER_QUEUE;

		if [ -f "$INIT_SERVER_LOG" ]; then 
			echo "初始化完成" >> ${INIT_SERVER_LOG}
			echo "SUCCESS" >> ${INIT_SERVER_LOG}
			sleep 2;
			mv -f $INIT_SERVER_LOG $INIT_SERVER_HISTORY_LOG;
			echo '初始化时间' >> $INIT_SERVER_HISTORY_LOG;
			echo `date +%Y%m%d_%H:%M` >> $INIT_SERVER_HISTORY_LOG;
			chown www:www $INIT_SERVER_HISTORY_LOG;
		fi
	fi

	# 发布队列存在才进行发布
	if [ -f "$PUBLISH_QUEUE" ]; then 
		
		if [ -f "${PUBLISH_LOG}" ]; then 
			touch ${PUBLISH_LOG};
			chown www:www ${PUBLISH_LOG};
		fi

		echo "    " >> ${PUBLISH_LOG}
		echo "监控到发布任务" >> ${PUBLISH_LOG}
		echo "    " >> ${PUBLISH_LOG}

		# 代码检出
		if [ -f "$PUBLISH_QUEUE_VERSION" ]; then 
			# 执行代码检出
			while read line 
			do 
				# $line格式：游戏名称 发布版本 包版本号 代码检出地址 svn账号 svn密码 (lol release 20140618151035 https://192.168.1.208/lol_server_compile/trunk forbidden 123456)
				checkoutCode $line;
			done < $PUBLISH_QUEUE_VERSION;
			wait;

			rm -f $PUBLISH_QUEUE_VERSION;
		fi

		echo "    " >> ${PUBLISH_LOG}
		echo "开始往各服务器推送代码" >> ${PUBLISH_LOG}
		echo "    " >> ${PUBLISH_LOG}

		# 计数器，用于记录当前同时有几个队列在发布中，每次同时最多能替换100个平台的配置文件
		m=0;

		# 循环发布队列逐个进行替换配置文件
		while read line 
		do 
			{
			# $line格式：游戏名称 发布版本 区服 服务器web目录 服务器用户名 服务器ip 服务器端口号(lol release s2 /www/wwwroot/demacia/qimi/release/s2/ root 127.0.0.1 22)
			changeConfigFile $line;
			}&
			if [ $m == $MAX_PUBLISH_QUEUE_NUMBER ]; then
				m=0;
				wait;
			else
				m=$(($m+1));
			fi
			
		done < $PUBLISH_QUEUE;
		wait;

		# 计数器，用于记录当前同时有几个队列在发布中，每次同时最多能打包100个平台
		k=0;

		# 循环发布队列逐个进行打包
		while read line 
		do 
			{
			# $line格式：游戏名称 发布版本 区服 服务器web目录 服务器用户名 服务器ip 服务器端口号(lol release s2 /www/wwwroot/demacia/qimi/release/s2/ root 127.0.0.1 22)
			packageTar $line;
			}&
			if [ $k == $MAX_PUBLISH_QUEUE_NUMBER ]; then
				k=0;
				wait;
			else
				k=$(($k+1));
			fi
			
		done < $PUBLISH_QUEUE;
		wait;

		# 计数器，用于记录当前同时有几个队列在发布中，每次同时最多能发布100个平台
		n=0;

		# 循环发布队列逐个进行打包
		while read line 
		do 
			{
			# $line格式：游戏名称 发布版本 区服 服务器web目录 服务器用户名 服务器ip 服务器端口号(lol release s2 /www/wwwroot/demacia/qimi/release/s2/ root 127.0.0.1 22)
			# 推送
			execPublishQueue $line;
			}&
			if [ $n == $MAX_PUBLISH_QUEUE_NUMBER ]; then
				n=0;
				wait;
			else
				n=$(($n+1));
			fi
			
		done < $PUBLISH_QUEUE;
		wait;

		rm -f $PUBLISH_QUEUE;

		if [ -f "$PUBLISH_LOG" ]; then 
			echo "发布完成" >> ${PUBLISH_LOG}
			echo "SUCCESS" >> ${PUBLISH_LOG}
			echo "共执行服务器数：" >> ${PUBLISH_LOG}
			cat ${PUBLISH_LOG} | grep "发布完成-------" | wc -l >> ${PUBLISH_LOG}
			echo "服务器执行列表：" >> ${PUBLISH_LOG}
			cat ${PUBLISH_LOG} | grep "发布完成-------" >> ${PUBLISH_LOG}
			sleep 2;
			mv -f $PUBLISH_LOG $PUBLISH_HISTORY_LOG;
			echo '发布时间' >> $PUBLISH_HISTORY_LOG;
			echo `date +%Y%m%d_%H:%M` >> $PUBLISH_HISTORY_LOG;
			chown www:www $PUBLISH_HISTORY_LOG;
		fi

	fi

	# 30s后再次监控是否有发布任务
	sleep $MONITOR_SLEEP_TIME;
done
