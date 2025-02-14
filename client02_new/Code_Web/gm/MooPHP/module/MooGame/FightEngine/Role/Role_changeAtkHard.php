<?php
class Mod_MooGame_FightEngine_Role_changeAtkHard {
	function changeAtkHard($num, $rate = 0) {
		
		// 修改当前角色的暴击率
		$this->MOD->atkHard += $num;

		$this->MOD->atkHard < 0 && $this->MOD->atkHard = 0;
		$this->MOD->atkHard > 100 && $this->MOD->atkHard = 100;
		
		Mod_MooGame_FightEngine_Control::$atkHardHarmRate[$this->MOD->id] += $rate;

		return true;
	}
}