<?php

class anzhi {
	public $secret;
	public $apiKey;
	public $serverAddr;

	public function __construct($apiKey, $secret, $serverAddr = '') {
		$this->secret = $secret;
		$this->apiKey = $apiKey;
		$this->serverAddr = $serverAddr ? $serverAddr : 'http://user.anzhi.com/web/api/sdk/third/1/queryislogin';
	}

	public function users($do, $params = array()) {

		switch($do){
			case 'getInfo':
				break;
			default:
				return false;
				break;
		}

		return $this->postRequest($params, 'login');
	}
	
	public function pay($do, $params = array()) {
	
		$this->serverAddr = 'http://pay.anzhi.com/web/api/third/1/queryorder';
		switch ($do){
			case 'checkOrder';
				break;
			default:
				return false;
				break;
		}
	
		return $this->postRequest($params, 'pay');
	}

	//=================================================================================================
	public static function generate_sig($params_array, $secret, $type) {
		
		$str = '';
		if ($type == 'login') {
			$str = $params_array['appkey'] . $params_array['account'] . $params_array['sid'] . $secret;
		} else {
			$str = $params_array['appkey'] . $params_array['tradenum'] . $params_array['mintradetime'] . $params_array['maxtradetime'] . $secret;
		}

		return base64_encode($str);
	}


	private function create_post_string($params, $type) {

		$params['appkey'] = $this->apiKey;
		$params['time'] = $this->getMillisecond();

		$params['sign'] = $this->generate_sig($params, $this->secret, $type);

		ksort($params);
		
		$post_params = array();
		foreach ($params as $key => &$val) {
			$post_params[] = "{$key}={$val}";
		}

		return implode('&', $post_params);
	}
	
	public function getMillisecond() {
		list($s1, $s2) = explode(' ', microtime());
		return date('YmdHis') . round(($s1) * 1000);;
	}

	public function postRequest($params, $type) {

		$post_string = $this->create_post_string($params, $type);

		if (function_exists('curl_init')) {
			$ch = curl_init();

			curl_setopt($ch, CURLOPT_URL, $this->serverAddr);
			curl_setopt($ch, CURLOPT_POST, true);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			$result = curl_exec($ch);
			curl_close($ch);
		} else {
			$context =
			array('http' =>
			array('method' => 'POST',
			'header' => 'Content-type: application/x-www-form-urlencoded'."\r\n".
			'User-Agent: Facebook API PHP5 Client 1.1 '."\r\n".
			'Content-length: ' . strlen($post_string),
			'content' => $post_string));
			$contextid=stream_context_create($context);
			$sock = fopen($this->serverAddr, 'r', false, $contextid);
			if ($sock) {
				$result='';
				while (!feof($sock))
				$result.=fgets($sock, 4096);

				fclose($sock);
			}
		}
		
		$result = str_replace("'", '"', $result);

		if($result){
			$result = json_decode($result, true);
		} else {
			$result = false;
		}

		return $result;
	}

}