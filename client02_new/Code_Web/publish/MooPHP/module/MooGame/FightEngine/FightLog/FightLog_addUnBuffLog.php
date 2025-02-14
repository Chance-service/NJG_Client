<?php
class Mod_MooGame_FightEngine_FightLog_addUnBuffLog {
	/**
	 * 移除效果
	 *
	 * @param $actionOrder 0为出手后移除，1为出手前移除
	 */
	function addUnBuffLog($roleId, $beRoleId, $effect, $actionOrder = 0) {

		$data['ackUniqueId']	= Mod_MooGame_FightEngine_Control::$ackNum;
		$beRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($beRoleId);
		$data['round']			= Mod_MooGame_FightEngine_Control::$turnNum;
		$data['type']			= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_UNBUFF;
		$data['effectId']		= $effect->id;
		$data['effectName']		= $effect->effectName;
		if ($effect->specialEffectId) {
			$data['specialEffectId'] = $effect->specialEffectId;
		}
		$data['uniqueId']		= $effect->uniqueId;
		$data['magicId']		= $effect->magicId;
		$data['magicUqId']		= $effect->magicUqId;
		$data['magicName']		= $effect->magicName;
		if ($effect->magicRemove == Mod_MooGame_FightEngine_Magic::MAGIC_REMOVE_ROUND_START) {
			$data['magicRemove'] = $effect->magicRemove;
		}
		if ($effect->effectConfusion) {
			$data['effectConfusion'] = 1;
		}
		$data['execRoleId']		= $roleId;
		$data['atRoleId']		= $effect->atRoleId;
		$data['beRoleId']		= $beRoleId;
		$data['toProps']		= $effect->effectToProps;
		$data['value']			= $effect->effectRealValue;
		$data['propsChangeLog']	= $beRole->propsChangeLog;
		if ($actionOrder) {
			$data['actionOrder']	= 1;
		} else {
			$data['actionOrder']	= 0;
		}

		if ($effect->effectToProps != 'atk') {
			MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;
		}
		$beRole->propsChangeLog = array();

		return $data;
	}
}