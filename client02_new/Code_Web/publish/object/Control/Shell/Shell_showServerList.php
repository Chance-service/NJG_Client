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
		MooView::set('nowTime', date('Y-m-d H:i:s'));
		MooView::set('Time', date('H:i:s'));
		
		$serversConf = MooConfig::get('main.servers');
		if(!$getServers) {
			$timeout = 10000;
			MooView::set('timeout', $timeout);
			MooView::set('servers', $serversConf);
			MooView::render("shell");
		} else {
			if($serversConf && $command && $timeout) {
				$getServers = substr($getServers, 0, -1);
				$serversArr = explode(',', $getServers);
				
				$allServers = array();
				foreach ($serversConf as $key => $val) {
					$allServers[] = $key;
				}
				
				$urls = array();
				$curlResults = array();
				// $urls['wow'] = "http://203.195.147.93:5132/shell?params=cmd:ls&timeout=10&user=hawk";
				foreach($allServers as $key => $val) {
					if(in_array($val, $serversArr)) {
					    $url = $serversConf[$val]['url'] . "/shell?cmd=" . $command ."&timeout=" . $timeout . "&user=hawk";
					    $urls[$val] = $url;	
						$res = MooUtil::curl_send($url);
						
						if(!$res) {
							$res = "error!";
							$msg = "失败";
						} else {
							$msg = "完成";
						}
						$curlResults[$val] = $res;
						$servers[$val]['checked'] 	= 1;
						$servers[$val]['res'] 		= $res;
					} else {
						$curlResults[$val] = "";
						$servers[$val]['checked'] 	= 0;
						$msg = "";
						$servers[$val]['res'] 		= "";
					}
					
					// 结果写入
					$servers[$val]['game'] 		= $serversConf[$val]['game'];
					$servers[$val]['platform'] 	= $serversConf[$val]['platform'];
					$servers[$val]['serverId'] 	= $serversConf[$val]['serverId'];
					$servers[$val]['url'] 		= $serversConf[$val]['url'];
					$servers[$val]['desc'] 		= $serversConf[$val]['desc'];
					
					$servers[$val]['status']	= $msg;
					$servers[$val]['isView']	= 1;	//勾选上
				}
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
			
			MooView::render("shell");
		}
	}
}