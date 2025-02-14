<?php
class Control_Gm_changeLeader {
	function changeLeader() {
		
		$selectServer 	= MooForm::request('selectServer');
		$allianceId 	= MooForm::request('allianceId');	// 可选
		$leaderId 		= MooForm::request('leaderId');
		
		$params = array();
		$userName = "admin";
		$params['allianceId'] = $allianceId;
		$params['leaderId']   = $leaderId;
	
		$serverUrl = $selectServer;
		
		$cmd = "exchangeAllianceL";
		$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
		
		$res = MooUtil::curl_send($url);
		$returnData = MooJson::decode($res, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = 'ok';
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = $returnData['msg'];;
			$this->OBJ->showMessage($returnData);
		}
		
	}
}