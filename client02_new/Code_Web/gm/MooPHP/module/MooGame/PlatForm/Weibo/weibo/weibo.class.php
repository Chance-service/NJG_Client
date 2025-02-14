<?php

class weiboApi {
	public $secret;
	public $apiKey;
	public $serverAddr;

	public function __construct($apiKey, $secret, $serverAddr = '') {
		$this->secret = $secret;
		$this->apiKey = $apiKey;
		$this->serverAddr = $serverAddr ? $serverAddr : 'https://api.weibo.com/2/';
	}

	public function users($do, $params = array()) {

		switch($do) {
			case 'getInfo':
				break;
			default:
				return false;
				break;
		}

		$params['apiDir'] = $this->serverAddr . 'users/show.json';

		return $this->postRequest($params, 'users', $do);
	}


	public function mgp($do, $params = array()) {

		switch ($do){
			case 'start':
				$params['apiDir'] = 'http://m.game.weibo.cn/api/mgp/app/start.json';
				break;
			case 'updateForCp':
				$params['apiDir'] = 'http://m.game.weibo.cn/api/mgp/rank/updateForCp.json';
				break;
			default:
				return false;
				break;
		}

		return $this->postRequest($params, 'mgp', $do);
	}
	
	
	//=================================================================================================
	private function create_post_string($params, $mod, $do) {

		$sendParams = array();
		if ($mod == 'users') {
			$sendParams['access_token'] = $params['access_token'];
			$sendParams['uid'] = $params['uid'];
		} else {
			if ($do == 'start') {
				$sendParams['access_token'] = $params['access_token'];
				$sendParams['phoneid'] = $params['phoneid'];
				$sendParams['appkey'] = $this->apiKey;
			} else {
				$sendParams['access_token'] = $params['access_token'];
				$sendParams['uid'] = $params['uid'];
				$sendParams['appkey'] = $this->apiKey;
				$sendParams['rank_key'] = $params['rank_key'];
				$sendParams['rank_group'] = $params['rank_group'];
				$sendParams['score'] = $params['score'];
			}
		}

		ksort($sendParams);

		$post_params = array();
		foreach ($sendParams as $key => &$val) {
			$post_params[] = "{$key}=" . urlencode($val);
		}

		return implode('&', $post_params);
	}


	public function postRequest($params, $mod, $do) {

		$post_string = $this->create_post_string($params, $mod, $do);
		
		$ch = curl_init();
		if ($mod == 'users') {
			curl_setopt($ch, CURLOPT_URL, $params['apiDir'] . '?' . $post_string);
		} else {
			curl_setopt($ch, CURLOPT_URL, $params['apiDir']);
			curl_setopt($ch, CURLOPT_POST, true);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
		}
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