<?php
class Dao_Group extends PublishDB {
	
	public $primaryKey = 'group_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'group';
		parent::__construct();
	}
}