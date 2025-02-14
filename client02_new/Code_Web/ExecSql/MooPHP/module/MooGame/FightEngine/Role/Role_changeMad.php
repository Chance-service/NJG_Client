<?php
class Mod_MooGame_FightEngine_Role_changeMad {

	/**
	 * 狂化
	 */
	function changeMad($num, $atkRate) {
		
		$number = round($this->MOD->hpMax * ($num / 100));
		
		// 修改当前角色的HP上限
		$this->MOD->hpMax += $number;
		
		$addAtk = round(abs($number) * ($atkRate / 100));
		$this->MOD->atk += $addAtk;
		
		// 狂化做处理
		MooMod::get('MooGame_FightEngine_FightLog')->addSpecialEffectLog(3449, $this->MOD->id, $this->MOD->id, $atkRate, false, 1, 0, true);
		
		$this->MOD->hpMax < 0 && $this->MOD->hpMax = 0;
		$this->MOD->hpMax = round($this->MOD->hpMax);

		return true;
	}
}