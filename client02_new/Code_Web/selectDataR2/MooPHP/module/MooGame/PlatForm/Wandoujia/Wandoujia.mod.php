<?php
require_once dirname(__FILE__) . '/wandoujia/wandoujia.class.php';

class Mod_MooGame_PlatForm_Wandoujia extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'WD';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('WANDOUJIA_SERVER_ADDR') && WANDOUJIA_SERVER_ADDR) {
				$serverAddr = WANDOUJIA_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new wandoujia(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}