<?php
class Mod_MooGame_FightEngine_Control_setAttacker {
	
	function setAttacker($role) {
		$role->group = 'attacker';
		Mod_MooGame_FightEngine_Control::$attacker[$role->id] = $role;
		Mod_MooGame_FightEngine_Control::$initAttacker[$role->id] = clone($role); 
	}
}