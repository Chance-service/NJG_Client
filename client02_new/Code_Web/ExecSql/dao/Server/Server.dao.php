<?php
class Dao_Server extends PublishDB {
	
	public $primaryKey = 's_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'server';
		parent::__construct();
	}
}