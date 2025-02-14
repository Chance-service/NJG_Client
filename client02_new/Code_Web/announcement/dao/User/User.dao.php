<?php
class Dao_User extends announceDB {
	
	public $primaryKey = 'user_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.announce.prefix') . 'user';
		parent::__construct();
	}
}