<?php
class Mod_MooGame_FightEngine_Role_changeMpMax {
	function changeMpMax($num) {

		// 修改当前角色的MP上限
		$this->MOD->mpMax += $num;
		
		$this->MOD->mpMax < 0 && $this->MOD->mpMax = 0;
		round($this->MOD->mpMax, 2);
		
		return true;
	}
}