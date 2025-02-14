<?php
class Mod_MooGame_PlatForm_Appchina_getUserInfo {

	public function getUserInfo($sessionKey) {

		$appchina = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['ticket'] = $sessionKey;

		$rs = $appchina->users('getInfo', $param);
		
		if ($rs['status']) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Appchina_getVisitorInfo no data');
			return false;
		}

		// 一个用户返回值
		$userInfo = $rs['data'];

		$data = array();
		$data['uId'] = $userInfo['user_id'] . '__' . $this->MOD->platFormLabel;
		$data['uName'] = $userInfo['user_name'];
		$data['uMail'] = $userInfo['email'];
		$data['uPic'] = '';
		$data['uSex'] = 'MALE';
		$data['uPlatFormUid'] = $userInfo['user_id'];

		return $data;

		return $data;
	}
}
