<?php
class Control_Publish_getIngExecLog {

	function getIngExecLog() {
		
		$logInfo = MooObj::get('Publish_Log')->getIngExecLog();
		
		echo MooJson::encode($logInfo);
		exit;
	}
}