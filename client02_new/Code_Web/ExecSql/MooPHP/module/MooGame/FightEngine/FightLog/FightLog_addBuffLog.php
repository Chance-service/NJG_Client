<?php
class Mod_MooGame_FightEngine_FightLog_addBuffLog {
	function addBuffLog($roleId, $beRoleId, $effect) {

		if ($effect->effectToProps == 'atk') {
			return true;
		}

		$data['round']		= Mod_MooGame_FightEngine_Control::$turnNum;
		$data['ackUniqueId']		= Mod_MooGame_FightEngine_Control::$ackNum;
		$data['type']		= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_BUFF;
		$data['execRoleId']	= $roleId;
		$data['beRoleId']	= $beRoleId;
		$data['effectId']	= $effect->id;
		$data['effectName']	= $effect->effectName;
		if ($effect->specialEffectId) {
			$data['specialEffectId'] = $effect->specialEffectId;
		}
		$data['magicId']	= $effect->magicId;
		$data['magicUqId']	= $effect->magicUqId;
		$data['magicName']	= $effect->magicName;
		if ($effect->magicRemove == Mod_MooGame_FightEngine_Magic::MAGIC_REMOVE_ROUND_START) {
			$data['magicRemove'] = $effect->magicRemove;
		}
		$data['magicAim']	= $effect->magicAim;
		$data['magicAimNum']	= $effect->magicAimNum;
		$data['uniqueId']	= $effect->uniqueId;
		$data['timeout']	= $effect->timeOut;
		if ($effect->buffId) {
			$data['buffId']	= $effect->buffId;
		}

		/*
		if ($effect->buffRealValue) {
			$data['buffRealValue']	= abs($effect->buffRealValue);
		} else {
			$buffValue = rand($effect->effectMinValue, $effect->effectMaxValue);
			$data['buffRealValue']	= abs($buffValue);
		}
		// */
		$buffValue = rand($effect->effectMinValue, $effect->effectMaxValue);
		$data['buffRealValue']	= abs($buffValue);

		$data['haveAnimation']	= $effect->haveAnimation;

		$endArr = end(MooMod::get('MooGame_FightEngine_FightLog')->fightLog);
		if ($endArr['propsChangeLog']) {
			$data['propsChangeLog'] = $endArr['propsChangeLog'];
		}

		MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;

		return true;
	}
}