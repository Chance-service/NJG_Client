<?php
class Mod_MooGame_FightEngine_Control_getAliveRole {

	function getAliveRole($roleId) {
		$role = Mod_MooGame_FightEngine_Control::$defender[$roleId];
		if (!$role) {
			$role = Mod_MooGame_FightEngine_Control::$attacker[$roleId];
		}
		
		if (!$role) {
			$role = Mod_MooGame_FightEngine_Control::$petDefender[$roleId];
			if (!$role) {
				$role = Mod_MooGame_FightEngine_Control::$petAttacker[$roleId];
			}
		}

		return $role;
	}
}