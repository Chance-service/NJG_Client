#!/bin/bash

#服务器
SERVER="54.172.184.242";

#端口
SSH_PORT=22;

#用户名
SSH_USER="publish";

#发布的路径
SER_PATH="/data/nginx/htdocs/"$1;

#打包的报名称
PACK_NAME="r2CDN"$1;

#shell路径
SHELL_PATH="/data/wwwroot/publish/cdnPub/";

echo "代码检出"

cd ${SHELL_PATH}cdnCheckoutDir/publish_CDN;

svn up;

echo "移动到打包目录"

cp -rf ./$1 ../../cdnTarDir/;

cd ../../cdnTarDir/$1;

echo "打压缩包"

find . -type d -name ".svn"|xargs rm -rf

tar zcf $PACK_NAME.tar.gz ./*

echo "移动压缩包到推送目录"

mv $PACK_NAME.tar.gz ../../cdnRsyncDir/

cd ../../cdnRsyncDir/

#登录服务器修改 指定目录 服务器权限
ssh -p $SSH_PORT $SSH_USER@$SERVER "sudo chown -R $SSH_USER:$SSH_USER $SER_PATH";
#ssh -p 22 publish@54.172.184.242 "sudo chown -R publish:publish /data/nginx/htdocs/android_R2Game_ar";
echo "推送到服务器"
#推送tar.gz 代码
rsync -av --progress -e "ssh -c arcfour -p ${SSH_PORT}" $PACK_NAME.tar.gz publish@$SERVER:$SER_PATH
#rsync -av --progress -e "ssh -c arcfour -p 22" r2CDNandroid_R2Game_ar.tar.gz publish@54.172.184.242:/data/nginx/htdocs/android_R2Game_ar
echo "登录服务器解压缩"
#登录服务器修改完成
ssh -p $SSH_PORT $SSH_USER@$SERVER "sudo chown -R root:root $SER_PATH;cd $SER_PATH;sudo tar zxf $PACK_NAME.tar.gz;sudo rm -f $PACK_NAME.tar.gz;sudo sh /data/nginx/htdocs/purge-all.sh"
ssh -p 22 publish@54.172.184.242 "sudo chown -R root:root /data/nginx/htdocs/android_R2Game_ar;cd /data/nginx/htdocs/android_R2Game_ar;sudo tar zxf r2CDNandroid_R2Game_ar.tar.gz;sudo rm -f r2CDNandroid_R2Game_ar.tar.gz;sudo sh /data/nginx/htdocs/purge-all.sh"

echo "发布完成"





