<?php
class Mod_MooGame_FightEngine_Role_dead {
	function dead($execRoleId) {
		// 记录一个效果日志
		$effect = null;
		$effect = (object)$effect;
		$effect->id		= 0;
		$effect->effectName	= '死亡';

		// 判断当前对战者是否已经死亡
		if ($this->MOD->group == 'attacker' && !Mod_MooGame_FightEngine_Control::$attacker[$this->MOD->id]) {
			return true;
		} elseif ($this->MOD->group == 'defender' && !Mod_MooGame_FightEngine_Control::$defender[$this->MOD->id]) {
			return true;
		}
		
		// 判断是否能重生
		$isRebirth = false;
		if ($this->MOD->rebirth && Mod_MooGame_FightEngine_Control::$rebirthNumber < 2) {
			if (rand(1, 100) <= $this->MOD->rebirth) {
				$isRebirth = true;
			}
		}
		
		// 判断是否有自爆
		if ($this->MOD->blew) {
			
			$execRole = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($execRoleId);
			if ($this->MOD->group == 'attacker') {
				$tmpAtkers = Mod_MooGame_FightEngine_Control::$defender;
			} else {
				$tmpAtkers = Mod_MooGame_FightEngine_Control::$attacker;
			}

			foreach ($tmpAtkers as $tmpRoleId => $tmpRoleObj) {
				// 判断战士是否存在
				$tempDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($tmpRoleId);
				if (!$tempDefer) {
					continue;
				}
				$value = -round(($tmpRoleObj->hpMax * ($this->MOD->blew / 100)));
				$rs = $tmpRoleObj->changeProps('hp', $value, $effect);
				// 增加一个战斗记录
				MooMod::get('MooGame_FightEngine_FightLog')->addAttackLog($this->MOD->id, $tmpRoleObj->id, abs($value), 0, 1);
				MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3450, $this->MOD->id, $tmpRoleObj->id);
			}
			
		}

		MooMod::get('MooGame_FightEngine_FightLog')->addEffectLog($execRoleId, $this->MOD->id, $effect);
		
		// 判断是否有自爆
		if ($this->MOD->blew) {
			if ($this->MOD->group == 'attacker') {
				$tmpAtkers = Mod_MooGame_FightEngine_Control::$defender;
			} else {
				$tmpAtkers = Mod_MooGame_FightEngine_Control::$attacker;
			}
			foreach ($tmpAtkers as $tmpRoleId => $tmpRoleObj) {
				// 判断战士是否存在
				$tempDefer = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($tmpRoleId);
				if ($tempDefer->hp <= 0) {
					$tempDefer->dead($this->MOD->id);
				}
			}
			
		}

		if (Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$this->MOD->id]) {
			
			$sortGroup = ucfirst($this->MOD->group);
			$sortGroup = "sort{$sortGroup}";
			
			if ($this->MOD->setBuff && Mod_MooGame_FightEngine_Control::${$sortGroup}) {
				
				$tmpSortArr = Mod_MooGame_FightEngine_Control::${$sortGroup};
				ksort($tmpSortArr);
				$copyTmpSortArr = $tmpSortArr;
				
				foreach ((array)$tmpSortArr as $tmpGroupId => $tmpGroupInfo) {
					if ($tmpGroupId == $this->MOD->groupId) {
						unset($tmpSortArr[$tmpGroupId]);
						unset($copyTmpSortArr[$tmpGroupId]);
						break;
					}
					unset($tmpSortArr[$tmpGroupId]);
				}
				
				$nextRoleId = array();
				if ($tmpSortArr) {
					$nextRoleId = current($tmpSortArr);
				}
				
				if (!$nextRoleId) {
					$nextRoleId = array_shift($copyTmpSortArr);
				}

				if (Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]) {
					if (Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]->rmFriendSetBuff) {
						foreach ($this->MOD->setBuff as $tempBeRoleId => $tmpEffectUniqueInfo) {
							foreach ($tmpEffectUniqueInfo as $tmpEffectUniqueId) {
								Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]->rmFriendSetBuff[$tempBeRoleId][$tmpEffectUniqueId] = $tmpEffectUniqueId;
							}
						}
					} else {
						Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]->rmFriendSetBuff = $this->MOD->setBuff;
					}
				}
				
			}
			if ($this->MOD->rmFriendSetBuff && Mod_MooGame_FightEngine_Control::${$sortGroup}) {
			
				$tmpSortArr = Mod_MooGame_FightEngine_Control::${$sortGroup};
				ksort($tmpSortArr);
				$copyTmpSortArr = $tmpSortArr;
			
				foreach ((array)$tmpSortArr as $tmpGroupId => $tmpGroupInfo) {
					if ($tmpGroupId == $this->MOD->groupId) {
						unset($tmpSortArr[$tmpGroupId]);
						unset($copyTmpSortArr[$tmpGroupId]);
						break;
					}
					unset($tmpSortArr[$tmpGroupId]);
				}
			
				$nextRoleId = array();
				if ($tmpSortArr) {
					$nextRoleId = current($tmpSortArr);
				}
			
				if (!$nextRoleId) {
					$nextRoleId = array_shift($copyTmpSortArr);
				}
			
				if (Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]) {
					if (Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]->rmFriendSetBuff) {
						foreach ($this->MOD->rmFriendSetBuff as $tempBeRoleId => $tmpEffectUniqueInfo) {
							foreach ($tmpEffectUniqueInfo as $tmpEffectUniqueId) {
								Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]->rmFriendSetBuff[$tempBeRoleId][$tmpEffectUniqueId] = $tmpEffectUniqueId;
							}
						}
					} else {
						Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$nextRoleId]->rmFriendSetBuff = $this->MOD->setBuff;
					}
				}
			
			}
			if (!$isRebirth) {

				// 去掉当前出手的战士之前发给别的战士的buff
				if (Mod_MooGame_FightEngine_Control::$copyRole[$this->MOD->id]->setSpecialEffect) {
					foreach (Mod_MooGame_FightEngine_Control::$copyRole[$this->MOD->id]->setSpecialEffect as $beRoleId => $effectUniqueIdArr) {
						$role = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($beRoleId);
						if (!$role) {
							continue;
						}
						foreach ((array)$effectUniqueIdArr as $effectInfoArr) {
							$v1 = $role->$effectInfoArr['effectToProps'];
							$role->$effectInfoArr['effectToProps'] -= $effectInfoArr['value'];
							$role->$effectInfoArr['effectToProps'] = max(0, $role->$effectInfoArr['effectToProps']);
							$v2 = $role->$effectInfoArr['effectToProps'];
							
							if ($effectInfoArr['effectToProps'] == 'hpMax' && ($role->hpMax < $role->hp)) {
								$role->hp = $role->hpMax;
							}
							
							$log = array();
							$log['roleId'] = $role->id;
							$log['props'] = $effectInfoArr['effectToProps'];
							$log['fromValue'] = $v1;
							$log['toValue'] = $v2;
							
							MooMod::get('MooGame_FightEngine_FightLog')->addEffectLog($execRoleId, $this->MOD->id, $effect, 0, $log);
						}
					}
					
				}
				
				if (Mod_MooGame_FightEngine_Control::${$sortGroup}) {
					foreach (Mod_MooGame_FightEngine_Control::${$sortGroup} as $key => $tmpSortRoleId) {
						if ($tmpSortRoleId == $this->MOD->id) {
							unset(Mod_MooGame_FightEngine_Control::${$sortGroup}[$key]);
						}
					}
					
				}
				unset(Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$this->MOD->id]);
			}
			
			foreach (Mod_MooGame_FightEngine_Control::$attacker as $role) {
				// 去掉当前出手的战士之前死亡的队友发给别的战士的buff
				if ($role->rmFriendSetBuff) {
				
					foreach ($role->rmFriendSetBuff as $beRoleId => $effectUniqueIdArr) {
						if ($beRoleId == $this->MOD->id) {
							unset($role->rmFriendSetBuff[$beRoleId]);
						}
					}
				}
				// 去掉当前出手的战士之前发给别的战士的buff
				if ($role->setBuff) {
					foreach ($role->setBuff as $beRoleId => $effectUniqueIdArr) {
						if ($beRoleId == $this->MOD->id) {
							unset($role->setBuff[$beRoleId]);
						}
					}
				}
			}
			foreach (Mod_MooGame_FightEngine_Control::$defender as $role) {
				// 去掉当前出手的战士之前死亡的队友发给别的战士的buff
				if ($role->rmFriendSetBuff) {
			
					foreach ($role->rmFriendSetBuff as $beRoleId => $effectUniqueIdArr) {
						if ($beRoleId == $this->MOD->id) {
							unset($role->rmFriendSetBuff[$beRoleId]);
						}
					}
				}
				// 去掉当前出手的战士之前发给别的战士的buff
				if ($role->setBuff) {
					foreach ($role->setBuff as $beRoleId => $effectUniqueIdArr) {
						if ($beRoleId == $this->MOD->id) {
							unset($role->setBuff[$beRoleId]);
						}
					}
				}
			}
		}
		
		// 判断是否是重生
		if ($isRebirth) {
			
			Mod_MooGame_FightEngine_Control::$rebirthNumber += 1;
			
			$value = round(($this->MOD->hpMax * ($this->MOD->rebirthHp / 100)));
			$rs = $this->MOD->changeProps('hp', $value, $effect);
			
			Mod_MooGame_FightEngine_Control::$rebirthLog[Mod_MooGame_FightEngine_Control::$turnNum][Mod_MooGame_FightEngine_Control::$ackNum][$this->MOD->id] = $this->MOD->id;
			
			Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$this->MOD->id] = clone(Mod_MooGame_FightEngine_Control::$copyRole[$this->MOD->id]);
			Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$this->MOD->id]->hp = $value;
			
			if (Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$this->MOD->id]->setSpecialEffect) {
				unset(Mod_MooGame_FightEngine_Control::${$this->MOD->group}[$this->MOD->id]->setSpecialEffect);
			}
			
			// 增加一个战斗记录
			MooMod::get('MooGame_FightEngine_FightLog')->addAttackLog($this->MOD->id, $execRole->id, abs($value), 0, 2);
			if ($this->MOD->propsChangeLog) {
				unset($this->MOD->propsChangeLog);
			}
		}

		$initGroup = ucfirst($this->MOD->group);
		$initGroup = "init{$initGroup}";

		if (Mod_MooGame_FightEngine_Control::${$initGroup}[$this->MOD->id] && !$isRebirth) {
			unset(Mod_MooGame_FightEngine_Control::${$initGroup}[$this->MOD->id]);
		}

		return true;

	}
}