<?php

class Mod_MooGame_FightEngine_Magic_exec {

	/**
	 * 执行魔法
	 * @param $role
	 */
	function exec($role, $noLog = false) {

		$execRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($this->MOD->roleId);

		// 取出魔法对应的效果，挨个触发
		foreach ((array)$this->MOD->effect as $effect) {
			if ($effect->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_SELF) {

				// 判断是否是对己方起效
				if (in_array($this->MOD->magicAim, array(Mod_MooGame_FightEngine_Magic::MAGIC_AIM_GROUP, Mod_MooGame_FightEngine_Magic::MAGIC_AIM_SELF))) {
					$beRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($role->id);
				} else{
					$beRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($this->MOD->roleId);
				}

				if ($effect->effectByRole == Mod_MooGame_FightEngine_Effect::EFFECT_BY_ROLE_AIM) {
					$atRole = $role;
				} else {
					$atRole = $beRole;
				}
			} else {
				$beRole = $atRole = $role;
			}
			
			// 掌控，受到风、火、雷、冰、土技能伤害时，对效果免疫，伤害20%反伤攻击者
			if ($atRole->control && in_array($this->MOD->id, MooConfig::get('skill.fightHandleSkill'))) {
				if ($effect->effectToProps != 'hp') {
					continue;
				}
			}
			
			// 判断魔法的效果是否是对我方全体或者敌方全体起效
			if ($effect->effectAimGroup) {

				// 判断魔法所作用方
				if ($effect->effectAimGroup == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_GROUP_ALLSELF) {
					// 判断是否是对己方起效
					if ($execRole->group == 'attacker') {
						$atRoles = Mod_MooGame_FightEngine_Control::$attacker;
					} else {
						$atRoles = Mod_MooGame_FightEngine_Control::$defender;
					}
				} else {
					// 判断是否是对己方起效
					if ($execRole->group == 'attacker') {
						$atRoles = Mod_MooGame_FightEngine_Control::$defender;
					} else {
						$atRoles = Mod_MooGame_FightEngine_Control::$attacker;
					}
				}

				foreach ($atRoles as $tempBeRole) {

					$tempAtRole = $tempBeRole;
					$tmpEffect = clone($effect);
					$tmpEffect->execRoleId = $this->MOD->roleId;
					$tmpEffect->magicUqId = Mod_MooGame_FightEngine_Control::$magicUqId;
					$tmpEffect->atRoleId = $atRole->id;
					$tmpEffect->beRoleId = $tempAtRole->id;
					$tmpEffect->uniqueId = Mod_MooGame_FightEngine_Control::$effectUqId++;
					
					if (Mod_MooGame_FightEngine_Control::$rebirthLog[Mod_MooGame_FightEngine_Control::$turnNum][Mod_MooGame_FightEngine_Control::$ackNum][$tempBeRole->id]) {
						unset(Mod_MooGame_FightEngine_Control::$rebirthLog[Mod_MooGame_FightEngine_Control::$turnNum][Mod_MooGame_FightEngine_Control::$ackNum][$tempBeRole->id]);
						continue;
					}

					// 判断是否存在使用时触发的effect
					if (in_array(Mod_MooGame_FightEngine_Effect::TRIGGER_MAGIC_USE, $effect->trigger)) {
						$rs = $tmpEffect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_MAGIC_USE, $tempAtRole, $tempBeRole, $noLog);
						if ($rs) {
							$tmpEffect->buff($tempBeRole, $noLog);
							$execRole->setBuff[$tempBeRole->id][$tmpEffect->uniqueId] = $tmpEffect->uniqueId;
						}
					} else {
						// 其他的效果直接设置到目标角色身上
						$tmpEffect->buff($tempBeRole, $noLog);
						$execRole->setBuff[$tempBeRole->id][$tmpEffect->uniqueId] = $tmpEffect->uniqueId;
					}
					
				}
			} else {
				
				// 判断是否是冰冻、麻痹、控制、魅惑
				$isTrap = false;
				if (in_array($effect->effectToProps, array('unMagicAble', 'unAttackAble', 'unActionAble', 'addict'))) {
					// 判断是否是有陷阱
					if ($beRole->trap) {
						if (rand(0, 100) < $beRole->trap) {
							$atRole= $beRole = $execRole;
							$isTrap = true;
						}
					}
				
				}
				
				// 毒体，灼魂、吸血对其无效，并将其技能反作用至释放者身上
				if ($atRole->poison && in_array($effect->magicId, MooConfig::get('skill.fightInhaleHpSkill'))) {
					if ($effect->effectMaxValue > 0 && in_array($effect->effectByProps, array('harm', 'initHarm')) && $effect->effectToProps == 'hp') {
						$beRole = $execRole;
					}
				}
				
				$tmpEffect = clone($effect);
				$tmpEffect->execRoleId = $this->MOD->roleId;
				$tmpEffect->atRoleId = $beRole->id;
				$tmpEffect->beRoleId = $atRole->id;
				$tmpEffect->magicUqId = Mod_MooGame_FightEngine_Control::$magicUqId;
				$tmpEffect->uniqueId = Mod_MooGame_FightEngine_Control::$effectUqId++;
				
				if (Mod_MooGame_FightEngine_Control::$rebirthLog[Mod_MooGame_FightEngine_Control::$turnNum][Mod_MooGame_FightEngine_Control::$ackNum][$beRole->id]) {
					unset(Mod_MooGame_FightEngine_Control::$rebirthLog[Mod_MooGame_FightEngine_Control::$turnNum][Mod_MooGame_FightEngine_Control::$ackNum][$beRole->id]);
					continue;
				}

				// 判断是否存在使用时触发的effect
				if (in_array(Mod_MooGame_FightEngine_Effect::TRIGGER_MAGIC_USE, $effect->trigger)) {
					$rs = $tmpEffect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_MAGIC_USE, $execRole, $beRole, $noLog);
					if ($rs) {
						if ($isTrap) {
							$tmpEffect->buff($beRole, $noLog, $isTrap, $role);
						} else {
							$tmpEffect->buff($beRole, $noLog, $isTrap);
						}
						$execRole->setBuff[$beRole->id][$tmpEffect->uniqueId] = $tmpEffect->uniqueId;
					}
				} else {
					// 其他的效果直接设置到目标角色身上						
					$tmpEffect->buff($beRole, $noLog, $isTrap);
					
					$execRole->setBuff[$beRole->id][$tmpEffect->uniqueId] = $tmpEffect->uniqueId;
				}
				
			}

		}

		return true;
	}

}