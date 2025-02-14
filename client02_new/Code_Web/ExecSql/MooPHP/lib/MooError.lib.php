<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooError {
	private $errorMsg;
	
	static public function set($errorMsg) {
		$MooError = self::_getInstance();
		if (is_array($errorMsg)) {
			$errorMsg = array_filter($errorMsg);
			count($errorMsg) > 0 ? $MooError->errorMsg = array_merge($MooError->errorMsg, $errorMsg) : false;
		} else {
			$errorMsg ? $MooError->errorMsg[] = (string)$errorMsg : false;
		}
	}

	/**
	 * 获取当前记录的错误
	 *
	 * @return array
	 */
	static public function get() {
		$MooError = self::_getInstance();
		$errorMsg = $MooError->errorMsg;
		return $errorMsg;
	}
	/**
	 * 清空当前记录的错误
	 *
	 * @return array
	 */
	static public function clear() {
		$MooError = self::_getInstance();
		$MooError->errorMsg = array();
	}
	
	
	/**
	 * 单件
	 *
	 * @return object
	 */
	static private function _getInstance() {
		if (is_object($this) && $this instanceof MooError) {
			return $this;
		}
		static $MooError = null;
		if (!$MooError) {
			$MooError = new MooError();
		}
		return $MooError;
	}
}