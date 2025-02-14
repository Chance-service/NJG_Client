<?php
class Mod_MooGame_FightEngine_Role_changeHpMax {
	
	function changeHpMax($num, $noLog = 0) {

		// 修改当前角色的HP上限
		$this->MOD->hpMax += $num;
		
		$this->MOD->hpMax < 0 && $this->MOD->hpMax = 0;
		$this->MOD->hpMax = round($this->MOD->hpMax, 2);
		
		if ($num > 0 && $noLog) {
			$this->MOD->hp = $this->MOD->hpMax;
		}
		
		return true;
	}
}