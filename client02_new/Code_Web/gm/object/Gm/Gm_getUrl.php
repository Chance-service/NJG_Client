<?php
class Gm_getUrl {
	function getUrl($serverIpPort, $cmd, $userName, $params = array()) {
		$paramsStr = "";
		if ($params) {
			foreach ($params as $key => $val) {
				$param = $key . ":" . $val;
				if ($paramsStr) {
					$paramsStr .= ";" . $param;
				} else {
					$paramsStr = $param;
				}
			}
		}
		if ($paramsStr) {
			$url = "http://{$serverIpPort}/{$cmd}?params={$paramsStr}&user={$userName}";
		} else {
			$url = "http://{$serverIpPort}/{$cmd}?user={$userName}";
		}
		
		$date = date("Y-m-d");
		$log = ROOT_PATH . "/urlLogs/" . "url.log." . $date;
		
		MooFile::write($log, date('Y-m-d H:i:s') ."--" . $url."\n", true);
		return $url;
	}
}