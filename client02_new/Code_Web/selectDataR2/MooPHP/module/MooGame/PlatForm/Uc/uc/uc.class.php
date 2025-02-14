<?php

class uc {
	public $secret;
	public $apiKey;
	public $appId;
	public $serverAddr;

	public function __construct($appId, $apiKey, $secret, $serverAddr = '') {
		$this->secret = $secret;
		$this->apiKey = $apiKey;
		$this->appId = $appId;
		$this->serverAddr = $serverAddr ? $serverAddr : 'http://sdk.g.uc.cn/ss/';
	}

	public function users($do, $params = array()) {

		switch($do){
			case 'getInfo':
				break;
			default:
				return false;
				break;
		}

		$params['service'] = 'ucid.user.sidInfo';

		return $this->postRequest($params);
	}

	//=================================================================================================
	public static function generate_sig($params_array, $secret) {

		$data = array();
		$data['sid'] = $params_array['data']['sid'];
		ksort($data);
		$str = '';
		foreach ($data as $k => $v) {
			$str .= "$k=$v";
		}

		$sign = md5($params_array['game']['cpId'] . $str . $secret);
		
		return $sign;
	}


	private function create_post_string($params) {

		$postData = array();
		$postData['id'] = time();
		$postData['service'] = $params['service'];
		$postData['data']['sid'] = $params['sid'];
		$postData['game']['cpId'] = $this->appId;
		$postData['game']['gameId'] = $this->apiKey;
		$postData['game']['channelId'] = "{$params['channelId']}";
		$postData['game']['serverId'] = $params['serverId'];
		$postData['sign'] = $this->generate_sig($postData, $this->secret);

		return json_encode($postData);
	}


	public function postRequest($params) {

		$post_string = $this->create_post_string($params);

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $this->serverAddr);
		//curl_setopt($ch, CURLOPT_URL, 'http://sdk.test4.g.uc.cn/ss');
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
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