<?php
class Control_Gm_sendServerAward {
	function sendServerAward() {
		$game 		= MooForm::request('game');
		$servers 	= MooForm::request('servers');
		
		if($servers) {
			$servers = substr($servers, 0, -1);
			$serversArr = explode(',', $servers);
		}
		
		$awardMsg 	= MooForm::request('awardMsg');
		$awardInfo	= MooForm::request('awardInfo'); 
		// 后台用户名
		$userName = MooObj::get('User')->getUserName();
		
		/*
		$sessionKey = $userName . '_playerid';
		$playerId = MooSession::get($userName . '_playerid');
		
		if(!$selectChannel && !$playerId) {
			$returnData['code'] = 0;
			$returnData['msg']  = '请先查询用户';
			$this->OBJ->showMessage($returnData);
		}
		*/
		
		$params = array();
		// 选择渠道 就是该渠道所有
		$params['playerid'] = -1;
		
		if ($awardMsg) {
			$params['message'] = $awardMsg;
		}
		if ($awardInfo) {
			$params['reward'] = $awardInfo;
		}
		
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
		$cmd = "playerreward";
		
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
		$log = ROOT_PATH . "/urlLogs/" . "sendServerAward.log." . $date;
		
		MooFile::write($log, date('Y-m-d H:i:s') ."--\n" . $allRes."\n", true);
		
		exit($allRes);
		
		/*
		MooFile::write('log.txt', $allRes, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = 'ok';
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = '发送失败';
			$this->OBJ->showMessage($returnData);
		}
		*/
	}
}