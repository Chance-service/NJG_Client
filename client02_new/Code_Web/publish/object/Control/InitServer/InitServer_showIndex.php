<?php
class Control_InitServer_showIndex {

	function showIndex() {
		
		$treeData = array();
		
		$gameId = MooForm::request('gameId');
		
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
		MooView::render('initServerIndex');
	}
}