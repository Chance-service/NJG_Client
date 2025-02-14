<?php
class Mod_MooGame_FightEngine_Role_changeAddReduceHarm {

	/**
	 * 改变角色是否可以加减伤
	 */
	function changeAddReduceHarm($num) {

		$this->MOD->addReduceHarm += $num;

		return true;
	}
}