<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document ConfMaker 配置生成模块
 * $Id: ConfMaker_demo.php starten $
 */
class Control_ExcelConfMaker_selectData {
	var $theConf 	= array();
	var $fileName 	= 'selectData.conf.xls';
	var $tpl 		= ''; // 生成配置文件的模板
	var $confPHPTpl = '<?php
$CONF = ';
	
	public function selectData() {	

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
			$res['puid']  		= 	trim($val['puid']);
			$res['date']  		= 	$val['date'];
			$result[] = $res;
		}
		
		$confTpl = $this->confPHPTpl . format_array_to_string_byStarten($result);		
		MooFile::write(ROOT_PATH . '/conf/selectData.conf.php', $confTpl);
		
		$dbconfigs		= MooConfig::get('lz_execsqldbconfig');
		$androidDbs 	= $dbconfigs['Android-All'];
		$iosDbs 		= $dbconfigs['IOS-All'];
		$appstoreDbs 	= $dbconfigs['Appstore-All'];
		
		$dbconfs = $androidDbs;
		$selectDataArr = array();
		foreach ($result  as $key => $value) {
			$serverId = $value['serverId'];
			$puid	  = $value['puid'];
			$date	  = $value['date'];
			
			$startTime = strtotime($date);
			$endTime   = strtotime($date) + 86400;

			$conf = $dbconfs[$serverId];
			 
/* 测试服务器
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
			
			$sql1 	= "SELECT puid,name,deviceId,registertime,lastlogin FROM  `player` WHERE  `puid` =  '".$puid ."' ";
			$result1 = mysql_query($sql1, $link);

			$rs = mysql_fetch_array($result1);
			$data = array();
			if ($rs) {
				$data[0] = $serverId;	
				$data[1] = $rs['puid'];
				$data[2] = $rs['name'];
				$data[3] = $rs['deviceId'];
				$initDate = date('Ymd', $rs['registertime']);
				$lastLoginDate = date('Ymd', $rs['lastlogin']);
				if($initDate == $date) {
					$data[4] = 1;
				} else {
					$data[4] = 0;
				}
				
				if ($lastLoginDate == $date) {
					$data[5] = 1;
				} else {
					$data[5] = 0;
				}
				$data[6] = date('Y-m-d H:i:s', $rs['registertime']);
				$data[7] = date('Y-m-d H:i:s', $rs['lastlogin']);

			} else {
				$data[0] = $serverId;
				$data[1] = $puid;
				$data[2] = '-';
				$data[3] = '-';
				$data[4] = '-';
				$data[5] = '-';
				$data[6] = '-';
				$data[7] = '-';
			}
			
			$sql2 	= "SELECT sum(goodsCost) as nums FROM  `recharge` WHERE  `uid` =  '".$puid ."' and create_time >= ".$startTime." and create_time < ".$endTime;
			$result2 = mysql_query($sql2, $link);
			
			$rs2 = mysql_fetch_array($result2);
						
			if ($rs2['nums']) {
				$data[8] = $rs2['nums'];
			} else {
				$data[8] = 0;
			}
			$data[9] = $date;

			$selectDataArr[] = $data;
		}
		
		
				// 标题框
		$excelRs = array(
			0 => array(
				0 => '',
				1 => '',
				2 => '',
				3 => '',
				4 => '运营数据查询',
				5 => '',
				6 => '',
				7 => '',
				8 => '',
				9 => '',
			),
			1 => array(
				0 => '所在服',
				1 => 'puid',
				2 => '角色名',
				3 => '设备id',
				4 => '是否今日注册(1是,0否)',
				5 => '是否今日登录(1是,0否)',
				6 => '注册时间',
				7 => '上次登录时间',
				8 => '今日充值金额',
				9 => '查询日期',
			),
		);	
	
		$excelRs = array_merge($excelRs, $selectDataArr);
		
		$writeExcelArr[0]['name'] = '运营数据查询';
		$writeExcelArr[0]['data'] = $excelRs;
		
		$path = ROOT_PATH . "/doc/excel/selectData/" . "selectDataResult.xls";	
		
		$r = MooObj::get('Control_ExcelConfMaker_Excel')->write($path, $writeExcelArr);
		
		return $r;
	}
}