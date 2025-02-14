<?php
class Mod_MooGame_FightEngine_FightLog_addMagicLog {
	function addMagicLog($atkerId, $magic, $deferId = null) {
		$data['round']			= Mod_MooGame_FightEngine_Control::$turnNum;
		$data['ackUniqueId']		= Mod_MooGame_FightEngine_Control::$ackNum;
		$data['type']			= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_MAGIC;
		$data['execRoleId']		= $atkerId;
		$data['beRoleId']		= $deferId;
		$data['magicId']		= $magic->id;
		$data['magicUqId']		= $magic->magicUqId;
		$data['magicName']		= $magic->magicName;
		$data['magicAimNum']		= $magic->magicAimNum;

		MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;

		return $data;
	}
}