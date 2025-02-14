<?php
require_once dirname(__FILE__) . '/ucios/ucios.class.php';

class Mod_MooGame_PlatForm_Ucios extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'UCIOS';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('UCIOS_SERVER_ADDR') && UCIOS_SERVER_ADDR) {
				$serverAddr = UCIOS_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new ucios(Mod_MooGame_PlatForm::$appName, Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}