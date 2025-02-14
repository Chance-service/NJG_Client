<?php
class Mod_MooGame_FightEngine_Control_Auto_wheelStart {
	/**
	 * 开始自动车轮战斗
	 */
	private $heroConfig;
	private $skillConfig;
	
	function wheelStart() {
		
		$this->heroConfig = $heroConfig = MooConfig::get('hero');
		$skillConfig = MooConfig::get('skill');
		$skillConfigArr = array();
		foreach ($skillConfig['skill2Conf'] as $tmpSkillId => $tmpSkillInfo) {
			$skillConfigArr[$tmpSkillId] = $tmpSkillInfo;
		}
		foreach ($skillConfig['skill3Conf'] as $tmpSkillId => $tmpSkillInfo) {
			$skillConfigArr[$tmpSkillId] = $tmpSkillInfo;
		}
		
		$this->skillConfig = $skillConfigArr;
		
		// 开始战斗前发送的魔法
		foreach (Mod_MooGame_FightEngine_Control::$attacker as $role) {
			$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($role->id);
			if ($currentAtker->specialMagic) {
				foreach($currentAtker->specialMagic as $row) {
					$magic = $this->getSpecialMagic($row);
					// 如果取到魔法则直接发动魔法
					if ($magic) {
						$this->magic($currentAtker, $magic, 1);
					}
				}
			}
			
		}

		foreach (Mod_MooGame_FightEngine_Control::$attacker as $key => $role) {
			$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($role->id);
			if ($currentAtker->setBuff) {
				unset($currentAtker->setBuff);
			}
			if ($currentAtker->propsChangeLog) {
				unset($currentAtker->propsChangeLog);
			}
			if ($currentAtker->specialMagic) {
				unset($currentAtker->specialMagic);
			}
			$role->hpMax = $role->hp;
			$role->defMax = $role->def;
			$role->atkMax = $role->atk;
			$currentAtker->hpMax = $currentAtker->hp;
			$currentAtker->defMax = $currentAtker->def;
			$currentAtker->atkMax = $currentAtker->atk;
			Mod_MooGame_FightEngine_Control::$attacker[$key] = $role;
			
			Mod_MooGame_FightEngine_Control::$copyRole[$role->id] = clone($currentAtker);

			if ($currentAtker->setSpecialEffect) {
				unset($currentAtker->setSpecialEffect);
			}

		}
		foreach (Mod_MooGame_FightEngine_Control::$defender as $role) {
			$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($role->id);
			if ($currentAtker->specialMagic) {
				foreach($currentAtker->specialMagic as $row) {
					$magic = $this->getSpecialMagic($row);
					// 如果取到魔法则直接发动魔法
					if ($magic) {
						$this->magic($currentAtker, $magic, 1);
					}
				}
			}
		}
		foreach (Mod_MooGame_FightEngine_Control::$defender as $key => $role) {
			$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($role->id);
			if ($currentAtker->setBuff) {
				unset($currentAtker->setBuff);
			}
			if ($currentAtker->propsChangeLog) {
				unset($currentAtker->propsChangeLog);
			}
			if ($currentAtker->specialMagic) {
				unset($currentAtker->specialMagic);
			}
			$role->hpMax = $role->hp;
			$role->defMax = $role->def;
			$role->atkMax = $role->atk;
			$currentAtker->hpMax = $currentAtker->hp;
			$currentAtker->defMax = $currentAtker->def;
			$currentAtker->atkMax = $currentAtker->atk;
			Mod_MooGame_FightEngine_Control::$defender[$key] = $role;
			
			Mod_MooGame_FightEngine_Control::$copyRole[$role->id] = clone($currentAtker);
			
			if ($currentAtker->setSpecialEffect) {
				unset($currentAtker->setSpecialEffect);
			}
			
		}
		
		while (true) {
			// 双方如果有一方全灭，则结束战斗
			if (empty(Mod_MooGame_FightEngine_Control::$attacker)
			|| empty(Mod_MooGame_FightEngine_Control::$defender)) {

				// 获取胜利方
				if (empty(Mod_MooGame_FightEngine_Control::$attacker)) {
					Mod_MooGame_FightEngine_Control::$winner = 'defender';
				} else {
					Mod_MooGame_FightEngine_Control::$winner = 'attacker';
				}

				return;
			}

			// 如果超过限定回合，则直接终止战斗
			if (Mod_MooGame_FightEngine_Control::$maxTurnNum > 0 && Mod_MooGame_FightEngine_Control::$turnNum >= Mod_MooGame_FightEngine_Control::$maxTurnNum) {
				return;
			}

			// 根据战士的敏捷判断出招先后顺序
			$roles = $this->roleSort();

			// 开始一个回合的战斗
			$this->goAround($roles);
		}
	}

	/**
	 * 判断出招先后顺序
	 */
	function roleSort() {
		// 攻击者先出手
		$roles = $attacker = $defender = array();
		$attackerFirst = $defenderFirst = array();
		$i = 0;
		foreach (Mod_MooGame_FightEngine_Control::$attacker as $role) {
			
			Mod_MooGame_FightEngine_Control::$sortAttacker[$role->groupId] = $role->id;
			
			++$i;
			if ($role->groupId == 1) {
				$attackerFirst = array(
						'id' => $role->id,
						'group' => 'attacker',
				);
				continue;
			}
			$attacker[$role->groupId] = array(
					'id' => $role->id,
					'group' => 'attacker',
			);
		}
		krsort($attacker);
		
		foreach (Mod_MooGame_FightEngine_Control::$sortAttacker as $tmpRoleId) {
			if (!Mod_MooGame_FightEngine_Control::$attacker[$tmpRoleId]) {
				unset(Mod_MooGame_FightEngine_Control::$sortAttacker[$tmpRoleId]);
			}
		}
		
		foreach (Mod_MooGame_FightEngine_Control::$defender as $role) {
			
			Mod_MooGame_FightEngine_Control::$sortDefender[$role->groupId] = $role->id;
			
			++$i;
			if ($role->groupId == 1) {
				$defenderFirst = array(
						'id' => $role->id,
						'group' => 'defender',
				);
				continue;
			}
			$defender[$role->groupId] = array(
					'id' => $role->id,
					'group' => 'defender',
			);
		}
		krsort($defender);
		
		foreach (Mod_MooGame_FightEngine_Control::$sortDefender as $tmpRoleId) {
			if (!Mod_MooGame_FightEngine_Control::$defender[$tmpRoleId]) {
				unset(Mod_MooGame_FightEngine_Control::$sortDefender[$tmpRoleId]);
			}
		}
		
		/*
		 * 站位顺序
		 * 1  6  4       4
		 * 5  3       3  6
		 * 2       2  5  1
		 */
		
		// 进攻方先出手
		for ($j = 1; $j <= $i; $j++) {
			if ($j % 2 == 1) {
				if ($attackerFirst) {
					$roles[] = $attackerFirst;
					unset($attackerFirst);
				} else {
					if ($attacker) {
						$roles[] = array_pop($attacker);
					} else {
						if ($defender) {
							$roles[] = array_pop($defender);
						}
					}
				}
			} else {
				if ($defenderFirst) {
					$roles[] = $defenderFirst;
					unset($defenderFirst);
				} else {
					if ($defender) {
						$roles[] = array_pop($defender);
					} else {
						if ($attacker) {
							$roles[] = array_pop($attacker);
						}
					}
				}
			}
		}

		return $roles;
	}

	/**
	 * 开始一个回合的战斗
	 * @param $roles
	 */
	function goAround($roles) {
		
		// 更新回合数
		Mod_MooGame_FightEngine_Control::$turnNum++;

		// 更新当前回合对战的顺序id数
		Mod_MooGame_FightEngine_Control::$ackNum = 0;
		
		// 对场上所有战士进行法宝处理
		foreach ($roles as $row) {
			
			// 设置当前的进攻者
			$currentAtker = '';
			$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($row['id']);
		
			// 判断战士是否存在
			if (!$currentAtker) {
				continue;
			}
		
			// 宝物技能
			if ($currentAtker->treasureMagic) {
				foreach ($currentAtker->treasureMagic as $treasureMagicInfo) {
					if (in_array($treasureMagicInfo['skillId'], array(2109, 2209, 2309, 2409, 2509))) {
						if (Mod_MooGame_FightEngine_Control::$turnNum > 1) {
							MooMod::get('MooGame_FightEngine_FightLog')->addTreasureEffectLog($treasureMagicInfo['skillId'], $currentAtker->id, null, -$treasureMagicInfo['delValue']);
						} else {
							MooMod::get('MooGame_FightEngine_FightLog')->addTreasureEffectLog($treasureMagicInfo['skillId'], $currentAtker->id, null, $treasureMagicInfo['addValue']);
						}
					}
		
				}
			}
		}
		
		// 宠物对战
		if (Mod_MooGame_FightEngine_Control::$turnNum > 1 && (Mod_MooGame_FightEngine_Control::$turnNum % 3 == 1)) {
			
			if (Mod_MooGame_FightEngine_Control::$petAttacker) {
				foreach (Mod_MooGame_FightEngine_Control::$petAttacker as $pet) {
					// 双方如果有一方全灭，则结束战斗
					if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
						return true;
					}
						
					// 设置当前的进攻者
					$currentAtker = '';
					$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($pet->id);
					
					// 判断战士是否存在
					if (!$currentAtker) {
						continue;
					}
					
					// 战士行动
					$this->action($currentAtker, true);
						
					// 双方如果有一方全灭，则结束战斗
					if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
						return true;
					}
				}
			}
			if (Mod_MooGame_FightEngine_Control::$petDefender) {
				foreach (Mod_MooGame_FightEngine_Control::$petDefender as $pet) {
					// 双方如果有一方全灭，则结束战斗
					if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
						return true;
					}
			
					// 设置当前的进攻者
					$currentAtker = '';
					$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($pet->id);
						
					// 判断战士是否存在
					if (!$currentAtker) {
						continue;
					}
						
					// 战士行动
					$this->action($currentAtker, true);
			
					// 双方如果有一方全灭，则结束战斗
					if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
						return true;
					}
				}
			}
		}
		
		// 魔神特殊处理
		$haveDevil = false;
		foreach (Mod_MooGame_FightEngine_Control::$defender as $devilObj) {
			if ($devilObj->boss == 2) {
				$haveDevil = true;
			}
		}
		if ($haveDevil) {
			if (Mod_MooGame_FightEngine_Control::$turnNum < 2) {
				// 双方如果有一方全灭，则结束战斗
				if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
					return true;
				}
				foreach (Mod_MooGame_FightEngine_Control::$attacker as $roleObj) {
						
					// 设置当前的进攻者
					$currentAtker = '';
					$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($roleObj->id);
					
					// 判断战士是否存在
					if (!$currentAtker) {
						continue;
					}
					
					// 宝物技能
					if ($currentAtker->treasureMagic) {
						foreach ($currentAtker->treasureMagic as $treasureMagicInfo) {
							if (in_array($treasureMagicInfo['skillId'], array(2109, 2209, 2309, 2409, 2509)) && Mod_MooGame_FightEngine_Control::$turnNum > 1) {
								if (Mod_MooGame_FightEngine_Control::$turnNum > 1) {
									$currentAtker->atk -= $treasureMagicInfo['delValue'];
									$currentAtker->atk = max(0, $currentAtker->atk);
								}
							}
					
						}
					}
					
					// 战士行动
					$this->action($currentAtker);
						
					// 双方如果有一方全灭，则结束战斗
					if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
						return true;
					}
				}
			} else {
				foreach (Mod_MooGame_FightEngine_Control::$defender as $devilObj) {
					// 设置当前的进攻者
					$currentAtker = '';
					$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($devilObj->id);
					
					// 判断战士是否存在
					if (!$currentAtker) {
						continue;
					}
					
					// 宝物技能
					if ($currentAtker->treasureMagic) {
						foreach ($currentAtker->treasureMagic as $treasureMagicInfo) {
							if (in_array($treasureMagicInfo['skillId'], array(2109, 2209, 2309, 2409, 2509)) && Mod_MooGame_FightEngine_Control::$turnNum > 1) {
								if (Mod_MooGame_FightEngine_Control::$turnNum > 1) {
									$currentAtker->atk -= $treasureMagicInfo['delValue'];
									$currentAtker->atk = max(0, $currentAtker->atk);
								}
							}
					
						}
					}
					
					// 战士行动
					$this->action($currentAtker, true);
						
					// 双方如果有一方全灭，则结束战斗
					if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
						return true;
					}
				}
			}
			return true;
		}

		// 对场上所有战士进行战斗
		foreach ($roles as $row) {
			// 双方如果有一方全灭，则结束战斗
			if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
				return true;
			}
			
			// 设置当前的进攻者
			$currentAtker = '';
			$currentAtker = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($row['id']);

			// 判断战士是否存在
			if (!$currentAtker) {
				continue;
			}
			
			// 宝物技能
			if ($currentAtker->treasureMagic) {
				foreach ($currentAtker->treasureMagic as $treasureMagicInfo) {
					if (in_array($treasureMagicInfo['skillId'], array(2109, 2209, 2309, 2409, 2509)) && Mod_MooGame_FightEngine_Control::$turnNum > 1) {
						if (Mod_MooGame_FightEngine_Control::$turnNum > 1) {
							$currentAtker->atk -= $treasureMagicInfo['delValue'];
							$currentAtker->atk = max(0, $currentAtker->atk);
						}
					}
				
				}
			}
			
			$this->action($currentAtker);
			
			// 双方如果有一方全灭，则结束战斗
			if (empty(Mod_MooGame_FightEngine_Control::$attacker) || empty(Mod_MooGame_FightEngine_Control::$defender)) {
				return true;
			}
			
			// 去掉当前出手的战士之前发给别的战士的buff
			if ($currentAtker->setBuff) {
				
				foreach ($currentAtker->setBuff as $beRoleId => $effectUniqueIdArr) {
					$role = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($beRoleId);
					if (!$role) {
						continue;
					}

					foreach ((array)$role->effect as $effect) {
						if ($effect->timeOut != -1 && in_array($effect->uniqueId, $effectUniqueIdArr) && Mod_MooGame_FightEngine_Control::$turnNum != $effect->startTime) {
							$role->removeEffect($effect->uniqueId);
						}
					}
				}
			}

			// 更新战士的回合数
			$currentAtker->lastActionRound = Mod_MooGame_FightEngine_Control::$turnNum;

		}

	}

	/**
	 * 战士行动
	 * @param $currentAtker
	 */
	function action($currentAtker, $besureMagicAction = false) {

		// 更新当前回合对战的顺序id数
		Mod_MooGame_FightEngine_Control::$ackNum++;
		
		// 去掉当前出手的战士之前死亡的队友发给别的战士的buff
		if ($currentAtker->rmFriendSetBuff) {
		
			foreach ($currentAtker->rmFriendSetBuff as $beRoleId => $effectUniqueIdArr) {
				$role = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($beRoleId);
				if (!$role) {
					continue;
				}
				foreach ((array)$role->effect as $effect) {
					if (in_array($effect->uniqueId, $effectUniqueIdArr) && Mod_MooGame_FightEngine_Control::$turnNum != $effect->startTime) {
						$role->removeEffect($effect->uniqueId, 0, 1);
					}
				}
			}
		}
		
		// 计算本次是技能回合还是普攻回合
		$actionType = Mod_MooGame_FightEngine_Control::$turnNum % 2;
		if ($actionType == 0) {
			$unAttackAble = true;
		} else {
			$unMagicAble = true;
		}
		
		// 判断是否物理魔法攻击不能
		if (!$besureMagicAction && $currentAtker->unActionAble > 0 || ($currentAtker->unAttackAble > 0 && $currentAtker->unMagicAble > 0)) {
			MooMod::get('MooGame_FightEngine_FightLog')->addUnActionLog($currentAtker->id);
			return;
		}
		
		// 判断是否是混乱，混乱不能进行魔法攻击
		$magic = null;
		if ($besureMagicAction || (!$unMagicAble && $currentAtker->unMagicAble <= 0)) {
			$magic = $this->getMagic($currentAtker);
		}
		
		if ((!$magic && !$unMagicAble && $currentAtker->unMagicAble) || ($magic && !$besureMagicAction && $currentAtker->unAttackAble <= 0 && $currentAtker->unMagicAble > 0)) {
			MooMod::get('MooGame_FightEngine_FightLog')->addUnMagicLog($currentAtker->id);
			return;
		}
		
		// 如果取到魔法则直接发动魔法
		if ($magic && Mod_MooGame_FightEngine_Control::$turnNum != 1) {
			$this->magic($currentAtker, $magic);
			if ($currentAtker->assassination) {
				$this->attack($currentAtker, 1);
			}
			
			// 判断是否有回春技能，避免进入死循环
			if ($currentAtker->effect) {
				foreach ((array)$currentAtker->effect as $tmpEffectObj) {
					if ($tmpEffectObj->magicId == 3516) {
						$rs = $tmpEffectObj->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_FIGHT, $currentAtker, $currentAtker, false, false, true);
						MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3516, $currentAtker->id, $currentAtker->id, $rs['change']);

					}
				}
			}
			
			//boss召唤小怪
			if (!$currentAtker->unAttackAble && (in_array($currentAtker->boss, array(1, 3))) && (count(Mod_MooGame_FightEngine_Control::$defender) < 3)) {
			
				$temDefender = Mod_MooGame_FightEngine_Control::$defender;
				if (!$temDefender) {
					$temDefender = array();
				}
				$nowOPenPosition = array(2 => 2, 4 => 4);
				foreach ($temDefender as $id => $info) {
					if ($id == $currentAtker->id) {
						unset($temDefender[$id]);
					} else {
						if ($nowOPenPosition[$info->groupId]) {
							unset($nowOPenPosition[$info->groupId]);
						}
					}
				}
				
				$rebirthNumber = 2 - count($temDefender);
				for ($i = 1; $i <= $rebirthNumber; $i++) {
					$key = 0;
					$key = array_rand(Mod_MooGame_FightEngine_Control::$bossRebirthMobs);
					if ($key) {
						if (!$nowOPenPosition) {
							continue;
						}
						$nowPosition = array_rand($nowOPenPosition);
						if (Mod_MooGame_FightEngine_Control::$bossRebirthMobsArr[$nowPosition] >=
								count(Mod_MooGame_FightEngine_Control::$initBossRebirthMobs) / 2 ) {
							continue;
						}
						
						Mod_MooGame_FightEngine_Control::$defender[$key] = Mod_MooGame_FightEngine_Control::$bossRebirthMobs[$key];
						unset(Mod_MooGame_FightEngine_Control::$bossRebirthMobs[$key]);
						Mod_MooGame_FightEngine_Control::$defender[$key]->groupId = $nowPosition;
						Mod_MooGame_FightEngine_Control::$bossRebirthMobsArr[$nowPosition] += 1;
						unset($nowOPenPosition[$nowPosition]);
						
						//增加召唤log
						MooMod::get('MooGame_FightEngine_FightLog')->addBossRebirthMobsLog($currentAtker->id, Mod_MooGame_FightEngine_Control::$defender[$key]->id,$nowPosition);
					}
				}
				
			}
			
			return;
		}
		
		if ($currentAtker->unAttackAble > 0) {
			MooMod::get('MooGame_FightEngine_FightLog')->addUnAttackLog($currentAtker->id);
			return;
		}

		// 判断是否物理攻击不能
		if (($unAttackAble && !$magic && $currentAtker->unAttackAble <= 0) || (!$unAttackAble && $currentAtker->unAttackAble <= 0)) {
			$this->attack($currentAtker);
			
			//boss召唤小怪
			if (!$currentAtker->unMagicAble && ($currentAtker->boss == 1) && (count(Mod_MooGame_FightEngine_Control::$defender) < 3)) {
			
				$temDefender = Mod_MooGame_FightEngine_Control::$defender;
				if (!$temDefender) {
					$temDefender = array();
				}
				$nowOPenPosition = array(2 => 2, 4 => 4);
				foreach ($temDefender as $id => $info) {
					if ($id == $currentAtker->id) {
						unset($temDefender[$id]);
					} else {
						if ($nowOPenPosition[$info->groupId]) {
							unset($nowOPenPosition[$info->groupId]);
						}
					}
				}
				
				$rebirthNumber = 2 - count($temDefender);
				for ($i = 1; $i <= $rebirthNumber; $i++) {
					$key = 0;
					$key = array_rand(Mod_MooGame_FightEngine_Control::$bossRebirthMobs);
					if ($key) {
						if (!$nowOPenPosition) {
							continue;
						}
						$nowPosition = array_rand($nowOPenPosition);
						if (Mod_MooGame_FightEngine_Control::$bossRebirthMobsArr[$nowPosition] >=
								count(Mod_MooGame_FightEngine_Control::$initBossRebirthMobs) / 2 ) {
							continue;
						}
						
						Mod_MooGame_FightEngine_Control::$defender[$key] = Mod_MooGame_FightEngine_Control::$bossRebirthMobs[$key];
						unset(Mod_MooGame_FightEngine_Control::$bossRebirthMobs[$key]);
						Mod_MooGame_FightEngine_Control::$defender[$key]->groupId = $nowPosition;
						Mod_MooGame_FightEngine_Control::$bossRebirthMobsArr[$nowPosition] += 1;
						unset($nowOPenPosition[$nowPosition]);
						
						//增加召唤log
						MooMod::get('MooGame_FightEngine_FightLog')->addBossRebirthMobsLog($currentAtker->id, Mod_MooGame_FightEngine_Control::$defender[$key]->id,$nowPosition);
					}
				}
				
			}
			return;
		}
	}
	
	/**
	 * 取出该战士拥有的魔法
	 * @param $currentAtker
	 */
	function getMagic($currentAtker) {
		foreach($currentAtker->magic as $row) {
			// 判断CD（当前回合 - 该魔法最后使用回合，如果小于等于CD的回合，则跳过该魔法）
			if ($row->magicLastTurn > 0) {
				if (Mod_MooGame_FightEngine_Control::$turnNum - $row->magicLastTurn <= $row->magicCD || $row->magicCD == -1) {
					continue;
				}
			}
	
			// 判断魔法是否还有使用次数
			if ($row->magicMaxUseNum > 0 && $row->magicUseNum >= $row->magicMaxUseNum) {
				continue;
			}
	
			// 判断当前战士是否有足够的魔法值
			if ($row->consumeMp > 0 && $row->consumeMp > $currentAtker->mp) {
				continue;
			}
	
			// 判断是否有几率触发该魔法
			if (rand(0, 100) <= $row->magicOdds) {
				Mod_MooGame_FightEngine_Control::$magicUqId++;
				$row->magicUqId = Mod_MooGame_FightEngine_Control::$magicUqId;
				$magic = $row;
				break;
			}
		}
	
		// 如果一个魔法都没有取到，则直接跳出
		if (!$magic) {
			return false;
		}
	
		return $magic;
	}

	/**
	 * 取出该战士拥有的特殊魔法
	 * @param $currentAtker
	 */
	function getSpecialMagic($row) {
		$magic = null;
		// 判断是否有几率触发该魔法
		if (rand(0, 100) <= $row->magicOdds) {
			Mod_MooGame_FightEngine_Control::$magicUqId++;
			$row->magicUqId = Mod_MooGame_FightEngine_Control::$magicUqId;
			$magic = $row;
		}
		
		// 如果一个魔法都没有取到，则直接跳出
		if (!$magic) {
			return false;
		}

		return $magic;
	}

	/**
	 * 物理攻击
	 * @param $currentAtker
	 */
	function attack($currentAtker, $isAssassination = false) {

		$currentDefer = '';
		$leastHpDefer = '';
		$leastHp = 0;

		// 取出攻击目标
		if ($currentAtker->group == 'attacker') {
			
			$deferIdArr = $defender = array();
			if ($currentAtker->addict) {
				$defender = Mod_MooGame_FightEngine_Control::$attacker;
			} else {
				$defender = Mod_MooGame_FightEngine_Control::$defender;
			}
		
			// 先打前排，再打第二排，最后打第三排
			foreach ((array)$defender as $tempRoleId => $tempRole) {
				// 判断战士是否存在
				$tempDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($tempRoleId);
				if ($tempDefer) {
					$deferIdArr[$tempRole->groupId] = $tempDefer;
				}
				
				if ($leastHp) {
					if ($tempDefer->hp < $leastHp) {
						$leastHpDefer = $tempDefer;
					}
				} else {
					$leastHp = $tempDefer->hp;
					$leastHpDefer = $tempDefer;
				}
			}
			ksort($deferIdArr);
			if($currentAtker->addict) {
				//如果被魅惑（混乱）被打的人为随机
				$id = array_rand($deferIdArr);
				$currentDefer =	$deferIdArr[$id];
			}else {				
				$currentDefer = $this->getDefer($currentAtker, $deferIdArr);
			}		
		} else {
			$deferIdArr = $defender = array();
			if ($currentAtker->addict) {
				$defender = Mod_MooGame_FightEngine_Control::$defender;
			} else {
				$defender = Mod_MooGame_FightEngine_Control::$attacker;
			}
			
			// 先打前排，再打第二排，最后打第三排
			foreach ((array)$defender as $tempRoleId => $tempRole) {
				// 判断战士是否存在
				$tempDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($tempRoleId);
				if ($tempDefer) {
					$deferIdArr[$tempRole->groupId] = $tempDefer;
				}
				
				if ($leastHp) {
					if ($tempDefer->hp < $leastHp) {
						$leastHpDefer = $tempDefer;
					}
				} else {
					$leastHp = $tempDefer->hp;
					$leastHpDefer = $tempDefer;
				}
			}
			ksort($deferIdArr);
			if($currentAtker->addict) {
				//如果被魅惑（混乱）被打的人为随机
				$id = array_rand($deferIdArr);
				$currentDefer =	$deferIdArr[$id];
			}else {				
				$currentDefer = $this->getDefer($currentAtker, $deferIdArr);
			}
		}

		if (!$currentDefer) {
			return array();
		}

		// 判断当前对战者是否已经死亡
		if ($currentDefer->group == 'attacker' && !Mod_MooGame_FightEngine_Control::$attacker[$currentDefer->id]) {
			return array();
		} elseif ($currentDefer->group == 'defender' && !Mod_MooGame_FightEngine_Control::$defender[$currentDefer->id]) {
			return array();
		}
		
		// 判断是否是刺杀
		if ($isAssassination) {
			if (!$leastHpDefer || !$currentAtker->assassination) {
				return false;
			}
			$currentAtker->attack($leastHpDefer, false, true);
			//刺杀log
			MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3520, $currentAtker->id, $leastHpDefer->id);
		} else {
			$currentAtker->attack($currentDefer);
		}
		
		// 横扫，普通攻击时，同时以80%攻击力攻击同排的所有单位
		if ($currentAtker->sweepAway) {
			
			$positionArr = array();
			if (in_array($currentDefer->groupId, array(2, 3, 4))) {
				$positionArr = array(2, 3, 4);
			} elseif (in_array($currentDefer->groupId, array(5, 6))) {
				$positionArr = array(5, 6);
			} else {
				$positionArr = array(1);
			}
			
			$sweepDefenders = array();
			if ($currentAtker->group == 'attacker') {
				$tmpAtkers = Mod_MooGame_FightEngine_Control::$defender;
			} else {
				$tmpAtkers = Mod_MooGame_FightEngine_Control::$attacker;
			}
			
			foreach ($tmpAtkers as $tmpRoleId => $tmpRoleObj) {
				if (!in_array($tmpRoleObj->groupId, $positionArr) || $tmpRoleId == $currentDefer->id) {
					continue;
				}
				$sweepDefenders[$tmpRoleId] = $tmpRoleObj;
			}
			
			if ($sweepDefenders) {
				foreach ($sweepDefenders as $sweepDefender) {
					$currentAtker->attack($sweepDefender, true);
					MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3523, $currentAtker->id, $sweepDefender->id);
				}
			}
		}
		
		// 判断战士是否存在
		$tempDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($currentDefer->id);
		if ($currentAtker->specialTreasureMagic && $tempDefer) {
			foreach($currentAtker->specialTreasureMagic as $row) {
				$magic = $this->getSpecialMagic($row);
				// 如果取到魔法则直接发动魔法
				if ($magic) {
					$this->magic($currentAtker, $magic, false, $tempDefer);
				}
			}
		}
		
	}

	/**
	 * 魔法攻击
	 * @param $currentAtker
	 * @param $magic
	 */
	function magic($currentAtker, $magic, $noLog = false, $treasureDefer = null) {
		// 随机取出当前的进攻方和防守方数组
		if ($currentAtker->group == 'attacker') {
			if ($currentAtker->addict) {
				$defers = Mod_MooGame_FightEngine_Control::$attacker;
				$atkers = Mod_MooGame_FightEngine_Control::$defender;
			} else {
				$defers = Mod_MooGame_FightEngine_Control::$defender;
				$atkers = Mod_MooGame_FightEngine_Control::$attacker;
			}
		} else {
			
			if ($currentAtker->addict) {
				$defers = Mod_MooGame_FightEngine_Control::$defender;
				$atkers = Mod_MooGame_FightEngine_Control::$attacker;
			} else {
				$defers = Mod_MooGame_FightEngine_Control::$attacker;
				$atkers = Mod_MooGame_FightEngine_Control::$defender;
			}
		}

		// 判断该魔法的作用目标
		$aimRole = array();
		switch ($magic->magicAim) {
			// 如果作用目标是自己
			case Mod_MooGame_FightEngine_Magic::MAGIC_AIM_SELF:
				if ($currentAtker->addict) {
					// 判断是否是对己方起效
					if ($currentAtker->group == 'attacker') {
						$tmpAtRoles = Mod_MooGame_FightEngine_Control::$defender;
					} else {
						$tmpAtRoles = Mod_MooGame_FightEngine_Control::$attacker;
					}
					$tmpRoleId = array_rand($tmpAtRoles);
					$aimRole[$tmpRoleId] = $tmpAtRoles[$tmpRoleId];
				} else {
					$aimRole[$currentAtker->id] = $currentAtker;
				}
				break;
			// 如果作用目标是友方
			case Mod_MooGame_FightEngine_Magic::MAGIC_AIM_GROUP:
				// 判断是作用于所有战士，还是指定数量的战士
				if ($magic->magicAimNum == -1) {
					$aimRole = $atkers;
				} else {
					$aimRole = $this->getAimRole($currentAtker, $atkers, $magic);
					if (!$aimRole) {
						// 随机取出指定数量的战士
						$maxNum = count($atkers);
						$maxNum = $maxNum < $magic->magicAimNum ? $maxNum : $magic->magicAimNum;
						for ($i = 0; $i < $maxNum; $i++) {
							//鼓舞技能特殊处理
							if (in_array($magic->id, array(3115, 3215, 3315, 3415, 3515))) {
								if (count($atkers) > 2) {
									unset($atkers[$currentAtker->id]);
								}
							}
							$id = array_rand($atkers);
							$aimRole[$id] = $atkers[$id];
							unset($atkers[$id]);
						}
					}

				}
				break;
			// 其他情况是敌方
			default:
				// 判断是作用于所有战士，还是指定数量的战士
				if ($magic->magicAimNum == -1) {
					$aimRole = $defers;
				} else {
					
					if ($magic->magicAimRow) {
						$deferIdArr = array();
						// 先打前排，再打第二排，最后打第三排
						foreach ((array)$defers as $tempRoleId => $tempRole) {
							// 判断战士是否存在
							$currentDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($tempRoleId);
							if ($currentDefer) {
								$deferIdArr[$tempRole->groupId] = $tempRoleId;
							}
						}
						ksort($deferIdArr);
						
						if (substr_count($magic->magicAimRow, ':')) {
							$rowArr = explode(',', $magic->magicAimRow);
							foreach ($rowArr as $tmpInfo) {
								$roleNumberArr = explode(':', $tmpInfo);
								if ($roleNumberArr[0] == 1) {
									if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
										$tmpDefers = array();
										if ($deferIdArr[2]) {
											$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
										}
										if ($deferIdArr[3]) {
											$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
										}
										if ($deferIdArr[4]) {
											$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
										}
										$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
										$haveDefer = false;
										for ($i = 0; $i < $maxNum; $i++) {
											// 先打前排，再打第二排，最后打第三排
											$rateNumber = rand(1, 100);
											if ($rateNumber <= $magic->magicAimRowRate) {
												$id = array_rand($tmpDefers);
											}
											if (!$id) {
												continue;
											}
											$haveDefer = true;
											$aimRole[$id] = $defers[$id];
											unset($tmpDefers[$id]);
										}
										if (!$haveDefer) {
											$id = $this->getDefer($currentAtker, $deferIdArr);
											if (!$id) {
												continue;
											}
											$aimRole[$id] = $defers[$id];
											unset($defers[$id]);
										}
									} elseif ($deferIdArr[5] || $deferIdArr[6]) {
										$tmpDefers = array();
										if ($deferIdArr[5]) {
											$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
										}
										if ($deferIdArr[6]) {
											$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
										}
										$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
										$haveDefer = false;
										for ($i = 0; $i < $maxNum; $i++) {
											// 先打前排，再打第二排，最后打第三排
											$rateNumber = rand(1, 100);
											if ($rateNumber <= $magic->magicAimRowRate) {
												$id = array_rand($tmpDefers);
											}
											if (!$id) {
												continue;
											}
											$haveDefer = true;
											$aimRole[$id] = $defers[$id];
											unset($tmpDefers[$id]);
										}
										if (!$haveDefer) {
											$id = $this->getDefer($currentAtker, $deferIdArr);
											if (!$id) {
												continue;
											}
											$aimRole[$id] = $defers[$id];
											unset($defers[$id]);
										}
									} else {
										// 先打前排，再打第二排，最后打第三排
										$id = $this->getDefer($currentAtker, $deferIdArr);
										if (!$id) {
											continue;
										}
										$aimRole[$id] = $defers[$id];
									}
								}
								if ($roleNumberArr[0] == 2) {
									if ($deferIdArr[5] || $deferIdArr[6]) {
										$tmpDefers = array();
										if ($deferIdArr[5]) {
											$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
										}
										if ($deferIdArr[6]) {
											$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
										}
										$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
										$haveDefer = false;
										for ($i = 0; $i < $maxNum; $i++) {
											// 先打前排，再打第二排，最后打第三排
											$rateNumber = rand(1, 100);
											if ($rateNumber <= $magic->magicAimRowRate) {
												$id = array_rand($tmpDefers);
											}
											if (!$id) {
												continue;
											}
											$haveDefer = true;
											$aimRole[$id] = $defers[$id];
											unset($tmpDefers[$id]);
										}
										if (!$haveDefer) {
											$id = $this->getDefer($currentAtker, $deferIdArr);
											if (!$id) {
												continue;
											}
											$aimRole[$id] = $defers[$id];
											unset($defers[$id]);
										}
									} else {
										// 风系、祝福、雷系系技能从后往前打
										if (in_array($magic->id, array(3113, 3213, 3313, 3413, 3513, 3103, 3203, 3303, 3403, 3503))) {
											if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
												$tmpDefers = array();
												if ($deferIdArr[2]) {
													$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
												}
												if ($deferIdArr[3]) {
													$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
												}
												if ($deferIdArr[4]) {
													$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
												}
												$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
												$haveDefer = false;
												for ($i = 0; $i < $maxNum; $i++) {
													// 先打前排，再打第二排，最后打第三排
													$rateNumber = rand(1, 100);
													if ($rateNumber <= $magic->magicAimRowRate) {
														$id = array_rand($tmpDefers);
													}
													if (!$id) {
														continue;
													}
													$haveDefer = true;
													$aimRole[$id] = $defers[$id];
													unset($tmpDefers[$id]);
												}
												if (!$haveDefer) {
													$id = $this->getDefer($currentAtker, $deferIdArr);
													if (!$id) {
														continue;
													}
													$aimRole[$id] = $defers[$id];
													unset($defers[$id]);
												}
											} else {
												// 先打前排，再打第二排，最后打第三排
												$id = $this->getDefer($currentAtker, $deferIdArr);
												if (!$id) {
													continue;
												}
												$aimRole[$id] = $defers[$id];
											}
										} elseif ($deferIdArr[1]) {
											$tmpDefers = array();
											if ($deferIdArr[1]) {
												$tmpDefers[$deferIdArr[1]] = $deferIdArr[1];
											}
											$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
											$haveDefer = false;
											for ($i = 0; $i < $maxNum; $i++) {
												// 先打前排，再打第二排，最后打第三排
												$rateNumber = rand(1, 100);
												if ($rateNumber <= $magic->magicAimRowRate) {
													$id = array_rand($tmpDefers);
												}
												if (!$id) {
													continue;
												}
												$haveDefer = true;
												$aimRole[$id] = $defers[$id];
												unset($tmpDefers[$id]);
											}
											if (!$haveDefer) {
												$id = $this->getDefer($currentAtker, $deferIdArr);
												if (!$id) {
													continue;
												}
												$aimRole[$id] = $defers[$id];
												unset($defers[$id]);
											}
										} else {
											if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
												$tmpDefers = array();
												if ($deferIdArr[2]) {
													$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
												}
												if ($deferIdArr[3]) {
													$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
												}
												if ($deferIdArr[4]) {
													$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
												}
												$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
												$haveDefer = false;
												for ($i = 0; $i < $maxNum; $i++) {
													// 先打前排，再打第二排，最后打第三排
													$rateNumber = rand(1, 100);
													if ($rateNumber <= $magic->magicAimRowRate) {
														$id = array_rand($tmpDefers);
													}
													if (!$id) {
														continue;
													}
													$haveDefer = true;
													$aimRole[$id] = $defers[$id];
													unset($tmpDefers[$id]);
												}
												if (!$haveDefer) {
													$id = $this->getDefer($currentAtker, $deferIdArr);
													if (!$id) {
														continue;
													}
													$aimRole[$id] = $defers[$id];
													unset($defers[$id]);
												}
											} else {
												// 先打前排，再打第二排，最后打第三排
												$id = $this->getDefer($currentAtker, $deferIdArr);
												if (!$id) {
													continue;
												}
												$aimRole[$id] = $defers[$id];
											}
										}
										
									}
								}
								if ($roleNumberArr[0] == 3) {
									if ($deferIdArr[1]) {
										$aimRole[$deferIdArr[1]] = $defers[$deferIdArr[1]];
									} else {
										// 风系、祝福系技能从后往前打
										if (in_array($magic->id, array(3101, 3201, 3301, 3401, 3501, 3113, 3213, 3313, 3413, 3513))) {
											if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
												$tmpDefers = array();
												if ($deferIdArr[2]) {
													$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
												}
												if ($deferIdArr[3]) {
													$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
												}
												if ($deferIdArr[4]) {
													$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
												}
												$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
												$haveDefer = false;
												for ($i = 0; $i < $maxNum; $i++) {
													// 先打前排，再打第二排，最后打第三排
													$rateNumber = rand(1, 100);
													if ($rateNumber <= $magic->magicAimRowRate) {
														$id = array_rand($tmpDefers);
													}
													if (!$id) {
														continue;
													}
													$haveDefer = true;
													$aimRole[$id] = $defers[$id];
													unset($tmpDefers[$id]);
												}
												if (!$haveDefer) {
													$id = $this->getDefer($currentAtker, $deferIdArr);
													if (!$id) {
														continue;
													}
													$aimRole[$id] = $defers[$id];
													unset($defers[$id]);
												}
											}
											else if ($deferIdArr[5] || $deferIdArr[6]) {
												$tmpDefers = array();
												if ($deferIdArr[5]) {
													$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
												}
												if ($deferIdArr[6]) {
													$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
												}
												$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
												$haveDefer = false;
												for ($i = 0; $i < $maxNum; $i++) {
													// 先打前排，再打第二排，最后打第三排
													$rateNumber = rand(1, 100);
													if ($rateNumber <= $magic->magicAimRowRate) {
														$id = array_rand($tmpDefers);
													}
													if (!$id) {
														continue;
													}
													$haveDefer = true;
													$aimRole[$id] = $defers[$id];
													unset($tmpDefers[$id]);
												}
												if (!$haveDefer) {
													$id = $this->getDefer($currentAtker, $deferIdArr);
													if (!$id) {
														continue;
													}
													$aimRole[$id] = $defers[$id];
													unset($defers[$id]);
												}
											}  else {
												// 先打前排，再打第二排，最后打第三排
												$id = $this->getDefer($currentAtker, $deferIdArr);
												if (!$id) {
													continue;
												}
												$aimRole[$id] = $defers[$id];
											}
										} else {
											// 先打前排，再打第二排，最后打第三排
											$id = $this->getDefer($currentAtker, $deferIdArr);
											if (!$id) {
												continue;
											}
											$aimRole[$id] = $defers[$id];
										}
									}
								}
							}
							
							// 如果所打的那排已经没有人，就从前往后排打
							if (!$aimRole) {
								$rowArr = explode(',', $magic->magicAimRow);
								foreach ($rowArr as $tmpInfo) {
									$roleNumberArr = explode(':', $tmpInfo);
	
										if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
											$tmpDefers = array();
											if ($deferIdArr[2]) {
												$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
											}
											if ($deferIdArr[3]) {
												$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
											}
											if ($deferIdArr[4]) {
												$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
											}
											$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
											$haveDefer = false;
											for ($i = 0; $i < $maxNum; $i++) {
												// 先打前排，再打第二排，最后打第三排
												$rateNumber = rand(1, 100);
												if ($rateNumber <= $magic->magicAimRowRate) {
													$id = array_rand($tmpDefers);
												}
												if (!$id) {
													continue;
												}
												$haveDefer = true;
												$aimRole[$id] = $defers[$id];
												unset($tmpDefers[$id]);
											}
											if (!$haveDefer) {
												$id = $this->getDefer($currentAtker, $deferIdArr);
												if (!$id) {
													continue;
												}
												$aimRole[$id] = $defers[$id];
												unset($defers[$id]);
											}
										} elseif ($deferIdArr[5] || $deferIdArr[6]) {
											$tmpDefers = array();
											if ($deferIdArr[5]) {
												$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
											}
											if ($deferIdArr[6]) {
												$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
											}
											$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
											$haveDefer = false;
											for ($i = 0; $i < $maxNum; $i++) {
												// 先打前排，再打第二排，最后打第三排
												$rateNumber = rand(1, 100);
												if ($rateNumber <= $magic->magicAimRowRate) {
													$id = array_rand($tmpDefers);
												}
												if (!$id) {
													continue;
												}
												$haveDefer = true;
												$aimRole[$id] = $defers[$id];
												unset($tmpDefers[$id]);
											}
											if (!$haveDefer) {
												$id = $this->getDefer($currentAtker, $deferIdArr);
												if (!$id) {
													continue;
												}
												$aimRole[$id] = $defers[$id];
												unset($defers[$id]);
											}
										} else {
											$aimRole[$deferIdArr[1]] = $defers[$deferIdArr[1]];
										}
								}
							
							}
						} else {
							$tmpDefers = array();
							$rowArr = explode(',', $magic->magicAimRow);
							foreach ($rowArr as $tmpRowId) {
								if ($tmpRowId == 1) {
									if ($deferIdArr[2]) {
										$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
									}
									if ($deferIdArr[3]) {
										$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
									}
									if ($deferIdArr[4]) {
										$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
									}
								}
								if ($tmpRowId == 2) {
									if ($deferIdArr[5]) {
										$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
									}
									if ($deferIdArr[6]) {
										$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
									}
								}
								if ($tmpRowId == 3) {
									if ($deferIdArr[1]) {
										$tmpDefers[$deferIdArr[1]] = $deferIdArr[1];
									}
								}
							}
							// 随机取出指定数量的战士
							$haveDefer = false;
							$maxNum = count($tmpDefers);
							$maxNum = $maxNum < $magic->magicAimNum ? $maxNum : $magic->magicAimNum;
							for ($i = 0; $i < $maxNum; $i++) {
								$rateNumber = rand(1, 100);
								if ($rateNumber <= $magic->magicAimRowRate) {
									$id = array_rand($tmpDefers);
								}
								if (!$id) {
									continue;
								}
								$haveDefer = true;
								$aimRole[$id] = $defers[$id];
								unset($tmpDefers[$id]);
							}
							
							if (!$haveDefer) {
								$id = $this->getDefer($currentAtker, $deferIdArr);
								if (!$id) {
									continue;
								}
								$aimRole[$id] = $defers[$id];
								unset($defers[$id]);
							}
						}
					} else {
						if ($magic->delMinHpMagic) {
							$minHp = 0;
							foreach ($defers as $tmpId => $aimRoleObj) {
								if ($minHp) {
									if ($minHp > $aimRoleObj->hp) {
										$minHp = $aimRoleObj->hp;
										$id = $tmpId;
									}
								} else {
									$minHp = $aimRoleObj->hp;
									$id = $tmpId;
								}
							}
							$aimRole[$id] = $defers[$id];
						} else {
					
							// 随机取出指定数量的战士
							$maxNum = count($defers);
							$maxNum = $maxNum < $magic->magicAimNum ? $maxNum : $magic->magicAimNum;
							for ($i = 0; $i < $maxNum; $i++) {
								$id = '';
								$deferIdArr = array();
								// 先打前排，再打第二排，最后打第三排
								foreach ((array)$defers as $tempRoleId => $tempRole) {
									// 判断战士是否存在
									$currentDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($tempRoleId);
									if ($currentDefer) {
										$deferIdArr[$tempRole->groupId] = $tempRoleId;
									}
								}
		
								ksort($deferIdArr);
								// 先打前排，再打第二排，最后打第三排
								if ($maxNum > 1 || in_array($magic->id, array(3108, 3208, 3308, 3408, 3508, 3197, 3297, 3397, 3497, 3597)) || $currentAtker->addict) {
									$idKey = array_rand($deferIdArr);
									$id = $deferIdArr[$idKey];
									/*
									if ($currentAtker->addict && $id == $currentAtker->id) {
										if ($currentAtker->effect) {
											foreach ($currentAtker->effect as $eKey => $vInfoObj) {
												if ($vInfoObj->magicId == $magic->id) {
													unset($currentAtker->effect[$eKey]);
												}
											}
										}
										// 取出攻击目标
										if ($currentAtker->group == 'attacker') {
											Mod_MooGame_FightEngine_Control::$attacker[$currentAtker->id] = $currentAtker;
											if (in_array($magic->id, array(3108, 3208, 3308, 3408, 3508))) {
												Mod_MooGame_FightEngine_Control::$attacker[$currentAtker->id]->addict = 0;
											}
										} else {
											Mod_MooGame_FightEngine_Control::$defender[$currentAtker->id] = $currentAtker;
											if (in_array($magic->id, array(3108, 3208, 3308, 3408, 3508))) {
												Mod_MooGame_FightEngine_Control::$defender[$currentAtker->id]->addict = 0;
											}
										}
									}
									// */
									
								} else {
									$id = $this->getDefer($currentAtker, $deferIdArr);
								}
		
								if (!$id) {
									continue;
								}
								$aimRole[$id] = $defers[$id];
								unset($defers[$id]);
							}
						}
					}
				}
				break;
		}
		
		// 法宝固定打的将
		if ($treasureDefer) {
			$aimRole = array();
			$aimRole[$treasureDefer->id] = $treasureDefer;
		}
		
		// 对一二转一开始就加血和加攻、加生命上限技能做处理
		if ($noLog) {
			foreach ($aimRole as $k => $tmpRoleObj) {
				if ($this->skillConfig[$magic->id]['attribute'] && !in_array($this->heroConfig['heroConf'][$tmpRoleObj->confId]['attribute'], $this->skillConfig[$magic->id]['attribute'])) {
					unset($aimRole[$k]);
				}
			}
			if (!$aimRole) {
				return;
			}
		}

		// 增加一个魔法使用记录
		$aimIds = array();
		foreach ($aimRole as $role) {
			$aimIds[] = $role->id;
		}
		
		if (!$noLog) {
			MooMod::get('MooGame_FightEngine_FightLog')->addMagicLog($currentAtker->id, $magic, implode(',', $aimIds));
		}
		
		// 如果是群攻技能，则在攻击后产生增益效果的转生技能只能产生作用一次，不能每打一个人自己一次
		Mod_MooGame_FightEngine_Control::$gainSkillArr = array();
		
		// 对施法目标进行挨个施法
		foreach ($aimRole as $role) {
			
			// 判断魔法作用方是否有魔法免疫
			if ($role->magicImmune) {
				continue;
			}
			
			// 对穷奇做处理
			if (!$noLog && $role->oddPoor && in_array($magic->id, MooConfig::get('skill.fightHandleSkill'))) {
				//MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3526, $currentAtker->id, $role->id, 0, true);
				if ($magic) {
					foreach ($magic->effect as $tmpEffectObj) {
						if ($tmpEffectObj->effectToProps == 'hp') {
							$delHpRate = rand($tmpEffectObj->effectMinValue, $tmpEffectObj->effectMinValue);
							$initDelHp = $currentAtker->atk - $role->def;
							$delHp = 0;
							if ($initDelHp <= 0) {
								$delHp = 1;
							} else {
								$delHp = abs($initDelHp * ($delHpRate / 100));
							}
							break;
						}
					}
				}
				$role->attack($currentAtker, 0, 0, 1, $delHp);
			} else {
				$currentAtker->useMagic($role, $magic, $noLog);
			}
		}
		
		// 循环后释放
		Mod_MooGame_FightEngine_Control::$gainSkillArr = array();

		// 更新该魔法最后的触发回合
		$magic->magicLastTurn = Mod_MooGame_FightEngine_Control::$turnNum;

		// 更新魔法的使用次数
		$magic->magicUseNum++;

	}
	
	/**
	 * 获取当前防御者
	 * 
	 * @param object $currentAtker
	 * @param array $deferIdArr
	 */
	private function getDefer($currentAtker, $deferIdArr) {
		
		/*
		 * 站位顺序
		* 1  6  4       4
		* 5  3       3  6
		* 2       2  5  1
		*/
		$currentDefer = null;
		if ($currentAtker->groupId == 1) {
			if ($deferIdArr[3]) {
				$currentDefer = $deferIdArr[3];
			} else {
				if ($deferIdArr) {
					if (count($deferIdArr) > 1 && $deferIdArr[1]) {
						unset($deferIdArr[1]);
					}
					$currentDefer = reset($deferIdArr);
				}
			}
		} elseif (in_array($currentAtker->groupId, array(5, 6))) {
			if (!$deferIdArr[2] && !$deferIdArr[3] && !$deferIdArr[4]) {
				if ($deferIdArr[$currentAtker->groupId]) {
					$currentDefer = $deferIdArr[$currentAtker->groupId];
				} else {
					if ($deferIdArr) {
						if (count($deferIdArr) > 1 && $deferIdArr[1]) {
							unset($deferIdArr[1]);
						}
						$currentDefer = reset($deferIdArr);
					}
				}
			} else {
				if ($currentAtker->groupId == 5 && $deferIdArr[2]) {
					$currentDefer = $deferIdArr[2];
				} elseif ($currentAtker->groupId == 6 && $deferIdArr[4]) {
					$currentDefer = $deferIdArr[4];
				} else {
					if ($deferIdArr) {
						if (count($deferIdArr) > 1 && $deferIdArr[1]) {
							unset($deferIdArr[1]);
						}
						$currentDefer = reset($deferIdArr);
					}
				}
			}
		} else {
			if ($deferIdArr[$currentAtker->groupId]) {
				$currentDefer = $deferIdArr[$currentAtker->groupId];
			} else {
				
				if (in_array($currentAtker->groupId, array(2, 3, 4)) && (!$deferIdArr[2] && !$deferIdArr[3] && !$deferIdArr[4])) {
					if (in_array($currentAtker->groupId, array(2, 3)) && $deferIdArr[5]) {
						$currentDefer = $deferIdArr[5];
					} elseif ($currentAtker->groupId == 4 && $deferIdArr[6]) {
						$currentDefer = $deferIdArr[6];
					} else {
						if ($deferIdArr) {
							if (count($deferIdArr) > 1 && $deferIdArr[1]) {
								unset($deferIdArr[1]);
							}
							$currentDefer = reset($deferIdArr);
						}
					}
				} else {
					if ($deferIdArr) {
						if (count($deferIdArr) > 1 && $deferIdArr[1]) {
							unset($deferIdArr[1]);
						}
						$currentDefer = reset($deferIdArr);
					}
				}
			}
		}
		
		return $currentDefer;
	}
	
	/**
	 * 获取目标
	 */
	private function getAimRole($currentAtker, $defers, $magic) {

		$deferIdArr = array();
		// 先打前排，再打第二排，最后打第三排
		foreach ((array)$defers as $tempRoleId => $tempRole) {
			// 判断战士是否存在
			$currentDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($tempRoleId);
			if ($currentDefer) {
				$deferIdArr[$tempRole->groupId] = $tempRoleId;
			}
		}
						
		ksort($deferIdArr);
		
		//治愈特殊处理 :3112,3212, 3312, 3412, 3512------------------------------- 
		//3112 : 第一排随机两个
		if ($magic->id == 3112) { 
			if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4] ) {
				if ($deferIdArr[2]) {
					$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
				}
				if ($deferIdArr[3]) {
					$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
				}
				if ($deferIdArr[4]) {
					$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
				}
				if (count($tmpDefers) > 2){
					$removeNumber = rand(2,4);
					unset($tmpDefers[$deferIdArr[$removeNumber]]);					
				}
				foreach ($tmpDefers as $id =>$val) {
					$aimRole[$id] = $defers[$id];
				}
				return $aimRole;
			} else if ($deferIdArr[5] || $deferIdArr[6]) {
				if ($deferIdArr[5]) {
					$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
				}
				if ($deferIdArr[6]) {
					$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
				}
				foreach ($tmpDefers as $id =>$val) {
					$aimRole[$id] = $defers[$id];
				}
				return $aimRole;
			} else {
				$aimRole[$deferIdArr[1]] = $defers[$deferIdArr[1]];
				return $aimRole;
			}
		}
		// 3212:正常
		//3312 : 前两排随机4个
		if ($magic->id == 3312) {
			if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4] || $deferIdArr[5] || $deferIdArr[6]) {
				if ($deferIdArr[2]) {
					$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
				}
				if ($deferIdArr[3]) {
					$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
				}
				if ($deferIdArr[4]) {
					$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
				}
				if ($deferIdArr[5]) {
					$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
				}
				if ($deferIdArr[6]) {
					$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
				}
				
				if (count($tmpDefers) > 4){
					$removeNumber = rand(2,6);
					unset($tmpDefers[$deferIdArr[$removeNumber]]);					
				}
				foreach ($tmpDefers as $id =>$val) {
					$aimRole[$id] = $defers[$id];
				}
				return $aimRole;
			} else {
				$aimRole[$deferIdArr[1]] = $defers[$deferIdArr[1]];
				return $aimRole;
			}			
		}
		//3412 : 前两排全部
		if ($magic->id == 3412) {
			if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4] || $deferIdArr[5] || $deferIdArr[6]) {
				if ($deferIdArr[2]) {
					$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
				}
				if ($deferIdArr[3]) {
					$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
				}
				if ($deferIdArr[4]) {
					$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
				}
				if ($deferIdArr[5]) {
					$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
				}
				if ($deferIdArr[6]) {
					$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
				}
				foreach ($tmpDefers as $id =>$val) {
					$aimRole[$id] = $defers[$id];
				}
				return $aimRole;
			} else {
				$aimRole[$deferIdArr[1]] = $defers[$deferIdArr[1]];
				return $aimRole;
			}
		}
		//3512 : 全体
		//治愈特殊处理 :3112,3212, 3312, 3412, 3512 end-------------------------------
		
		if (substr_count($magic->magicAimRow, ':')) {
			$rowArr = explode(',', $magic->magicAimRow);
			foreach ($rowArr as $tmpInfo) {
				$roleNumberArr = explode(':', $tmpInfo);
				if ($roleNumberArr[0] == 1) {
					if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
						$tmpDefers = array();
						if ($deferIdArr[2]) {
							$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
						}
						if ($deferIdArr[3]) {
							$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
						}
						if ($deferIdArr[4]) {
							$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
						}
						$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
						$haveDefer = false;
						for ($i = 0; $i < $maxNum; $i++) {
							// 先打前排，再打第二排，最后打第三排
							$rateNumber = rand(1, 100);
							if ($rateNumber <= $magic->magicAimRowRate) {
								$id = array_rand($tmpDefers);
							}
							if (!$id) {
								continue;
							}
							$haveDefer = true;
							$aimRole[$id] = $defers[$id];
							unset($tmpDefers[$id]);
						}
						if (!$haveDefer) {
							$id = $this->getDefer($currentAtker, $deferIdArr);
							if (!$id) {
								continue;
							}
							$aimRole[$id] = $defers[$id];
							unset($defers[$id]);
						}
					} elseif ($roleNumberArr[1] > 1) {
						$tmpDefers = array();
						if ($deferIdArr[5] || $deferIdArr[6]) {
							if ($deferIdArr[5]) {
								$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
							}
							if ($deferIdArr[6]) {
								$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
							}
						} else {
							if ($deferIdArr[1]) {
								$tmpDefers[$deferIdArr[1]] = $deferIdArr[1];
							}
						}
						
						$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
						$haveDefer = false;
						for ($i = 0; $i < $maxNum; $i++) {
							// 先打前排，再打第二排，最后打第三排
							$rateNumber = rand(1, 100);
							if ($rateNumber <= $magic->magicAimRowRate) {
								$id = array_rand($tmpDefers);
							}
							if (!$id) {
								continue;
							}
							$haveDefer = true;
							$aimRole[$id] = $defers[$id];
							unset($tmpDefers[$id]);
						}
						if (!$haveDefer) {
							$id = $this->getDefer($currentAtker, $deferIdArr);
							if (!$id) {
								continue;
							}
							$aimRole[$id] = $defers[$id];
							unset($defers[$id]);
						}
					} else {
						// 先打前排，再打第二排，最后打第三排
						$id = $this->getDefer($currentAtker, $deferIdArr);
						if (!$id) {
							continue;
						}
						$aimRole[$id] = $defers[$id];
					}
				}
				if ($roleNumberArr[0] == 2) {
					if ($deferIdArr[5] || $deferIdArr[6]) {
						$tmpDefers = array();
						if ($deferIdArr[5]) {
							$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
						}
						if ($deferIdArr[6]) {
							$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
						}
						$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
						$haveDefer = false;
						for ($i = 0; $i < $maxNum; $i++) {
							// 先打前排，再打第二排，最后打第三排
							$rateNumber = rand(1, 100);
							if ($rateNumber <= $magic->magicAimRowRate) {
								$id = array_rand($tmpDefers);
							}
							if (!$id) {
								continue;
							}
							$haveDefer = true;
							$aimRole[$id] = $defers[$id];
							unset($tmpDefers[$id]);
						}
						if (!$haveDefer) {
							$id = $this->getDefer($currentAtker, $deferIdArr);
							if (!$id) {
								continue;
							}
							$aimRole[$id] = $defers[$id];
							unset($defers[$id]);
						}
					} elseif ($roleNumberArr[1] > 1) {
						$tmpDefers = array();
						if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
							if ($deferIdArr[2]) {
								$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
							}
							if ($deferIdArr[3]) {
								$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
							}
							if ($deferIdArr[4]) {
								$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
							}
						} else {
							if ($deferIdArr[1]) {
								$tmpDefers[$deferIdArr[1]] = $deferIdArr[1];
							}
						}
						
						$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
						$haveDefer = false;
						for ($i = 0; $i < $maxNum; $i++) {
							// 先打前排，再打第二排，最后打第三排
							$rateNumber = rand(1, 100);
							if ($rateNumber <= $magic->magicAimRowRate) {
								$id = array_rand($tmpDefers);
							}
							if (!$id) {
								continue;
							}
							$haveDefer = true;
							$aimRole[$id] = $defers[$id];
							unset($tmpDefers[$id]);
						}
						if (!$haveDefer) {
							$id = $this->getDefer($currentAtker, $deferIdArr);
							if (!$id) {
								continue;
							}
							$aimRole[$id] = $defers[$id];
							unset($defers[$id]);
						}
					} else {
						// 先打前排，再打第二排，最后打第三排
						$id = $this->getDefer($currentAtker, $deferIdArr);
						if (!$id) {
							continue;
						}
						$aimRole[$id] = $defers[$id];
					}
				}
				if ($roleNumberArr[0] == 3) {
					if ($deferIdArr[1]) {
						$aimRole[$deferIdArr[1]] = $defers[$deferIdArr[1]];
					} elseif ($roleNumberArr[1] > 1) {
						$tmpDefers = array();
						if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
							if ($deferIdArr[2]) {
								$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
							}
							if ($deferIdArr[3]) {
								$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
							}
							if ($deferIdArr[4]) {
								$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
							}
						} else {
							if ($deferIdArr[5]) {
								$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
							}
							if ($deferIdArr[6]) {
								$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
							}
						}
						
						$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
						$haveDefer = false;
						for ($i = 0; $i < $maxNum; $i++) {
							// 先打前排，再打第二排，最后打第三排
							$rateNumber = rand(1, 100);
							if ($rateNumber <= $magic->magicAimRowRate) {
								$id = array_rand($tmpDefers);
							}
							if (!$id) {
								continue;
							}
							$haveDefer = true;
							$aimRole[$id] = $defers[$id];
							unset($tmpDefers[$id]);
						}
						if (!$haveDefer) {
							$id = $this->getDefer($currentAtker, $deferIdArr);
							if (!$id) {
								continue;
							}
							$aimRole[$id] = $defers[$id];
							unset($defers[$id]);
						}
					} else {
						// 先打前排，再打第二排，最后打第三排
						$id = $this->getDefer($currentAtker, $deferIdArr);
						if (!$id) {
							continue;
						}
						$aimRole[$id] = $defers[$id];
					}
				}
			}
				
			// 如果所打的那排已经没有人，就从前往后排打
			if (!$aimRole) {
				$rowArr = explode(',', $magic->magicAimRow);
				foreach ($rowArr as $tmpInfo) {
					$roleNumberArr = explode(':', $tmpInfo);
	
					if ($deferIdArr[2] || $deferIdArr[3] || $deferIdArr[4]) {
						$tmpDefers = array();
						if ($deferIdArr[2]) {
							$tmpDefers[$deferIdArr[2]] = $deferIdArr[2];
						}
						if ($deferIdArr[3]) {
							$tmpDefers[$deferIdArr[3]] = $deferIdArr[3];
						}
						if ($deferIdArr[4]) {
							$tmpDefers[$deferIdArr[4]] = $deferIdArr[4];
						}
						$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
						$haveDefer = false;
						for ($i = 0; $i < $maxNum; $i++) {
							// 先打前排，再打第二排，最后打第三排
							$rateNumber = rand(1, 100);
							if ($rateNumber <= $magic->magicAimRowRate) {
								$id = array_rand($tmpDefers);
							}
							if (!$id) {
								continue;
							}
							$haveDefer = true;
							$aimRole[$id] = $defers[$id];
							unset($tmpDefers[$id]);
						}
						if (!$haveDefer) {
							$id = $this->getDefer($currentAtker, $deferIdArr);
							if (!$id) {
								continue;
							}
							$aimRole[$id] = $defers[$id];
							unset($defers[$id]);
						}
					} elseif ($deferIdArr[5] || $deferIdArr[6]) {
						$tmpDefers = array();
						if ($deferIdArr[5]) {
							$tmpDefers[$deferIdArr[5]] = $deferIdArr[5];
						}
						if ($deferIdArr[6]) {
							$tmpDefers[$deferIdArr[6]] = $deferIdArr[6];
						}
						$maxNum = count($tmpDefers) < $roleNumberArr[1] ? count($tmpDefers) : $roleNumberArr[1];
						$haveDefer = false;
						for ($i = 0; $i < $maxNum; $i++) {
							// 先打前排，再打第二排，最后打第三排
							$rateNumber = rand(1, 100);
							if ($rateNumber <= $magic->magicAimRowRate) {
								$id = array_rand($tmpDefers);
							}
							if (!$id) {
								continue;
							}
							$haveDefer = true;
							$aimRole[$id] = $defers[$id];
							unset($tmpDefers[$id]);
						}
						if (!$haveDefer) {
							$id = $this->getDefer($currentAtker, $deferIdArr);
							if (!$id) {
								continue;
							}
							$aimRole[$id] = $defers[$id];
							unset($defers[$id]);
						}
					} else {
						$aimRole[$deferIdArr[1]] = $defers[$deferIdArr[1]];
					}
				}
					
			}
		}
		
		return $aimRole;
	}
	
}
