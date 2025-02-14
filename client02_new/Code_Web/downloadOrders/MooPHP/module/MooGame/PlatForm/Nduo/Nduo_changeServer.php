<?php
class Mod_MooGame_PlatForm_Nduo_changeServer {

	public function changeServer($sessionKey, $serverId) {

		$nduo = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $sessionKey;
		$param['server_id'] = $serverId;

		$rs = $nduo->users('changeServer', $param);
		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Nduo_getVisitorInfo no data');
			return false;
		}
		
		// 一个用户返回值
		$userInfo = $rs['data'];

		$data = array();
		$data['uId']      = $userInfo['user']['uid'] . '__' . $this->MOD->platFormLabel;
		$data['uMail']    = $userInfo['user']['email'];
		$data['uNowServer']     = $userInfo['user']['nowServer'];
		$data['uServer']     = $userInfo['user']['server'];
		$data['uSex']     = $userInfo['user']['sex'] ? 1 : 0;
		$data['uPlatFormUid'] = $userInfo['user']['uid'];
		$data['uScore'] = $userInfo['user']['score'];
		$data['session_key'] = $userInfo['session_key'];

		return $data;
	}
}
