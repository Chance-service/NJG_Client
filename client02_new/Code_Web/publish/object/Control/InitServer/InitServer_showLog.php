<?php
class Control_InitServer_showLog {

	function showLog() {
		
		$platformInfo = array();
		$platformList = MooObj::get('Publish')->getPlatformList();
		if ($platformList) {
			foreach ($platformList as $tmpInfo) {
				$platformInfo[$tmpInfo['id']] = $tmpInfo['name'];
			}
		}
		
		$logList = array();
		$logInfoList = MooObj::get('InitServer')->getLogList();
		
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
			
				$logList[] = $tmpInfo;
			}
			
		}
		
		MooView::set('logList', $logList);
		MooView::render('initServerLog');
	}
}