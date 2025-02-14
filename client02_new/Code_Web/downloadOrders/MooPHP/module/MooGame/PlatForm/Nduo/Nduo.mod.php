<?php
require_once dirname(__FILE__) . '/nduo/nduo.class.php';

class Mod_MooGame_PlatForm_Nduo extends Mod_MooGame_PlatForm {
	// 平台的标识
	public $platFormLabel = 'ND';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('NDUO_SERVER_ADDR') && NDUO_SERVER_ADDR) {
				$serverAddr = NDUO_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new nduo(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}