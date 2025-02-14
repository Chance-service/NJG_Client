<?php
class Mod_MooGame_FightEngine_FightLog_addAttackLog {
	function addAttackLog($atkerId, $deferId, $fightValue = 0, $magicInfo = 0, $isBlewOrRebirth = 0, $isAssassination = 0, $isChase = 0) {

		$beRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($deferId);

		$data['round']		= Mod_MooGame_FightEngine_Control::$turnNum;
		$data['ackUniqueId']		= Mod_MooGame_FightEngine_Control::$ackNum;
		$data['type']		= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_ATTACK;
		$data['execRoleId']	= $atkerId;
		$data['beRoleId']	= $deferId;
		$data['harm']		= $fightValue;
		if ($isBlewOrRebirth) {
			if ($isBlewOrRebirth == 1) {
				$data['isBlew'] = 1;
			} elseif ($isBlewOrRebirth == 2) {
				$data['isRebirth'] = 1;
			}
		}
		if ($isAssassination) {
			$data['isAssassination'] = 1;
		}
		if ($isChase) {
			$data['isChase'] = 1;
		}
		$data['propsChangeLog']	= $beRole ? $beRole->propsChangeLog : array();
		
		MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;
		
		if ($magicInfo) {
			Mod_MooGame_FightEngine_Control::$ackNum++;
			$data['round']		= Mod_MooGame_FightEngine_Control::$turnNum;
			$data['ackUniqueId']		= Mod_MooGame_FightEngine_Control::$ackNum;
			$data['type']		= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_ATTACK;
			$data['execRoleId']	= $atkerId;
			$data['beRoleId']	= $deferId;
			$data['harm']		= $fightValue;
			$data['magicUqId']		= $magicInfo['magicUqId'];
			$data['magicId']		= $magicInfo['magicId'];
			$data['propsChangeLog']	= $beRole ? $beRole->propsChangeLog : array();
			MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;
		}

		$beRole->propsChangeLog = array();
		return true;
	}
}