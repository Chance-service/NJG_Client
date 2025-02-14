<?php
class Control_checkAction {

	function checkAction($mod, $do) {
		
		if (!$mod || !$do) {
			return;
		}
		
		$gameId = MooForm::request('gameId');
		$parentNode = $childNode = '';
		if ($mod == 'Publish') {
			if ($do == 'showIndex' && $gameId) {
				$parentNode = 'publish';
				$childNode = "publish_{$gameId}";
			} elseif ($do == 'showPublishLog') {
				$parentNode = 'publishLog';
				$childNode = "publishLog_view";
			} elseif ($do == 'showLastPublishLog') {
				$parentNode = 'publishLog';
				$childNode = "publishLog_last";
			} elseif ($do == 'showAddGame') {
				$parentNode = 'game';
				$childNode = "game_add";
			} elseif ($do == 'showGameList') {
				$parentNode = 'game';
				$childNode = "game_manage";
			} elseif ($do == 'showAddPlatform') {
				$parentNode = 'platform';
				$childNode = "platform_add";
			} elseif ($do == 'showPlatformList') {
				$parentNode = 'platform';
				$childNode = "platform_manage";
			} elseif ($do == 'showAddServer') {
				$parentNode = 'server';
				$childNode = "server_add";
			} elseif ($do == 'showServerList') {
				$parentNode = 'server';
				$childNode = "server_manage";
			} elseif ($do == 'postData' && $gameId) {
				$parentNode = 'publish';
				$childNode = "publish_{$gameId}";
			}
		} elseif ($mod == 'User') {
			if ($do == 'add') {
				$parentNode = 'power';
				$childNode = "power_addUser";
			} elseif ($do == 'manage') {
				$parentNode = 'power';
				$childNode = "power_manageUser";
			} elseif ($do == 'permit') {
				$parentNode = 'power';
				$childNode = "power_addPower";
			} else {
				$parentNode = 'power';
				$childNode = "power_managePower";
			}
		} elseif ($mod == 'ServerOnOff') {
			if ($do == 'showOnIndex' && $gameId) {
				$parentNode = 'serverOn';
				$childNode = "serverOn_{$gameId}";
			} elseif ($do == 'showOffIndex' && $gameId) {
				$parentNode = 'serverOff';
				$childNode = "serverOff_{$gameId}";
			} elseif ($do == 'showLog') {
				$parentNode = 'serverOnOffLog';
				$childNode = "serverOnOffLog_view";
			} elseif ($do == 'showLastLog') {
				$parentNode = 'serverOnOffLog';
				$childNode = "serverOnOffLog_last";
			} elseif ($do == 'postData' && $gameId) {
				$type = MooForm::request('type');
				if ($type == 'on') {
					$parentNode = 'serverOn';
					$childNode = "serverOn_{$gameId}";
				} else {
					$parentNode = 'serverOff';
					$childNode = "serverOff_{$gameId}";
				}
			}
		} elseif ($mod == 'ExecSql') {
			if ($do == 'showSql') {
				$parentNode = 'updateSql';
				$childNode = "updateSql_exec";
			} elseif ($do == 'uploadSql') {
				$parentNode = 'updateSql';
				$childNode = "uploadSql_exec";
			} elseif ($do == 'uploadSqlConf') {
				$parentNode = 'updateSql';
				$childNode = "uploadSqlConf_exec";
			}
		} elseif ($mod == 'InitServer') {
			if ($do == 'showIndex' && $gameId) {
				$parentNode = 'initServer';
				$childNode = "initServer_{$gameId}";
			} elseif ($do == 'showLog') {
				$parentNode = 'initServerLog';
				$childNode = "initServerLog_view";
			} elseif ($do == 'showLastLog') {
				$parentNode = 'initServerLog';
				$childNode = "initServerLog_last";
			} elseif ($do == 'postData' && $gameId) {
				$parentNode = 'initServer';
				$childNode = "initServer_{$gameId}";
			}
		}
		
		if (!$parentNode || !$childNode) {
			return;
		}
		
		MooView::set('openNode', 1);
		MooView::set('parentNode', $parentNode);
		MooView::set('childNode', $childNode);
	}
}