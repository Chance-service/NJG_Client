<?php
class Control_Gm_changePlayerInfo {
	function changePlayerInfo() {
		
		$game 	= MooForm::request('game');
		$key 	= MooForm::request('key');
		$value 	= MooForm::request('value');
		// 后台用户名
		$userName = MooObj::get('User')->getUserName();
		
		$sessionKey = $userName . '_playerid';
		$playerId = MooSession::get($userName . '_playerid');
		
		if(!$playerId) {
			$returnData['code'] = 0;
			$returnData['msg']  = '请先查询用户';
			$this->OBJ->showMessage($returnData);
		}
		
		$params = array();
		$params['playerid'] = $playerId;
		$params['value'] = $value;
		
		if($key == "vip") {
			$params['type'] = 3;
		} else if($key == "silver") {
			$params['type'] = 2;
			
		} else if($key == "golden") {
			$params['type'] = 1;
		}
		
		// getUrl
		$server 	= MooForm::request('serverUrl');
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
		if($serverLists) {
			$serverUrl = $serverLists[$server]['url'];
		}
		
		$cmd = "changeplayer";
		$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
		
		$res = MooUtil::curl_send($url);
		$returnData = MooJson::decode($res, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = 'ok';
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = '修改失败';
			$this->OBJ->showMessage($returnData);
		}
		
	}
}