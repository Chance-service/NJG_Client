<?php
class Mod_MooGame_FightEngine_Role_changeDefMax {
	function changeDefMax($num) {
		// 修改当前角色的Def上限
		$this->MOD->defMax += $num;

		$this->MOD->defMax < 0 && $this->MOD->defMax = 0;
		round($this->MOD->defMax, 2);
		return true;
	}
}