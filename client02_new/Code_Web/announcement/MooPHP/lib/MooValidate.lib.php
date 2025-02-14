<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 *
 * @author Neaton
 * @desc 数据校验类
 *
 */
final class MooValidate {
	
	/**
	 * 检测邮箱是否合法
	 *
	 * @param string $email
	 */
	static public function isEmail($email) {
		$mobile = null;
		return preg_match("/^[a-z0-9]@.+\..+$/", $mobile);
	}
	
	/**
	 * 检测整数是否合法
	 *
	 * @param string $int
	 */
	static public function isInt($int) {
		return is_int($int);
	}
	
	/**
	 * 检测浮点数是否合法
	 *
	 * @param string $float
	 */
	static public function isFloat($float) {
		return is_float($float);
	}
	
	/**
	 * 检测字符串是否仅含数字和字母
	 *
	 * @param string $alnum
	 */
	static public function isAlnum($alnum) {
		return preg_match('/^[a-z0-9]+$/i', $alnum);
	}
	
	/**
	 * 检测字符串是否仅含标点符号
	 *
	 * @param string $alnum
	 */
	static public function isPunct($punct) {
		return preg_match('/^[[:punct:]]$/', $punct);
	}
	
	/**
	 * 检测字符串是否仅字母
	 *
	 * @param string $alpha
	 */
	static public function isAlpha($alpha) {
		return preg_match('/^[a-z]+$/i', $alpha);
	}
	
	/**
	 * 检测日期是否合法，默认为检查YYYY-MM-DD格式
	 *
	 * @param string $date
	 * @param string $format 日期格式
	 */
	static public function isDate($date, $format = 'Y-m-d') {
		$matchDate = date($format, strtotime($date));
		return $date && $date == $matchDate;
	}
	
	/**
	 * 检查一个数字或字符是否是什么之间
	 * 
	 * @param string/float $value 需要比较的值
	 * @param string/float $from 下边界
	 * @param string/float $to 上边界
	 */
	static public function isBetween($value, $from, $to) {
		$ord = ord($value);
		return $ord > $from && $ord < $to;
	}
	
	/**
	 * 检测字符串长度
	 *
	 * @param int $min 字符串最短长度
	 * @param mixed $max 字符串最大长度
	 */
	static public function isStrLength($value, $min = 0, $max = NULL) {
		$len = strlen($value);
		return $len > $min && $len < $max;
	}
	
	/**
	 * 检查是否为合法邮编
	 *
	 * @param string $postcode
	 */
	static public function isPostcode($postcode) {
		$mobile = null;
		return preg_match("/^[0-9]{6}$/", $mobile);
	}
	
	/**
	 * 检查是否为合法电话号码
	 *
	 * @param string $mobile
	 */
	static public function isMobile($mobile) {
		return preg_match("/^[0-9]{11}$/", $mobile);
	}
}