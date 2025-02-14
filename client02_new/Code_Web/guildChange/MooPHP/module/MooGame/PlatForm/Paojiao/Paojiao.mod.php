<?php
require_once dirname(__FILE__) . '/paojiao/paojiao.class.php';

class Mod_MooGame_PlatForm_Paojiao extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'PJ';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('PAOJIAO_SERVER_ADDR') && PAOJIAO_SERVER_ADDR) {
				$serverAddr = PAOJIAO_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new paojiao(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}