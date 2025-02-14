<?php
class Mod_MooGame_FightEngine_Role_changeAtkMax {
	function changeAtxMax($num) {
		// 修改当前角色的Atk上限
		$this->MOD->atkMax += $num;

		$this->MOD->atkMax < 0 && $this->MOD->atkMax = 0;
		$this->MOD->atkMax = round($this->MOD->atkMax, 2);
		return true;
	}
}