<?php

class Mod_MooGame_PlatForm_configure {
	/**
	 * 设置应用和平台交互的参数
	 *
	 * @param string $apiKey 应用api接口key
	 * @param string $apiSecret 应用api接口密钥
	 * @param string $hashSecret  传输hash的密钥
	 * @param string $hash  传输hash, 因为在amf传输方式的时候，无法通过get，post取得hash，所以必须是通过设置来创建hash
	 * @return void
	 */
	public function configure($apiKey, $apiSecret, $hashSecret = '', $hash = '', $appName = '') {
		Mod_MooGame_PlatForm::$apiKey = $apiKey;
		Mod_MooGame_PlatForm::$apiSecret = $apiSecret;
		$hashSecret && Mod_MooGame_PlatForm::$hashSecret = $hashSecret;
		$hash && Mod_MooGame_PlatForm::$hash = $hash;
		$appName && Mod_MooGame_PlatForm::$appName = $appName;
	}
}