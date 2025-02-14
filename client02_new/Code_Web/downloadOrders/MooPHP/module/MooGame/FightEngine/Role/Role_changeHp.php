<?php
class Mod_MooGame_FightEngine_Role_changeHp {
	/**
	 * 修改HP
	 * @param $num
	 * @param $replace
	 */
	function changeHp($num) {

		// 如果有防护罩，则先从防护罩中扣除
		if ($num < 0 && $this->MOD->shield > 0) {

			// 判断防护罩是否足够
			if ($this->MOD->shield >= abs($num)) {
				$this->MOD->changeProps('shield', $num);
				return true;
			} else {
				$num = $this->MOD->shield + $num;
				$this->MOD->changeProps('shield', -$this->MOD->shield);
			}
		}

		// 修改当前角色的HP
		$this->MOD->hp += $num;

		$this->MOD->hp < 0 && $this->MOD->hp = 0;
		if ($this->MOD->hpMax > 0 && $this->MOD->hp > $this->MOD->hpMax) {
			$this->MOD->hp = $this->MOD->hpMax;
		}

		$this->MOD->hp = round($this->MOD->hp, 2);
		return true;
	}
}