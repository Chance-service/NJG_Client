<?php
class Control_Gm_selectLeftDays {
	function selectLeftDays() {
		
		$selectServer 	= MooForm::request('selectServer');
		$playerId 	= MooForm::request('playerId');	// 可选
		
		$params = array();
		$userName = "admin";
		$params['playerId'] 	= $playerId;
	
		$serverUrl = $selectServer;
		
		$cmd = "monthCardInfo";
		$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
		
		$res = MooUtil::curl_send($url);
		$returnData = MooJson::decode($res, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = $returnData['msg'];
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = $returnData['msg'];
			$this->OBJ->showMessage($returnData);
		}
		
	}
}