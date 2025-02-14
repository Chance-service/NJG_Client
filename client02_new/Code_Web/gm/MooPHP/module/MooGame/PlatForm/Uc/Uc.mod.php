<?php
require_once dirname(__FILE__) . '/uc/uc.class.php';

class Mod_MooGame_PlatForm_Uc extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'UC';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('UC_SERVER_ADDR') && UC_SERVER_ADDR) {
				$serverAddr = UC_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new uc(Mod_MooGame_PlatForm::$appName, Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}