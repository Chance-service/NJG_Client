<?php
class Mod_MooGame_FightEngine_FightLog_addTreasureEffectLog {
	function addTreasureEffectLog($magicId, $sendRoleId, $atRoleId = null, $value = 0) {
		$data = array();
		$data['round'] = Mod_MooGame_FightEngine_Control::$turnNum;
		$data['ackUniqueId'] = Mod_MooGame_FightEngine_Control::$ackNum;
		$data['type'] = Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_TREASUREEFFECT;
		$data['magicId'] = $magicId;
		$data['sendRoleId'] = $sendRoleId;
		if ($atRoleId) {
			$data['atRoleId'] = $atRoleId;
		} else {
			$data['atRoleId'] = $sendRoleId;
			$data['isRoundStar'] = 1;
		}
		$data['value'] = $value;

		MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;
		return true;
	}
}