<?php
class Dao_Game extends announceDB {
	
	public $primaryKey = 'game_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.announce.prefix') . 'game';
		parent::__construct();
	}
}