<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];

// 安卓
$platform = 'android'; 
$startServer = 1;
$endServer = 62;

// ios
$platform2 = 'ios'; 
$startServer2 = 1;
$endServer2 = 33;

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


	$endRs_100 = array();
	$endRs_300 = array();
	$endRs_500 = array();
	$endRs_1000 = array();
	$endRs_5000 = array();
	$endRs_20000 = array();
	
	
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

	// 统计1 - 5日 所有渠道的充值数据
	$startTime 	= strtotime("2014-12-01");
	$endTime 	= strtotime("2014-12-06");		


	$sql_100 = "select count(*) as sumNum from ( SELECT SUM(amount) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 100 and  TotalMoney < 300 )  as total";
	$result_100 = mysql_query($sql_100, $link);
	$res_100 = mysql_fetch_array($result_100);
	$endRs_100[$platform .'-'. $serverId] = $res_100['sumNum'];	

	$sql_300 = "select count(*) as sumNum from ( SELECT SUM(amount) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 300 and  TotalMoney < 500 )  as total";

	$result_100 = mysql_query($sql_300, $link);
	$res_300 = mysql_fetch_array($result_100);
	$endRs_300[$platform .'-'. $serverId] = $res_300['sumNum'];
	
	$sql_500 = "select count(*) as sumNum from ( SELECT SUM(amount) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 500 and  TotalMoney < 1000 )  as total";
	$result_500 = mysql_query($sql_500, $link);
	$res_500 = mysql_fetch_array($result_500);
	$endRs_500[$platform .'-'. $serverId] = $res_500['sumNum'];	

	$sql_1000 = "select count(*) as sumNum from ( SELECT SUM(amount) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 1000 and  TotalMoney < 5000 )  as total";
	$result_1000 = mysql_query($sql_1000, $link);
	$res_1000 = mysql_fetch_array($result_1000);
	$endRs_1000[$platform .'-'. $serverId] = $res_1000['sumNum'];


	$sql_5000 = "select count(*) as sumNum from ( SELECT SUM(amount) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 5000 and  TotalMoney < 20000 )  as total";
	$result_5000 = mysql_query($sql_5000, $link);
	$res_5000 = mysql_fetch_array($result_5000);
	$endRs_5000[$platform .'-'. $serverId] = $res_5000['sumNum'];


	$sql_20000 = "select count(*) as sumNum from ( SELECT SUM(amount) as TotalMoney , playerId  FROM  `recharge` where create_time > ".$startTime." and create_time < ".$endTime." group by playerId having TotalMoney >= 20000)  as total";
	$result_20000 = mysql_query($sql_20000, $link);
	$res_20000 = mysql_fetch_array($result_20000);
	$endRs_20000[$platform .'-'. $serverId] = $res_20000['sumNum'];

	}
	/*
	echo "<pre>";
	print_r($endRs_500);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_100);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_300);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_1000);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_5000);
	echo "</pre>";

	echo "<pre>";
	print_r($endRs_20000);
	echo "</pre>";
	*/

	$Total_500 = array_sum($endRs_500);
	$Total_100 = array_sum($endRs_100);
	$Total_300 = array_sum($endRs_300);
	$Total_1000 = array_sum($endRs_1000);
	$Total_5000 = array_sum($endRs_5000);
	$Total_20000 = array_sum($endRs_20000);


	$rsAll = array();
	$rsAll[$platform]['gold_500'] = $Total_500;
	$rsAll[$platform]['gold_100'] = $Total_100;
	$rsAll[$platform]['gold_300'] = $Total_300;
	$rsAll[$platform]['gold_1000'] = $Total_1000;
	$rsAll[$platform]['gold_5000'] = $Total_5000;
	$rsAll[$platform]['gold_20000'] = $Total_20000;

	/*
	echo "<pre>";
	print_r($Total_500);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_100);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_300);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_1000);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_5000);
	echo "</pre>";

	echo "<pre>";
	print_r($Total_20000);
	echo "</pre>";

	echo "<pre>";
	print_r($rsAll);
	echo "</pre>";
	*/
	return $rsAll;
}

?>
