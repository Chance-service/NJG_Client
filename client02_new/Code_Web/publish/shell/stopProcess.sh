#bin/bash

PUBLISH_SH_PATH="/mnt/data/www/wwwroot/lol_publish_center"

if test $( pgrep -f 'publish.sh' | wc -l ) -eq 0
then 
        echo -e "\033[41;36m [publish] NO START \033[0m"
else
	kill $(pgrep -f 'publish.sh')
	cd ${PUBLISH_SH_PATH}/shell
	rm -rf codeCheckoutDir codeTarDir codeTarPlatformDir package
	cd ${PUBLISH_SH_PATH}/www
	rm -rf initServerLog initServerQueueMonitor publishLog publishQueueMonitor serverOnOffLog serverOnOffQueueMonitor
        echo -e "\033[41;36m [publish] IS STOP \033[0m" 
fi

if test $( pgrep -f 'serverOnOff.sh' | wc -l ) -eq 0
then 
        echo -e "\033[41;36m [serverOnOff] NO START \033[0m"
else
	kill $(pgrep -f 'serverOnOff.sh')
	cd ${PUBLISH_SH_PATH}/shell
	rm -rf codeCheckoutDir codeTarDir codeTarPlatformDir package
	cd ${PUBLISH_SH_PATH}/www
	rm -rf initServerLog initServerQueueMonitor publishLog publishQueueMonitor serverOnOffLog serverOnOffQueueMonitor
        echo -e "\033[41;36m [serverOnOff] IS STOP \033[0m" 
fi
