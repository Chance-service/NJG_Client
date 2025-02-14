<?php
class Mod_MooGame_FightEngine_Role_changeSpd {
	function changeSpd($num) {

		// 修改当前角色的Spd
		$this->MOD->spd += $num;

		$this->MOD->spd < 0 && $this->MOD->mp = 0;
		if ($this->MOD->spdMax > 0 && $this->MOD->spd > $this->MOD->spdMax) {
			$this->MOD->spd = $this->MOD->spdMax;
		}
		
		$this->MOD->spd = round($this->MOD->spd, 2);
		
		return true;
	}
}