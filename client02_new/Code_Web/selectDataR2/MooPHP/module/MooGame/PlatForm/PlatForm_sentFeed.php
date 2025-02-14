<?php
class Mod_MooGame_PlatForm_sentFeed {
	function sentFeed($template, $limited = false) {
		/**
		 * MooMod::get('MooGame_PlatForm')->sentFeed(array('uid' => $userInfo['uId'], 'title_data' => '1', 'body_data' => '2', 'body_template' => '3', 'body_general' => '4','image' => 'http://images.vancl.com/zhuanti/women/kuzi_20100809/kuzi_00.jpg'));
		 * limited 是否限制本次的发送
		 * @return 1
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
		// 是否是opensocial
		if ($hashData['useOS'] === 'TRUE') {
			$rs = $this->runOS($hashData, $template);
		} else {
			$rs = $this->runF8($hashData, $template);
		}

		return $rs;
	}
	private function jugdeUid($uId) {
		$feedTag = $uId . 'FeedSend';
		$isSend = MooCache::get($feedTag);
		$date = date('Y-m-d');
		if ($isSend) {
			$time = time() - $isSend['time'];
			if ($isSend['date'] == $date) {
				if ($isSend['nums'] >= 20) {
					return false;
				} else {
					$isSend['time'] = $time;
					$isSend['nums'] = $isSend['nums'] + 1;
				}
			} else {
				$isSend['time'] = $time;
				$isSend['nums'] = $isSend['nums'] + 1;
				$isSend['date'] = $date;
			}
		} else {
			$isSend['time']  = time();
			$isSend['nums'] = 1;
			$isSend['date'] = $date;
		}
		MooCache::set($feedTag, $isSend, 86400);
		return true;
	}

	private function runOS($hashData, $template) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->sentFeed($hashData, $template);
	}

	private function runF8($hashData, $template) {
		switch ($hashData['platForm']) {
			case 'MY' :
				$platForm = 'Manyou';break;
			case 'SJ' :
				$platForm = 'Com4399';break;
			case 'XN' :
				$platForm = 'Renren';break;
			case '51' :
				$platForm = 'Com51';break;
			case '91' :
				$platForm = 'Com91';break;
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
			// modify by Kobe
			case 'KX' :
				$platForm = 'Kaixin001';
				break;
			case 'GL':// 盖亚
				$platForm = 'GonLine';break;
			case 'QM':
				$platForm = 'Qimi';break;
			// end
			default :
				$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
				return false;
		}

		$rs = MooMod::get('MooGame_PlatForm_'.$platForm)->sentFeed($hashData, $template);
		return $rs;
	}

}
