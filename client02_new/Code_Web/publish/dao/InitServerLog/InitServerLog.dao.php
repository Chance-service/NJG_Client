<?php
class Dao_InitServerLog extends PublishDB {
	
	public $primaryKey = 'log_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'init_server_log';
		parent::__construct();
	}
}