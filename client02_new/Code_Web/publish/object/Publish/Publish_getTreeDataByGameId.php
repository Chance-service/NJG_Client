<?php
class Publish_getTreeDataByGameId {

	function getTreeDataByGameId($gameId, $serverIds = array()) {

		$treeData = array();
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		
		$versionList = array();
		$publishVersionList = MooConfig::get('main.publishVersion');
		foreach ($publishVersionList as $key => $value) {
			$treeData[$value] = array(
				'name' => $key,
				'type' => 'folder',
			);
		}
		foreach ($treeData as $key => $value) {
			$treeData[$key]['additionalParameters']['children'][] = array(
					'name' => '全选',
					'type' => 'item',
					'tag' => 'all',
			);
		}
		
		$all = array('all' => 1);
		$serverList = MooObj::get('Publish')->getServerList($gameId, $all);
		
		if ($serverList) {
			foreach ($serverList as $info) {
				// 显示已经选择
				$type = 'item';
				if($serverIds && in_array($info['id'], $serverIds)) {
					$type = 'selected';
				} 
				$treeData[$info['version']]['additionalParameters']['children'][] = array(
						'name' => $info['name'],
						'type' => $type,
						'value' => $info['id'],
				);
			}
		}
		
		$treeDataJson = MooJson::encode($treeData);
		return $treeDataJson;			
	}
}