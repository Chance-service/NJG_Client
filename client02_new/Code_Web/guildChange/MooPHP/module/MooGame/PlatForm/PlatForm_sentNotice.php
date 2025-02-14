<?php
class Mod_MooGame_PlatForm_sentNotice {
	function sentNotice($toIds, $message, $limited = false) {
		/**
		 * 给用户发送消息
		 *
		 * MooMod::get('MooGame_PlatForm')->sentNotice(array(1, 4), 'haha44444');
		 * @return boolean
		 */

		$hashData = MooMod::get('MooGame_PlatForm')->getHash();

		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		//note 针对发送者来做限定，这个可以不用限制得太死
		if ($limited && !$this->jugdeUid($hashData['uId'])) {
			return false;
		}

		//note 针对接受者来限定
		$limited && $toIds = $this->jugdeToIds($toIds);

		if(!$toIds) {
			return false;
		}

		// 是否是opensocial
		if ($hashData['useOS'] === 'TRUE') {
			$rs = $this->runOS($hashData, $toIds, $message);
		} else {
			$rs = $this->runF8($hashData, $toIds, $message);
		}
		return $rs;
	}


	private function jugdeUid($uId) {
		// 对发送通知加以限定
		$noticeTag = $uId . 'NoticeSend';
		$isSend = MooCache::get($noticeTag);
		if ($isSend) {
			$time = time() - $isSend['time'];
			//note 小于一分钟，大于20条后都不发
			if ($time < 60 || $isSend['nums'] >= 20) {
				return false;
			} else {
				$isSend['time'] = time();
				$isSend['nums'] = $isSend['nums'] + 1;
				MooCache::set($noticeTag, $isSend, 86400);
			}
		} else {
			$isSend['time'] = time();
			$isSend['nums'] = 1;
			MooCache::set($noticeTag, $isSend, 86400);
		}
		return true;
	}


	private function jugdeToIds($toIds) {

		$isSendIds = array();
		$toIds = explode(',', $toIds);
		foreach($toIds as $key=>$toId) {
			$noticeTag = $toId . 'NoticeReceipt';
			$isSend = MooCache::get($noticeTag);
			if ($isSend) {
				$time = time() - $isSend['time'];
				//note 15分钟内不要接受太多，或者接受超过了 20
				if ($time < 15 * 60 || $isSend['nums'] >= 20) {
					$isSendIds[] = $toId;
				} else {
					$isSend['time'] =  time();
					$isSend['nums'] = $isSend['nums'] + 1;
					 MooCache::set($noticeTag, $isSend, 86400);
				}
			} else {
				$isSend['time'] = time();
				$isSend['nums'] = 1;
				MooCache::set($noticeTag, $isSend, 86400);
			}
		}

		$toIds = array_diff($toIds, $isSendIds);
		if(count($toIds) > 0) {
			return implode(',', $toIds);
		}else {
			return false;
		}
	}


	private function runOS($hashData, $toIds, $message) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->sentNotice($toIds, $message);
	}

	private function runF8($hashData, $toIds, $message) {
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
			case 'IS' :
				$platForm = 'IsMole';break;
			case 'QD' :
				$platForm = 'Qidian';break;
			case 'QM':
				$platForm = 'Qimi';break;
			default :
				$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
				return false;
		}

		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->sentNotice($hashData, $toIds, $message);
		return $rs;
	}

}