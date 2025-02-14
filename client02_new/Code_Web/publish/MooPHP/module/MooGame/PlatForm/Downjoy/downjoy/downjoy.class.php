<?php

class downjoy {
	public $secret;
	public $apiKey;
	public $serverAddr;

	public function __construct($apiKey, $secret, $serverAddr = '') {
		$this->secret = $secret;
		$this->apiKey = $apiKey;
		$this->serverAddr = $serverAddr ? $serverAddr : 'http://connect.d.cn/open/member/info/';
	}

	public function users($do, $params = array()) {

		switch($do){
			case 'getInfo':
				break;
			default:
				return false;
				break;
		}

		return $this->postRequest($params);
	}

	//=================================================================================================
	public static function generate_sig($params_array, $apiKey) {

		return md5($params_array['token']. '|' .$apiKey);
	}


	private function create_post_string($params) {

		$params['app_id'] = $this->apiKey;
		$params['sig'] = md5($params['token']. '|' .$this->secret);
		ksort($params);

		$post_params = array();
		foreach ($params as $key => &$val) {
			$post_params[] = "{$key}={$val}";
		}

		return implode('&', $post_params);
	}


	public function postRequest($params) {

		$post_string = $this->create_post_string($params);
		
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $this->serverAddr . '?' . $post_string);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$result = curl_exec($ch);
		curl_close($ch);

		if($result){
			$result = json_decode($result, true);
		} else {
			$result = false;
		}

		return $result;
	}

}