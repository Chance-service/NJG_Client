<?php
class Mod_MooGame_FightEngine_Role_changeDef {
	function changeDef($num) {

		// 修改当前角色的DEF
		$this->MOD->def += $num;

		$this->MOD->def < 0 && $this->MOD->def = 0;

		if ($this->MOD->defMax > 0 && $this->MOD->def > $this->MOD->defMax) {
			//$this->MOD->def = $this->MOD->defMax;
		}
		$this->MOD->def = round($this->MOD->def, 2);

		return true;
	}
}