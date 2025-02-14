<?php
class Mod_MooGame_FightEngine_FightLog extends Mod_MooGame_FightEngine {
	public $fightLog = array();

	const FIGHT_LOG_TYPE_ATTACK		= 1;
	const FIGHT_LOG_TYPE_BUFF		= 2;
	const FIGHT_LOG_TYPE_EFFECT		= 3;
	const FIGHT_LOG_TYPE_MAGIC		= 4;
	const FIGHT_LOG_TYPE_UNBUFF		= 5;
	const FIGHT_LOG_TYPE_DEAD		= 6;
	const FIGHT_LOG_TYPE_UNACTION		= 7;
	const FIGHT_LOG_TYPE_UNATTACK		= 8;
	const FIGHT_LOG_TYPE_UNMAGIC		= 9;
	const FIGHT_LOG_TYPE_SPECIALEFFECT		= 10;
	const FIGHT_LOG_TYPE_TREASUREEFFECT		= 11;
	const FIGHT_LOG_TYPE_BOSSREBIRTHMOBS		= 12;
}