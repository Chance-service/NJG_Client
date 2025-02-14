<?php
require_once dirname(__FILE__) . '/qimi/qimi.class.php';

class Mod_MooGame_PlatForm_Qimi extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'QM';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('QIMI_SERVER_ADDR') && QIMI_SERVER_ADDR) {
				$serverAddr = QIMI_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new qimi(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}