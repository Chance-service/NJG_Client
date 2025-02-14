#bin/bash
#韩国ftp执行 android ios

#shell路径
SHELL_PATH="/data/wwwroot/publish/cdnPub/";

cd ${SHELL_PATH}cdnCheckoutDir/publish_CDN;

echo "代码检出"

svn up;

echo "移动到打包目录"

rm -rf ../../cdnTarDir/$1;

cp -rf ./* ../../cdnTarDir/;

cd ../../cdnTarDir;

echo "打压缩包"

find . -type d -name ".svn"|xargs rm -rf

echo "移动压缩包到svn推送目录"

cp -rf ./$1 ../cdnRsyncDir;

cd ../;

echo "推送文件";

aws s3 sync ${SHELL_PATH}cdnRsyncDir/$1 s3://origin.mud/$1

echo $1"_cdn生效完成";
