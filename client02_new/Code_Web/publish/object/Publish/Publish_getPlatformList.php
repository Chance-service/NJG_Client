<?php
class Publish_getPlatformList {

	function getPlatformList() {
		
		$returnData = array();
		
		$platformDao = MooDao::get('Platform');
		$sql = "SELECT * FROM @TABLE ORDER BY  `pl_time` DESC ";
		$platformList = $platformDao->getAll($sql);
		if (!$platformList) {
			return $returnData;
		}
		
		foreach ($platformList as $info) {
			$tmp = array();
			$tmp['id'] = $info['pl_id'];
			$tmp['name'] = $info['pl_name'];
			$tmp['tag'] = $info['pl_tag'];
			$returnData[] = $tmp;
		}

		return $returnData;
	}
}