<?php
class Mod_MooGame_FightEngine_FightLog_addBossRebirthMobsLog {
	function addBossRebirthMobsLog($sendRoleId, $roleId, $rolePosition) {
		$data = array();
		$data['round'] = Mod_MooGame_FightEngine_Control::$turnNum;
		$data['ackUniqueId'] = Mod_MooGame_FightEngine_Control::$ackNum;
		$data['type'] = Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_BOSSREBIRTHMOBS;
		$data['sendRoleId'] = $sendRoleId;
		$data['roleId'] = $roleId;
		$data['rolePosition'] = $rolePosition;

		MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;
		return true;
	}
}