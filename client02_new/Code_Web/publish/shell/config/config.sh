#!/bin/bash

# 发布系统web根目录
PUBLISH_WEB_DIR="/www/wwwroot/cdn/";

#svn 检出地址
SVN_CHECK_ADD="https://203.195.147.186/publish_server/trunk/t_sqls";

#svn 用户名
SVN_CHECK_USER="publish";

#svn 密码
SVN_CHECK_PWD="fvGUkh#tg@jilm!";

# 发布日志
PUBLISH_LOG_DIR="${PUBLISH_WEB_DIR}www/cdn_publishLog/";
PUBLISH_LOG="${PUBLISH_LOG_DIR}cdn_publish.log";
PUBLISH_HISTORY_LOG="${PUBLISH_LOG_DIR}cdn_publish_history.log";

# shell脚本放置目录
PUBLISH_SHELL_DIR="${PUBLISH_WEB_DIR}shell/";

# 代码检出的目录
CODE_CHECKOUT_DIR="${PUBLISH_SHELL_DIR}cdn_CheckoutDir/";

# 代码打包的目录
CODE_TAR_DIR="${PUBLISH_SHELL_DIR}cdn_codeTarDir/";
CODE_TAR_PLATFORM_DIR="${PUBLISH_SHELL_DIR}cdn_TarPlatformDir/";

# 代码压缩包放置的目录
PUBLISH_PACKAGE_DIR="${PUBLISH_SHELL_DIR}cdn_package/";

# 发布队列存放的目录和文件
PUBLISH_MONITOR_DIR="${PUBLISH_WEB_DIR}www/cdn_publishQueueMonitor/";
PUBLISH_QUEUE="${PUBLISH_MONITOR_DIR}cdn_queue.log";
PUBLISH_QUEUE_VERSION="${PUBLISH_MONITOR_DIR}cdn_queueVersion.log";


# 创建发布队列存放的目录
if [ ! -d "$PUBLISH_MONITOR_DIR" ]; then 
	mkdir -p "$PUBLISH_MONITOR_DIR";
	chown -R www:www $PUBLISH_MONITOR_DIR;
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

# 创建发布记录文件放置的目录
if [ ! -d "$PUBLISH_LOG_DIR" ]; then 
	mkdir -p "$PUBLISH_LOG_DIR";
	chown -R www:www $PUBLISH_LOG_DIR;
fi