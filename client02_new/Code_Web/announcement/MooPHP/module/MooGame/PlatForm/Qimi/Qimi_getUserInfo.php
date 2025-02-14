<?php
class Mod_MooGame_PlatForm_Qimi_getUserInfo {

	public function getUserInfo($sessionKey) {

		$qimi = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $sessionKey;

		$rs = $qimi->users('getInfo', $param);

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Qimi_getVisitorInfo no data');
			return false;
		}

		// 一个用户返回值
		$userInfo = $rs['data']['user'];

		$data = array();
		$data['uId'] = $userInfo['uid'] . '__' . $this->MOD->platFormLabel;
		$data['uName'] = $userInfo['name'];
		$data['uMail'] = $userInfo['email'];
		$data['uPic'] = $userInfo['avatar'];
		$data['uSex'] = $userInfo['sex'] == 1 ? 'MALE' : 'FEMALE';
		$data['uPlatFormUid'] = $userInfo['uid'];

		return $data;
	}
}
