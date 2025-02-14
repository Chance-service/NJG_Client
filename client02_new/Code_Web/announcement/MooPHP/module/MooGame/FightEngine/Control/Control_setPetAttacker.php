<?php
class Mod_MooGame_FightEngine_Control_setPetAttacker {
	
	function setPetAttacker($role) {
		$role->group = 'attacker';
		Mod_MooGame_FightEngine_Control::$petAttacker[$role->id] = $role;
		Mod_MooGame_FightEngine_Control::$initPetAttacker[$role->id] = clone($role); 
	}
}