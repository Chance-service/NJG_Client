<?php
class GlobalObject extends MooObject {

	protected function error($msg) {
		exit('Error request');
	}
	
	function showMessage($message) {
		echo MooJson::encode($message);
		exit;
	}

	function setMsg($message, $errorCode = '') {
		$debug = debug_backtrace();
		GlobalObject::debug($debug[0]['file'] . ':' . $debug[0]['line']);
		$message = $message . '__CODE__' . $errorCode;
		parent::setMsg($message);
	}

	function getMsg() {
		$msg = parent::getMsg();
		$message = array();
		foreach ((array)$msg as $row) {
			$m = explode('__CODE__', $row);
			$message[] = array('msg' => $m[0], 'code' => intval($m[1]));
		}
		return $message;
	}

	function debug($msg = '') {
		static $error = array();
		if ($msg) {
			$error[] = $msg;
		} else {
			return $error;
		}
	}
	
}
