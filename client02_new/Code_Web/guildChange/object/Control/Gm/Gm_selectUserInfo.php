<?php
class Control_Gm_selectUserInfo {
	function selectUserInfo() {
		$action = MooForm::request('action');
		
		$userOperation = MooConfig::get('useroperation.action');
		MooView::set('num', count($userOperation));
		MooView::set('userOperation', $userOperation);
		
		$serverOperation = MooConfig::get('serveroperation.action');
		MooView::set('num2', count($serverOperation));
		MooView::set('serverOperation', $serverOperation);
		
		if($action == 0) {
			MooView::render("gm_selectUserInfo");
		}else {
			$userName = MooObj::get('User')->getUserName();
			$game 	= MooForm::request('game');
			// 设置平台信息
			$channelInfo = MooObj::get('Game')->getPlatformByGame($game);
			if($channelInfo) {
				MooView::set('channelInfo', $channelInfo);
			}
			
			$type 	= MooForm::request('type');
			$role 	= MooForm::request('role');
			$puid 	= MooForm::request('puid');
			$id 	= MooForm::request('id');
			// playername/puid/playerid
			$params = array();
			if($type == "role") {
				$params['playername'] = $role;
				MooView::set('role', $role);
			} else if ($type == "puid") {
				$params['puid'] = $puid;
				MooView::set('puid', $puid);
			} else if($type == "id") {
				$params['playerid'] = $id;
				MooView::set('playerid', $id);
			}
			
			$server 	= MooForm::request('serverUrl');
			$serverLists = MooObj::get('Gm')->getServerListByGame($game);

			$channels = array();
			if($serverLists) {
				foreach($serverLists as $key=> $val) {
					if(!in_array($val['platform'], $channels)) {
						$channels[] = $val['platform'];
					}
					
				}
			}
			
			if($channels) {
				foreach($channels as $k => $v) {
					MooView::set('channel_'.$k,  $v);
				}
			}
			
			if($serverLists) {
				$serverUrl = $serverLists[$server]['url'];
			}
			
			$cmd = "playerinfo";
			if($params) {
				$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
				$data = MooUtil::curl_send($url);
			//	$data = '{"status":1,"id":1,"puid":"todd","name":"Milly.G","level":5,"exp":474,"golden":130,"vip":0,"silver":11394,"isOnline":"false"}';
				if ($data) {
					$dataArr = MooJson::decode($data, true);
					
					// 查询之后设置 playerid
					$playerid = $dataArr['id'];
					MooSession::set($userName . '_playerid', $playerid);
					
					$newData = array();
					foreach ($dataArr as $key => $val) {
						$arrData['key'] =  $key;
						$arrData['value'] =  $val;
						$newData[] = $arrData;
					}
					
					if($newData) {
						foreach ($newData as $k => $v) {
							if(in_array($v['key'], array('golden','vip','silver'))) {
								$newData[$k]['isChange'] = 1;
							} else {
								$newData[$k]['isChange'] = 0;
							}
						}
					}
					MooView::set('viewData', $newData);
				} else {
					$msg = "用户不存在";
					MooView::set('msg', $msg);
				}
			}
			
			MooView::set('nowGame', $game);
			MooView::set('nowServer', $server);
			MooView::set('serverLists', $serverLists);
			MooView::render("gm_selectUserInfo");
		}
	}
}