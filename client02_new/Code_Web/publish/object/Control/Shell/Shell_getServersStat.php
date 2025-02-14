<?php
class Control_Shell_getServersStat {
	function getServersStat() {
		$serverConf = MooConfig::get('game.servers');
		if($serverConf) {
			foreach ($serverConf as $k => $val) {
				$tag = $val['grep'];
				$commandInfo = "ps aux | grep '".$tag."' | grep 'Sl'  | awk '{print $2}'";
					
				$command = base64_encode($commandInfo);
				$command = str_replace("/","_",$command);
				$command = str_replace("=","-",$command);
					
				$url = "http://".$val['url'] . "/shell?cmd=" . $command ."&timeout=10000&user=hawk";
				$res = MooUtil::curl_send($url);
					
				$resArr = explode("\n",$res);
				$processIds = array();
				$processNum = 0;
				if($resArr)	{
					foreach ($resArr as $key => $val) {
						if ($val) {
							$processIds[] = $val;
						}
					}
					$processNum = count($processIds);
				}

				if ($processNum == 2) {
					$serverConf[$k]['stat'] = 1; //开服
				} else {
					$serverConf[$k]['stat'] = 0; // 关服
				}
			}
		}
		
		MooView::set("servers", $serverConf);
		
		MooView::render("serversStat");
	}
}