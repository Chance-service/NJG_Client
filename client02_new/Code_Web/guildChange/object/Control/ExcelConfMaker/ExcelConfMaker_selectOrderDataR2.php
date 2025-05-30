<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document ConfMaker 配置生成模块
 * $Id: ConfMaker_demo.php starten $
 */
class Control_ExcelConfMaker_selectOrderDataR2 {
	var $theConf 	= array();
	var $fileName 	= 'r2_selectData.conf.xls';
	var $tpl 		= ''; // 生成配置文件的模板
	var $confPHPTpl = '<?php
$CONF = ';
	
	public function selectOrderDataR2() {	

		$res = $this->setConf();
		
		return $res;
	}
	
	// 处理
	public function setConf() {
		$replace = array();
		$replace[] = '{name}';
		$replace[] = '{confId}';
	/*	
		$file 	= ROOT_PATH . $this->OBJ->excelDir . $this->fileName;

		// ios 
		$selectdatas 	= MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 0);	

		// ios
		$result = array();
		foreach ($selectdatas as $key => $val) {
			$res['serverId'] 		= $val['serverId'];
			$res['playerId']  		= 	trim($val['playerId']);
			$res['date']  			= 	$val['date'];
			$result[] = $res;
		}
*/		
		/*
		$confTpl = $this->confPHPTpl . format_array_to_string_byStarten($result);		
		MooFile::write(ROOT_PATH . '/conf/selectData_r2.conf.php', $confTpl);
		*/
		
		$dbconfigs		= MooConfig::get('hwgj_execsqldbconfig');
		$r2Dbconfigs 	= $dbconfigs['r2'];
		
		$dbconfs = $r2Dbconfigs;
		$arr = array();
		$selectDataArr = array();
		foreach ($dbconfs  as $serverId => $value) {
	
			
			$startTime   = "2015-01-09 00:00:00";
			$endTime     = "2015-04-10 00:00:00";

			$conf = $dbconfs[$serverId];
 // 测试服务器
/*
$conf = array();
$conf['host'] 	= '10.0.3.240:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '123456';
$conf['dbName'] = 'wow';
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
			
			$sql1 	= "select * from recharge where createTime >= '".$startTime."' and createTime <= '".$endTime."'";
			
			$result1 = mysql_query($sql1, $link);

			$rsArr = array();
			while($rs = mysql_fetch_array($result1)) {
				$data[0] = $serverId;
				$data[1] = 	$rs['orderSerial'];
				$data[2] = 	$rs['puid'];
				$data[3] =  $rs['goodsCost'];
				$data[4] =  $rs['createTime'];
				$rsArr[] = $data;
				$selectDataArr[] = $data;
			}
		}
				// 标题框
		$excelRs = array(
			0 => array(
				0 => '',
				1 => '',
				2 => '',
				3 => '账单数据查询',
				4 => '',
				5 => '',
			),
			1 => array(
				0 => '所在服',
				1 => 'orderSerial',
				2 => 'puid',
				3 => 'goodsCost',
				4 => 'createTime',
			),
		);	
	
		$excelRs = array_merge($excelRs, $selectDataArr);
		
		$writeExcelArr[0]['name'] = '运营数据查询';
		$writeExcelArr[0]['data'] = $excelRs;
		
		$path = ROOT_PATH . "/doc/excel/selectData/" . "selectOrders_r2.xls";	
		
		$r = MooObj::get('Control_ExcelConfMaker_Excel')->write($path, $writeExcelArr);
		
		return $r;
	}
}