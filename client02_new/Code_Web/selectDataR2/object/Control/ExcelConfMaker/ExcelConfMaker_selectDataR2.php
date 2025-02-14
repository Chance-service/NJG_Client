<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document ConfMaker 配置生成模块
 * $Id: ConfMaker_demo.php starten $
 */
class Control_ExcelConfMaker_selectDataR2 {
	var $theConf 	= array();
	var $fileName 	= 'r2_selectData.conf.xls';
	var $tpl 		= ''; // 生成配置文件的模板
	var $confPHPTpl = '<?php
$CONF = ';
	
	public function selectDataR2() {	

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
			$res['serverId'] 		= $val['serverId'];
			$res['playerId']  		= 	trim($val['playerId']);
			$res['date']  			= 	$val['date'];
			$result[] = $res;
		}
		/*
		$confTpl = $this->confPHPTpl . format_array_to_string_byStarten($result);		
		MooFile::write(ROOT_PATH . '/conf/selectData_r2.conf.php', $confTpl);
		*/
		
		$dbconfigs		= MooConfig::get('hwgj_execsqldbconfig');
		$r2Dbconfigs 	= $dbconfigs['r2'];
		
		$dbconfs = $r2Dbconfigs;
		$selectDataArr = array();
		foreach ($result  as $key => $value) {
			$serverId 	= $value['serverId'];
			$playerId	  = $value['playerId'];
			$date	  	= $value['date'];
			
			$startTime = 0;
			$endTime   = strtotime($date) + 86400;
			$endTime   = date('Y-m-d H:i:s');

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
			
			$sql1 	= "SELECT id,puid,createTime,loginTime FROM  `player` WHERE  `id` =  '".$playerId ."' ";
			$result1 = mysql_query($sql1, $link);

			$rs = mysql_fetch_array($result1);
			$data = array();
			if ($rs) {
				$data[0] = $serverId;
				$data[1] = $rs['id'];
				$data[2] = $rs['puid'];
				$data[3] =  $rs['createTime'];
			} else {
				$data[0] = $serverId;
				$data[1] = $playerId;
				$data[2] = '-';
				$data[3] = '-';
			}
			
			$sql2 	= "SELECT sum(goodsCost) as nums FROM  `recharge` WHERE  `playerId` =  ".$playerId;
			
			$result2 = mysql_query($sql2, $link);
			
			$rs2 = mysql_fetch_array($result2);
						
			if ($rs2['nums']) {
				$data[4] = $rs2['nums'];
			} else {
				$data[4] = 0;
			}
			$data[5] = $date;

			$selectDataArr[] = $data;
		}

				// 标题框
		$excelRs = array(
			0 => array(
				0 => '',
				1 => '',
				2 => '',
				3 => '运营数据查询',
				4 => '',
				5 => '',
			),
			1 => array(
				0 => '所在服',
				1 => 'playerId',
				2 => 'puid',
				3 => 'createTime',
				4 => '充值金额',
				5 => '截止时间',
			),
		);	
	
	
	
		$excelRs = array_merge($excelRs, $selectDataArr);
		
		$writeExcelArr[0]['name'] = '运营数据查询';
		$writeExcelArr[0]['data'] = $excelRs;
		
		$path = ROOT_PATH . "/doc/excel/selectData/" . "selectDataResult_r2.xls";	
		
		$r = MooObj::get('Control_ExcelConfMaker_Excel')->write($path, $writeExcelArr);
		
		return $r;
	}
}