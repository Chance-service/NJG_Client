<?php
class Publish_getServerInfo {

	function getServerInfo($serverId) {
		
		$serverDao = MooDao::get('Server');
		$serverObj = $serverDao->load($serverId);
		if (!$serverObj) {
			return false;
		}
		
		$returnData = array();
		$returnData['gameId'] = $serverObj->s_game_id;
		
		$platforms = array();
		if ($serverObj->s_platforms) {
			$tmp = explode(',', $serverObj->s_platforms);
			foreach ($tmp as $val) {
				$platforms[$val] = $val;
			}
		}
		$returnData['platforms'] = $platforms;
		$returnData['serverTag'] = $serverObj->s_tag;
		$returnData['serverName'] = $serverObj->s_name;
		$returnData['version'] = $serverObj->s_version;
		$returnData['onlineServerDir'] = $serverObj->s_online_dir;
		$returnData['serverIp'] = $serverObj->s_ip;
		$returnData['serverUser'] = $serverObj->s_user;
		$returnData['sshPort'] = $serverObj->s_port;

		return $returnData;
	}
}