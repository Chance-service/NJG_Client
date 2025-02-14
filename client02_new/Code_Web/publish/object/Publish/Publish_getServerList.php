<?php
class Publish_getServerList {

	function getServerList($gameId = 0, $serverIdArr = array()) {
		
		// 修改权限时候  获取所有服务器列表 不受权限影响 特殊处理
		if ($serverIdArr['all'] == 1) {
			$mod = 'addPermit';
			$serverIdArr = array();
		}
		
		$returnData = array();
		
		$serverDao = MooDao::get('Server');
		if ($gameId && $serverIdArr) {
			$sql = "SELECT * FROM @TABLE WHERE s_game_id=:gameId AND s_id IN (:serverIds)";
			$serverList = $serverDao->getAll($sql, array('gameId' => $gameId, 'serverIds' => $serverIdArr));
		} elseif ($serverIdArr) {
			$sql = "SELECT * FROM @TABLE WHERE s_id IN (:serverIds)";
			$serverList = $serverDao->getAll($sql, array('serverIds' => $serverIdArr));
		} elseif ($gameId) {
			$sql = "SELECT * FROM @TABLE WHERE `s_game_id`={$gameId} ORDER BY  `s_time` DESC ";
			$serverList = $serverDao->getAll($sql);
		} else {
			$sql = "SELECT * FROM @TABLE ORDER BY  `s_time` DESC ";
			$serverList = $serverDao->getAll($sql);
		}
		
		if (!$serverList) {
			return $returnData;
		}
		
		foreach ($serverList as $info) {
			$tmp = array();
			$tmp['id'] = $info['s_id'];
			$tmp['gameId'] = $info['s_game_id'];
			$tmp['name'] = $info['s_name'];
			$tmp['tag'] = $info['s_tag'];
			$tagArr = explode("_", $info['s_tag']);
			$tmp['sId'] = $tagArr[count($tagArr) - 1];
			$tmp['platforms'] = $info['s_platforms'];
			$tmp['version'] = $info['s_version'];
			$tmp['onlineServerDir'] = $info['s_online_dir'];
			$tmp['serverIp'] = $info['s_ip'];
			$tmp['serverUser'] = $info['s_user'];
			$tmp['sshPort'] = $info['s_port'];
			$returnData[] = $tmp;
		}
	
		$groupPermissionJson = MooObj::get('User')->getPermission();
		$serverIdPermitJson = $groupPermissionJson['serverIds'];
		$serverIdPermitArr = MooJson::decode($serverIdPermitJson, true);
		
		if ($serverIdPermitArr['isAll'] == 'no' && $mod != 'addPermit') {	
			$rsData = array();
			foreach ($returnData as $key => $val) {
				if (in_array($val['id'], $serverIdPermitArr['ids'])) {
					$rsData[] =	$val;
				}
			}			
			$returnData = $rsData;
		}
		
		MooArray::tdSort($returnData, 'platforms', SORT_DESC, 'sId', SORT_ASC);
		
		return $returnData;
	}
}