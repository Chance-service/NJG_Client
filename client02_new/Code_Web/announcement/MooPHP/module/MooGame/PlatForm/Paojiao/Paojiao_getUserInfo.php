<?php
class Mod_MooGame_PlatForm_Paojiao_getUserInfo {

	public function getUserInfo($sessionKey) {

		$paojiao = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['token'] = $sessionKey;

		$rs = $paojiao->users('getInfo', $param);
		
		if ($rs['code'] != 1) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Paojiao_getVisitorInfo no data');
			return false;
		}

		$data = array();
		$data['uId'] = $rs['data']['uid'] . '__' . $this->MOD->platFormLabel;
		$data['uMail'] = $rs['data']['uid'];
		$data['uPic'] = '';
		$data['uSex'] = 'MALE';
		$data['uPlatFormUid'] = $rs['data']['uid'];

		return $data;
	}
}
