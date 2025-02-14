<?php

class mobile {
	public $secret;
	public $apiKey;
	public $serverAddr;

	public function __construct($apiKey, $secret, $serverAddr = '') {
		$this->secret = $secret;
		$this->apiKey = $apiKey;
		$this->serverAddr = $serverAddr ? $serverAddr : 'http://s0.newmobile.xy.ismole.com/www/mobile/userCenter/www/api.php';
	}

	public function users($do, $params = array()) {

		switch($do){
			case 'reg':
				break;
			case 'login':
				break;
			case 'getInfo':
				break;
			case 'changeServer':
				break;
			case 'changeSex':
				break;
			case 'changePwd':
				break;
		}

		$params['mod'] = 'User';
		$params['do'] = $do;

		return $this->postRequest($params);
	}

    // 好友
	public function friends($do, $params = array()) {

		switch ($do){
			case 'getFriendList':
				break;
			case 'getAppFriendList':
				break;
			case 'getMultiFriend';
				break;
			case 'addFriend';
				break;
			case 'delFriend';
				break;
		}

		$params['mod'] = 'Friend';
		$params['do'] = $do;

		return $this->postRequest($params);
	}
	
	// 支付
	public function pay($do, $params = array()) {
		switch($do){
			case 'checkOrder':
				break;
		}

		$params['mod'] = 'Pay';
		$params['do'] = $do;

		return $this->postRequest($params);
	}


	public function feed($do, $params = array()) {

		switch($do){
			case 'add':
				break;
		}

		$params['mod'] = 'Feed';
		$params['do'] = $do;

		return $this->postRequest($params);
	}

	public function notification($do, $params = array()) {

		switch($do){
			case 'sendBoxMessageById':
				break;
		}

		$params['mod'] = 'Message';
		$params['do'] = $do;

		return $this->postRequest($params);
	}

	//=================================================================================================
	public static function generate_sig($params_array, $secret) {
		$str = '';
		ksort($params_array);
		foreach ($params_array as $k=>$v) {
			$str .= "$k=$v";
		}
		$str .= $secret;

		return md5($str);
	}


	private function create_post_string($params) {
		$params['appid'] = $this->apiKey;
		$params['time'] = time();
		$params['sign'] = $this->generate_sig($params, $this->secret);

		ksort($params);

		$post_params = array();
		foreach ($params as $key => &$val) {
			$post_params[] = "{$key}=" . urlencode($val);
		}

		return implode('&', $post_params);
	}


	public function postRequest($params) {

		$post_string = $this->create_post_string($params);

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

		if($result){
			$result = json_decode($result, true);
		} else {
			$result = false;
		}

		return $result;
	}

}