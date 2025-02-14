<?php
class Mod_MooGame_FightEngine_FightLog_addSpecialEffectLog {
	function addSpecialEffectLog($magicId, $sendRoleId, $atRoleId, $value = 0, $isImmunity = false, $round = 1, $ackUniqueId = 0, $isStarFight = false) {
		
		if (!$isStarFight && !Mod_MooGame_FightEngine_Control::$turnNum) {
			return true;
		}
		
		$data = array();
		if ($isStarFight) {
			$data['round'] = $round;
			$data['ackUniqueId'] = $ackUniqueId;
			$data['isRoundStar'] = 1;
		} else {
			$data['round'] = Mod_MooGame_FightEngine_Control::$turnNum;
			$data['ackUniqueId'] = Mod_MooGame_FightEngine_Control::$ackNum;
		}
		$data['type'] = Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_SPECIALEFFECT;
		$data['magicId'] = $magicId;
		$data['sendRoleId'] = $sendRoleId;
		$data['atRoleId'] = $atRoleId;
		$data['value'] = $value;
		$data['immunity'] = $isImmunity ? 1 : 0;

		MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;
		return true;
	}
}