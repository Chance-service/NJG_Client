<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooJson {
	static function encode($data) {
		return json_encode($data);
	}
	
	static function decode($data, $returnArray = true) {
		return json_decode($data, $returnArray);
	}
}