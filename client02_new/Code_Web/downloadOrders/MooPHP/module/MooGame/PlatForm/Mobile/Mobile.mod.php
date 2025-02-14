<?php
require_once dirname(__FILE__) . '/mobile/mobile.class.php';

class Mod_MooGame_PlatForm_Mobile extends Mod_MooGame_PlatForm {
	// 平台的标识
	public $platFormLabel = 'MB';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('MOBILE_SERVER_ADDR') && MOBILE_SERVER_ADDR) {
				$serverAddr = MOBILE_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new mobile(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}