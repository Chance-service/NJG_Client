<?php
class Mod_MooGame_FightEngine_Role extends Mod_MooGame_FightEngine {
	public $id;					// 角色ID
	public $confId;				// 配置id
	public $groupId;			// 角色在各个组里面的顺序
	public $roleName;			// 角色名
	public $hp		= 0;		// 血量
	public $hpMax	= 0;		// 血量上限
	public $mp		= 0;		// 魔法值
	public $mpMax	= 0;		// 魔法上限
	public $def		= 0;		// 当前防御值
	public $initDef		= 0;	// 初始防御值
	public $defMax	= 0;		// 防御值上限
	public $atk		= 0;		// 当前攻击力
	public $initAtk		= 0;	// 初始攻击力
	public $atkMax	= 0;		// 攻击力上限
	public $atkHard	= 0;		// 暴击率
	public $atkPercent	= 100;	// 伤害加成百分比
	public $atkRate		= 100;	// 命中率
	public $spd		= 0;		// 速度
	public $spdMax	= 0;		// 速度上限
	public $shield	= 0;		// 防护罩
	public $joukRate= 0;		// 闪避率
	public $isHero	= false;	// 当前角色是否为英雄
	public $group;				// 角色所在的分组
	public $positionHarm = 0;	// 角色位置伤害加成
	public $boss = 0;			// 1副本boss，2魔神boss

	public $effect	= array();	// 当前角色被释放的效果
	public $magic	= array();	// 当前角色拥有的魔法
	public $treasureMagic	= array();	// 当前角色拥有的法宝魔法
	public $specialTreasureMagic	= array();	// 当前角色拥有的特殊法宝魔法

	public $lastActionRound = 0;// 最后行动回合数
	public $propsChangeLog = array();// 属性变更记录

}