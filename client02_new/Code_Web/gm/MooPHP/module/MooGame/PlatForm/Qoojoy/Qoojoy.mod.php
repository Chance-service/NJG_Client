<?php
require_once dirname(__FILE__) . '/qoojoy/qoojoy.class.php';

class Mod_MooGame_PlatForm_Qoojoy extends Mod_MooGame_PlatForm {
	// 平台的标识
	public $platFormLabel = 'QJ';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('QOOJOY_SERVER_ADDR') && QOOJOY_SERVER_ADDR) {
				$serverAddr = QOOJOY_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new qoojoy(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}