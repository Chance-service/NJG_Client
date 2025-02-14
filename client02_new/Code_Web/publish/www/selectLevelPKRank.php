<?php
require_once('common.php');
$dbconf = MooConfig::get('lz_execsqldbconfig');
$appstoreConf = $dbconf['Appstore-All'];
$iosConf = $dbconf['IOS-All'];
$androidConf = $dbconf['Android-All'];

$platform = "android";
$server = 65;

// appstore 1服 sql 配置
// $conf = $appstoreConf[1];
// $conf = $iosConf[1];
$conf = $androidConf[$server];

$con = mysql_connect($conf['host'], $conf['user'], $conf['pwd']);

if(!$con) {
	die("连接失败");
}
mysql_select_db($conf['dbName']);

mysql_set_charset($conf['char']);

$sql =  'select * from rank_info where type = 1 and rank <= 100 order by rank asc limit 100';
$res = mysql_query($sql, $con);
$result = array();

while($rest = mysql_fetch_array($res)) {
	$rs['playerId']			= $rest['playerId'];
	$rs['rank']				= $rest['rank'];
	$result['pk'][] = $rs;
}

$sql2 =  'SELECT id,puid,level,exp FROM `player` order by level desc,exp desc limit 100';
$res = mysql_query($sql2, $con);
$i = 1;
while($rest = mysql_fetch_array($res)) {
	$rs['playerId']			= $rest['id'];
	$rs['level']			= $rest['level'];
	$rs['rank']				= $i;
	$result['level'][] = $rs;
	$i++;
}

$rsJson = MooJson::encode($result);
MooFile::write('pkLevelRank/'. $platform .'-' . $server . '.pkLevelRank.log.' . date('Y-m-d'), $rsJson, true);



