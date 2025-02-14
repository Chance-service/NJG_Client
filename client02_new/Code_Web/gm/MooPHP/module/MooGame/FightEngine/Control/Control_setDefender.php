<?php
class Mod_MooGame_FightEngine_Control_setDefender {
	
	function setDefender($role) {
		$role->group = 'defender';
		Mod_MooGame_FightEngine_Control::$defender[$role->id] = $role;
		Mod_MooGame_FightEngine_Control::$initDefender[$role->id] = clone($role);
	}
}