<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document Excel 工具
 * $Id: Excel_read.php $
 */
class Control_ExcelConfMaker_Excel_read {
	/**
	 * 
	 * 读取Excel文件
	 * 
	 * 
	 */
	public function read($excelFile, $encoding = 'UTF8', $sheetNum = 0) {
		
		static $regObjRead = array();
		
		$fileKey = md5($excelFile);
		
		// 注册
		if (isset($regObjRead[$fileKey])) {
						
			$obj = $regObjRead[$fileKey];
			
		} else {
			// 
			$obj = new Spreadsheet_Excel_Reader();
			
			// 设置字符编码
			$obj->setOutputEncoding($encoding);
			
			// 读取
			$obj->read($excelFile);
			
			$regObjRead[$fileKey] = $obj;
		}
		
		// 只获取第一个表的数据
		!$sheetNum && $sheetNum = 0;
		$data 	= $obj->sheets[$sheetNum]['cells'];
		$kF 	= $data[2];
		$fType 	= $data[3];
		
		unset($data[1]); // 表说明
		unset($data[2]); // 字段名称
		unset($data[3]); // 字段类型
		unset($data[4]); // 字段说明
		
		// 没有数据
		if (!$data) return array();
		
		// 处理
		$rs = array();
		foreach ($data as $k => $v) {
			foreach ($kF as $kn => $kv) {
				$tmpV = '';
				switch ($fType[$kn]) {
					case 'int': 	$tmpV = isset($v[$kn]) ? intval($v[$kn]) : 0; break;
					case 'string': 	$tmpV = isset($v[$kn]) ? "{$v[$kn]}" : ''; break;
					case 'float': 	$tmpV = isset($v[$kn]) ? floatval($v[$kn]) : 0; break;
					default: $tmpV = isset($v[$kn]) ? $v[$kn] : 0;
				}
				$rs[$k][$kv] = $tmpV;
			}
		}
		
		// 
		sort($rs);
		
		return $rs;
		
	}
}