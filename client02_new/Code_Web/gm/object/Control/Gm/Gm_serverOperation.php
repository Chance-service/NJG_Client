<?php
class Control_Gm_serverOperation {
	function serverOperation() {
		
		$actionId 	= MooForm::request('actionId');
		$userOperation = MooConfig::get('serverOperation.action');
		$actionConf = $userOperation[$actionId];
		$game 	= MooForm::request('game');
		// 后台用户名
		$userName = MooObj::get('User')->getUserName();
	
		$params = array();
		// getUrl
		$servers 	= MooForm::request('servers');
		if($servers) {
			$servers = substr($servers, 0, -1);
			$serversArr = explode(',', $servers);
		}
		
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
		
		$cmd = $actionConf['cmd'];
		$allRes = "";
		if($serversArr) {
			foreach($serversArr as $key => $server) {
				if($serverLists) {
					$serverUrl = $serverLists[$server]['url'];
					$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
					$res = MooUtil::curl_send($url);
					$returnData = MooJson::decode($res, true);
					if($returnData['status'] == 1) {
						$msg = "success";
					} else {
						$msg = "fail";
					}
					if(!$allRes) {
						$allRes = $server . ":" . $msg . "\n";
					} else {
						$allRes = $server . ":" . $msg . "\n" . $allRes;
					}
				}
			}
		}
		
		$date = date("Y-m-d");
		$log = ROOT_PATH . "/urlLogs/" .$cmd.".log." . $date;
		MooFile::write($log, date('Y-m-d H:i:s') ."--\n" . $allRes."\n", true);
		exit($allRes);
	}
}