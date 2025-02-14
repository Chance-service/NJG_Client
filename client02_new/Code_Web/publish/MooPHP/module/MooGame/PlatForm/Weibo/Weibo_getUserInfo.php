<?php
class Mod_MooGame_PlatForm_Weibo_getUserInfo {

	public function getUserInfo($sessionKey, $pUid) {

		$weibo = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['access_token'] = $sessionKey;
		$param['uid'] = $pUid;

		$rs = $weibo->users('getInfo', $param);

		if ($rs['error_code']) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Weibo_getVisitorInfo no data');
			return false;
		}

		$data = array();
		$data['uId'] = $rs['id'] . '__' . $this->MOD->platFormLabel;
		$data['uName'] = $rs['name'];
		$data['uMail'] = $rs['id'];
		$data['uPic'] = '';
		$data['uSex'] = 'MALE';
		$data['uPlatFormUid'] = $rs['id'];

		return $data;
	}
}
