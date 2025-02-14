<?php
class Mod_MooGame_PlatForm_Weibo_updateRank {

	public function updateRank($hashData, $score = 1, $rankKey = 1) {

		$weibo = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['uid'] = $hashData['platFormUid'];
		$param['rank_key'] = $rankKey;
		$param['rank_group'] = $hashData['serverId'];
		$param['score'] = $score;
		$param['access_token'] = $hashData['sessionId'];

		$rs = $weibo->mgp('updateForCp', $param);
		
		if ($rs['error_code']) {
			return false;
		}

		return true;
	}
}
