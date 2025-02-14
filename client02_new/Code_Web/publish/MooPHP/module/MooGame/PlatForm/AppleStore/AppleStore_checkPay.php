<?php
class Mod_MooGame_PlatForm_AppleStore_checkPay {
	/**
	 * $receipt 前端传过来appstore的订单凭证
	 * $sandbox 是否采用安全沙箱，如果采用则为调试订单否则是正式线上
	 */

	public function checkPay($receipt, $sandbox = false) {

		if ($sandbox) {
			$serverAddr = 'https://sandbox.itunes.apple.com/verifyReceipt';
		} else {
			$serverAddr = 'https://buy.itunes.apple.com/verifyReceipt';
		}

		$postData = json_encode(
			array('receipt-data' => $receipt)
		);

		// 向apple发送验证请求
		$ch = curl_init($serverAddr);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);

		$response = curl_exec($ch);
		curl_close($ch);

		$data = json_decode($response);

		if (!is_object($data)) {
			return false;
		}

		if (!isset($data->status) || $data->status != 0) {
			return false;
		}

		// 返回apple回调验证数据
		return array(
			'quantity'			=>  $data->receipt->quantity,
			'product_id'		=>  $data->receipt->product_id,
			'transaction_id'	=>  $data->receipt->transaction_id,
			'purchase_date'		=>  $data->receipt->purchase_date,
			//'app_item_id'		=>  $data->receipt->app_item_id,
			'bid'				=>  $data->receipt->bid,
			'bvrs'				=>  $data->receipt->bvrs
		);

		return $data;
	}
}
