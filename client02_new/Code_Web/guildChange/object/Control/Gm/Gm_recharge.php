<?php
class Control_Gm_recharge {
	function recharge() {
		
		$game 		= MooForm::request('game');
		$server 	= MooForm::request('serverUrl');
		$channel 	= MooForm::request('channel');	// 可选
		$goodsId 	= MooForm::request('goodsId');
		
		$orderId 		= MooForm::request('orderId');
		$rechargeMoney 	= MooForm::request('rechargeMoney');
		// 后台用户名
		$userName = MooObj::get('User')->getUserName();
		
		$sessionKey = $userName . '_playerid';
		$playerId = MooSession::get($userName . '_playerid');
		
		if(!$channel && !$playerId) {
			$returnData['code'] = 0;
			$returnData['msg']  = '请先查询用户';
			$this->OBJ->showMessage($returnData);
		}
		
		$params = array();
		if ($channel) {
			$params['platform'] = $channel;
		} else {
			$params['playerid'] = $playerId;
		}
		
		if ($goodsId) {
			$params['goodsId'] = $goodsId;
		}
		if ($orderId) {
			$params['orderSerial'] = $orderId;
		}
		if ($rechargeMoney) {
			$params['rechargeNum'] = $rechargeMoney;
		}
		
		$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
		if($serverLists) {
			$serverUrl = $serverLists[$server]['url'];
		}
		
		$cmd = "recharge";
		$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
		
		$res = MooUtil::curl_send($url);
		$returnData = MooJson::decode($res, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = 'ok';
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = '充值失败';
			$this->OBJ->showMessage($returnData);
		}
		
	}
}