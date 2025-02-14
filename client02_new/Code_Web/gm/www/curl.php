<?php
require_once 'common.php';

/*
$data = '{"status":1,"id":1,"puid":"todd","name":"Milly.G","level":5,"exp":474,"golden":130,"vip":0,"silver":11394,"isOnline":"false"}';
$_REQUEST = MooJson::decode($data, true);

v($_REQUEST);

$newData = array();
foreach ($_REQUEST as $key => $val) {
	$arrData['key'] =  $key;
	$arrData['value'] =  $val;
	$newData[] = $arrData;
}

v($newData);
*/

$serverIp = "localhost";
$port	  = "5132";
$cmd	  = "playerinfo";
$userName = "hawk";

$params = array(
		'puid' => 'todd',
		'id'   => '1',
		'name'   => 'zhao'
);


$url = getUrl($serverIp, $port, $cmd, $userName, $params);

v($url);

function getUrl($serverIp, $port, $cmd, $userName, $params = array()) {
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
		$url = "http://{$serverIp}:{$port}/{$cmd}?params={$paramsStr}&user={$userName}";
	} else {
		$url = "http://{$serverIp}:{$port}/{$cmd}?user={$userName}";
	}
	
	return $url;
}