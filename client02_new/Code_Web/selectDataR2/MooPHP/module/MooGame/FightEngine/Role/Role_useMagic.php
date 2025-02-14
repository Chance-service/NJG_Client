<?php

class Mod_MooGame_FightEngine_Role_useMagic {
	/**
	 * 魔法使用
	 */
	function useMagic($role, $magic, $noLog = false) {
		if (!$role || !$magic) {
			return false;
		}

		// 进攻时触发条件
		$effectCondition = array(
			Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT,
			Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT_MAGIC,
		);

		// 判断进攻方是否有满足条件触发的Effect
		foreach ((array)$this->MOD->effect as $effect) {
			if (array_intersect($effectCondition, $effect->trigger)) {
				if (in_array($effect->magicAim, array(Mod_MooGame_FightEngine_Magic::MAGIC_AIM_GROUP, Mod_MooGame_FightEngine_Magic::MAGIC_AIM_SELF))) {
					$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $this->MOD, $noLog);
				} else {
					$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $role, $noLog);
				}
				
			}
		}
		
		//青龙log
		if ($this->MOD->dragon) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3525, $this->MOD->id, $role->id);		
		}
		
		// 触发魔法
		$magic->exec($role, $noLog);
		
		$isHarmSkill = false;
		foreach ((array)$magic->effect as $effect) {
			if (in_array($effect->effectByProps, array('harm', 'initHarm'))  || 
				(in_array($effect->effectByProps, array('hp')) && $effect->effectMaxValue < 0 && $effect->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_ENEMY)) {
				$isHarmSkill = true;
			}
		}
		
		// 进攻后触发条件
		$fightAfterEffectCondition = array(
				Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT_AFTER);
		
		foreach ((array)$this->MOD->effect as $effect) {
			
			// 如果是群攻技能，则在攻击后产生增益效果的转生技能只能产生作用一次，不能每打一个人自己一次
			if (Mod_MooGame_FightEngine_Control::$gainSkillArr[$this->MOD->id][$effect->magicId]) {
				continue;
			}
			Mod_MooGame_FightEngine_Control::$gainSkillArr[$this->MOD->id][$effect->magicId] = $effect->magicId;
			
			// 判断进攻后是否有满足条件触发的Effect
			if ($isHarmSkill && array_intersect($fightAfterEffectCondition, $effect->trigger)) {
			
				// 判断是否是对己方起效
				if (in_array($effect->magicAim, array(Mod_MooGame_FightEngine_Magic::MAGIC_AIM_GROUP, Mod_MooGame_FightEngine_Magic::MAGIC_AIM_SELF))) {
						
					// 瘟疫，攻击对方时30%让对方中毒（中毒者损失20%攻击力）
					if ($this->MOD->plague) {
						if (rand(1, 100) <= $this->MOD->plague && $effect->effectMaxValue < 0) {
							$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $role, $noLog, false, false, true);
						}
					} else {
						//回春不做处理 已在其他页面执行
						if ($effect->magicId == 3516) {
							continue;
						}
						$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $this->MOD, $noLog, false, true);
					}
				} else{
					$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $role, $noLog, false, true);
				}
			}
		}
						
		// 防守时触发条件
		$effectCondition = array(
			Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND,
			Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND_MAGIC,
		);
		
		// 判断防守方是否有满足条件触发的Effect
		foreach ((array)$role->effect as $effect) {
			if (array_intersect($effectCondition, $effect->trigger) && ($this->MOD->id != $role->id)) {
				//技能为(不伤害)加攻 防 血 治愈 突击buff的时候,不进行反伤
				if (!$isHarmSkill && in_array($effect->effectToProps, array('hp')) && $effect->effectMaxValue < 0) {
					continue;
				}				
				if (in_array($effect->effectByProps, array('initHarm', 'harm')) && !MooMod::get('MooGame_FightEngine_Effect')->lastTimeHarm) {
					continue;
				}
				if (in_array($effect->magicId, array(3196, 3296, 3396, 3496, 3596)) && Mod_MooGame_FightEngine_Control::$turnNum == $effect->startTime && !$role->addict ) {
					if ($role->group == $this->MOD->group || $this->MOD->id == $effect->execRoleId ) {					
						continue;
					}				
				}

				$atbAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($role->id);
				if (in_array($effect->magicId, array(3196, 3296, 3396, 3496, 3596)) && !$atbAtker) {
					continue;
				}
				$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND, $this->MOD, $role, $noLog, false, true, false, true);
				if (in_array($effect->magicId, array(3446)) && $this->MOD->id > 0) {
					MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3446, $role->id, $this->MOD->id);
				}
				if (in_array($effect->magicId, array(3455)) && $this->MOD->id > 0) {
					MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3455, $role->id, $this->MOD->id);
				}
			}
		}
		
		return true;
	}
}