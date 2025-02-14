<?php

class duoku {
	public $secret;
	public $apiKey;
	public $appId;
	public $serverAddr;

	public function __construct($appId, $apiKey, $secret, $serverAddr = '') {
		$this->appId = $appId;
		$this->apiKey = $apiKey;
		$this->secret = $secret;
		$this->serverAddr = $serverAddr ? $serverAddr : 'http://sdk.m.duoku.com/openapi/sdk/checksession';
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
		$postData = array();
		$postData['appid'] = $this->appId;
		$postData['appkey'] = $this->apiKey;
		$postData['uid'] = $params['uid'];
		$postData['sessionid'] = $params['sessionid'];
		$postData['clientsecret'] = strtolower(md5($postData['appid'].$postData['appkey'].$postData['uid'].$postData['sessionid'].$this->secret));
		
		ksort($postData);
		$post_params = array();
		foreach ($postData as $key => &$val) {
			$post_params[] = "{$key}=" . urlencode($val);
		}

 		$postSring =  implode('&', $post_params);
 		
 		return $postSring;

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