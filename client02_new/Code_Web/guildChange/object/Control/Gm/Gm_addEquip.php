<?php
class Control_Gm_addEquip {
	function addEquip() {
		
		$game 		= MooForm::request('game');
		$server 	= MooForm::request('serverUrl');
		
		$equipId 	= MooForm::request('equipId');
		$equipNum	= MooForm::request('equipNum');
		$starlevel1 	= MooForm::request('starlevel1');
		$starlevel2		= MooForm::request('starlevel2'); 
		
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
		
		if ($equipId) {
			$params['equipid'] = $equipId;
		}
		if ($equipNum) {
			$params['strength'] = $equipNum;
		}
		if ($starlevel1) {
			$params['starlevel1'] = $starlevel1;
		}
		if ($starlevel2) {
			$params['starlevel2'] = $starlevel2;
		}
		
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
		if($serverLists) {
			$serverUrl = $serverLists[$server]['url'];
		}
		
		$cmd = "genequip";
		$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
		
		$res = MooUtil::curl_send($url);
		$returnData = MooJson::decode($res, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = 'ok';
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = '添加失败';
			$this->OBJ->showMessage($returnData);
		}
		
	}
}