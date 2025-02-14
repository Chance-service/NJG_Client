<?php
class Control_ServerOnOff_showLog {

	function showLog() {
		
		$platformInfo = array();
		$platformList = MooObj::get('Publish')->getPlatformList();
		if ($platformList) {
			foreach ($platformList as $tmpInfo) {
				$platformInfo[$tmpInfo['id']] = $tmpInfo['name'];
			}
		}
		
		$logList = array();
		$logInfoList = MooObj::get('ServerOnOff')->getLogList();
		
		if ($logInfoList) {
			foreach ($logInfoList as $tmpInfo) {
				$tmp = array();
				$tmpInfo['dateTime'] = date('Y-m-d H:i:s', $tmpInfo['time']);
				unset($tmpInfo['time']);
				unset($tmpInfo['date']);
				$tmpArr = explode(',', $tmpInfo['platforms']);
				unset($tmpInfo['platforms']);
				foreach ($tmpArr as $pId) {
					$tmp[] = $platformInfo[$pId];
				}
				$tmpInfo['platformsName'] = implode(',', $tmp);
				if ($tmpInfo['type'] == 'on') {
					$tmpInfo['type'] = '开服' ;
				} elseif ($tmpInfo['type'] == 'off') {
					$tmpInfo['type'] = '关服';
				} else {
					$tmpInfo['type'] = '无缝重启服';
				}
				
				$logList[] = $tmpInfo;
			}
			
		}
		
		MooView::set('logList', $logList);
		MooView::render('serverOnOffLog');
	}
}