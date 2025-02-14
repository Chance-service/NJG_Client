#!/bin/bash

# 每次最大发送的队列数
MAX_PUBLISH_QUEUE_NUMBER=50;

# 每隔多少时间监控是否存在发布任务
MONITOR_SLEEP_TIME=10;

# 发布系统web根目录
PUBLISH_WEB_DIR="/mnt/data/www/wwwroot/lol_publish_center/";



# 初始化服务器日志
INIT_SERVER_LOG_DIR="${PUBLISH_WEB_DIR}www/initServerLog/";
INIT_SERVER_LOG="${INIT_SERVER_LOG_DIR}initServer.log";
INIT_SERVER_HISTORY_LOG="${INIT_SERVER_LOG_DIR}initServer_history.log";

# 发布日志
PUBLISH_LOG_DIR="${PUBLISH_WEB_DIR}www/publishLog/";
PUBLISH_LOG="${PUBLISH_LOG_DIR}publish.log";
PUBLISH_HISTORY_LOG="${PUBLISH_LOG_DIR}publish_history.log";

# 开停服日志
SERVER_ON_OFF_LOG_DIR="${PUBLISH_WEB_DIR}www/serverOnOffLog/";
SERVER_ON_OFF_LOG="${SERVER_ON_OFF_LOG_DIR}serverOnOff.log";
SERVER_ON_OFF_HISTORY_LOG="${SERVER_ON_OFF_LOG_DIR}serverOnOff_history.log";

# shell脚本放置目录
PUBLISH_SHELL_DIR="${PUBLISH_WEB_DIR}shell/";

# 代码检出的目录
CODE_CHECKOUT_DIR="${PUBLISH_SHELL_DIR}codeCheckoutDir/";

# 代码打包的目录
CODE_TAR_DIR="${PUBLISH_SHELL_DIR}codeTarDir/";
CODE_TAR_PLATFORM_DIR="${PUBLISH_SHELL_DIR}codeTarPlatformDir/";

# 代码压缩包放置的目录
PUBLISH_PACKAGE_DIR="${PUBLISH_SHELL_DIR}package/";

# 初始化服务器队列存放的目录和文件
INIT_SERVER_MONITOR_DIR="${PUBLISH_WEB_DIR}www/initServerQueueMonitor/";
INIT_SERVER_QUEUE="${INIT_SERVER_MONITOR_DIR}$1_queue.log";

# 发布队列存放的目录和文件
PUBLISH_MONITOR_DIR="${PUBLISH_WEB_DIR}www/publishQueueMonitor/";
PUBLISH_QUEUE="${PUBLISH_MONITOR_DIR}$1_queue.log";
PUBLISH_QUEUE_VERSION="${PUBLISH_MONITOR_DIR}$1_queueVersion.log";

# 开停服队列存放的目录和文件
SERVER_ON_OFF_MONITOR_DIR="${PUBLISH_WEB_DIR}www/serverOnOffQueueMonitor/";
SERVER_ON_OFF_QUEUE="${SERVER_ON_OFF_MONITOR_DIR}$1_queue.log";

# 创建初始化服务器队列存放的目录
if [ ! -d "$INIT_SERVER_MONITOR_DIR" ]; then 
	mkdir -p "$INIT_SERVER_MONITOR_DIR";
	chown -R www:www $INIT_SERVER_MONITOR_DIR;
fi

# 创建发布队列存放的目录
if [ ! -d "$PUBLISH_MONITOR_DIR" ]; then 
	mkdir -p "$PUBLISH_MONITOR_DIR";
	chown -R www:www $PUBLISH_MONITOR_DIR;
fi

# 创建开停服队列存放的目录
if [ ! -d "$SERVER_ON_OFF_MONITOR_DIR" ]; then 
	mkdir -p "$SERVER_ON_OFF_MONITOR_DIR";
	chown -R www:www $SERVER_ON_OFF_MONITOR_DIR;
fi

# 创建代码检出的目录
if [ ! -d "$CODE_CHECKOUT_DIR" ]; then 
	mkdir -p "$CODE_CHECKOUT_DIR";
fi

# 创建代码打包的目录
if [ ! -d "$CODE_TAR_DIR" ]; then 
	mkdir -p "$CODE_TAR_DIR";
fi
if [ ! -d "$CODE_TAR_PLATFORM_DIR" ]; then 
	mkdir -p "$CODE_TAR_PLATFORM_DIR";
fi

# 创建代码包放置的目录
if [ ! -d "$PUBLISH_PACKAGE_DIR" ]; then 
	mkdir -p "$PUBLISH_PACKAGE_DIR";
fi

# 创建初始化服务器记录文件放置的目录
if [ ! -d "$INIT_SERVER_LOG_DIR" ]; then 
	mkdir -p "$INIT_SERVER_LOG_DIR";
	chown -R www:www $INIT_SERVER_LOG_DIR;
fi

# 创建发布记录文件放置的目录
if [ ! -d "$PUBLISH_LOG_DIR" ]; then 
	mkdir -p "$PUBLISH_LOG_DIR";
	chown -R www:www $PUBLISH_LOG_DIR;
fi

# 创建开停服记录文件放置的目录
if [ ! -d "$SERVER_ON_OFF_LOG_DIR" ]; then 
	mkdir -p "$SERVER_ON_OFF_LOG_DIR";
	chown -R www:www $SERVER_ON_OFF_LOG_DIR;
fi
