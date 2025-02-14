<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document ConfMaker 配置生成模块
 * $Id: ConfMaker_demo.php starten $
 */
class Control_ExcelConfMaker_updateOrderTime {
	var $theConf 	= array();
	var $fileName 	= 'errorOrders.xls';
	var $tpl 		= ''; // 生成配置文件的模板
	var $confPHPTpl = '<?php
$CONF = ';
	
	public function updateOrderTime() {	

		$res = $this->setConf();
		
		return $res;
	}
	
	// 处理
	public function setConf() {
		$replace = array();
		$replace[] = '{name}';
		$replace[] = '{confId}';
		
		$file 	= ROOT_PATH . $this->OBJ->excelDir . $this->fileName;

		// ios 
		$selectdatas 	= MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 0);	
	
		// ios
		$result = array();
		foreach ($selectdatas as $key => $val) {
			$res['platfrom'] 	= trim($val['platfrom']);
			$res['serverId'] 	= $val['serverId'];
			$res['order']  		= 	trim($val['order']);
			$res['time']  		= 	$val['time'];
			$result[] = $res;
		}
		
//		$confTpl = $this->confPHPTpl . format_array_to_string_byStarten($result);		
//		MooFile::write(ROOT_PATH . '/conf/selectData.conf.php', $confTpl);
		
		$dbconfigs		= MooConfig::get('lz_execsqldbconfig');
		$androidDbs 	= $dbconfigs['Android-All'];
		$iosDbs 		= $dbconfigs['IOS-All'];
		$appstoreDbs 	= $dbconfigs['Appstore-All'];
		
		$resStr = "";
		$selectDataArr = array();
		foreach ($result  as $key => $value) {
			$platfrom = $value['platfrom'];
			// db选择
			if($platfrom == "android") {
				$dbconfs = $androidDbs;
			} else if($platfrom == "ios") {
				$dbconfs = $iosDbs;
			} else if($platfrom == "appstore") {
				$dbconfs = $appstoreDbs;
			}
			
			$serverId = $value['serverId'];
			$order	  = $value['order'];
			
			$time	  = $value['time'];
			$date 	  = date('Y-m-d H:i:s', $time);

			$conf = $dbconfs[$serverId];

/*
 // 测试服务器
$conf = array();
$conf['host'] 	= '10.0.3.240:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '123456';
$conf['dbName'] = 'dragon_game';
$conf['char'] 	= 'utf8';	
*/

			
			$link = mysql_connect($conf['host'], $conf['user'], $conf['pwd']);	
			if (!$link) {
				echo $serverId . '数据库连接失败!' . mysql_error();
				continue;
			}
		
			if (!@mysql_select_db($conf['dbName'])) {
				echo $serverId. '选择数据库失败' . mysql_error();
				continue;
			}		
			mysql_set_charset($conf['char']);
			
			$sql1 =  "UPDATE  `recharge` SET  `request_time` = '".$date."',`create_time` = '".$time."' WHERE  `CooOrderSerial` =  '".$order."'";
			
			//var_dump($sql1);
			
			$result1 = mysql_query($sql1, $link);
			
			if($result1) {
				$resStr .= $platfrom . "__" . $serverId . "__" . $order . "__" . $date . "__" . $time . "__" . "ok" . "<br/>";
			} else {
				$resStr .= $platfrom . "__" . $serverId . "__" . $order . "__" . $date . "__" . $time . "__" . "失败" . "<br/>";
			}
		}	
	
		return $resStr;
	}
}