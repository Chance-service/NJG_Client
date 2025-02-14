<?php
class Control_Gm_sendAward {
	function sendAward() {
		
		$game 		= MooForm::request('game');
		$server 	= MooForm::request('serverUrl');
		
		$awardMsg 	= MooForm::request('awardMsg');
		$awardInfo	= MooForm::request('awardInfo'); 
		$selectChannel	= MooForm::request('selectChannel');
		// 后台用户名
		$userName = MooObj::get('User')->getUserName();
		
		$sessionKey = $userName . '_playerid';
		$playerId = MooSession::get($userName . '_playerid');
		
		if(!$selectChannel && !$playerId) {
			$returnData['code'] = 0;
			$returnData['msg']  = '请先查询用户';
			$this->OBJ->showMessage($returnData);
		}
		
		$params = array();
		// 选择渠道 就是该渠道所有
		if($selectChannel) {
			$params['channel'] = $selectChannel;
		} else {
			$params['playerid'] = $playerId;
		}
		
		if ($awardMsg) {
			$params['message'] = $awardMsg;
		}
		if ($awardInfo) {
			$params['reward'] = $awardInfo;
		}
		
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
		if($serverLists) {
			$serverUrl = $serverLists[$server]['url'];
		}
		
		$cmd = "playerreward";
		$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
		
		$res = MooUtil::curl_send($url);
		$returnData = MooJson::decode($res, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = 'ok';
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = '发送失败';
			$this->OBJ->showMessage($returnData);
		}
		
	}
}