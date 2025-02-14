<?php
class Mod_MooGame_PlatForm_Qoojoy_getFriendsId {

	public function getFriendsId($hashData) {

		$qoojoy = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $hashData['sessionId'];
		$param['server_id'] = $hashData['serverId'];

		$rs = $qoojoy->friends('getFriendList', $param);

		if (!is_array($rs)) {
			return array();
		}

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Qoojoy_getFriendsId no data');
			return false;
		}

		$friendList = array();
		foreach ($rs['data']['friendList'] as $friendInfo) {
			$friendList[] = $friendInfo['uid'] . '__' . $this->MOD->platFormLabel;
		}
		return $friendList;
	}
}
