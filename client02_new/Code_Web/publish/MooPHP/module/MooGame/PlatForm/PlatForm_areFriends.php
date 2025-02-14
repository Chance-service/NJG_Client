<?php
class Mod_MooGame_PlatForm_areFriends {
	/**
	 * 判断是否为好友
	 *
	 * @param string $uid1 uid1，包括平台的标识
	 * @param string $uid2 uid2，包括平台的标识
	 * @return boolean
	 */
	function areFriends($uid1, $uid2) {

		$hashData = MooMod::get('MooGame_PlatForm')->getHash();

		$uid1 = str_replace('__'.$hashData['platForm'], '', $uid1);
		$uid2 = str_replace('__'.$hashData['platForm'], '', $uid2);

		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
			return false;
		}

		if ($hashData['useOS'] === 'TRUE') {
			return $this->runOS($hashData, $uid1, $uid2);
		} else {
			return $this->runF8($hashData, $uid1, $uid2);
		}
	}

	function runOS($hashData, $uid1, $uid2) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->areFriends($hashData, $uid1, $uid2);
	}

	function runF8($hashData, $uid1, $uid2) {

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
			case 'KX' :
				$platForm = 'Kaixin001';break;
			case 'IS' :
				$platForm = 'IsMole';break;
			case 'QJ' :
				$platForm = 'Qoojoy';break;
			case 'QD' :
				$platForm = 'Qidian';break;
			case 'GL':// 盖亚
				$platForm = 'GonLine';break;
			default :
				$this->MOD->setMsg(MooConfig::get('error.errorCode.errorRequest'));
				return false;
		}

		$areFriend = MooMod::get('MooGame_PlatForm_'.$platForm)->areFriends($hashData, $uid1, $uid2);
		return $areFriend;
	}
}
