<?php
class Mod_MooGame_PlatForm_isPageFan {
	/**
	 * 判断是否为主页粉丝
	 *
	 * @return boolean
	 */
	function isPageFan() {

		$hashData = MooMod::get('MooGame_PlatForm')->getHash();

		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
			return false;
		}

		if ($hashData['useOS'] === 'TRUE') {
			return $this->runOS($hashData);
		} else {
			return $this->runF8($hashData);
		}
	}

	function runOS($hashData) {
		return false;
	}

	function runF8($hashData) {

		switch ($hashData['platForm']) {
			case 'MY' :
				return false;
			case 'SJ' :
				return false;
			case 'XN' :
				$platForm = 'Renren';break;
			case '51' :
				return false;
			case 'DE' :
				return false;
			case 'BAI' :
				return false;
			case 'FB' :
				$platForm = 'Facebook';break;
			case 'BD' :
				return false;
			case 'MS' :
				return false;
			case '360' :
				return false;
			case '139' :
				return false;
			case 'KX' :
				return false;
			case 'IS' :
				return false;
			case 'QD' :
				return false;
			case 'CW' :
				return false;
			default :
				$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
				return false;
		}

		$isPageFan = MooMod::get('MooGame_PlatForm_'.$platForm)->isPageFan($hashData);
		return $isPageFan;
	}
}
