<?php
require_once dirname(__FILE__) . '/weibo/weibo.class.php';

class Mod_MooGame_PlatForm_Weibo extends Mod_MooGame_PlatForm {
	//note 平台的标识
	public $platFormLabel = 'WB';

	function __construct() {
		if(Mod_MooGame_PlatForm::$platFormLibObj === null) {
			// 指定服务器地址
			if (defined('WEIBO_SERVER_ADDR') && WEIBO_SERVER_ADDR) {
				$serverAddr = WEIBO_SERVER_ADDR;
			} else {
				$serverAddr = '';
			}
			Mod_MooGame_PlatForm::$platFormLibObj = new weiboApi(Mod_MooGame_PlatForm::$apiKey, Mod_MooGame_PlatForm::$apiSecret, $serverAddr);
		}
	}
}