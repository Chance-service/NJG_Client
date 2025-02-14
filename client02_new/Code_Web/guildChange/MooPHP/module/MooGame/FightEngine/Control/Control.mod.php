<?php
class Mod_MooGame_FightEngine_Control extends Mod_MooGame_FightEngine {
	// 当前的战士
	static public $attacker;
	static public $defender;
	
	// 副本boss召唤的小怪
	static public $bossRebirthMobs;
	static public $initBossRebirthMobs;
	
	// 拷贝角色，用于重生
	static public $copyRole;
	
	// 当前出手顺序的战士
	static public $sortAttacker;
	static public $sortDefender;
	
	// 当前的宠物
	static public $petAttacker;
	static public $petDefender;

	// 死去的战士
	static public $atkDeader;
	static public $defDeader;

	// 原始的战士
	static public $initAttacker;
	static public $initDefender;
	
	// 原始的宠物
	static public $initPetAttacker;
	static public $initPetDefender;
	
	// 混乱的战士
	static public $mixAttacker;
	static public $mixDefender;

	// 当前回合数
	static public $turnNum;
	static public $maxTurnNum = 20;

	// 暴击伤害百分比
	static public $atkHardPercent = 150;
	static public $atkHardHarmRate;
	
	// 是否取整
	static public $isGetInt = true;

	// magic 的自增的数字
	static public $magicUqId = 0;

	// effect 的自增的数字
	static public $effectUqId = 1;
	
	// 计算每一个回合里面对战的顺序(唯一)id数
	static public $ackNum = 1;

	// 获得胜利的一方  return defender || attacker
	static public $winner;

	static public $roleSort = array();

	// 计算攻击时，是否是暴击
	static public $isAtkHard = false;
	
	// 计算复活次数
	static public $rebirthNumber = 0;
	
	// 转生记录
	static public $rebirthLog = array();
	
	// 如果是群攻技能，则在攻击后产生增益效果的转生技能只能产生作用一次，不能每打一个人自己一次
	static public $gainSkillArr = array();
	
	// 副本召唤小怪次数记录
	static public $bossRebirthMobsArr = array();

}