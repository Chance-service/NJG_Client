<?php
class Mod_MooGame_PlatForm_Anzhi_getUserInfo {

	public function getUserInfo($sessionKey, $account) {

		$anzhi = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['sid'] = $sessionKey;
		$param['account'] = $account;

		$rs = $anzhi->users('getInfo', $param);
		if ($rs['sc'] != 1) {
			if ($rs['sc'] != 200) {
				$this->MOD->setMsg('Mod_MooGame_PlatForm_Anzhi_getVisitorInfo no data');
				return false;
			}
		}

		// 一个用户返回值
		$userInfo = base64_decode($rs['msg']);
		$userInfo = str_replace("'", '"', $userInfo);
		$userInfo = json_decode($userInfo, true);
		if (!$userInfo['uid']) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Anzhi_getVisitorInfo no data');
			return false;
		}

		$data = array();
		$data['uId'] = $userInfo['uid'] . '__' . $this->MOD->platFormLabel;
		$data['uName'] = $userInfo['nickname'];
		$data['uMail'] = '';
		$data['uPic'] = '';
		$data['uSex'] = 'MALE';
		$data['uPlatFormUid'] = $userInfo['uid'];

		return $data;
	}
}
