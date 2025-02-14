<?php
class Mod_MooGame_PlatForm_Qimi_reg {

	public function reg($email, $password, $name, $sex) {

		$qimi = Mod_MooGame_PlatForm::$platFormLibObj;

		$params = array(
			'email' => $email,
			'password' => $password,
			'name' => $name,
			'sex' => $sex,
		);

		$rs = $qimi->users('reg', $params);

		$data = array();
		if ($rs['status'] != 100) {
			$data['status'] = $rs['status'];
			return $data;
		}

		$data['status'] = 100;
		$data['platFormUid'] = $rs['data']['user']['uid'];
		$data['sessionKey'] = $rs['data']['session_key'];
		$data['uMail'] = $rs['data']['user']['email'];
		$data['uSex'] = $rs['data']['user']['sex'];
		$data['uScore'] = $rs['data']['user']['score'];

		return $data;
	}
}
