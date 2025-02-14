<?php
class Mod_MooGame_FightEngine_Role_changeJoukRate {
	function changeJoukRate($num) {

		// 修改当前角色的闪避率
		$this->MOD->joukRate += $num;

		$this->MOD->joukRate < 0 && $this->MOD->joukRate = 0;
		$this->MOD->joukRate > 100 && $this->MOD->joukRate = 100;
		$this->MOD->joukRate = round($this->MOD->joukRate, 2);

		return true;
	}
}