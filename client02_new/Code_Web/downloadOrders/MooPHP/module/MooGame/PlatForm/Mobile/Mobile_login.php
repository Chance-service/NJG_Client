<?php
class Mod_MooGame_PlatForm_Mobile_login {

	public function login($email, $password) {

		$mobile = Mod_MooGame_PlatForm::$platFormLibObj;

		$params = array(
			'email' => $email,
			'password' => $password,
		);

		$data = array();
		$rs = $mobile->users('login', $params);
		$data['status'] = $rs['status'];

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Mobile_login no data');
			$data['error']   = $rs['error'];
		} else {
			$data['uId']      = $rs['data']['user']['uid'] . '__' . $this->MOD->platFormLabel;
			$data['uMail']    = $rs['data']['user']['email'];
			$data['uNowServer']     = $rs['data']['user']['nowServer'];
			$data['uServer']     = $rs['data']['user']['server'];
			$data['uSex']     = $rs['data']['user']['sex'] ? 1 : 0;
			$data['platFormUid'] = $rs['data']['user']['uid'];
			$data['uScore'] = $rs['data']['user']['score'];
			$data['sessionKey'] = $rs['data']['session_key'];
		}
		return $data;
	}
}
