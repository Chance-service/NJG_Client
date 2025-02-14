<?php
class Mod_MooGame_PlatForm_Qimi_checkPay {

	public function checkPay($userId, $orderId) {

		$qimi = Mod_MooGame_PlatForm::$platFormLibObj;
		//$param['session_key'] = $hashData['sessionId'];
		
		$param['userId'] = $userId;
		$param['orderId'] = $orderId;
		//$param['pay_type'] = $payType;

		$rs = $qimi->pay('checkOrder', $param);

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Qimi_checkPay no data');
			return false;
		}

		// 一个用户返回值
		$userInfo = $rs['data'];

		$data = array();
		$data['status'] = 100;
		$data['uId'] = $userInfo['uid'] . '__' . $this->MOD->platFormLabel;
		$data['appId'] = $userInfo['app_id'];
		$data['appZoneId'] = $userInfo['app_zoneid'];
		$data['appServerId'] = $userInfo['app_serverid'];
		$data['payAmt'] = $userInfo['pay_amt'];
		$data['dateline'] = $userInfo['dateline'];
		$data['uPlatFormUid'] = $userInfo['uid'];

		return $data;
	}
}
