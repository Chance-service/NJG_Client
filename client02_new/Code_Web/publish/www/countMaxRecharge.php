<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];
$appstoreDbs = $dbconfigs['Appstore-All'];

// 安卓
$platform = 'android'; 
$startServer = 1;
$endServer = count($androidDbs);

// ios
$platform2 = 'ios'; 
$startServer2 = 1;
$endServer2 = count($iosDbs);

// appstore
$platform3 = 'appstore'; 
$startServer3 = 1;
$endServer3 = count($appstoreDbs);

$androidRes = selectRecharge($platform, $startServer, $endServer, $androidDbs);

$iosRes = selectRecharge($platform2, $startServer2, $endServer2, $iosDbs);

$appstoreRes = selectRecharge($platform3, $startServer3, $endServer3, $appstoreDbs);




echo "<pre>";
print_r($androidRes);
echo "<pre>";

echo "<pre>";
print_r($iosRes);
echo "<pre>";

echo "<pre>";
print_r($appstoreRes);
echo "<pre>";
exit;


function selectRecharge($platform, $startServer, $endServer, $dbconfs) {

	$endRs = array();
	for($serverId = $startServer; $serverId <= $endServer; $serverId ++) {

	$conf = $dbconfs[$serverId];

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
	
	$sql = "SELECT uid,sum(amount) as total FROM `recharge` group by uid order by  total desc limit 1";
	$result = mysql_query($sql, $link);
	$res = mysql_fetch_array($result);

	$endRs[$platform .'-'. $serverId]['puid'] = $res['uid'];
	$endRs[$platform .'-'. $serverId]['totalMoney'] = $res['total'];

	
	}
	return $endRs;
}
?>
