<?php
class Dao_User extends PublishDB {
	
	public $primaryKey = 'user_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'user';
		parent::__construct();
	}
}