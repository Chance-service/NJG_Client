<?php
class Mod_MooGame_PlatForm_getNaFriendsId {
	
	/**
	 * 返回当前用户的未安装好友列表信息
	 * @return array $friendList
	 */

	function getNaFriendsId() {
		//note 所有好友
		$friendAllUids = MooMod::get('MooGame_PlatForm')->getFriendsId();

		//note 安装的好友
		$friendAppUids = MooMod::get('MooGame_PlatForm')->getAppFriendsId();

		//note 所有好友或安装的好友为空时，返回一个空数组
		if (!$friendAllUids) {
			return array();
		} else if(!$friendAppUids) {
			return $friendAllUids;
		}

		//note 未安装好友
		$friendNaUids = array_diff($friendAllUids, $friendAppUids);

		return $friendNaUids;
	}

}