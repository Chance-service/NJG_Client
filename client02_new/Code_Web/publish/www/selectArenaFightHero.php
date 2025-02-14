<?php
require_once 'common.php';

/*
$conf = array();
$conf['host'] 	= '192.168.1.33:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '';
$conf['dbName'] = 'game';
$conf['char'] 	= 'utf8';

$androidDbs[1] = $conf;
$iosDbs[1] = $conf;
// */

//*
$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];
// */


$endRs = array();
// 安卓
for($serverId = 1; $serverId <= count($androidDbs); $serverId ++) {
	$conf = $androidDbs[$serverId];
		
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
	
	$platform = 'android';
	// 存储id 和 puid
	$rsIdPuIds = array();
	$rsIds = array();
	
	$sql 	= "SELECT playerId FROM  `rank_info` WHERE `type`=1 ORDER BY `rank` ASC LIMIT 0 , 10";
	$result = mysql_query($sql, $link);
	
	$tenPuids = array();
	while($res = mysql_fetch_array($result)) {
		$tenPuids[] = $res['playerId'];
	}
	
	foreach ($tenPuids as $playerId) {
		$battleSql = "SELECT * FROM  `battle` WHERE `playerId`={$playerId}";
		$battleResult = mysql_query($battleSql, $link);
		$tmpArr = array();
		while($res = mysql_fetch_array($battleResult)) {
			$tmpArr[] = array('itemId' => $res['itemId'], 'weaponitem' => $res['weaponitem'], 'jewelryitem' => $res['jewelryitem'], 'helmetitem' => $res['helmetitem'], 'bookitem' => $res['bookitem'], 'mountitem' => $res['mountitem'], 'armoritem' => $res['armoritem']);
		}
		$rsIdPuIds[$playerId] = $tmpArr;
	}

	$endRs[$platform][$serverId] = $rsIdPuIds;
}

// ios
for($serverId = 1; $serverId <= count($iosDbs); $serverId ++) {
	$conf = $iosDbs[$serverId];

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

	$platform = 'ios';
	// 存储id 和 puid
	$rsIdPuIds = array();
	$rsIds = array();

	$sql 	= "SELECT playerId FROM  `rank_info` WHERE `type`=1 ORDER BY `rank` ASC LIMIT 0 , 10";
	$result = mysql_query($sql, $link);

	$tenPuids = array();
	while($res = mysql_fetch_array($result)) {
		$tenPuids[] = $res['playerId'];
	}

	foreach ($tenPuids as $playerId) {
		$battleSql = "SELECT * FROM  `battle` WHERE `playerId`={$playerId}";
		$battleResult = mysql_query($battleSql, $link);
		$tmpArr = array();
		while($res = mysql_fetch_array($battleResult)) {
			if (!$res['weaponitem']) {
				$res['weaponitem'] = 0;
			}
			if (!$res['jewelryitem']) {
				$res['jewelryitem'] = 0;
			}
			if (!$res['helmetitem']) {
				$res['helmetitem'] = 0;
			}
			if (!$res['bookitem']) {
				$res['bookitem'] = 0;
			}
			if (!$res['mountitem']) {
				$res['mountitem'] = 0;
			}
			if (!$res['armoritem']) {
				$res['armoritem'] = 0;
			}
			$tmpArr[] = array('itemId' => $res['itemId'], 'weaponitem' => $res['weaponitem'], 'jewelryitem' => $res['jewelryitem'], 'helmetitem' => $res['helmetitem'], 'bookitem' => $res['bookitem'], 'mountitem' => $res['mountitem'], 'armoritem' => $res['armoritem']);
		}
		$rsIdPuIds[$playerId] = $tmpArr;
	}

	$endRs[$platform][$serverId] = $rsIdPuIds;

}

/*
// 标题框
$excelRs1 = array(
	1 => array(
		0 => '平台',
		1 => '服',
		2 => 'playerId',
		3 => '将配置id',
	),
);
// */
foreach ($endRs as $key => $val) {
	
	foreach ($val as $sId => $sVal) {
		//*
		foreach ($sVal as $pId => $pVal) {
			$tmpArray = array();
			foreach ($pVal as $itemId) {
				$tmpArr = array();
				$tmpArr[] = $key;
				$tmpArr[] = $sId;
				$tmpArr[] = $pId;
				$tmpArr[] = $itemId['itemId'];
				$tmpArr[] = $itemId['weaponitem'];
				$tmpArr[] = $itemId['jewelryitem'];
				$tmpArr[] = $itemId['helmetitem'];
				$tmpArr[] = $itemId['bookitem'];
				$tmpArr[] = $itemId['mountitem'];
				$tmpArr[] = $itemId['armoritem'];
				$tmpArray[] = $tmpArr;
				$kkk = implode('	', $tmpArr);
				echo $kkk . "<br/>";
			}
			//$excelRs1 = array_merge($excelRs1, $tmpArray);
		}
		// */
	}
	
}

/*
$writeExcelArr[0]['name'] = '各服竞技场前10名玩家所有的将详细';
$writeExcelArr[0]['data'] = $excelRs1;


echo "<pre>";
print_r($writeExcelArr);
echo "</pre>";


$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write('log.xls', $writeExcelArr);

var_dump(111, $rs);

exit;
// */

?>
