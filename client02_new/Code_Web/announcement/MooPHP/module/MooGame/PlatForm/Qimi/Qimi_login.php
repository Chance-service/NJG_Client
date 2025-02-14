<?php
class Mod_MooGame_PlatForm_Qimi_login {

	public function login($email, $password) {

		$qimi = Mod_MooGame_PlatForm::$platFormLibObj;

		$params = array(
			'email' => $email,
			'password' => $password,
		);

		$rs = $qimi->users('login', $params);

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Qimi_getVisitorInfo no data');
			return false;
		}

		$data = array();
		$data['status'] = 100;
		$data['platFormUid'] = $rs['data']['user']['uid'];
		$data['uMail'] = $rs['data']['user']['email'];
		$data['uSex'] = $rs['data']['user']['sex'];
		$data['uScore'] = $rs['data']['user']['score'];
		$data['sessionKey'] = $rs['data']['session_key'];
		$data['isExperienceUser'] = $rs['data']['user']['experience'];

		return $data;
	}
}
