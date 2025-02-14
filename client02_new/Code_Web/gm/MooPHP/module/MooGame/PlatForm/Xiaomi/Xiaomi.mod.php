<?php
require_once dirname(__FILE__) . '/xiaomi/xiaomi.class.php';

class Mod_MooGame_PlatForm_Xiaomi extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'XM';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('XIAOMI_SERVER_ADDR') && XIAOMI_SERVER_ADDR) {
				$serverAddr = XIAOMI_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new xiaomi(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}