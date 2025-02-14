<?php
class Dao_Log extends PublishDB {
	
	public $primaryKey = 'log_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'log';
		parent::__construct();
	}
}