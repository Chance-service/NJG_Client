<?php
class Mod_MooGame_PlatForm_getSite {
	/**
	 *
	 *
	 * @param array $inviteToken 平台返回来的invite_token
	 * @return array $data
		$data['inviteeUid']		  = $inviteInfo['invitee_uid']; //被邀请者
		$data['inviterUid']		  = $inviteInfo['inviter_uid']; //发起邀请者
		$data['inviterMsg'] 		  = '';//邀请信息
		$data['inviteTime'] 		  = $inviteInfo['invite_time'];//邀请者邀请时间
	 */
	function getSite() {
		$hashData = MooMod::get('MooGame_PlatForm')->getHash();
		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		if ($hashData['useOS'] === 'TRUE') {
			return $this->runOS($hashData);
		} else {
			return $this->runF8($hashData);
		}
	}

	function runOS($hashData) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->getSite();
	}

	function runF8($hashData) {
		switch ($hashData['platForm']) {
			case 'MY' :
				$platForm = 'Manyou';break;
			case 'SJ' :
				$platForm = 'Com4399';break;
			case 'XN' :
				$platForm = 'Renren';break;
			case '51' :
				$platForm = 'Com51';break;
			case 'DE' :
				$platForm = 'Debug';break;
			case 'BAI' :
				$platForm = 'Baishehui';break;
			case 'FB' :
				$platForm = 'Facebook';break;
			case 'BD' :
				$platForm = 'Baidu';break;
			case 'MS' :
				$platForm = 'Myspace';break;
			case '360' :
				$platForm = 'Com360';break;
			case '139' :
				$platForm = 'Com139';break;
			case 'QD' :
				$platForm = 'Qidian';break;
			default :
				$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
				return array();
		}
		if (!$data = MooMod::get('MooGame_PlatForm_' . $platForm)->getSite()) {
			return array();
		}
		return $data;
	}
}