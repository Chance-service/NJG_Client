<?php
class Mod_MooGame_PlatForm_Wandoujia_getUserInfo {

	public function getUserInfo($sessionKey, $pUser) {

		$wandoujia = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['token'] = $sessionKey;
		$param['uid'] = $pUser;

		$rs = $wandoujia->users('getInfo', $param);
		
		if ($rs == 'false') {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Wandoujia_getVisitorInfo no data');
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
