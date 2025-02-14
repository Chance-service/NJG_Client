<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document ConfMaker 配置生成模块
 * $Id: ConfMaker_demo.php starten $
 */
class Control_ExcelConfMaker_makelolSqlConf {
	var $theConf 	= array();
	var $fileName 	= 'lol_sql_hosts.conf.xls';
	var $tpl 		= ''; // 生成配置文件的模板
	var $confPHPTpl = '<?php
$CONF = ';
	public function makelolSqlConf() {	

		$this->setConf();
		
	}
	
	// 处理
	public function setConf() {
		$replace = array();
		$replace[] = '{name}';
		$replace[] = '{confId}';
		
		$file 	= ROOT_PATH . $this->OBJ->excelDir . $this->fileName;
		// ios 
		$rsIos 	= MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 0);		
		// android
		$rsAndroid 	= MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 1); 
		
		// appstore
		$rsAppstore = MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 2);
		
		// 测试服
/*		$rsTestServer = MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 3);		
		
		// 测试服 和 运维测试服
		foreach ($rsTestServer as $key => $val) {
			$type = $val['type'];
			$result[$type][$val['serverId']]['host'] 	= $val['cdb_ip'].':'.$val['cdb_port'];
			$result[$type][$val['serverId']]['user'] 	= $val['db_user'];
			$result[$type][$val['serverId']]['pwd'] 	= $val['cdb_password'];
			$result[$type][$val['serverId']]['dbName']	= $val['cdb_dbname'];
			$result[$type][$val['serverId']]['char']	= 'utf8';	
		}
*/		
		// ios
		$re = array();
		foreach ($rsIos as $key => $val) {
			$res['host'] 	= $val['cdb_ip'].':'.$val['cdb_port'];
			$res['user'] 	= $val['db_user'];
			$res['pwd']  	= trim($val['cdb_password']);
			$res['dbName']  = $val['cdb_dbname'];
			$res['char']	= 'utf8';
			$re[$val['serverId']] = $res;
		}
		
		// android
		$re2 = array();
		foreach ($rsAndroid as $key => $val) {
			$res2['host'] 	= $val['cdb_ip'].':'.$val['cdb_port'];
			$res2['user'] 	= $val['db_user'];
			$res2['pwd']  	= trim($val['cdb_password']);
			$res2['dbName']  = $val['cdb_dbname'];
			$res2['char']	= 'utf8';
			$re2[$val['serverId']] = $res2;
		}
		
		// appstore
		$re3 = array();
		foreach ($rsAppstore as $key => $val) {
			$res3['host'] 	= $val['cdb_ip'].':'.$val['cdb_port'];
			$res3['user'] 	= $val['db_user'];
			$res3['pwd']  	= trim($val['cdb_password']);
			$res3['dbName'] = $val['cdb_dbname'];
			$res3['char']	= 'utf8';
			$re3[$val['serverId']] = $res3;
		}
		
		$result['Android-All'] 	= $re2;
		$result['IOS-All'] 		= $re;		
		$result['Appstore-All'] = $re3;			
	
/*		echo "<pre>";
		print_r($result);
		echo "</pre>";
*/				
		$confTpl = $this->confPHPTpl . format_array_to_string_byStarten($result);		
		MooFile::write(ROOT_PATH . '/conf/lol_execsqldbconfig.conf.php', $confTpl);
		MooView::set('confTpl', highlight_string($confTpl, true));
		
		return $result;
	}
}