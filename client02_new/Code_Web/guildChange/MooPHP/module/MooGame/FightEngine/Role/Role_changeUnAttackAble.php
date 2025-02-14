<?php
class Mod_MooGame_FightEngine_Role_changeUnAttackAble {

	/**
	 * 改变角色是否可以发动物理攻击
	 */
	function changeUnAttackAble($num) {

		$this->MOD->unAttackAble += $num;

		$this->MOD->unAttackAble < 0 && $this->MOD->unAttackAble = 0;

		return true;
	}
}