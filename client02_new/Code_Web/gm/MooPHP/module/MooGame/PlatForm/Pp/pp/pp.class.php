<?php
require_once dirname(__FILE__) . '/ppException.php';

class ppPlatForm {
	public $secret;
	public $apiKey;
	public $serverAddr;

	public function __construct($apiKey, $secret, $serverAddr = '') {
		$this->secret = $secret;
		$this->apiKey = $apiKey;
		$this->serverAddr = $serverAddr ? $serverAddr : 'http://passport_i.25pp.com:8080/index?tunnel-command=2852126756';
	}

	public function users($do, $params = array()) {

		switch($do){
			case 'getInfo':
				break;
			default:
				return false;
				break;
		}
		
		$rs = MySocket::instance()->postCurl($params['token_key']);
		
		$result = json_decode($rs, true);

		return $result;
	}

}