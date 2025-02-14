<?php
class Mod_MooGame_PlatForm_payOrder {
	/**
	 * 注册订单
	 *
	 * @param  $orderId 订单id
	 * @param  $amount 订单金额
	 * @param  $desc 订单描述
	 * @param array $data 订单其他参数
	 * @return string token
	 */
	public function payOrder($orderId, $amount, $desc = '', $data = array()) {

		// 获得hashData
		$hashData = MooMod::get('MooGame_PlatForm')->getHash();

		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		// 加入数据中
		$order = array();
		$order['orderId'] = $orderId; // 订单id
		$order['amount'] = $amount;  // 订单金额
		$order['desc'] = $desc;	 // 订单描述
		foreach($data as $key => $val) {
			$order[$key] = $val;
		}

		// 是否是opensocial
		if ($hashData['useOS'] === 'TRUE') {
			$data = $this->runOS($hashData, $order);
		} else {
			$data = $this->runF8($hashData, $order);
		}

		// 订单数据
		return $data;
	}

	private function runOS($hashData, $order) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->payOrder($hashData, $order);
	}

	private function runF8($hashData, $order) {
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
			// modify by Kobe
			case 'KX' :
				$platForm = 'Kaixin001';
				break;
			// end
			case 'QD' :
				$platForm = 'Qidian';break;
			default :
				$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
				return false;
		}

		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->payOrder($hashData, $order);
		return $rs;
	}

}
