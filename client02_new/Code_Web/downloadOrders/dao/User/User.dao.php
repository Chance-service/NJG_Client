<?php
class Dao_User extends cosDB {
	
	public $primaryKey = 'user_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.downloadOrder.prefix') . 'user';
		parent::__construct();
	}
}