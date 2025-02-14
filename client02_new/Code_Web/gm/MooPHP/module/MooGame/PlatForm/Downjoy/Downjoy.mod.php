<?php
require_once dirname(__FILE__) . '/downjoy/downjoy.class.php';

class Mod_MooGame_PlatForm_Downjoy extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'DJ';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('DOWNJOY_SERVER_ADDR') && DOWNJOY_SERVER_ADDR) {
				$serverAddr = DOWNJOY_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new downjoy(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}