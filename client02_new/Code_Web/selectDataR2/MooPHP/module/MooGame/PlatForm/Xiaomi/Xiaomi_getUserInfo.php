<?php
class Mod_MooGame_PlatForm_Xiaomi_getUserInfo {

	public function getUserInfo($pUid) {

		$data = array();
		$data['uId'] = $pUid . '__' . $this->MOD->platFormLabel;
		$data['uName'] = '';
		$data['uMail'] = $pUid;
		$data['uPic'] = '';
		$data['uSex'] = 'FEMALE';
		$data['uPlatFormUid'] = $pUid;

		return $data;
	}
}
