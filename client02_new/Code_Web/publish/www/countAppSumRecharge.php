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
$endServer3 = 3;

$androidRes = selectRecharge($platform, $startServer, $endServer, $androidDbs);

$iosRes = selectRecharge($platform2, $startServer2, $endServer2, $iosDbs);

$appstoreRes = selectRecharge($platform3, $startServer3, $endServer3, $appstoreDbs);

/*
echo "<pre>";
print_r($androidRes);
echo "<pre>";

echo "<pre>";
print_r($iosRes);
echo "<pre>";
*/

echo "<pre>";
print_r($appstoreRes);
echo "<pre>";

$rechargeNum = array();
foreach($appstoreRes['appstore']['rechargeNum'] as $key => $val) {
	$rechargeNum['rechargeNum'][$key] = array_sum($val);
}

foreach($appstoreRes['appstore']['rechargeMoney'] as $key => $val) {
	$rechargeNum['rechargeMoney'][$key] = array_sum($val);
}

echo "<pre>";
print_r($rechargeNum);
echo "<pre>";

$totalMoney = array_sum($rechargeNum['rechargeMoney']);

echo "<pre>";
print_r($totalMoney);
echo "<pre>";

exit;



function selectRecharge($platform, $startServer, $endServer, $dbconfs) {
	
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
	
	// 查询时间
	$startTime = strtotime(MooForm::request('startDate'));
	$endTime = strtotime(MooForm::request('endDate')) + 86400;
	
	$rechargeConf =  array(	
		0,
		10,
		100,
		500,
		1000,
		5000,
	);
	
	$rs = array();
	// 总数
	$sum = count($rechargeConf);
	foreach($rechargeConf as $k => $val) {
		
		if ($k < $sum - 1) {
			$sql = "select count(*) as sumNum  from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= ".$rechargeConf[$k]." and  TotalMoney < ".$rechargeConf[$k+1]." )  as total";
			$result = mysql_query($sql, $link);
			$res = mysql_fetch_array($result);
			$endRs[$platform]['rechargeNum'][$val][$serverId] = $res['sumNum'];
			
			
			$sql2 = "select sum(TotalMoney) as TotalMoney from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= ".$rechargeConf[$k]." and  TotalMoney < ".$rechargeConf[$k+1]." )  as Totals";
			$result2 = mysql_query($sql2, $link);
			$res2 = mysql_fetch_array($result2);
			$endRs[$platform]['rechargeMoney'][$val][$serverId] = $res2['TotalMoney'];
	
		} else {
			$sql = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= ".$rechargeConf[$k]." )  as total";
			$result = mysql_query($sql, $link);
			$res = mysql_fetch_array($result);
			$endRs[$platform]['rechargeNum'][$val][$serverId] = $res['sumNum'];
			
			$sql2 = "select sum(TotalMoney) as TotalMoney  from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= ".$rechargeConf[$k]." )  as Totals";
			$result2 = mysql_query($sql2, $link);
			$res2 = mysql_fetch_array($result2);
			$endRs[$platform]['rechargeMoney'][$val][$serverId] = $res2['TotalMoney'];
		}
		
		}
	}
	
	return $endRs;
}

?>
