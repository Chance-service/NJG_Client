<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 控制获取外部变量的类
 * 
 * example:
 * 
 * $item = array();
 * $item['badInt']		= 'int';
 * $item['int']			= 'int';
 * $item['badArr']		= 'array';
 * $item['arr']			= 'array';
 * $item['badTrim']		= 'trim';
 * $item['trim']		= 'trim';
 * 
 * $GET = Form::get($item);
 * print_r($GET);
 * $POST = Form::post($item);
 * print_r($POST);
 * $REQUEST = Form::request($item);
 * print_r($REQUEST);
 *
 */
final class MooForm implements MooFormInterface {
	/**
	 * 构造函数
	 *
	 */
	public function __construct() {
		exit('ERROR: The class is static');
	}

	/**
	 * 从$_GET数组中取出指定数据
	 *
	 * @param array $input
	 * @return array
	 */
	static public function get() {
		$input = func_get_args();
		return self::_get($_GET, $input);
	}

	/**
	 * 从$_POST数组中取出指定数据
	 *
	 * @param array $input
	 * @return array
	 */
	static public function post() {
		$input = func_get_args();
		return self::_get($_POST, $input);
	}

	/**
	 * 从$_REQUEST数组中取出指定数据
	 *
	 * @param array $input
	 * @return array
	 */
	static public function request() {
		$input = func_get_args();
		return self::_get($_REQUEST, $input);
	}

	/**
	 * 判别是否为post方法提交
	 * 
	 * @param mixed $btn 按纽名
	 * @return mixed
	 */
	static public function isSubmit($btn = null) {
		if ($btn) {
			return isset($_POST[$btn]) && $_POST[$btn] ? true : false;
		}
		return is_array($_POST) && count($_POST) > 0 ? true : false;
	}

	/**
	 * Get Request
	 *
	 * @param array $requests
	 * @param array $input
	 * @return array
	 */
	static private function _get($requests, $input) {
		if (!is_array($requests)) {
			return array();
		}

		// 如果$input参数不是数组
		if (count($input) == 1) {
			return $requests[current($input)];
		}

		// 如果$input是数组
		$data = array();
		foreach ($input as $key) {
			$data[$key] = isset($requests[$key]) ? $requests[$key] : null;
		}
		return $data;
	}
}