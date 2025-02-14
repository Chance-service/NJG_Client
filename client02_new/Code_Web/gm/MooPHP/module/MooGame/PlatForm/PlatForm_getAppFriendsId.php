<?php
class Mod_MooGame_PlatForm_getAppFriendsId {

	/**
	 * 返回当前用户的已经安装好友列表信息
	 * @param $pageInfo 需要翻页向平台获取用户列表时需要传，其他情况不需要传，
	 * 例如 91手机平台:PageNo第几页页号(从1开始)、PageSize每页数量(5的倍数)
	 * @return array $friendList
	 */

	function getAppFriendsId($pageInfo = array()) {

		static $getAppFriendsData = null;
		if ($getAppFriendsData !== null) {
			return $getAppFriendsData;
		}

		$hashData = MooMod::get('MooGame_PlatForm')->getHash();
		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			$getAppFriendsData = false;
			return false;
		}

		if ($hashData['useOS'] === 'TRUE') {
			$getAppFriendsData =  $this->runOS($hashData, $pageInfo);
		} else {
			$getAppFriendsData = $this->runF8($hashData, $pageInfo);
		}

		return $getAppFriendsData;

	}

	function runOS($hashData, $pageInfo) {
		if ($pageInfo) {
			return MooMod::get('MooGame_PlatForm')->getAppFriendsId($hashData, $pageInfo);
		} else {
			return MooMod::get('MooGame_PlatForm')->getAppFriendsId($hashData);
		}
	}

	function runF8($hashData, $pageInfo) {
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
			case 'QJ' :
				$platForm = 'Qoojoy';break;
			case 'QD' :
				$platForm = 'Qidian';break;
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
				return false;
		}

		if ($pageInfo) {
			$friendsId = MooMod::get('MooGame_PlatForm_'.$platForm)->getAppFriendsId($hashData, $pageInfo);
		} else {
			$friendsId = MooMod::get('MooGame_PlatForm_'.$platForm)->getAppFriendsId($hashData);
		}
		return $friendsId;
	}

}
