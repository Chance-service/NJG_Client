<?php
// 生成小语种 权限
$game 		= $_REQUEST['game'];
$area 		= $_REQUEST['area'];
$lang 		= $_REQUEST['lang'];
$content 	= $_REQUEST['content'];

if(empty($game) || empty($area) || empty($lang) || empty($content)) {
	file_put_contents('logs/error.log', date('Y-m-d H:i:s') . "--data:". json_encode($_REQUEST) . "\n", FILE_APPEND);
	exit("error");
} else {
	$fileName = $game . "_" . $area . "_" . $lang . ".txt";
	file_put_contents('announce_all/' . $fileName, $content);
	exit("ok");
}