<?php
class Dao_Platform extends PublishDB {
	
	public $primaryKey = 'pl_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'platform';
		parent::__construct();
	}
}