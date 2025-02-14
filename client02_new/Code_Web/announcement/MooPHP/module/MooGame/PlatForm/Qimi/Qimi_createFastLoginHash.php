<?php
class Mod_MooGame_PlatForm_Qimi_createFastLoginHash {
	/**
	 * 根据平台post给我们的信息，构造出用户的信息hash，便于和falsh等交互
	 *
	 * @return string $hash base64_encode
	 */
	public function createFastLoginHash($gameUid, $serverId, $platFormUid = '') {

		if (!$gameUid || !$serverId) {
			return false;
		}
		
		if ($platFormUid) {
			$tmpArr = explode('__', $platFormUid);
		}

		$data = array();
		$data['platFormUid']	= $platFormUid ? $tmpArr[0] : '';
		$data['platForm'] = $this->MOD->platFormLabel;
		// 给用户id加上平台后缀，用于区分这个用户是来自哪个平台的.
		$data['uId'] = $gameUid;
		$data['pUid'] = $platFormUid ? $platFormUid : '';
		// sessionKey
		$data['sessionId'] = '';
		$data['serverId'] = $serverId;
		// api key
		$data['skey'] = Mod_MooGame_PlatForm::$apiKey;
		$data['useOS'] = 'FALSE';

		$hash = MooMod::get('MooGame_PlatForm')->encrypt($data, md5(Mod_MooGame_PlatForm::$hashSecret . Mod_MooGame_PlatForm::$apiKey));
		Mod_MooGame_PlatForm::$hash = $hash;
		return $hash;
	}
}