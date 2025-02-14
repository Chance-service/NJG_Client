<?php
class Control_Gm_broadcast {
	function broadcast() {
		$game 		= MooForm::request('game');
		$servers 	= MooForm::request('servers');
		if($servers) {
			$servers = substr($servers, 0, -1);
			$serversArr = explode(',', $servers);
		}
		
		$message 	= MooForm::request('message');
		$broadType 	= MooForm::request('type');
		if($broadType == "chat") {
			$type = 2;
		} else if($broadType == "broad") {
			$type = 3;
		}
		// 后台用户名
		$userName = MooObj::get('User')->getUserName();
		
		$params = array();
		// 选择渠道 就是该渠道所有
		if ($message) {
			$params['message'] = $message;
		}
		$params['type'] = $type;
		
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
		if($serverLists) {
			$serverUrl = $serverLists[$server]['url'];
		}
		
		$cmd = "broadcast";
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
		$log = ROOT_PATH . "/urlLogs/" . "broadcast_".$broadType.".log." . $date;
		MooFile::write($log, date('Y-m-d H:i:s') ."--\n" . $allRes."\n", true);
		exit($allRes);
	}
}