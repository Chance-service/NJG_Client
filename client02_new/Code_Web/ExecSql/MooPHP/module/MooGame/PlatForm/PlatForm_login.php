<?php

class Mod_MooGame_PlatForm_login {

	function login($platForm, $email, $password) {

		if (!$platForm) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}
		
		$platForm = ucfirst($platForm);

		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->login($email, $password);

		return $rs;
	}

}
