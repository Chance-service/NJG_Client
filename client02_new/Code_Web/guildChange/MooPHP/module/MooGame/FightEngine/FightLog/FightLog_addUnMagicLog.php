<?php
class Mod_MooGame_FightEngine_FightLog_addUnMagicLog {
	function addUnMagicLog($atkerId) {

		$data['round']		= Mod_MooGame_FightEngine_Control::$turnNum;
		$data['ackUniqueId']		= Mod_MooGame_FightEngine_Control::$ackNum;
		$data['type']		= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_UNMAGIC;
		$data['execRoleId']	= $atkerId;
		$data['propsChangeLog']	= array();
		MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;

		return true;
	}
}