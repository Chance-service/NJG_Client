<?php
require_once 'common.php';

// $fileName1 = ROOT_PATH . "/doc/excel/cs_1.xls";
// $fileName2 = ROOT_PATH . "/doc/excel/cs_2.xls";
// $fileName3 = ROOT_PATH . "/doc/excel/cs_3.xls";

$fileName1 = ROOT_PATH . "/doc/excel/order_1.xls";
$fileName2 = ROOT_PATH . "/doc/excel/order_2.xls";


 $cs1 = MooObj::get('Control_ExcelConfMaker_Excel')->read($fileName1 ,'UTF-8', 0);

 $cs2 = MooObj::get('Control_ExcelConfMaker_Excel')->read($fileName2 ,'UTF-8', 0);

 $cs3 = MooObj::get('Control_ExcelConfMaker_Excel')->read($fileName3 ,'UTF-8', 0);

 v(count($cs1));
 v(count($cs2));
 v(count($cs3));

$newStr1 = array();
foreach ($cs1 as $key => $val) {
	$newStr1[] = $val['playerId'] .'_'. $val['serverId'] .'_'. $val['str'];
}

$newStr2 = array();
foreach ($cs2 as $key => $val) {
	$newStr2[] = $val['playerId'] .'_'. $val['serverId'] .'_'. $val['str'];
}

$newStr3 = array();
foreach ($cs3 as $key => $val) {
	$newStr3[] = $val['playerId'] .'_'. $val['serverId'] .'_'. $val['str'];
}

// 追加2
foreach ($newStr2 as $key => $val) {
 	if(!in_array($val, $newStr1)) {
 		$newStr1[] = $val;
 	} 
}

v(count($newStr1));

// 追加3
foreach ($newStr3 as $key => $val) {
	if(!in_array($val, $newStr1)) {
		$newStr1[] = $val;
	}
}

// v(count($newStr1));
// v($newStr1);

$resStr = array();
foreach ($newStr1 as $key => $val) {
	$arr = explode('_',$val);
	echo $arr[0] . "  " . $arr[1] . "  " . $arr[2] ."<br/>";
	
	$dataArr = MooJson::decode($arr[2]);
	v($dataArr['d']);
	$colorData = array();
	foreach ($dataArr['d'] as $k => $v) {
		if($v['c'] == 1) {
			$colorData[$k] = "红";
		} else if($v['c'] == 2) {
			$colorData[$k] = "绿";
		} else if($v['c'] == 3) {
			$colorData[$k] = "蓝";
		}  else if($v['c'] == 4) {
			$colorData[$k] = "金";
		}
	}
	
	$str = implode("  ", $colorData);
	
//	v($colorData);
//	v($str);
	
	$resStr[] = $arr;
}

// v($resStr);

exit;

// v($cs3);