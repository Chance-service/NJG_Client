<?php
require_once dirname(__FILE__) . '/pp/pp.class.php';

class Mod_MooGame_PlatForm_Pp extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'PP';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('PP_SERVER_ADDR') && PP_SERVER_ADDR) {
				$serverAddr = PP_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new ppPlatForm(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}