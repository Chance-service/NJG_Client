<?php
class Mod_MooGame_PlatForm_getUserInfo {
	/**
	 * 返回用户信息
	 *
	 * @return array $userInfo
		$userInfo['uId']	= $data['uId'];
		$userInfo['uName']	= $data['uName'];
		$userInfo['uPic']	= $data['uPic'];
		$userInfo['uSex']	= $data['uSex'];
		$userInfo['uSiteId']	= $data['uSiteId'];
		$userInfo['uUchid']	= $data['uUchid'];
		$userInfo['uPlatFormUid']	= $data['uPlatFormUid'];
	 */
	function getUserInfo($platForm, $sessionKey, $pUser = '') {
		
		static $userInfo = array();
		if ($userInfo) {
			return $userInfo;
		}

		if (!$platForm || !$sessionKey) {
			MooLog::error('Mod_MooGame_PlatForm_getUserInfo no hashData');
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		$platForm = ucfirst($platForm);
		if (!$pUser) {
			$data = MooMod::get('MooGame_PlatForm_' . $platForm)->getUserInfo($sessionKey);
		} else {
			$data = MooMod::get('MooGame_PlatForm_' . $platForm)->getUserInfo($sessionKey, $pUser);
		}

		if (!$data['uId']) {
			MooLog::error('Mod_MooGame_PlatForm_getUserInfo no uId or uName or uPic');
			$this->MOD->setMsg(MooConfig::get('system.errorCode.overtime'));
			return false;
		}

		return $data;
	}

}
