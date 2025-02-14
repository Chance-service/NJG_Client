<?php
class Control_ServerOnOff_showRestartIndex {

	function showRestartIndex() {
		
		$treeData = array();
		
		$gameId = MooForm::request('gameId');
		
		// 获取发布权限 $publishPermit = array('beta' => 1, 'release' => 1);
		$publishPermit = MooObj::get('User_Group')->getPublishPermitBygameId($gameId);
		// 兼容处理 防止数据出错
		if (!$publishPermit) {
			$publishPermit = array('beta' => 0, 'release' => 0);
		}
		
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		
		$versionList = array();
		$publishVersionList = MooConfig::get('main.publishVersion');
		foreach ($publishVersionList as $key => $value) {
			if ($publishPermit[$key] == 1) {
				$treeData[$value] = array(
					'name' => $key,
					'type' => 'folder',
				);
			}	
		}
		foreach ($treeData as $key => $value) {
			$treeData[$key]['additionalParameters']['children'][] = array(
					'name' => '全选',
					'type' => 'item',
					'tag' => 'all',
			);
		}
		
		$serverList = MooObj::get('Publish')->getServerList($gameId);
		if ($serverList) {
			foreach ($serverList as $info) {
				$treeData[$info['version']]['additionalParameters']['children'][] = array(
						'name' => $info['name'],
						'type' => 'item',
						'value' => $info['id'],
				);
			}
		}
		
		$treeDataJson = MooJson::encode($treeData);
		MooView::set('gameId', $gameId);
		MooView::set('treeData', $treeDataJson);
		MooView::set('gameName', $gameInfo['gameName']);
		MooView::render('serverRestartIndex');
	}
}