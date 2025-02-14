<?php
class Mod_MooGame_FightEngine_Control_Auto_start {

	/**
	 * 开始自动战斗
	 */
	function start() {
		while (true) {
			// 双方如果有一方全灭，则结束战斗
			if (empty(Mod_MooGame_PVPEngine_Control::$attacker)
			|| empty(Mod_MooGame_PVPEngine_Control::$defender)) {

				// 获取胜利方
				if (empty(Mod_MooGame_PVPEngine_Control::$attacker)) {
					Mod_MooGame_PVPEngine_Control::$winner = 'defender';
				} else {
					Mod_MooGame_PVPEngine_Control::$winner = 'attacker';
				}

				return;
			}

			// 如果超过限定回合，则直接终止战斗
			if (Mod_MooGame_PVPEngine_Control::$maxTurnNum > 0
				&& Mod_MooGame_PVPEngine_Control::$turnNum >= Mod_MooGame_PVPEngine_Control::$maxTurnNum) {
				return;
			}

			// 根据战士的敏捷判断出招先后顺序
			$roles = $this->roleSort();

			// 开始一个回合的战斗
			$this->goAround($roles);
		}
	}

	/**
	 * 根据战士的敏捷，判断出招先后顺序
	 */
	function roleSort() {
		// 根据敏捷判断出招先后顺序
		$roles = array();
		$i = 0;
		foreach (Mod_MooGame_PVPEngine_Control::$attacker as $role) {
			$roles[$i]['id'] = $role->id;
			$roles[$i]['spd'] = $role->spd + (rand(0, 100) / 10000); // 增加0.00--0.01个点波动几率
			$roles[$i]['group'] = 'attacker';
			$i++;
		}
		foreach (Mod_MooGame_PVPEngine_Control::$defender as $role) {
			$roles[$i]['id'] = $role->id;
			$roles[$i]['spd'] = $role->spd + (rand(0, 100) / 10000); // 增加0.00--0.01个点波动几率
			$roles[$i]['group'] = 'defender';
			$i++;
		}

		// 敏捷高的先出手。敏捷一样的情况下，进攻方先出手。
		MooArray::tdsort($roles, 'spd', SORT_DESC);
		return $roles;
	}

	/**
	 * 开始一个回合的战斗
	 * @param $roles
	 */
	function goAround($roles) {
		// 更新回合数
		Mod_MooGame_PVPEngine_Control::$turnNum++;

		// 更新当前回合对战的顺序id数
		Mod_MooGame_PVPEngine_Control::$ackNum = 0;

		// 回合开始时，需要判断所有战士身上的效果
		foreach ($roles as $key => $row) {
			$role = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($row['id']);
			$role->roundStartBuff();
		}

		// 对场上所有战士进行战斗
		foreach ($roles as $row) {
			// 双方如果有一方全灭，则结束战斗
			if (empty(Mod_MooGame_PVPEngine_Control::$attacker) || empty(Mod_MooGame_PVPEngine_Control::$defender)) {
				return true;
			}

			// 设置当前的进攻者
			$currentAtker = '';
			$currentAtker = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($row['id']);

			// 判断战士是否存在
			if (!$currentAtker) {
				continue;
			}

			// 战士行动
			$this->action($currentAtker);

			// 更新战士的回合数
			$currentAtker->lastActionRound = Mod_MooGame_PVPEngine_Control::$turnNum;

			// 取出所有效果
			foreach ((array)$currentAtker->effect as $effect) {
				// 判断效果是否永不过期
				if ($effect->timeOut != -1) {

					// 判断是否是回合前才需要去掉的到期效果
					if ($effect->magicRemove != Mod_MooGame_PVPEngine_Magic::MAGIC_REMOVE_ROUND_START) {

						// 对剧毒种子处理
						if ($effect->specialEffectId && ($effect->specialEffectId == Mod_MooGame_PVPEngine_Effect::SPECIAL_EFFECT_VIRULENT_SEED)) {
							if (Mod_MooGame_PVPEngine_Control::$turnNum - $effect->startTime >= $effect->timeOut) {
								$currentAtker->removeEffect($effect->uniqueId, Mod_MooGame_PVPEngine_Effect::VIRULENT_SEED_BOMB);
								Mod_MooGame_PVPEngine_Control::$ackNum++;
							}
						} else {

							// 去掉已经到期的效果
							if ($currentAtker->lastActionRound - $effect->startTime >= $effect->timeOut) {
								$currentAtker->removeEffect($effect->uniqueId);
							}
						}

					} elseif ($effect->magicRemove == Mod_MooGame_PVPEngine_Magic::MAGIC_REMOVE_ROUND_START
						&& (Mod_MooGame_PVPEngine_Control::$turnNum - $effect->startTime) > $effect->timeOut) {
							$currentAtker->removeEffect($effect->uniqueId, Mod_MooGame_PVPEngine_Magic::MAGIC_REMOVE_ROUND_START);
					}

				}
			}

		}

	}

	/**
	 * 战士行动
	 * @param $currentAtker
	 */
	function action($currentAtker) {

		// 更新当前回合对战的顺序id数
		Mod_MooGame_PVPEngine_Control::$ackNum++;

		// 判断是否魔法攻击不能
		$magic = null;
		if ($currentAtker->unMagicAble <= 0) {
			$magic = $this->getMagic($currentAtker);
		}

		// 如果取到魔法则直接发动魔法
		if ($magic) {
			$this->magic($currentAtker, $magic);
			return true;
		}

		// 判断是否物理攻击不能
		if ($currentAtker->unAttackAble <= 0) {
			$this->attack($currentAtker);
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
				if (Mod_MooGame_PVPEngine_Control::$turnNum - $row->magicLastTurn <= $row->magicCD || $row->magicCD == -1) {
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
				Mod_MooGame_PVPEngine_Control::$magicUqId++;
				$row->magicUqId = Mod_MooGame_PVPEngine_Control::$magicUqId;
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
	 * 物理攻击
	 * @param $currentAtker
	 */
	function attack($currentAtker) {

		$currentDefer = '';

		// 取出攻击目标
		if ($currentAtker->group == 'attacker') {
			$deferIdArr = array();
			// 先从对面目标选取出击对象
			foreach ((array)Mod_MooGame_PVPEngine_Control::$defender as $tempRoleId => $tempRole) {
				$deferIdArr[$tempRoleId] = $tempRoleId;
				if ($tempRole->groupId == $currentAtker->groupId) {
					// 判断战士是否存在
					$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($tempRoleId);
					if (!$currentDefer) {
						$currentDefer = '';
						unset($deferIdArr[$tempRoleId]);
					}
				}
			}
			// 如果对面目标不存在，再从同等的目标选取出击对象（主角对主角，副将对副将）
			if (!$currentDefer) {
				$sameHeroType = array();
				foreach ((array)Mod_MooGame_PVPEngine_Control::$defender as $tempRoleId => $tempRole) {
					if ($tempRole->isHero == $currentAtker->isHero) {
						$sameHeroType[$tempRoleId] = $tempRoleId;
					}
				}
				// 判断战士是否存在
				if ($sameHeroType) {
					$deferId = array_rand($sameHeroType);
					$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($deferId);
					if (!$currentDefer) {
						$currentDefer = '';
					}
				}
			}
			// 前两种情况都不存在则随机给一个出击对象
			if (!$currentDefer && $deferIdArr) {
				$deferId = '';
				$deferId = array_rand($deferIdArr);
				$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($deferId);
				if (!$currentDefer) {
					$currentDefer = '';
				}
			}

		} else {
			$deferIdArr = array();
			// 先从对面目标选取出击对象
			foreach ((array)Mod_MooGame_PVPEngine_Control::$attacker as $tempRoleId => $tempRole) {
				$deferIdArr[$tempRoleId] = $tempRoleId;
				if ($tempRole->groupId == $currentAtker->groupId) {
					// 判断战士是否存在
					$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($tempRoleId);
					if (!$currentDefer) {
						$currentDefer = '';
						unset($deferIdArr[$tempRoleId]);
					}
				}
			}
			// 如果对面目标不存在，再从同等的目标选取出击对象（主角对主角，副将对副将）
			if (!$currentDefer) {
				$sameHeroType = array();
				foreach ((array)Mod_MooGame_PVPEngine_Control::$attacker as $tempRoleId => $tempRole) {
					if ($tempRole->isHero == $currentAtker->isHero) {
						$sameHeroType[$tempRoleId] = $tempRoleId;
					}
				}
				// 判断战士是否存在
				if ($sameHeroType) {
					$deferId = array_rand($sameHeroType);
					$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($deferId);
					if (!$currentDefer) {
						$currentDefer = '';
					}
				}
			}
			// 前两种情况都不存在则随机给一个出击对象
			if (!$currentDefer && $deferIdArr) {
				$deferId = '';
				$deferId = array_rand($deferIdArr);
				$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($deferId);
				if (!$currentDefer) {
					$currentDefer = '';
				}
			}
		}

		if (!$currentDefer) {
			return array();
		}

		// 判断当前对战者是否已经死亡
		if ($currentDefer->group == 'attacker' && !Mod_MooGame_PVPEngine_Control::$attacker[$currentDefer->id]) {
			return array();
		} elseif ($currentDefer->group == 'defender' && !Mod_MooGame_PVPEngine_Control::$defender[$currentDefer->id]) {
			return array();
		}

		$currentAtker->attack($currentDefer);
	}

	/**
	 * 魔法攻击
	 * @param $currentAtker
	 * @param $magic
	 */
	function magic($currentAtker, $magic) {
		// 随机取出当前的进攻方和防守方数组
		if ($currentAtker->group == 'attacker') {
			$defers = Mod_MooGame_PVPEngine_Control::$defender;
			$atkers = Mod_MooGame_PVPEngine_Control::$attacker;
		} else {
			$defers = Mod_MooGame_PVPEngine_Control::$attacker;
			$atkers = Mod_MooGame_PVPEngine_Control::$defender;
		}

		// 判断该魔法的作用目标
		$aimRole = array();
		switch ($magic->magicAim) {
			// 如果作用目标是自己
			case Mod_MooGame_PVPEngine_Magic::MAGIC_AIM_SELF:
				$aimRole[$currentAtker->id] = $currentAtker;
				break;
			// 如果作用目标是友方
			case Mod_MooGame_PVPEngine_Magic::MAGIC_AIM_GROUP:
				// 判断是作用于所有战士，还是指定数量的战士
				if ($magic->magicAimNum == -1) {
					$aimRole = $atkers;
				} else {
					// 随机取出指定数量的战士
					$maxNum = count($atkers);
					$maxNum = $maxNum < $magic->magicAimNum ? $maxNum : $magic->magicAimNum;
					for ($i = 0; $i < $maxNum; $i++) {
						$id = array_rand($atkers);
						$aimRole[$id] = $atkers[$id];
						unset($atkers[$id]);
					}

				}
				break;
			// 其他情况是敌方
			default:
				// 判断是作用于所有战士，还是指定数量的战士
				if ($magic->magicAimNum == -1) {
					$aimRole = $defers;
				} else {
					// 随机取出指定数量的战士
					$maxNum = count($defers);
					$maxNum = $maxNum < $magic->magicAimNum ? $maxNum : $magic->magicAimNum;
					for ($i = 0; $i < $maxNum; $i++) {
						$id = '';
						$deferIdArr = array();
						// 先从对面目标选取出击对象
						foreach ((array)$defers as $tempRoleId => $tempRole) {
							$deferIdArr[$tempRoleId] = $tempRoleId;
							if ($tempRole->groupId == $currentAtker->groupId) {
								// 判断战士是否存在
								$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($tempRoleId);
								if (!$currentDefer) {
									$id = '';
								} else {
									$id = $tempRoleId;
								}
							}
						}
						// 如果对面目标不存在，再从同等的目标选取出击对象（主角对主角，副将对副将）
						if (!$id) {
							$sameHeroType = array();
							foreach ((array)$defers as $tempRoleId => $tempRole) {
								if ($tempRole->isHero == $currentAtker->isHero) {
									$sameHeroType[$tempRoleId] = $tempRoleId;
								}
							}
							// 判断战士是否存在
							if ($sameHeroType) {
								$deferId = array_rand($sameHeroType);
								$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($deferId);
								if (!$currentDefer) {
									$id = '';
								} else {
									$id = $deferId;
								}
							}
						}
						// 前两种情况都不存在则随机给一个出击对象
						if (!$id) {
							$deferId = array_rand($deferIdArr);
							$currentDefer = MooMod::get('MooGame_PVPEngine_Control')->getAliveRole($deferId);
							if (!$currentDefer) {
								$id = '';
							} else {
								$id = $deferId;
							}
						}
						if (!$id) {
							continue;
						}
						$aimRole[$id] = $defers[$id];
						unset($defers[$id]);
					}
				}
				break;
		}

		// 增加一个魔法使用记录
		$aimIds = array();
		foreach ($aimRole as $role) {
			$aimIds[] = $role->id;
		}
		MooMod::get('MooGame_PVPEngine_FightLog')->addMagicLog($currentAtker->id, $magic, implode(',', $aimIds));

		// 对施法目标进行挨个施法
		foreach ($aimRole as $role) {
			$currentAtker->useMagic($role, $magic);
		}

		// 更新该魔法最后的触发回合
		$magic->magicLastTurn = Mod_MooGame_PVPEngine_Control::$turnNum;

		// 更新魔法的使用次数
		$magic->magicUseNum++;

	}
}
