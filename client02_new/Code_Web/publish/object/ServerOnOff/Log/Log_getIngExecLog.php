<?php
class ServerOnOff_Log_getIngExecLog {

	function getIngExecLog() {

		$logData = array();
		$logData['isPublishIng'] = 0;

		$logPath = WEB_DIR . "/serverOnOffLog/serverOnOff.log";
		
		$isExists = MooFile::isExists($logPath);
		if ($isExists) {
			$logData['isPublishIng'] = 1;
			$log = MooFile::readAll($logPath);
			$log = htmlspecialchars($log);
			$log = str_replace("\n", "<br/>", $log);
			$logData['log'] = $log;
		}

		return $logData;
	}
}