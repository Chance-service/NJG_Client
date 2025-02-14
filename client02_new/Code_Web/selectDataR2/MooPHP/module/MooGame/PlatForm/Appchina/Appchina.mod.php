<?php
require_once dirname(__FILE__) . '/appchina/appchina.class.php';

class Mod_MooGame_PlatForm_Appchina extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'AC';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('APPCHINA_SERVER_ADDR') && APPCHINA_SERVER_ADDR) {
				$serverAddr = APPCHINA_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new appchina(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}