<?php
class Mod_MooGame_PlatForm_Uc_getUserInfo {

	public function getUserInfo($sessionKey, $platFormServer = 2379, $channelId = 0) {

		$uc = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['sid'] = $sessionKey;
		$param['channelId'] = $channelId;
		$param['serverId'] = $platFormServer;

		$rs = $uc->users('getInfo', $param);
		
		if ($rs['state']['code'] != 1) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_UC_getVisitorInfo no data');
			return false;
		}

		$data = array();
		$data['uId'] = $rs['data']['ucid'] . '__' . $this->MOD->platFormLabel;
		$data['uName'] = $rs['data']['nickName'];
		$data['uMail'] = $rs['data']['ucid'];
		$data['uPic'] = '';
		$data['uSex'] = $rs['data']['sex'] == 1 ? 'MALE' : 'FEMALE';
		$data['uPlatFormUid'] = $rs['data']['ucid'];

		return $data;
	}
}
