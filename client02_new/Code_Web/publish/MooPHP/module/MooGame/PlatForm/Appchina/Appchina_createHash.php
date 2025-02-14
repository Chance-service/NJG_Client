<?php
class Mod_MooGame_PlatForm_Appchina_createHash {
	/**
	 * 根据平台post给我们的信息，构造出用户的信息hash，便于和falsh等交互
	 *
	 * @return string $hash base64_encode
	 */
	public function createHash($sessionKey, $gameUid, $platFormUid, $serverId) {

		if (!$sessionKey || !$gameUid || !$platFormUid || !$serverId) {
			MooLog::error('Mod_MooGame_PlatForm_createHash no sessionKey or platFormUid');
			$this->MOD->setMsg('Mod_MooGame_PlatForm_createHash no sessionKey or platFormUid');
			return false;
		}

		$data = array();
		$data['platFormUid']	= $platFormUid;
		$data['platForm'] = $this->MOD->platFormLabel;
		// 给用户id加上平台后缀，用于区分这个用户是来自哪个平台的.
		$data['pUid'] = $platFormUid . '__' . $this->MOD->platFormLabel;
		$data['uId'] = $gameUid;
		// sessionKey
		$data['sessionId'] = $sessionKey;
		$data['serverId'] = $serverId;
		// api key
		$data['skey'] = Mod_MooGame_PlatForm::$apiKey;
		$data['useOS'] = 'FALSE';

		$hash = MooMod::get('MooGame_PlatForm')->encrypt($data, md5(Mod_MooGame_PlatForm::$hashSecret . Mod_MooGame_PlatForm::$apiKey));
		Mod_MooGame_PlatForm::$hash = $hash;
		return $hash;
	}
}