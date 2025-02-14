<?php

class Mod_MooGame_PlatForm_createFastLoginHash {

	function createFastLoginHash($platForm, $gameUid = '', $serverId = '', $platFormUid = '') {

		if (!$platForm) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}
		
		$platForm = ucfirst($platForm);

		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->createFastLoginHash($gameUid, $serverId, $platFormUid);

		return $rs;
	}

}
