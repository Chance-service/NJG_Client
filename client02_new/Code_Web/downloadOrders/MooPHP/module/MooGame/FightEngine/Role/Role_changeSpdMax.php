<?php
class Mod_MooGame_FightEngine_Role_changeSpdMax {
	function changeSpdMax($num) {

		// 修改当前角色的Spd上限
		$this->MOD->spdMax += $num;

		$this->MOD->spdMax < 0 && $this->MOD->spdMax = 0;
		round($this->MOD->spdMax, 2);
		
		return true;
	}
}