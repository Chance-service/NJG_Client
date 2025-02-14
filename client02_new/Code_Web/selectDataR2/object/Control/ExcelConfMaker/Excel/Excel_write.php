<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document Excel 写入工具
 * $Id: Excel_write.php $
 */
class Control_ExcelConfMaker_Excel_write {
	/**
	 * 
	 * 写入工具Excel文件
	 * 
	 * 
	 */
	public function write($excelFile, $excelSheets) {
		if (!$excelFile || !$excelSheets || !is_array($excelSheets)) {
			return false;	
		}
		
		// 对象
		$makeExcel = new PHPExcel();
		$objWriter = PHPExcel_IOFactory::createWriter($makeExcel, 'Excel5');
		
		// 数据
		foreach ($excelSheets as $key => $sheet) {
			// 
			$sheetName = $sheet['name'];
			$sheetData = $this->format($sheet['data']);
			
			// 创建一个sheet
			$makeExcel->createSheet($key);
			// 设置excel活动sheet
			$makeExcel->setActiveSheetIndex($key);
			// 当前活动表
			$objActSheet = $makeExcel->getActiveSheet();
			// 设置活动sheet标题
			$objActSheet->setTitle($sheetName);      
			
			// 循环处理数据
			foreach ($sheetData as $sD) {
				foreach ($sD as $v) $objActSheet->setCellValue($v['name'], $v['val']);
			}
			
		}
		
		// 路径
		$dirPath = dirname($excelFile) . '/';
		if (!file_exists($dirPath)) @mkdir($dirPath, 0777);
		
		// 保存文件
		$objWriter->save($excelFile);
		
		return true;
	}
	
	// 格式话数据
	private function format($data) {
		$rs = array();
		foreach ($data as $key => $val) {
			$cols = $key + 1;
			foreach ($val as $k => $v) {
				$rows = $k + 1;
				$rs[$key][$k] = array('name' => $this->getCode($rows) . $cols, 'val' => $v);
			}
		}
		return $rs;
	}
	
	// 格式化列头键 A1 B1 C1 D1 等
	private function getCode($num) {
		$i = intval($num / 26);
		$j = $num % 26;
		$str = '';
		if ($num <= 26) {
			$str = chr($num + 64);
		} else {
			if ($j == 0) {
				$str .= chr($i + 63);
			} else {
				$str .= chr($i + 64);
			}
			if ($j == 0) {
				$str .= chr(26 + 64);
			} else {
				$str .= chr($j + 64);
			}
		}
		return $str;
	}
}