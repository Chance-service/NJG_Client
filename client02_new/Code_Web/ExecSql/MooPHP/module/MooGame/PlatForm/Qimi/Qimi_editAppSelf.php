<?php
class Mod_MooGame_PlatForm_Qimi_editAppSelf {

	public function editAppSelf($email, $name, $password, $sex) {

		$qimi = Mod_MooGame_PlatForm::$platFormLibObj;

		$params = array(
			'email' => $email,
			'name' => $name,
			'password' => $password,
			'sex' => $sex,
		);

		$hashData = MooMod::get('MooGame_PlatForm')->getHash();
		if (!$hashData) {
			MooLog::error('Mod_MooGame_PlatForm_Qimi_editAppSelf no hashData');
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}
		$params['session_key'] = $hashData['sessionId'];

		$rs = $qimi->users('edit', $params);

		$data = array();
		if ($rs['status'] != 100) {
			$data['status'] = $rs['status'];
			return $data;
		}

		$data['status'] = 100;

		return $data;
	}
}