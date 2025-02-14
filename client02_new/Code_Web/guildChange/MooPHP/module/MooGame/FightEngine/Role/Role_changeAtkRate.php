<?php
class Mod_MooGame_FightEngine_Role_changeAtkRate {
	function changeAtkRate($num) {
		// 修改当前角色的命中率
		$this->MOD->atkRate += $num;

		$this->MOD->atkRate < 0 && $this->MOD->atkRate = 0;
		$this->MOD->atkRate > 100 && $this->MOD->atkRate = 100;
		$this->MOD->atkRate = round($this->MOD->atkRate, 2);

		return true;
	}
}