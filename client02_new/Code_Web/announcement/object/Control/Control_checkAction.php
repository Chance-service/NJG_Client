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
			} elseif ($do == 'showRestartIndex' && $gameId) {
				$parentNode = 'serverRestart';
				$childNode = "serverRestart_{$gameId}";
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
				} elseif ($type == 'off') {
					$parentNode = 'serverOff';
					$childNode = "serverOff_{$gameId}";
				} else {
					$parentNode = 'serverRestart';
					$childNode = "serverRestart_{$gameId}";
				}
			}
		} elseif ($mod == 'ExecSql') {
			if ($do == 'showSql' && $gameId) {
				$parentNode = 'updateSql';
				$parentNode2 = "updateSql_{$gameId}";
				$childNode = "ExecSql_{$gameId}";
			} elseif ($do == 'uploadSql' && $gameId) {
				$parentNode = 'updateSql';
				$parentNode2 = "updateSql_{$gameId}";
				$childNode = "upSql_{$gameId}";
			} elseif ($do == 'uploadSqlConf' && $gameId) {
				$parentNode = 'updateSql';
				$parentNode2 = "updateSql_{$gameId}";
				$childNode = "upSqlConf_{$gameId}";
			} elseif ($do == 'uploadSqlExcel' && $gameId) {
				$parentNode = 'updateSql';
				$parentNode2 = "updateSql_{$gameId}";
				$childNode = "upSqlExcel_{$gameId}";
			}
			MooView::set('display', 1);
			MooView::set('parentNode2', $parentNode2);
		}   elseif($mod == 'Game') {
			if($do == 'addGame') {
				$parentNode = 'power';
				$childNode = "power_addGame";	
			} elseif($do == 'showGameList'){
				$parentNode = 'power';
				$childNode = "power_manageGame";	
			}
			
		} elseif ($mod == 'Data') {
			if($do == 'showData') {
				$parentNode = 'data';
				$childNode = "data_showData";	
			} elseif($do == 'showStatData'){
				$parentNode = 'data';
				$childNode = "data_showStatData";	
			} elseif($do == 'showHistory'){
				$parentNode = 'data';
				$childNode = "data_showHistory";	
			}  elseif($do == 'getPlatformData'){
				$parentNode = 'data';
				$childNode = "data_getPlatformData";	
			} elseif($do == 'getChannelData'){
				$parentNode = 'data';
				$childNode = "data_getChannelData";	
			}
			
		} elseif ($mod == 'Recharge') {
			if($do == 'fetchOrder') {
				$parentNode = 'recharge';
				$childNode = "recharge_fetchOrder";	
			} elseif($do == 'fetchOrderByPuid'){
				$parentNode = 'recharge';
				$childNode = "recharge_fetchRecharge";	
			} elseif($do == 'fetchBills'){
				$parentNode = 'recharge';
				$childNode = "recharge_fetchBills";	
			}
		} elseif ($mod == 'Cdk') {
			if($do == 'create' || $do == 'addCdk') {
				$parentNode = 'cdk';
				$childNode = "cdk_create";	
			} elseif($do == 'cdkOperate' || $do == 'delCdkType' || $do == 'deleteCdk' || $do == 'resetCdk'){
				$parentNode = 'cdk';
				$childNode = "cdk_select";	
			} elseif($do == 'cdkUse' || $do == 'selectCdkType'){
				$parentNode = 'cdk';
				$childNode = "cdk_cdkUse";	
			}
		} elseif($mod == 'Shell') {
				$parentNode = 'serverControl';
				$childNode = "serverControl_shell";	
		}elseif($mod == 'Announce') {
			if($do == 'add') {
				$parentNode = 'data';
				$childNode = "data_add";	
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