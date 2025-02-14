<?php
require_once 'common.php';

// $file = ROOT_PATH . "/www/" . "enter_sendAward.xls";
$file = ROOT_PATH . "/www/" . "enter_sendAward_test.xls";
$selectdatas 	= MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 0);	
// v($selectdatas);
// 8000/item.php?username=4911119&itemid=30000_90008&count=2&serverid=1&content=%EC%9D%B4%EB%B2%A4%ED%8A%B8+%EC%B0%B8%EC%97%AC&time=1429319610&sign=e1da6c58b8d8151c573feb21a4a21f5b
$title = "";
$content = "재물신강림텍스트오류 보상";

$result = array();
foreach ($selectdatas as $key => $val) {
	$serverId = $val['serverId'];
	$puids = explode("_", $val['puid']);
	$username = $puids[1];
	$awards = explode("_", $val['award']);
	$itemid = $awards[0] . "_" . $awards[1];
	$count = $awards[2];
	$time = time();
	$trueKey = md5($username . $itemid . $count . $serverId . $title  .$content. $time);
	$url = "http://125.209.197.65:8000/item.php?username=" . $username . "&serverid=" . $serverId ."&itemid=" . $itemid . "&count=" . $count . "&content=" . $content . "&time=" . $time . "&sign=" . $trueKey;
	$res = curl_send($url);
	if ($res['result']) {
		$result[$serverId . "__" . $val['puid']] = 1;
	}  else {
		MooFile::write('sendAward.log', $url . "\n", true);
		$result[$serverId . "__" . $val['puid']] = 0;
	}
}

v($result);

function curl_send($url, $parameter = null) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $parameter);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$result = curl_exec($ch);
	curl_close($ch);
	return $result;
}

