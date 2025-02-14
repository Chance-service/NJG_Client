<?php
class Mod_MooGame_FightEngine_Effect_exec {
	/**
	 * 触发效果
	 * @param $role
	 * @param $beRole
	 * @param $trigger
	 */
	function exec($trigger, $atker = null, $defer = null, $noLog = false, $noAddReduceHarm = false, $isActionAfter = false, $isPlague = false, $isAgainsInjury = false) {

		if ($this->MOD->effectAim == 4) {
			$this->MOD->effectAim = 1;
		}
		
		// 取出施法方
		$execRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($this->MOD->execRoleId);

		if ($trigger == Mod_MooGame_FightEngine_Effect::TRIGGER_ROUND_START) {
			// 取出法术所在方
			$atRole	= MooMod::get('MooGame_FightEngine_Control')->getAliveRole($this->MOD->atRoleId);

			// 取出魔法作用方
			$beRole	= $this->MOD->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_SELF ? $execRole : $atRole;
		} else {
			
			// 判断法所作用方
			if ($this->MOD->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_SELF) {
				// 如果作用是我方，则判断当前是防御还是进攻。如果是防御，我方是防御方；如果是进攻，我方是进攻方。

				// 判断是否是对己方起效
				if (in_array($this->MOD->magicAim, array(Mod_MooGame_FightEngine_Magic::MAGIC_AIM_GROUP, Mod_MooGame_FightEngine_Magic::MAGIC_AIM_SELF))) {
					$beRole = $defer;
				} else{
					$beRole = $trigger == Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND ? $defer : $atker;
				}
			} else {
				// 如果作用是对方，则判断当前是防御还是进攻。如果是防御，对方是进攻方；如果是进攻，对方是防御方。
				if ($trigger == Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT) {
					$beRole = $atker;
				} else {
					$beRole = $trigger == Mod_MooGame_FightEngine_Effect::TRIGGER_DEFEND ? $atker : $defer;
				}
			}
		}
		
		if (!$beRole) {
			return false;
		}

		// 判断效果依据，如果是伤害的话，则需要特殊处理
		if (in_array($this->MOD->effectByProps, array('harm', 'initHarm'))) {

			$isInitHarm = $this->MOD->effectByProps == 'initHarm' ? true : false;

			$value = rand($this->MOD->effectMinValue, $this->MOD->effectMaxValue);
			
			if (!$this->MOD->effectValueReplace) {
				// 判断是否是根据对方的伤害给自己增加相应的生命值
				if ($this->MOD->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_SELF && $this->MOD->effectByRole == Mod_MooGame_FightEngine_Effect::EFFECT_BY_ROLE_AIM
					|| $this->MOD->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_ENEMY && $this->MOD->effectByRole == Mod_MooGame_FightEngine_Effect::EFFECT_BY_ROLE_SELF
				) {
					if (MooMod::get('MooGame_FightEngine_Effect')->lastTimeHarm) {
						$value = abs(MooMod::get('MooGame_FightEngine_Effect')->lastTimeHarm) * ($value / 100);
					} else {
						$atRole	= MooMod::get('MooGame_FightEngine_Control')->getAliveRole($this->MOD->beRoleId);
						$value = MooMod::get('MooGame_FightEngine_Control')->countHarm($execRole, $atRole, $isInitHarm, false, 0, 0, $isActionAfter) * ($value / 100);
					}
				} else {
					$value = MooMod::get('MooGame_FightEngine_Control')->countHarm($execRole, $beRole, $isInitHarm, false, 0, 0, $isActionAfter) * ($value / 100);
				}
			}

			if (abs($value) < 1) {
				if ($value > 0) {
					$value = 1;
				} else {
					$value = -1;
				}
			}
			
			// 是否有存在加减伤效果
			if ($beRole->addReduceHarm && !$noAddReduceHarm && !$isActionAfter) {
				if ($value < 0 && $beRole->addReduceHarm < 0 && abs($beRole->addReduceHarm) > 100) {
					$value = $value + $value * ((abs($beRole->addReduceHarm) - 100) / 100);
				} else {
					$value = $value + $value * ($beRole->addReduceHarm / 100);
				}
				
				if (abs($value) < 1) {
					if ($value > 0) {
						$value = 1;
					} else {
						$value = -1;
					}
				}
			}
			
			// 是否有存在朱雀
			$isSuzakuAtkHard = false;
			if ($execRole->suzaku && !$isActionAfter) {
				if (rand(1, 100) <= $execRole->suzaku) {
					$value = round($value * ($execRole->suzakuHarmRate / 100));
					Mod_MooGame_FightEngine_Control::$isAtkHard = true;
					$isSuzakuAtkHard = true;
				}
			}
			
			// 是否有存在青龙
			if ($execRole->dragon && !$this->MOD->effectValueReplace && !$isActionAfter) {
				$tmpRate = rand($this->MOD->effectMinValue, $this->MOD->effectMaxValue);
				$value = $execRole->atk * ($tmpRate / 100);
			}
			
			// 判断是否取整
			$value = Mod_MooGame_FightEngine_Control::$isGetInt ? round($value) : $value;
			
			// 更新储每次被施法受到的伤害
			if ($value < 0 && !$isAgainsInjury) {
				MooMod::get('MooGame_FightEngine_Effect')->lastTimeHarm = $value;
			}
		} else {
			
			// 判断不能行动的效果、魔法免疫、净化是否能起效
			if (in_array($this->MOD->effectToProps, array('unAttackAble', 'unMagicAble', 'unActionAble', 'magicImmune', 'clearHarmEffect', 'clearBeneficialEffect', 'clearAllEffect'))) {
				// 人物不能行动和免疫属性值只能为0、1，所以要把百分比改为固定的值
				$value = 1;
			} else {
				Mod_MooGame_FightEngine_Control::$isAtkHard = false; // 走此处时，把是否暴击初始为false
				
				// 瘟疫，攻击对方时30%让对方中毒（中毒者损失20%攻击力）
				if ($isPlague && !$isActionAfter) {
					
					$beRole = $defer;
				}
				
				$value = $this->countValue($trigger, $execRole, $beRole);
			}
			
			//MooMod::get('MooGame_FightEngine_Effect')->lastTimeHarm = 0;
		}
		
		// 仙气、妖气、人气等做处理
		if ($noLog && in_array($this->MOD->magicId, array(3457, 3458, 3459, 3521, 3522, 3524))) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog($this->MOD->magicId, $execRole->id, $beRole->id, $this->MOD->effectMaxValue, false, 1, 0, true);
		}
		
		// 宝物技能
		$treasureRate = 0;
		$isTreasureRebirth = false;
		if ($beRole->treasureMagic) {
			$treasureMagicConfig = MooConfig::get('skill.treasureSkillConf');
			foreach ($beRole->treasureMagic as $treasureMagicInfo) {
		
				// 宝物几率不会被冰冻、麻痹
				if (in_array($this->MOD->effectToProps, array('unMagicAble', 'unAttackAble'))) {
					if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['trigger'] == 6 && $treasureMagicConfig[$treasureMagicInfo['skillId']]['attackType'] == 2) {
						$treasureRate = $treasureMagicConfig[$treasureMagicInfo['skillId']]['value'] * 100;
					}
				}
		
				if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['trigger'] == 4) {
					if ($treasureMagicConfig[$treasureMagicInfo['skillId']]['toProps'] == 'die' && (rand(1, 100) <= $treasureMagicConfig[$treasureMagicInfo['skillId']]['rate'] * 100) && !$beRole->haveTreasureRebirth) {
						$isTreasureRebirth = true;
					}
				}
		
			}
		}

		// 根据概率判断效果是否会触发
		$effectRate = $this->MOD->effectRate - $treasureRate;
		$effectRate = max(0, $effectRate);
		if (rand(1, 100) > $effectRate) {
			return false;
		}
		
		// 判断是否是有坚定，不会被冰冻、麻痹、控制、魅惑
		if ($beRole->firm && in_array($this->MOD->effectToProps, array('unMagicAble', 'unAttackAble', 'unActionAble', 'addict'))) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3451, $beRole->id, $beRole->id, 0, true);
			return false;
		}
		
		// 判断是否是有追击，对受到冰冻、麻痹、控制、魅惑等状态的敌人造成的伤害提高50%
		$isChase = false;
		if ($value < 0 && $execRole->chase && ($beRole->unMagicAble || $beRole->unAttackAble || $beRole->unActionAble || $beRole->addict) && !$isActionAfter) {
			$value = round($value * ($execRole->chase / 100));
			$isChase = true;
			
			MooMod::get('MooGame_FightEngine_Effect')->lastTimeHarm = $value;
		}
		
		// 意志，受到风、火、雷、冰、土等技能伤害时，减少40%受到的伤害
		if (in_array($this->MOD->magicId, MooConfig::get('skill.fightHandleSkill'))) {
			if ($beRole->will && !$isActionAfter) {
				$value = round($value * (1 - ($beRole->will / 100)));
			} elseif ($execRole->element && !$isActionAfter) {
				$value = round($value * ($execRole->element / 100));
			}
		}
		
		// 圣光，治疗效果提升30%
		if ($execRole->saintLight && in_array($this->MOD->magicId, MooConfig::get('skill.fightAddHpSkill')) && !$isActionAfter) {
			//$value = round($value * (1 + ($beRole->saintLight / 100)));
			$value = round($value * (1 + (30 / 100)));
		}
		
		// 判断是否需要覆盖之前产生的行动效果
		if ($this->MOD->isCover && $beRole->{$this->MOD->effectToProps} && !in_array($this->MOD->effectToProps, array('hp', 'hpMax'))) {
			$this->coverUnAble($beRole, $this->MOD->effectToProps);
		}
		
		// 判断是否是使用净化效果
		if (in_array($this->MOD->effectToProps, array('clearHarmEffect', 'clearBeneficialEffect', 'clearAllEffect'))) {
			$this->MOD->effectRealValue = $value;
			if (!$noLog) {
				MooMod::get('MooGame_FightEngine_FightLog')->addEffectLog($this->MOD->execRoleId, $beRole->id, $this->MOD, $trigger);
			}
			switch ($this->MOD->effectToProps) {
				case 'clearHarmEffect':
					$rs = $beRole->clearHarmEffect();
					break;
				case 'clearBeneficialEffect':
					$rs = $beRole->clearBeneficialEffect();
					break;
				case 'clearAllEffect':
					$rs = $beRole->clearAllEffect();
					break;
			}
		
			return $rs;
		}
		
		// 改变敌方的血量
		if ($this->MOD->effectToProps == 'hp' && $value < 0 && $isTreasureRebirth && !$beRole->haveTreasureRebirth && $beRole->hp <= abs($value)) {
			$value = -($beRole->hp - 1);
			$beRole->haveTreasureRebirth = true;
		}
		
		// 判断魔法作用方
		if ($this->MOD->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_SELF || $this->MOD->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_ENEMY) {
			if (in_array($this->MOD->effectToProps, array('atkHard', 'mad', 'rebirth', 'suzaku'))) {
				$rs = $beRole->changeProps($this->MOD->effectToProps, $value, $this->MOD, $this->MOD->atkHardHarmRate, $noLog);
			} else {
				// 毒体，灼魂、吸血对其无效，并将其技能反作用至释放者身上
				if ($defer->poison && in_array($this->MOD->magicId, MooConfig::get('skill.fightInhaleHpSkill'))) {
						if ($execRole->id == $beRole->id) {
							$beRole = $defer;
						} else {
							$beRole = $execRole;
						}
				}
				
				$rs = $beRole->changeProps($this->MOD->effectToProps, $value, $this->MOD, 0, $noLog);
			}
		} elseif ($this->MOD->effectAim == Mod_MooGame_FightEngine_Effect::EFFECT_AIM_BOTH) {
			if (!$execRole || $beRole != $execRole) {
				$execRole && $rs = $execRole->changeProps($this->MOD->effectToProps, $value, $this->MOD, 0, $noLog);
				$beRole && $rs = $beRole->changeProps($this->MOD->effectToProps, $value, $this->MOD, 0, $noLog);
				// 修改指定数值
				$this->MOD->effectRealValue = $rs['change'];
				if (!$noLog) {
					$rs && MooMod::get('MooGame_FightEngine_FightLog')->addEffectLog($this->MOD->execRoleId, $execRole->id, $this->MOD, $trigger);
				}
			} else {
				$rs = $beRole->changeProps($this->MOD->effectToProps, $value, $this->MOD, 0, $noLog);
			}
		}
		
		Mod_MooGame_FightEngine_Control::$isAtkHard = false; // 走此处时，把是否暴击初始为false
		
		// 修改指定数值
		$this->MOD->effectTotalValue += $rs['change'];
		$this->MOD->effectTotalValueCopy += $rs['change']; // 用于shield的buff消失的时候使用
		//特殊处理:治疗不显示实效值
		if (in_array($this->MOD->magicId, array(3111, 3211, 3311, 3411, 3511))) {
			$this->MOD->effectRealValue = $value;
		}else {			
			$this->MOD->effectRealValue = $rs['change'];
		}
		$this->MOD->buffRealValue = $value; // 实际起效的buff值

		$execRolePropsChangeLog = $execRole->propsChangeLog;
		$beRolePropsChangeLog = $beRole->propsChangeLog;
		
		if ($noLog && ($execRole->id != $beRole->id)) {
			$execRole->setSpecialEffect[$beRole->id][$this->MOD->uniqueId] = array(
					'effectToProps' => $this->MOD->effectToProps,
					'value' => $rs['change'],
			);
		}

		if (!$noLog) {
			$rs && MooMod::get('MooGame_FightEngine_FightLog')->addEffectLog($this->MOD->execRoleId, $beRole->id, $this->MOD, $trigger);
		}
		
		// 毒体，灼魂、吸血对其无效，并将其技能反作用至释放者身上
		if ($defer->poison && in_array($this->MOD->magicId, MooConfig::get('skill.fightInhaleHpSkill')) && !$isActionAfter) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3456, $defer->id, $execRole->id, 0, true);
		}
		
		if ($isSuzakuAtkHard && !$isActionAfter) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3517, $execRole->id, $beRole->id);
		}
		
		if ($isChase && !$isActionAfter) {
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3460, $execRole->id, $beRole->id);
		}
		
		// 瘟疫，攻击对方时30%让对方中毒（中毒者损失20%攻击力）
		if ($isPlague && $this->MOD->effectToProps == 'atk' && $this->MOD->effectMaxValue < 0 && !$isActionAfter) {
			$plagueValue = $this->MOD->effectMaxValue ? $this->MOD->effectMaxValue : 0;
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3461, $execRole->id, $beRole->id, $plagueValue);
		}
		
		// 判断是否要取消防护罩的buff（shield）
		if ($execRolePropsChangeLog) {
			$execRole->checkShield($execRolePropsChangeLog);
		}
		if ($beRolePropsChangeLog) {
			$beRole->checkShield($beRolePropsChangeLog);
		}

		if ($execRole && $execRole->hp <= 0) {
			$execRole->dead($beRole->id);
		}
		if ($beRole && $beRole->hp <= 0) {
			if ($isTreasureRebirth) {
				$beRole->hp = 1;
			} else {
				$beRole->dead($this->MOD->execRoleId);
			}
		}
		return $rs;
	}

	function countValue($trigger, $execRole, $beRole) {
		$value = rand($this->MOD->effectMinValue, $this->MOD->effectMaxValue);
		
		if (!$this->MOD->effectValueReplace) {
			// 判断是否是根据属性的百分比来增加
			if ($this->MOD->effectByProps) {
				if ($this->MOD->effectByRole == Mod_MooGame_FightEngine_Effect::EFFECT_BY_ROLE_SELF) {
					if ($this->MOD->atRoleId && in_array($this->MOD->magicId, array(3196, 3296, 3396, 3496, 3596))) {
						$atbAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($this->MOD->atRoleId);
						if ($atbAtker) {
							$value = $atbAtker->{$this->MOD->effectByProps} * ($value / 100);
						} else {
							$value = $execRole->{$this->MOD->effectByProps} * ($value / 100);
						}
					} else {
						$value = $execRole->{$this->MOD->effectByProps} * ($value / 100);
					}
				} else {
					$value = $beRole->{$this->MOD->effectByProps} * ($value / 100);
				}

				// 判断是否取整
				$value = Mod_MooGame_FightEngine_Control::$isGetInt ? round($value) : $value;
			} elseif ($this->MOD->effectToProps == 'hp' && ($execRole->id != $beRole->id) && $value < 0) {
				// 判断暴击
				Mod_MooGame_FightEngine_Control::$isAtkHard = false;
				if (rand(0, 100) < $execRole->atkHard) {
					$value *= (Mod_MooGame_FightEngine_Control::$atkHardPercent / 100);
					Mod_MooGame_FightEngine_Control::$isAtkHard = true;
				}

				// 判断是否取整
				$value = Mod_MooGame_FightEngine_Control::$isGetInt ? round($value) : $value;
			} else {
				// 判断是否取整
				$value = Mod_MooGame_FightEngine_Control::$isGetInt ? round($value) : $value;
			}
			
		} else {
			// 判断是否取整
			$value = Mod_MooGame_FightEngine_Control::$isGetInt ? round($value) : $value;
		}

		if (abs($value) < 1) {
			if ($value > 0) {
				$value = 1;
			} else {
				$value = -1;
			}
		}

		return $value;
	}

	private function coverUnAble($beRole, $effectToProps) {

		if (!$beRole->effect) {
			return;
		}

		// 判断当前角色身上是否有有益的效果
		foreach ($beRole->effect as $uniqueId => $effectObj) {
			if ($effectObj->effectToProps == $effectToProps) {
				$beRole->removeEffect($uniqueId);
			}
		}

		return;
	}

}