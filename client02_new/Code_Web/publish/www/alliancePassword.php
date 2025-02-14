<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs 	= $dbconfigs['IOS-All'];
$appDbs 	= $dbconfigs['Appstore-All'];

// 安卓1服
/*
$conf = array();
$conf['host'] 	= 'localhost:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '';
$conf['dbName'] = 'dragon_game';
$conf['char'] 	= 'utf8';	
*/

$platform = $_REQUEST['platform'];
$serverId = $_REQUEST['serverId'];
$playerId = $_REQUEST['playerId'];

if ($platform == 'android') {
	$dbconfig = $androidDbs;
} elseif ($platform == 'ios') {
	$dbconfig = $iosDbs;
} elseif ($platform == 'appstore') {
	$dbconfig = $appDbs;
}
$conf = $dbconfig[$serverId];
if(!$conf) {
exit("你选的服不存在,请确定你的服信息!");
}	
	
$link = mysql_connect($conf['host'], $conf['user'], $conf['pwd']);	
if (!$link) {
	echo '数据库连接失败!' . mysql_error();
	exit;
}

if (!@mysql_select_db($conf['dbName'])) {
	echo '选择数据库失败' . mysql_error();
	exit;
}		
mysql_set_charset($conf['char']);

$sql 	= "SELECT name,password FROM  `alliance` WHERE  playerId = ".$playerId;
$result = mysql_query($sql, $link);

$rs = array();
while($res = mysql_fetch_array($result)) {
	$rs['name'] = $res['name'];
	$rs['password'] = $res['password'];
}

echo "军团名称与密码如下:";
echo "<pre>";
print_r($rs);
echo "</pre>";




?>