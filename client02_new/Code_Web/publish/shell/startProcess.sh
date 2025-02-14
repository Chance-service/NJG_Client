#bin/bash

PUBLISH_SH_PATH="/mnt/data/www/wwwroot/lol_publish_center/shell"

# 文件是否存在
if [[ ! -f "${PUBLISH_SH_PATH}/publish.sh" ]]; then
        echo "${PUBLISH_SH_PATH}/publish.sh not exites"
        exit;
fi

if test $( pgrep -f 'publish.sh' | wc -l ) -eq 0
then 
        cd $PUBLISH_SH_PATH
        ./publish.sh &
        echo -e "\033[41;36m [publish] SUCCESS \033[0m"
else
        echo -e "\033[41;36m [publish] IS RUNNING \033[0m" 
fi

# 文件是否存在
if [[ ! -f "${PUBLISH_SH_PATH}/serverOnOff.sh" ]]; then
        echo "${PUBLISH_SH_PATH}/serverOnOff.sh not exites"
        exit;
fi

if test $( pgrep -f 'serverOnOff.sh' | wc -l ) -eq 0
then 
        cd $PUBLISH_SH_PATH
        ./serverOnOff.sh &
        echo -e "\033[41;36m [serverOnOff] SUCCESS \033[0m"
else
        echo -e "\033[41;36m [serverOnOff] IS RUNNING \033[0m" 
fi