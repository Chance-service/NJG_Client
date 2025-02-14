<?php
class Mod_MooGame_FightEngine_Role_changeMp {
	function changeMp($num) {

		// 修改当前角色的MP
		$this->MOD->mp += $num;
		
		$this->MOD->mp < 0 && $this->MOD->mp = 0;
		if ($this->MOD->mpMax > 0 && $this->MOD->mp > $this->MOD->mpMax) {
			$this->MOD->mp = $this->MOD->mpMax;
		}
		
		$this->MOD->mp = round($this->MOD->mp, 2);
		return true;
	}
}