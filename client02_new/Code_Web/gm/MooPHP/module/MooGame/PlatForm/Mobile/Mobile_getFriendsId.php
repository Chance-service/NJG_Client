<?php
class Mod_MooGame_PlatForm_Mobile_getFriendsId {

	public function getFriendsId($hashData) {

		$mobile = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $hashData['sessionId'];
		$param['server_id'] = $hashData['serverId'];

		$rs = $mobile->friends('getFriendList', $param);

		if (!is_array($rs)) {
			return array();
		}

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Mobile_getFriendsId no data');
			return false;
		}

		$friendList = array();
		foreach ($rs['data']['friendList'] as $friendInfo) {
			$friendList[] = $friendInfo['uid'] . '__' . $this->MOD->platFormLabel;
		}
		return $friendList;
	}
}
