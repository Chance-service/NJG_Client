<?php
class Control_Shell_showServerList {
	function showServerList() {
		
		$game = MooForm::request('game');
		$platform = MooForm::request('platform');
		
		$getServers = MooForm::request('servers');
		$commandInfo = MooForm::request('command');
		$command = base64_encode($commandInfo);
		$command = str_replace("/","_",$command);
		$command = str_replace("=","-",$command);
		$timeout = MooForm::request('timeout');
		
		if(!$game) {
			$timeout = 10000;
			MooView::set('timeout', $timeout);
			MooView::render("shellServerList");
		} else {
			$fetchServerUrl = MooConfig::get('main.url.fetch_server');
			$serverUrl  = $fetchServerUrl . "?game=" . $game;
			
			$serverInfo = MooUtil::curl_send($serverUrl);
			$serverInfoArr  =  MooJson::decode($serverInfo, true);
			
			$servers = array();
			if($serverInfoArr) {
				foreach ($serverInfoArr as $key => $val) {
					if(!$platforms) {
						$platforms[] = $val['platform'];
					} elseif(!in_array($val['platform'], $platforms)) {
						$platforms[] = $val['platform'];
					}
					$arr['platform'] 		=  $val['platform'];
					$arr['folder'] 			=  $val['folder'];
					if ($platform) {
						if ($arr['platform'] == $platform) {
							$arr['name'] 		=  $val['platform'] . $val['server'];
							$arr['ip']	 		= $val['ip'];
							$arr['script_port']	= $val['script_port'];
							$arr['res']	 		= '';
							$arr['status']	 	= '';
							$arr['dburl']	 	= $val['dburl'];
							
							if ($arr['ip'] && $arr['script_port']) {
								$arr['type']	 	= 1;	// 有效
							} else {
								$arr['type']	 	= 0;	// 无效 
							}
							$arr['isView']  = 0;
							$servers[$arr['name']] = $arr;
						}
					} else {
						$arr['name'] 		=  $val['platform'] . $val['server'];
						$arr['ip']	 		= $val['ip'];
						$arr['script_port']	= $val['script_port'];
						$arr['res']	 		= '';
						$arr['status']	 	= '';
						$arr['dburl']	 	= $val['dburl'];
						
						if ($arr['ip'] && $arr['script_port']) {
							$arr['type']	 	= 1;	// 有效
						} else {
							$arr['type']	 	= 0;	// 无效 
						}
						$arr['isView']  = 0;			// 是否勾选
						
						$servers[$arr['name']] = $arr;
					} 
				}
			}
			
			
			if($getServers && $command && $timeout) {
				$getServers = substr($getServers, 0, -1);
				$serversArr = explode(',', $getServers);
				$urls = array();
				$curlResults = array();
				// $urls['wow'] = "http://203.195.147.93:5132/shell?params=cmd:ls&timeout=10&user=hawk";
				foreach($serversArr as $key => $val) {
					// 无效的排除
					if($servers[$val]['type'] == 0) {
						continue;
					}
				    $url = "http://" . $servers[$val]['ip'] . ":" . $servers[$val]['script_port'] . "/shell?params=cmd:" . $command .";timeout:" . $timeout . "&user=hawk";
				    
				    $urls[$val] = $url;	
					$res = MooUtil::curl_send($url);
					if(!$res) {
						$res = "error!";
						$msg = "失败";
					} else {
						$msg = "完成";
					}
					$curlResults[$val] = $res;
					// 结果写入
					$servers[$val]['res'] 		= $res;
					$servers[$val]['status']	= $msg;
					$servers[$val]['isView']	= 1;	//勾选上
				}
			/*	
				// 移除没有被选中的
				foreach ($servers as $key => $val) {
					if(!in_array($key, $serversArr) || $servers[$key]['type'] == 0) {
						unset($servers[$key]);
					}
				}
			 */	
			}
			
			if($servers) {
				$selectAll = "all";
				MooView::set('selectAll', $selectAll);
				$selectNo = "全不选";
				MooView::set('selectNo', $selectNo);
			}
			
			if ($platform) {
				MooView::set('platform', $platform);
			}
			if(!$timeout) {
				$timeout = 10000;
			}
			MooView::set('timeout', $timeout);
			MooView::set('nowGame', $game);
			
			MooView::set('command', $commandInfo);
			
			MooView::set('servers', $servers);
			MooView::set('platforms', $platforms);
			
			MooView::render("shellServerList");
		}
	}
}