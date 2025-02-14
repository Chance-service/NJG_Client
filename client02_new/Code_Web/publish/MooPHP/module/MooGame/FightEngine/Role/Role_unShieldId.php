<?php
class Mod_MooGame_FightEngine_Role_unShieldId {
	/**
	 * 判断角色的防护罩是否变成0了
	 * 去掉buff
	 * @param $effect
	 */
	function unShieldId() {
		$propsChangeLog = $this->MOD->propsChangeLog;
		$logs = array();
		foreach ($propsChangeLog as $v) {
			if ($v['props'] != 'shield') {
				$logs[] = $v;
				continue;
			}
			$changeNum = $v['fromValue'] - $v['toValue'];
			if ($changeNum <= 0) {
				return true;
			}

			foreach ((array)$this->MOD->effect as $effect) {
				if ($effect->effectToProps == 'shield' && $changeNum > 0) {
					if (($effect->effectTotalValueCopy - $changeNum) > 0) {
						$v['effectId'] = $effect->id;
						$v['uniqueId'] = $effect->uniqueId;
						$logs[] = $v;
						break;
					} else {
						$v['toValue'] = $v['fromValue'] - $effect->effectTotalValueCopy;
						$v['effectId'] = $effect->id;
						$v['uniqueId'] = $effect->uniqueId;
						$logs[] = $v;
						$v['fromValue'] = $v['toValue'];
						$changeNum -= $effect->effectTotalValueCopy;

						if ($this->MOD->shieldEffectId) {
							unset($this->MOD->shieldEffectId);
						}
						if ($this->MOD->shieldUniqueId) {
							unset($this->MOD->shieldUniqueId);
						}
					}
				}
			}
		}
		$this->MOD->propsChangeLog = $logs;
		return true;
	}
}