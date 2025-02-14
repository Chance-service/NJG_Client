<?php
class Mod_MooGame_FightEngine_FightLog_addEffectLog {
	function addEffectLog($roleId, $beRoleId, $effect, $trigger = 0, $tmpLog = array()) {
		
		$data = array();
		$data['round']		= Mod_MooGame_FightEngine_Control::$turnNum;
		$data['beRoleId'] 	= $beRoleId;
		$data['trigger'] 	= $trigger;

		if ($effect->id != 0) {
			$beRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($beRoleId);

			$data['type']		= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_EFFECT;
			$data['ackUniqueId']		= Mod_MooGame_FightEngine_Control::$ackNum;
			$data['effectId'] 	= $effect->id;
			$data['effectName']	= $effect->effectName;
			if ($effect->specialEffectId) {
				$data['specialEffectId'] = $effect->specialEffectId;
			}
			$data['uniqueId']	= $effect->uniqueId;
			$data['execRoleId']	= $roleId;
			$data['atRoleId'] 	= $effect->atRoleId;
			$data['toProps']	= $effect->effectToProps;
			$data['value'] 		= $effect->effectRealValue;
			$data['magicId']	= $effect->magicId;
			$data['magicUqId']	= $effect->magicUqId;
			$data['magicName']	= $effect->magicName;
			if ($effect->magicRemove == Mod_MooGame_FightEngine_Magic::MAGIC_REMOVE_ROUND_START) {
				$data['magicRemove'] = $effect->magicRemove;
			}
			$data['magicAim']	= $effect->magicAim;
			$data['magicAimNum']	= $effect->magicAimNum;
			$data['propsChangeLog']	= $beRole ? $beRole->propsChangeLog : array();
			
			//增加第三数组第四个数据
			$magicConf = MooConfig::get('skill'); 
			$skill = array_merge($magicConf['skill2Conf'], $magicConf['skill3Conf']);
			foreach ($skill as $skillInfo) {
				$rebirthSkill[] = $skillInfo[id];
			}
			unset($rebirthSkill[3460]);
			if (in_array($effect->magicId, $rebirthSkill)) {
				$data['isRebirthSkill'] = true;
			}
			
			if (in_array($effect->magicId, array(3447, 3448, 3453))) {
				if ($effect->magicId == 3453) {
					$sendRoleId = $roleId;
					$atRoleId = $beRoleId;
					$value = 0;
				} else {
					$sendRoleId = $roleId;
					$atRoleId = $roleId;
					$value = $effect->effectMaxValue ? $effect->effectMaxValue : 0;
				}
				MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog($effect->magicId, $sendRoleId, $atRoleId, $value);
			}
			MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;

			$beRole->propsChangeLog = array();
		} else {
			
			$data['execRoleId']	= $roleId;
			$data['type']		= Mod_MooGame_FightEngine_FightLog::FIGHT_LOG_TYPE_DEAD;
			$data['ackUniqueId']		= Mod_MooGame_FightEngine_Control::$ackNum;
			
			if ($tmpLog) {
				$nowKey = count(MooMod::get('MooGame_FightEngine_FightLog')->fightLog);
				MooMod::get('MooGame_FightEngine_FightLog')->fightLog[$nowKey - 1]['propsChangeLog'][] = $tmpLog;
			} else {
				MooMod::get('MooGame_FightEngine_FightLog')->fightLog[] = $data;
			}
		}

		return $data;
	}
}