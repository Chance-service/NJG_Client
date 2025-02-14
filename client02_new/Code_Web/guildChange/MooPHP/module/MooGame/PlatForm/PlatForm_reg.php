<?php

class Mod_MooGame_PlatForm_reg {

	function reg($platForm, $email, $password, $name, $sex) {

		if (!$platForm) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}
		
		$platForm = ucfirst($platForm);

		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->reg($email, $password, $name, $sex);

		return $rs;
	}

}
