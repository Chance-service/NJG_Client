<?php
class Mod_MooGame_PlatForm_Pp_getUserInfo {

	public function getUserInfo($tokenKey) {
		
		$pp = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['token_key'] = $tokenKey;
		
		$rs = $pp->users('getInfo', $param);
		
		if ($rs['status'] != 0) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_UC_getVisitorInfo no data');
			return false;
		}
		
		$data = array();
		$data['uId'] = $rs['userid'] . '__' . $this->MOD->platFormLabel;
		$data['uName'] = '';
		$data['uMail'] = $rs['username'];
		$data['uPic'] = '';
		$data['uSex'] = 'FEMALE';
		$data['uPlatFormUid'] = $rs['userid'];
		
		return $data;
	}
}
