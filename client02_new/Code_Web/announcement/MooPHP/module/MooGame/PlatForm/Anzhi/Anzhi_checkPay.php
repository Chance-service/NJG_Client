<?php
class Mod_MooGame_PlatForm_Anzhi_checkPay {

	public function checkPay($orderId) {

		$anzhi = Mod_MooGame_PlatForm::$platFormLibObj;
		
		$param['type'] = 0;
		$param['tradenum'] = $orderId;
		$param['mintradetime'] = '';
		$param['maxtradetime'] = '';

		$rs = $anzhi->pay('checkOrder', $param);

		if ($rs['sc'] != 200) {
			if ($rs['sc'] != 1) {
				$this->MOD->setMsg('Mod_MooGame_PlatForm_Anzhi_getVisitorInfo no data');
				return false;
			}
		}
		
		$data = array();
		$orderInfo = base64_decode($rs['msg']);
		$orderInfo = str_replace("'", '"', $orderInfo);
		$orderInfo = json_decode($orderInfo, true);
		foreach ($orderInfo as $info) {
			$data['payAmt'] = $info['tradeamount'];
		}
		
		$data['dateline'] = $rs['time'];

		return $data;
	}
}
