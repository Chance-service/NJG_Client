<?php
require_once dirname(__FILE__) . '/anzhi/anzhi.class.php';

class Mod_MooGame_PlatForm_Anzhi extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'AZ';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('ANZHI_SERVER_ADDR') && ANZHI_SERVER_ADDR) {
				$serverAddr = ANZHI_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new anzhi(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}