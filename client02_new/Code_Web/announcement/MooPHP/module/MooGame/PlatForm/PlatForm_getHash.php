<?php
class Mod_MooGame_PlatForm_getHash {

	/**
	 * 返回基本用户信息数组
	 *
	 * @return  array $hash
		$hash['platForm']	= $this->Mod->platFormLabel;
		$hash['uId']		= $uId . '__' . $this->Mod->platFormLabel;
		$hash['sessionId']	= MooForm::request('xn_sig_session_key');
		$hash['skey']		= MooForm::request('xn_sig_api_key');
		$hash['platFormUid']	= MooForm::request('xn_sig_user');
		$hash['useOS']		= 'FALSE';
	 */
	public function getHash() {

		$hashData = Mod_MooGame_PlatForm::$hashData;

		if (!empty($hashData)) {
			return $hashData;
		}

		if (!$hash = Mod_MooGame_PlatForm::$hash) {
			//note  向下兼容 hash_key 写法
			$hash = MooForm::request('hashKey') ? MooForm::request('hashKey') : MooForm::request('hash_key');
		}
		if (!$hash) {
			return array();
		}

		$hashData = MooMod::get('MooGame_PlatForm')->decrypt($hash, md5(Mod_MooGame_PlatForm::$hashSecret . Mod_MooGame_PlatForm::$apiKey));
		if ($hashData) {
			Mod_MooGame_PlatForm::$hashData = $hashData;
			return $hashData;
		} else {
			return array();
		}
		
	}
}