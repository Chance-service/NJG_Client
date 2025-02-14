<?php
class Mod_MooGame_PlatForm extends Mod_MooGame {

	//note 应用api接口key
	static $apiKey = '';

	//note 应用api接口密钥
	static $apiSecret = '';

	//note 加密后，用于和falsh等交互等，存储用户信息
	static $hash = '';
	
	// 平台应用英文名，有些平台需要，如QQ
	static $appName = '';

	//note 传输hash的密钥
	static $hashSecret = 'qoojoyMooModPlatform~!@';

	//note 实例化后的平台接口
	static $platFormLibObj = null;

	//note 一些基本用户信息，直接放到这里，减少反复调用 MooUtil::authcode
	static $hashData = array();
}
