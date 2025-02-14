<?php
class Mod_MooGame_PlatForm_Qimi_getFriendsId {

	public function getFriendsId($hashData) {

		$qimi = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $hashData['sessionId'];

		$rs = $qimi->friends('getFriendList', $param);

		if (!is_array($rs)) {
			return array();
		}

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Qimi_getFriendsId no data');
			return false;
		}

		$friendList = array();
		foreach ($rs['data']['friendList'] as $friendInfo) {
			$friendList[] = $friendInfo['uid'] . '__' . $this->MOD->platFormLabel;
		}
		return $friendList;
	}
}
