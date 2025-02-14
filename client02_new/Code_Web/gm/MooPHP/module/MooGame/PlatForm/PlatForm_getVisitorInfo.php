<?php
class Mod_MooGame_PlatForm_getVisitorInfo {
	/**
	 * 返回用户信息
	 *
	 * @return array $userInfo
		$userInfo['uId']	= $data['uId'];
		$userInfo['uName']	= $data['uName'];
		$userInfo['uPic']	= $data['uPic'];
		$userInfo['uSex']	= $data['uSex'];
		$userInfo['uSiteId']	= $data['uSiteId'];
		$userInfo['uUchid']	= $data['uUchid'];
		$userInfo['uPlatFormUid']	= $data['uPlatFormUid'];
	 */
	function getVisitorInfo() {
		
		static $userInfo = array();
		if ($userInfo) {
			return $userInfo;
		}

		$hashData = MooMod::get('MooGame_PlatForm')->getHash();

		if (!$hashData) {
			MooLog::error('Mod_MooGame_PlatForm_getVisitorInfo no hashData');
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		if ($hashData['useOS'] === 'TRUE') {
			$data = $this->runOS($hashData);
		} else {
			$data = $this->runF8($hashData);
		}

		if (!$data['uId']) {
			MooLog::error('Mod_MooGame_PlatForm_getVisitorInfo no uId or uName or uPic');
			$this->MOD->setMsg(MooConfig::get('system.errorCode.overtime'));
			return false;
		}

		return $data;
	}

	function runOS($hashData) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->getVisitorInfo($hashData);
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
			case 'Studivz' :
				$platForm = 'Studivz';break;
			case 'KX' :
				$platForm = 'Kaixin001';break;
			case 'IS' :
				$platForm = 'IsMole';break;
			case 'QD' :
				$platForm = 'Qidian';break;
			case 'QJ' :
				$platForm = 'Qoojoy';break;
			case 'MX' :
				$platForm = 'Mixi';break;
			// add by yangjiacheng,新版的api接口	
			case 'MixiNew' :
				$platForm = 'MixiNew';break;
			// add by yangjiacheng
			case 'YBG' :
				$platForm = 'Yabage';break;
			// add by yangjiacheng
			case 'VZ' :
				$platForm = 'VZ';break;
			// add by Kobe Bao
			case 'QQ' :
				$platForm = 'QQ';break;
			case 'CW':// 赛我网
				$platForm = 'Cyworld';break;
			case 'GL':// 盖亚
				$platForm = 'GonLine';break;
			case 'QM':
				$platForm = 'Qimi';break;
			// end
			default :
				$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
				return array();
		}
		if (!$data = MooMod::get('MooGame_PlatForm_' . $platForm)->getVisitorInfo($hashData)) {
			return array();
		}
		return $data;
	}
}
