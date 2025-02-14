<?php
class Mod_MooGame_PlatForm_getInviteInfo {
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
	function getInviteInfo($inviteToken) {
		$hashData = MooMod::get('MooGame_PlatForm')->getHash();
		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		if ($hashData['useOS'] === 'TRUE') {
			return $this->runOS($hashData, $inviteToken);
		} else {
			return $this->runF8($hashData, $inviteToken);
		}

	}

	function runOS($hashData, $inviteToken) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->getInviteInfo($hashData, $inviteToken);
	}

	function runF8($hashData, $inviteToken) {
		switch ($hashData['platForm']) {
			case 'MY' :
				$platForm = 'Manyou';break;
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
		if (!$data = MooMod::get('MooGame_PlatForm_' . $platForm)->getInviteInfo($hashData, $inviteToken)) {
			return array();
		}
		return $data;
	}
}