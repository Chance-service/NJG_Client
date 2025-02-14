<?php
class Mod_MooGame_FightEngine_Role_changeShield {
	function changeShield($num, $effect = '') {
		// 修改当前角色的防护罩
		$this->MOD->shield += $num;

		$this->MOD->shield < 0 && $this->MOD->shield = 0;
		$this->MOD->shield = round($this->MOD->shield, 2);
		if ($effect) {
			$this->MOD->shieldEffectId = $effect->magicId;
			$this->MOD->shieldUniqueId = $effect->uniqueId;
		}

		return true;
	}
}