<?php
class Control_Gm_changeGuildExp {
	function changeGuildExp() {
		
		$selectServer 	= MooForm::request('selectServer');
		$allianceId 	= MooForm::request('allianceId');	// 可选
		$addExp			= MooForm::request('addExp');
		
		$params = array();
		$userName = "admin";
		$params['allianceId'] 	= $allianceId;
		$params['exp']   		= $addExp;
	
		$serverUrl = $selectServer;
		
		$cmd = "addallianceexp";
		$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
		
		$res = MooUtil::curl_send($url);
		$returnData = MooJson::decode($res, true);
		if($returnData['status'] == 1) {
			$returnData['code'] = 1;
			$returnData['msg']  = 'ok';
			$this->OBJ->showMessage($returnData);
		} else {
			$returnData['code'] = 2;
			$returnData['msg']  = $returnData['msg'];
			$this->OBJ->showMessage($returnData);
		}
		
	}
}