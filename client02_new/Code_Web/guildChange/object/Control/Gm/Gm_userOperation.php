<?php
class Control_Gm_userOperation {
	function userOperation() {
		
		$actionId 	= MooForm::request('actionId');
		$userOperation = MooConfig::get('userOperation.action');
		$actionConf = $userOperation[$actionId];
		$game 	= MooForm::request('game');
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
		
		if($actionConf['type']) {
			$params['type'] = $actionConf['type'];
		}
		
		// getUrl
		$server 	= MooForm::request('serverUrl');
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
		if($serverLists) {
			$serverUrl = $serverLists[$server]['url'];
		}
		
		$cmd = $actionConf['cmd'];
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