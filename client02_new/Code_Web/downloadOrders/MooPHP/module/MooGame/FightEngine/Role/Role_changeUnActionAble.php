<?php
class Mod_MooGame_FightEngine_Role_changeUnActionAble {

	/**
	 * 改变角色是否可以发动物理和魔法攻击
	 */
	function changeUnActionAble($num) {

		$this->MOD->unActionAble += $num;

		$this->MOD->unActionAble < 0 && $this->MOD->unActionAble = 0;

		return true;
	}
}