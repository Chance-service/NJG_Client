<?php
class Dao_Game extends PublishDB {
	
	public $primaryKey = 'game_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'game';
		parent::__construct();
	}
}