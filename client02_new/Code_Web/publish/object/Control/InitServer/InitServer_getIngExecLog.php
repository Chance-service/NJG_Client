<?php
class Control_InitServer_getIngExecLog {

	function getIngExecLog() {
		
		$logInfo = MooObj::get('InitServer_Log')->getIngExecLog();
		
		echo MooJson::encode($logInfo);
		exit;
	}
}