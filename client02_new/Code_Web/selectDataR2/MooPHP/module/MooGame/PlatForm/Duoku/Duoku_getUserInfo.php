<?php
class Mod_MooGame_PlatForm_Duoku_getUserInfo {

	public function getUserInfo($sessionKey, $pUser) {

		$duoku = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['sessionid'] = $sessionKey;
		$param['uid'] = $pUser;

		$rs = $duoku->users('getInfo', $param);

		if ($rs['error_code'] != 0) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Duoku_getVisitorInfo no data');
			return false;
		}

		$data = array();
		$data['uId'] = $pUser . '__' . $this->MOD->platFormLabel;
		$data['uMail'] = $pUser;
		$data['uPic'] = '';
		$data['uSex'] = 'MALE';
		$data['uPlatFormUid'] = $pUser;

		return $data;
	}
}
