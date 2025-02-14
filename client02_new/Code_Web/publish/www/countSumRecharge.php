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

// 统计总数量
$total = array();
foreach ($androidRes['android'] as $key=>$val) {
	$total[$key] = $androidRes['android'][$key] + $iosRes['ios'][$key] + $appstoreRes['appstore'][$key];
}

// 统计安卓 ios
$andIos = array();
foreach ($androidRes['android'] as $key=>$val) {
	$andIos[$key] = $androidRes['android'][$key] + $iosRes['ios'][$key];
}

$allData = array();

$allData['andIos'] = $andIos;
$allData['appstore'] = $appstoreRes['appstore'];
$allData['all'] = $total;

/*
echo "<pre>";
print_r($allData);
echo "<pre>";
*/

$rsData = MooJson::encode($allData);
print_r($rsData);
exit;



function selectRecharge($platform, $startServer, $endServer, $dbconfs) {
	$endRs_10 = array();
	$endRs_30 = array();
	$endRs_50 = array();
	$endRs_100 = array();
	$endRs_500 = array();
	$endRs_1000 = array();
	$endRs_2000 = array();
	
	
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
	
	$sql_10 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 10 and  TotalMoney < 30 )  as total";
	$result_10 = mysql_query($sql_10, $link);
	$res_10 = mysql_fetch_array($result_10);
	$endRs_10[$platform .'-'. $serverId] = $res_10['sumNum'];
	
	$sql_30 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 30 and  TotalMoney < 50 )  as total";
	$result_30 = mysql_query($sql_30, $link);
	$res_30 = mysql_fetch_array($result_30);
	$endRs_30[$platform .'-'. $serverId] = $res_30['sumNum'];

	$sql_50 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 50 and  TotalMoney < 100 )  as total";
	$result_50 = mysql_query($sql_50, $link);
	$res_50 = mysql_fetch_array($result_50);
	$endRs_50[$platform .'-'. $serverId] = $res_50['sumNum'];	


	$sql_100 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 100 and  TotalMoney < 500 )  as total";
	$result_100 = mysql_query($sql_100, $link);
	$res_100 = mysql_fetch_array($result_100);
	$endRs_100[$platform .'-'. $serverId] = $res_100['sumNum'];	


	$sql_500 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 500 and  TotalMoney < 1000 )  as total";
	$result_500 = mysql_query($sql_500, $link);
	$res_500 = mysql_fetch_array($result_500);
	$endRs_500[$platform .'-'. $serverId] = $res_500['sumNum'];


	$sql_1000 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 1000 and  TotalMoney < 2000 )  as total";
	$result_1000 = mysql_query($sql_1000, $link);
	$res_1000 = mysql_fetch_array($result_1000);
	$endRs_1000[$platform .'-'. $serverId] = $res_1000['sumNum'];


	$sql_2000 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 2000)  as total";
	$result_2000 = mysql_query($sql_2000, $link);
	$res_2000 = mysql_fetch_array($result_2000);
	$endRs_2000[$platform .'-'. $serverId] = $res_2000['sumNum'];

	}

	$Total_10 = array_sum($endRs_10);
	$Total_30 = array_sum($endRs_30);
	$Total_50 = array_sum($endRs_50);
	$Total_100 = array_sum($endRs_100);
	$Total_500 = array_sum($endRs_500);
	$Total_1000 = array_sum($endRs_1000);
	$Total_2000 = array_sum($endRs_2000);


	$rsAll = array();
	$rsAll[$platform]['money_10'] = $Total_10;
	$rsAll[$platform]['money_30'] = $Total_30;
	$rsAll[$platform]['money_50'] = $Total_50;
	$rsAll[$platform]['money_100'] = $Total_100;
	$rsAll[$platform]['money_500'] = $Total_500;
	$rsAll[$platform]['money_1000'] = $Total_1000;
	$rsAll[$platform]['money_2000'] = $Total_2000;

	return $rsAll;
}

?>
