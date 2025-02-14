<?php
class Control_ServerOnOff_getIngExecLog {

	function getIngExecLog() {
		
		$logInfo = MooObj::get('ServerOnOff_Log')->getIngExecLog();
		
		echo MooJson::encode($logInfo);
		exit;
	}
}