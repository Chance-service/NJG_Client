<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];

// 安卓
$platform = 'android'; 
$startServer = 1;
$endServer = 60;

// ios
$platform2 = 'ios'; 
$startServer2 = 1;
$endServer2 = 32;

$androidRes = selectRecharge($platform, $startServer, $endServer, $androidDbs);

$iosRes = selectRecharge($platform2, $startServer2, $endServer2, $iosDbs);

echo "查询结果如下";
echo "<pre>";
print_r($androidRes);
echo "</pre>";

echo "<pre>";
print_r($iosRes);
echo "</pre>";
exit;



function selectRecharge($platform, $startServer, $endServer, $dbconfs) {

	$endRs_30 = array();
	$endRs_100 = array();
	$endRs_300 = array();
	$endRs_800 = array();
	$endRs_1500 = array();
	$endRs_3000 = array();
	
	
	for($serverId = $startServer; $serverId <= $endServer; $serverId ++) {

	$conf = $dbconfs[$serverId];
						
/*
	$conf = array();
	$conf['host'] 	= 'localhost:3306';
	$conf['user'] 	= 'root';
	$conf['pwd']  	= '';
	$conf['dbName'] = 'dragon_game';
	$conf['char'] 	= 'utf8';	
*/
		
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

	// 统计15 - 19日 所有渠道的充值数据
	$startTime 	= strtotime("2014-11-15");
	$endTime 	= strtotime("2014-11-20");		

	$sql_30 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 30 and  TotalMoney < 100 )  as total";
	$result_30 = mysql_query($sql_30, $link);
	$res_30 = mysql_fetch_array($result_30);
	$endRs_30[$platform .'-'. $serverId] = $res_30['sumNum'];		


	$sql_100 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 100 and  TotalMoney < 300 )  as total";
	$result_100 = mysql_query($sql_100, $link);
	$res_100 = mysql_fetch_array($result_100);
	$endRs_100[$platform .'-'. $serverId] = $res_100['sumNum'];	

	$sql_300 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 300 and  TotalMoney < 800 )  as total";

	$result_100 = mysql_query($sql_300, $link);
	$res_300 = mysql_fetch_array($result_100);
	$endRs_300[$platform .'-'. $serverId] = $res_300['sumNum'];


	$sql_800 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 800 and  TotalMoney < 1500 )  as total";
	$result_800 = mysql_query($sql_800, $link);
	$res_800 = mysql_fetch_array($result_800);
	$endRs_800[$platform .'-'. $serverId] = $res_800['sumNum'];


	$sql_1500 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 1500 and  TotalMoney < 3000 )  as total";
	$result_1500 = mysql_query($sql_1500, $link);
	$res_1500 = mysql_fetch_array($result_1500);
	$endRs_1500[$platform .'-'. $serverId] = $res_1500['sumNum'];


	$sql_3000 = "select count(*) as sumNum from ( SELECT SUM(goodsCost) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 3000)  as total";
	$result_3000 = mysql_query($sql_3000, $link);
	$res_3000 = mysql_fetch_array($result_3000);
	$endRs_3000[$platform .'-'. $serverId] = $res_3000['sumNum'];

	}
	/*
	echo "<pre>";
	print_r($endRs_30);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_100);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_300);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_800);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_1500);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_3000);
	echo "</pre>";
	*/

	$Total_30 = array_sum($endRs_30);
	$Total_100 = array_sum($endRs_100);
	$Total_300 = array_sum($endRs_300);
	$Total_800 = array_sum($endRs_800);
	$Total_1500 = array_sum($endRs_1500);
	$Total_3000 = array_sum($endRs_3000);


	$rsAll = array();
	$rsAll[$platform]['money_30'] = $Total_30;
	$rsAll[$platform]['money_100'] = $Total_100;
	$rsAll[$platform]['money_300'] = $Total_300;
	$rsAll[$platform]['money_800'] = $Total_800;
	$rsAll[$platform]['money_1500'] = $Total_1500;
	$rsAll[$platform]['money_3000'] = $Total_3000;

	/*
	echo "<pre>";
	print_r($Total_30);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_100);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_300);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_800);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_1500);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_3000);
	echo "</pre>";

	echo "<pre>";
	print_r($rsAll);
	echo "</pre>";
	*/
	return $rsAll;
}

?>
