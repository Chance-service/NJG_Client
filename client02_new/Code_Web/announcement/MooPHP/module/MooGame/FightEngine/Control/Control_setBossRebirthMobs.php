<?php
class Mod_MooGame_FightEngine_Control_setBossRebirthMobs {
	
	function setBossRebirthMobs($role) {
		$role->group = 'defender';
		Mod_MooGame_FightEngine_Control::$bossRebirthMobs[$role->id] = $role;
		Mod_MooGame_FightEngine_Control::$initBossRebirthMobs[$role->id] = clone($role);
	}
}