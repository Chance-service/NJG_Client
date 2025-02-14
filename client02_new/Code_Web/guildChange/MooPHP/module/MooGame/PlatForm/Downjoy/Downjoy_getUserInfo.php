<?php
class Mod_MooGame_PlatForm_Downjoy_getUserInfo {

	public function getUserInfo($sessionKey, $uid) {

		$downjoy = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['mid'] = $uid;
		$param['token'] = $sessionKey;

		$rs = $downjoy->users('getInfo', $param);
		
		if ($rs['error_code'] != 0) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Downjoy_getVisitorInfo no data');
			return false;
		}

		$data = array();
		$data['uId'] = $rs['memberId'] . '__' . $this->MOD->platFormLabel;
		$data['uMail'] = $rs['memberId'];
		$data['uPic'] = '';
		$data['uSex'] = 'MALE';
		$data['uPlatFormUid'] = $rs['memberId'];

		return $data;
	}
}
