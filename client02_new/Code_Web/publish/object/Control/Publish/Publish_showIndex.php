<?php
class Control_Publish_showIndex {

	function showIndex() {
		
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

		
		/*
		 var tree_data = {
			'for-sale' : {name: '发布', type: 'folder'},
			'vehicles' : {name: 'Vehicles', type: 'folder'},
			'tickets' : {name: 'Tickets', type: 'item'},
			'services' : {name: 'Services', type: 'item'},
			'personals' : {name: 'Personals', type: 'item'}
		}
		tree_data['for-sale']['additionalParameters'] = {
			'children' : {
				'all' : {name: 'all', type: 'item', tag: 'all'},
				'appliances' : {name: 'Appliances', type: 'item'},
				'arts-crafts' : {name: 'Arts & Crafts', type: 'item'},
				'clothing' : {name: 'Clothing', type: 'item'},
				'computers' : {name: 'Computers', type: 'item'},
				'jewelry' : {name: 'Jewelry', type: 'item'},
				'office-business' : {name: 'Office & Business', type: 'item'},
				'sports-fitness' : {name: 'Sports & Fitness', type: 'item'}
			}
		}
		tree_data['vehicles']['additionalParameters'] = {
			'children' : {
				'cars' : {name: 'Cars', type: 'folder'},
				'motorcycles' : {name: 'Motorcycles', type: 'item'},
				'boats' : {name: 'Boats', type: 'item'}
			}
		}
		tree_data['vehicles']['additionalParameters']['children']['cars']['additionalParameters'] = {
			'children' : {
				'classics' : {name: 'Classics', type: 'item', value: 'vehicles_cars_classics'},
				'convertibles' : {name: 'Convertibles', type: 'item', value: 'vehicles_cars_convertibles'},
				'coupes' : {name: 'Coupes', type: 'item'},
				'hatchbacks' : {name: 'Hatchbacks', type: 'item'},
				'hybrids' : {name: 'Hybrids', type: 'item'},
				'suvs' : {name: 'SUVs', type: 'item'},
				'sedans' : {name: 'Sedans', type: 'item'},
				'trucks' : {name: 'Trucks', type: 'item'}
			}
		}
		// */
		
		
		
		$treeDataJson = MooJson::encode($treeData);
		MooView::set('gameId', $gameId);
		MooView::set('treeData', $treeDataJson);
		MooView::set('gameName', $gameInfo['gameName']);
		MooView::render('publishIndex');
	}
}