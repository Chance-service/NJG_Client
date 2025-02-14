<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * 导出excel的类
 *
 * 例子：
ExcelUtil::createRow(array('姓名', '年龄', '职业'));
ExcelUtil::createRow(array('马顺仁', '26', '程序员'));
ExcelUtil::createRow(array('张三', '24', '销售'));
ExcelUtil::download();


$excel = new MooExcel();
$excel->createRow(array('姓名', '年龄', '职业'));
$excel->createRow(array('马顺仁', '26', '程序员'));
$excel->createRow(array('张三', '24', '销售'));
$excel->download();
 *
 */
class MooExcel {
	private $data = '';
	private $char = 'UTF-8';

	/**
	 * 生成一行
	 *
	 * @param array $row
	 */
	function createRow($row) {
		$excel = self::_getInstance();

		foreach ($row as $k => $v) {
			$row[$k] = str_replace(array("\t", "\n", '\t'), '', $v);
		}
		$data = implode("\t", $row);
		if ($excel->char != 'GBK') {
			$data = iconv($excel->char, 'GBK//IGNORE', $data);
		}
		$excel->data .= "{$data}\t\n";
	}

	/**
	 * 设置字符集
	 *
	 * @param string $char
	 */
	function setChar($char) {
		$excel = self::_getInstance();
		$excel->char = strtoupper($char);
	}

	/**
	 * 生成一个空行
	 *
	 */
	function createBlank() {
		$excel = self::_getInstance();
		$excel->data .= "\t\n";
	}

	/**
	 * 下载
	 *
	 * @param string $fileName
	 */
	function download($fileName = '') {
		$excel = self::_getInstance();
		$fileName = $fileName ? $fileName : date('ymd-Hi');
		header("Content-type:application/vnd.ms-excel; charset=utf-8");
		header("Content-Disposition:attachment;filename={$fileName}.xls");
		echo $excel->data;
		exit;
	}

	/**
	 * 工厂
	 *
	 * @return object
	 */
	private function _getInstance() {
		if (is_object($this) && $this instanceof MooExcel) {
			return $this;
		}
		static $excel = null;
		if (!is_object($excel)) {
			$excel = new MooExcel();
		}
		return $excel;
	}
}