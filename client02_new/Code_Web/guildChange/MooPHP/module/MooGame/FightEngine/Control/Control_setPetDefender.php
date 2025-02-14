<?php
class Mod_MooGame_FightEngine_Control_setPetDefender {
	
	function setPetDefender($role) {
		$role->group = 'defender';
		Mod_MooGame_FightEngine_Control::$petDefender[$role->id] = $role;
		Mod_MooGame_FightEngine_Control::$initPetDefender[$role->id] = clone($role);
	}
}