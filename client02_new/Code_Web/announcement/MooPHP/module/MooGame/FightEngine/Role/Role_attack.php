<?php
MooMod::get('MooGame_FightEngine_Effect');

class Mod_MooGame_FightEngine_Role_attack {
	/**
	 * 物理攻击
	 * @param $defender
	 */
	function attack($defender, $isSweepAway = false, $isAssassination = false, $isOddPoor = false, $delHp = 0) {
		if (!$defender) {
			return false;
		}

		// 进攻触发条件
		$effectCondition = array(
			Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT,
			Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT_ATK,
		);

		// 判断进攻方是否有满足条件触发的Effect
		foreach ((array)$this->MOD->effect as $effect) {
			if (array_intersect($effectCondition, $effect->trigger)) {
				if (in_array($effect->magicAim, array(Mod_MooGame_FightEngine_Magic::MAGIC_AIM_GROUP, Mod_MooGame_FightEngine_Magic::MAGIC_AIM_SELF))) {
					$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $this->MOD);
				} else {
					$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $defender);
				}
			}
			// 增加刺穿log
			if (in_array($effect->magicId, array(3462))) {
				MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog($effect->magicId, $this->MOD->id, $defender->id);
			}
		}

		// 判断当前对战者是否已经死亡
		if ($this->MOD->group == 'attacker' && !Mod_MooGame_FightEngine_Control::$attacker[$this->MOD->id]) {
			return false;
		} elseif ($this->MOD->group == 'defender' && !Mod_MooGame_FightEngine_Control::$defender[$this->MOD->id]) {
			return false;
		}

		// 判断命中率和闪避率
		if($this->MOD->atkRate < 100 || $defender->joukRate > 0) {

			if (rand(1, 100) > $this->MOD->atkRate || rand(1, 100) < $defender->joukRate) {
				// 增加一个战斗记录
				MooMod::get('MooGame_FightEngine_FightLog')->addAttackLog($this->MOD->id, $defender->id, 0);
				return true;
			}
		}
		
		// 法宝技能
		$treasureAtkHardRate = 0;
		$isTreasureAddHp = $isTreasureDelDef = $isTreasureRebirth = $isContinuDelDef = false;
		if (!$isOddPoor && $this->MOD->treasureMagic) {
			$treasureMagicConfig = MooConfig::get('skill.treasureSkillConf');
			foreach ($this->MOD->treasureMagic as $treasureMagicInfo) {
				if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['trigger'] == 2 && $treasureMagicConfig[$treasureMagicInfo['skillId']]['attackType'] == 1) {
					if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['toProps'] == 'atkHard') {
						$treasureAtkHardRate = $treasureMagicConfig[$treasureMagicInfo['skillId']]['value'] * 100;
					}
					if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['toProps'] == 'harm') {
						$isTreasureAddHp = $treasureMagicConfig[$treasureMagicInfo['skillId']]['value'];
					}
					if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['toProps'] == 'defense') {
						$isTreasureDelDef = $treasureMagicConfig[$treasureMagicInfo['skillId']]['value'];
						if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['isContinu']) {
							$isContinuDelDef = $treasureMagicConfig[$treasureMagicInfo['skillId']]['value'];
								
						} else {
							$isTreasureDelDef = $treasureMagicConfig[$treasureMagicInfo['skillId']]['value'];
						}
					}
					
				}
			}
		}
		if ($defender->treasureMagic) {
			$treasureMagicConfig = MooConfig::get('skill.treasureSkillConf');
			foreach ($defender->treasureMagic as $treasureMagicInfo) {
				if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['trigger'] == 4) {
					if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['toProps'] == 'die' && (rand(1, 100) <= $treasureMagicConfig[$treasureMagicInfo['skillId']]['rate'] * 100) && !$defender->haveTreasureRebirth) {
						$isTreasureRebirth = true;
					}
				}
		
			}
		}
		
		// 是否是宝物持续降防
		if ($isContinuDelDef) {
			$delDef = $defender->def * $isContinuDelDef;
			
			MooMod::get('MooGame_FightEngine_FightLog')->addTreasureEffectLog($treasureMagicInfo['skillId'], $this->MOD->id, $defender->id, (int)$delDef);
				
			if ($defender->group == 'attacker' && Mod_MooGame_FightEngine_Control::$attacker[$defender->id]) {
				Mod_MooGame_FightEngine_Control::$attacker[$defender->id]->def += $delDef;
				if (Mod_MooGame_FightEngine_Control::$attacker[$defender->id]->def < 0) {
					Mod_MooGame_FightEngine_Control::$attacker[$defender->id]->def = 0;
				}
			} elseif ($defender->group == 'defender' && Mod_MooGame_FightEngine_Control::$defender[$defender->id]) {
				Mod_MooGame_FightEngine_Control::$defender[$defender->id]->def += $delDef;
				if (Mod_MooGame_FightEngine_Control::$defender[$defender->id]->def < 0) {
					Mod_MooGame_FightEngine_Control::$defender[$defender->id]->def = 0;
				}
			}
			
			$defender->def += $delDef;
		}

		// 判断是否是刺穿
		if (!$isOddPoor && $this->MOD->pierce) {
			$harm = MooMod::get('MooGame_FightEngine_Control')->countHarm($this->MOD, $defender, false, $this->MOD->pierce, $treasureAtkHardRate, $isTreasureDelDef);
		// 计算伤害
		} else {
			$harm = MooMod::get('MooGame_FightEngine_Control')->countHarm($this->MOD, $defender, false, false, $treasureAtkHardRate, $isTreasureDelDef);
		}
		
		// 判断是否有回春技能
		if ($this->MOD->effect) {
			foreach ((array)$this->MOD->effect as $tmpEffectObj) {
				if ($tmpEffectObj->magicId == 3516) {
					MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3516, $this->MOD->id, $this->MOD->id, $this->MOD->hpMax * 0.2);
				}
			}
		}
		
		// 穷奇反伤
		if ($isOddPoor) {
			$harm = round($delHp * ($this->MOD->oddPoor / 100));
		}

		// 是否有存在加减伤效果
		if ($defender->addReduceHarm) {
			$harm = $harm + $harm * ($defender->addReduceHarm / 100);
			$harm < 1 && $harm = 1;
		}
		
		// 判断是否是有追击，对受到冰冻、麻痹、控制、魅惑等状态的敌人造成的伤害提高50%
		$isChase = false;
		if (!$isOddPoor && $this->MOD->chase && ($defender->unMagicAble || $defender->unAttackAble || $defender->unActionAble || $defender->addict)) {
			$harm = round($harm * ($this->MOD->chase / 100));
			$isChase = true;
		}
		
		// 是否有存在朱雀
		$isSuzakuAtkHard = false;
		if (!$isOddPoor && $this->MOD->suzaku) {
			if (rand(1, 100) <= $this->MOD->suzaku) {
				$harm = round($harm * ($this->MOD->suzakuHarmRate / 100));
				Mod_MooGame_FightEngine_Control::$isAtkHard = true;
				$isSuzakuAtkHard = true;
			}
		}
		
		// 是否有存在白虎
		if (!$isOddPoor && $defender->whiteTiger) {
			if (rand(1, 100) <= $defender->whiteTiger) {
				$harm = 0;
			}
		}
		
		// 是否是横扫
		if (!$isOddPoor && $isSweepAway) {
			$harm = ceil($this->MOD->atk * ($this->MOD->sweepAway / 100) - $defender->def);
		}
				
		// 是否是刺杀
		if (!$isOddPoor && $isAssassination) {
			$harm = $defender->hpMax * ($this->MOD->assassination / 100);
		}
		
		// 判断是否取整
		$harm = Mod_MooGame_FightEngine_Control::$isGetInt ? round($harm) : $harm;
		
		MooMod::get('MooGame_FightEngine_Effect')->lastTimeHarm = $harm;

		// 改变敌方的血量
		if ($isTreasureRebirth && !$defender->haveTreasureRebirth && $defender->hp <= $harm) {
			$harm = $defender->hp - 1;
			$defender->haveTreasureRebirth = true;
		}
		$defender->changeProps('hp', -$harm);
		$propsChangeLog = $defender->propsChangeLog;
		
		Mod_MooGame_FightEngine_Control::$isAtkHard = false; // 走此处时，把是否暴击初始为false
		
		$defender->unShieldId();

		// 增加一个战斗记录
		if ($isAssassination || $isChase) {
			MooMod::get('MooGame_FightEngine_FightLog')->addAttackLog($this->MOD->id, $defender->id, $harm, 0, 0, $isAssassination, $isChase);
		} else {
			MooMod::get('MooGame_FightEngine_FightLog')->addAttackLog($this->MOD->id, $defender->id, $harm);
		}
		
		// 宝物普攻加血
		if (!$isOddPoor && $isTreasureAddHp) {
			
			$treasureAddHp = round($harm * $isTreasureAddHp);
			
			if ($treasureAddHp > 0) {
				$effectObj = MooMod::get('MooGame_FightEngine_Effect', '', false);
				$effectObj->id = -1;
				$effectObj->trigger = array(
						7,
				);
				$effectObj->effectAim = 1;
				$effectObj->effectMaxValue = $treasureAddHp ;
				$effectObj->effectMinValue = $treasureAddHp;
				$effectObj->effectConfusion = 0;
				$effectObj->effectToProps = 'hp';
				$effectObj->effectByProps = 'harm';
				$effectObj->effectByRole = 2;
				$effectObj->timeOut = 1;
				$effectObj->effectRemove = 0;
				$effectObj->effectRate = 100;
				$effectObj->effectValueReplace = 1;
				$effectObj->execRoleId = $this->MOD->id;
				$effectObj->atRoleId = $defender->id;
				$effectObj->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT_ATK, $this->MOD, $defender, false, true);
			}
		}
		
		// 穷奇反伤
		if ($isOddPoor) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3526, $this->MOD->id, $defender->id, 0, true);
		}
		
		// 是否有存在白虎
		if (!$isOddPoor && $defender->whiteTiger && $harm == 0) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3518, $defender->id, $defender->id, 0, true);
		}
		
		if (!$isOddPoor && $isSuzakuAtkHard) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3517, $this->MOD->id, $defender->id);
		}
		
		if (!$isOddPoor && $isChase) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3460, $this->MOD->id, $defender->id);
		}
		
		if ($isAssassination) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3520, $this->MOD->id, $defender->id);
		}
		
		// 判断是否要取消防护罩的buff（shield）
		$defender->checkShield($propsChangeLog);
		
		// 如果HP小于等于0，则角色死亡
		if ($defender->hp <= 0) {
			$defender->dead($this->MOD->id);
			if ($defender->effect) {
				foreach ((array)$defender->effect as $effect) {
					// 反伤效果
					if ($effect->effectAim == 2 && $effect->effectByRole == 1 && in_array($effect->effectByProps, array('harm', 'initHarm')) && $effect->effectToProps == 'hp') {
						$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND, $this->MOD, $defender, false, false, true);
					}
				}
			}
			return true;
		}
		
		// 防守触发条件
		$effectCondition = array(
				Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND,
				Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND_ATK);
		
		// 判断防守是否有满足条件触发的Effect
		foreach ((array)$defender->effect as $effect) {
			
			if (array_intersect($effectCondition, $effect->trigger)) {
				
				$atbAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($defender->id);
				if (in_array($effect->magicId, array(3196, 3296, 3396, 3496, 3596))) {
					if (!$atbAtker || Mod_MooGame_FightEngine_Control::$turnNum == $effect->startTime) {
						continue;
					}
				}

				$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND, $this->MOD, $defender, false, false, true);
				if (in_array($effect->magicId, array(3446)) && $this->MOD->id > 0) {
					MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3446, $defender->id, $this->MOD->id);
				}
			}
		}
		
		if ($isOddPoor) {
			// 判断防守是否有满足条件触发的Effect
			foreach ((array)$this->MOD->effect as $effect) {
					
				if (array_intersect($effectCondition, $effect->trigger)) {
			
					$atbAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($this->MOD->id);
					if (in_array($effect->magicId, array(3196, 3296, 3396, 3496, 3596))) {
						if (!$atbAtker || Mod_MooGame_FightEngine_Control::$turnNum == $effect->startTime) {
							continue;
						}
					}
			
					$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND, $defender, $this->MOD, false, false, true);
					if (in_array($effect->magicId, array(3446)) && $defender->id > 0) {
						MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3446, $this->MOD->id, $defender->id);
					}
				}
			}
		}
		
		// 进攻后触发条件
		if (!$isOddPoor) {
			$effectCondition = array(
					Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT_AFTER);
			
			// 穷奇反伤不触发进攻后触发的条件
			if (!$isOddPoor) {
				// 判断进攻后是否有满足条件触发的Effect
				foreach ((array)$this->MOD->effect as $effect) {
					if (array_intersect($effectCondition, $effect->trigger)) {
						// 判断是否是对己方起效
						if (in_array($effect->magicAim, array(Mod_MooGame_FightEngine_Magic::MAGIC_AIM_GROUP, Mod_MooGame_FightEngine_Magic::MAGIC_AIM_SELF))) {
							
							// 瘟疫，攻击对方时30%让对方中毒（中毒者损失20%攻击力）
							if ($this->MOD->plague) {
								
								if (rand(1, 100) <= $this->MOD->plague && $effect->effectMaxValue < 0) {
									$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $defender, false, false, false, true);
								}
							} else {
								$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $this->MOD, false, false, true);
							}
							
							//$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $this->MOD);
						} else{
							$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $this->MOD, $defender, false, false, true);
						}
						
					}
				}
			}
		}

		return true;
	}
}