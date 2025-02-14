<?php
MooMod::get('MooGame_FightEngine_Control');

class Mod_MooGame_FightEngine_Effect_buff {
	/**
	 * 设置效果
	 * @param $role
	 * @param $beRole
	 * @param $trigger
	 */
	function buff($role, $noLog = false, $isTrap = 0, $execRole = 0) {
		
		// 根据概率判断buff是否会触发
		if (mt_rand(1, 100) > $this->MOD->buffRate) {
			return true;
		}
		
		foreach ($role->effect as $temId => $effect) {
			if(($effect->magicId == $this->MOD->magicId) && ($effect->id == $this->MOD->id)) {
				unset($role->effect[$temId]);
			}
		}		
		if ($isTrap) {				
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3454, $execRole->id, $role->id);
		}
				
		$this->MOD->startTime = Mod_MooGame_FightEngine_Control::$turnNum;
		
		// 将效果设置到目标角色身上
		if (Mod_MooGame_FightEngine_Control::$attacker[$role->id]) {
			Mod_MooGame_FightEngine_Control::$attacker[$role->id]->effect[$this->MOD->uniqueId] = $this->MOD;
		} elseif (Mod_MooGame_FightEngine_Control::$defender[$role->id]) {
			Mod_MooGame_FightEngine_Control::$defender[$role->id]->effect[$this->MOD->uniqueId] = $this->MOD;
		} else {
			$role->effect[$this->MOD->uniqueId] = $this->MOD;
		}
		
		if (!$noLog) {
			MooMod::get('MooGame_FightEngine_FightLog')->addBuffLog($this->MOD->execRoleId, $role->id, $this->MOD);
		}
		return true;
	}
}