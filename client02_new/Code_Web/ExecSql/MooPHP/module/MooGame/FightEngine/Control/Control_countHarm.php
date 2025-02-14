<?php
class Mod_MooGame_FightEngine_Control_countHarm {
	/**
	 * 伤害计算器
	 * @param $attacker
	 * @param $defender
	 */
	function countHarm($attacker, $defender, $isInitHarm = false, $isPierce = false, $treasureAtkHardRate = 0, $treasureDelDefRate = 0, $isNoAtkHard = false) {
		if ($isInitHarm) {
			$initDef += $treasureDelDefRate < 0 ? ($defender->initDef * (1 + $treasureDelDefRate)) : $defender->initDef;
			$initDef = max(0, $initDef);
			$initAtk = $attacker->initAtk;
			// 宝物技能
			if ($attacker->initDef < $initDef && $attacker->treasureMagic) {
				
				foreach ($attacker->treasureMagic as $treasureMagicInfo) {
					if (in_array($treasureMagicInfo['skillId'], array(2110, 2210, 2310, 2410, 2510))) {
						$addAtk = $initDef * $treasureMagicInfo['value'];
						$initAtk += $addAtk;
						
						if ($attacker->group == 'attacker' && Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]) {
							Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->initAtk = $initAtk;
							if (Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->initAtk < 0) {
								Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->initAtk = 0;
							}
						} elseif ($attacker->group == 'defender' && Mod_MooGame_FightEngine_Control::$defender[$attacker->id]) {
							Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->initAtk = $initAtk;
							if (Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->initAtk < 0) {
								Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->initAtk = 0;
							}
						}
						
						MooMod::get('MooGame_FightEngine_FightLog')->addTreasureEffectLog($treasureMagicInfo['skillId'], $attacker->id, $attacker->id, (int)$addAtk);
					}
				}
			}
			
			// 计算消耗的血量(攻击力 - 防御力) * 伤害加成
			$harm = ceil($initAtk - $initDef) * ($attacker->atkPercent / 100);
			$harm < 1 && $harm = 1;
		} elseif ($isPierce) {
			$def = $defender->def * (1 + ($isPierce / 100));
			$def += $treasureDelDefRate < 0 ? ($def * (1 + $treasureDelDefRate)) : $def;
			$def = max(0, $def);
			$atk = $attacker->atk;
			// 宝物技能
			if ($attacker->def < $def && $attacker->treasureMagic) {
			
				foreach ($attacker->treasureMagic as $treasureMagicInfo) {
					if (in_array($treasureMagicInfo['skillId'], array(2110, 2210, 2310, 2410, 2510))) {
						
						$addAtk = $def * $treasureMagicInfo['value'];
						$atk += $addAtk;
						
						if ($attacker->group == 'attacker' && Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]) {
							Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->atk = $atk;
							if (Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->atk < 0) {
								Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->atk = 0;
							}
						} elseif ($attacker->group == 'defender' && Mod_MooGame_FightEngine_Control::$defender[$attacker->id]) {
							Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->atk = $atk;
							if (Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->atk < 0) {
								Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->atk = 0;
							}
						}
						
						MooMod::get('MooGame_FightEngine_FightLog')->addTreasureEffectLog($treasureMagicInfo['skillId'], $attacker->id, $attacker->id, (int)$addAtk);
					}
				}
				
			}
			
			$harm = ceil($atk - $def) * ($attacker->atkPercent / 100);
			$harm < 1 && $harm = 1;
		} else {
			$def += $treasureDelDefRate < 0 ? ($defender->def * (1 + $treasureDelDefRate)) : $defender->def;
			$def = max(0, $def);
			$atk = $attacker->atk;
			// 宝物技能
			if ($attacker->def < $def && $attacker->treasureMagic) {
					
				foreach ($attacker->treasureMagic as $treasureMagicInfo) {
					if (in_array($treasureMagicInfo['skillId'], array(2110, 2210, 2310, 2410, 2510))) {
						$addAtk = $def * $treasureMagicInfo['value'];
						$atk += $addAtk;
						
						if ($attacker->group == 'attacker' && Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]) {
							Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->atk = $atk;
							if (Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->atk < 0) {
								Mod_MooGame_FightEngine_Control::$attacker[$attacker->id]->atk = 0;
							}
						} elseif ($attacker->group == 'defender' && Mod_MooGame_FightEngine_Control::$defender[$attacker->id]) {
							Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->atk = $atk;
							if (Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->atk < 0) {
								Mod_MooGame_FightEngine_Control::$defender[$attacker->id]->atk = 0;
							}
						}
						
						MooMod::get('MooGame_FightEngine_FightLog')->addTreasureEffectLog($treasureMagicInfo['skillId'], $attacker->id, $attacker->id, (int)$addAtk);
					}
				}
			}
			
			// 计算消耗的血量(攻击力 - 防御力) * 伤害加成
			$harm = ceil($atk - $def) * ($attacker->atkPercent / 100);
			$harm < 1 && $harm = 1;
		}

		// 判断暴击
		Mod_MooGame_FightEngine_Control::$isAtkHard = false;
		if (!$isNoAtkHard) {
			$nowAtkHard = $treasureAtkHardRate ? ($attacker->atkHard + $treasureAtkHardRate) : $attacker->atkHard;
			if (rand(0, 100) < $nowAtkHard) {
				if (Mod_MooGame_FightEngine_Control::$atkHardHarmRate[$attacker->id]) {
					$harm *= (Mod_MooGame_FightEngine_Control::$atkHardHarmRate[$attacker->id] / 100);
				} else {
					$harm *= (Mod_MooGame_FightEngine_Control::$atkHardPercent / 100);
				}
				Mod_MooGame_FightEngine_Control::$isAtkHard = true;
			}
		}
		
		// 判断是否有位置伤害加成或减伤
		if ($defender->positionHarm) {
			$harm = $harm + $harm * $defender->positionHarm;
			$harm < 1 && $harm = 1;
		}
		
		return $harm;
	}
}