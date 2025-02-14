<?php
class Mod_MooGame_FightEngine_FightLog_getLog {
	function getLog() {
		return MooMod::get('MooGame_FightEngine_FightLog')->fightLog;
	}
}