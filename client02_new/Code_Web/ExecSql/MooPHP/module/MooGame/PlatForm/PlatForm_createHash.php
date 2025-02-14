<?php

class Mod_MooGame_PlatForm_createHash {

	function createHash($platForm, $sessionKey = '', $gameUid = '', $platFormUid = '', $serverId = '') {

		if (!$platForm) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}
		
		$platForm = ucfirst($platForm);
		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->createHash($sessionKey, $gameUid, $platFormUid, $serverId);

		return $rs;
	}

}
