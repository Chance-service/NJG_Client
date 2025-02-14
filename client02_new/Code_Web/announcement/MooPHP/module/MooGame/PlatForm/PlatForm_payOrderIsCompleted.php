<?php
class Mod_MooGame_PlatForm_payOrderIsCompleted {
	/**
	 * 简单订单支付支付完成
	 *
	 * @param string $orderId 订单id
	 * @return Boolean
	 */
	function payOrderIsCompleted($orderId) {

		// 获得hashData
		$hashData = MooMod::get('MooGame_PlatForm')->getHash();

		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		// 是否是opensocial
		if ($hashData['useOS'] === 'TRUE') {
			$data = $this->runOS($hashData, $orderId);
		} else {
			$data = $this->runF8($hashData, $orderId);
		}

		// 是否成功
		return $data;
	}

	private function runOS($hashData, $orderId) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->payOrderIsCompleted($hashData, $orderId);
	}

	private function runF8($hashData, $orderId) {
		switch ($hashData['platForm']) {
			case 'MY' :
				$platForm = 'Manyou';break;
			case 'XN' :
				$platForm = 'Renren';break;
			case '51' :
				$platForm = 'Com51';break;
			case 'DE' :
				$platForm = 'Debug';break;
			case 'BAI' :
				$platForm = 'Baishehui';break;
			case 'FB' :
				$platForm = 'Facebook';break;
			case 'BD' :
				$platForm = 'Baidu';break;
			case 'MS' :
				$platForm = 'Myspace';break;
			case '360' :
				$platForm = 'Com360';break;
			case '139' :
				$platForm = 'Com139';break;
			case 'QD' :
				$platForm = 'Qidian';break;
			default :
				$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
				return false;
		}

		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->payOrderIsCompleted($hashData, $orderId);
		return $rs;
	}


}