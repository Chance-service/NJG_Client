<?php
class Mod_MooGame_FightEngine_Role_checkShield {
	/**
	 * 判断角色的防护罩是否变成0了
	 * 去掉buff
	 * @param $effect
	 */
	function checkShield($propsChangeLog) {

		foreach ($propsChangeLog as $v) {
			if ($v['props'] != 'shield') {
				continue;
			}
			$changeNum = $v['fromValue'] - $v['toValue'];
			if ($changeNum <= 0) {
				return true;
			}

			foreach ((array)$this->MOD->effect as $effect) {
				if ($effect->effectToProps == 'shield' && $effect->effectTotalValueCopy > 0) {
					if (($effect->effectTotalValueCopy - $changeNum) > 0) {
						$effect->effectTotalValueCopy -= $changeNum;
						break;
					} else {

						$effect->effectTotalValueCopy = 0;
						$changeNum -= $effect->effectTotalValueCopy;

						if ($this->MOD->shieldEffectId) {
							unset($this->MOD->shieldEffectId);
						}
						if ($this->MOD->shieldUniqueId) {
							unset($this->MOD->shieldUniqueId);
						}

						// 记录一个效果日志
						MooMod::get('MooGame_FightEngine_FightLog')->addUnBuffLog($effect->execRoleId, $effect->atRoleId, $effect);

					}
				}
			}

		}
		return true;
	}
}