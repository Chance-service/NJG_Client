<?php
class Mod_MooGame_FightEngine_Role_changeAtk {

	function changeAtk($num) {
		// 修改当前角色的Atk
		$this->MOD->atk += $num;

		$this->MOD->atk < 0 && $this->MOD->atk = 0;

		if ($this->MOD->atkMax > 0 && $this->MOD->atk > $this->MOD->atkMax) {
			//$this->MOD->atk = $this->MOD->atkMax;
		}
		$this->MOD->atk = round($this->MOD->atk, 2);

		return true;
	}
}