<?php
require_once dirname(__FILE__) . '/duoku/duoku.class.php';

class Mod_MooGame_PlatForm_Duoku extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'DK';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('DUOKU_SERVER_ADDR') && DUOKU_SERVER_ADDR) {
				$serverAddr = DUOKU_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new duoku(Mod_MooGame_PlatForm::$appName, Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}