<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

require_once dirname(__FILE__) . '/dirty/dirty.inc.php';

/**
 * @desc 文字过滤类
 * 
 * expample:
 * $data = '操';
 * $data = MooFilter::getChar($data);
 * $data = '***';
 *
 */
class MooFilter {
	/**
	 * 过滤字符
	 *
	 * @param char $char
	 * @return char 字符
	 */
	static public function getChar($char) {
		$drityFile = LIB_PATH . '/dirty/dirty.txt';
		$dirty = new qp_dirty($drityFile);

		//note 过滤内容
		$str = $dirty->replace_dirty($char);
		return $str;
	}
	
	/**
	 * 检查字符
	 *
	 * @param char $char
	 * @return char 字符
	 */
	static public function checkChar($char) {
		$drityFile = LIB_PATH . '/dirty/dirty.txt';
		$dirty = new qp_dirty($drityFile);

		//note 过滤内容
		$rs = $dirty->check_dirty($char);
		return $rs;
	}
	
}