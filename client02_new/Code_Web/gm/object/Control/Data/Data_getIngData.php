<?php
class Control_Data_getIngData {

	function getIngData() {
			
		$dataInfo = array();
		$dataInfo['hasGetData'] = 0;

		$logPath = WEB_DIR . "/DataLog/realTimeData.log";	// 实时数据
		
		$isExists = MooFile::isExists($logPath);
		if ($isExists) {
			$dataInfo['hasGetData'] = 1;
		}
		echo MooJson::encode($dataInfo);
		exit;
	}
}