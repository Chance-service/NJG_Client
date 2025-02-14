<?php
class Dao_ServerOnOffLog extends PublishDB {
	
	public $primaryKey = 'log_id';
	public $tableName;
	public function __construct() {
		$this->tableName = MooConfig::get('dbconfig.publish.prefix') . 'onoff_log';
		parent::__construct();
	}
}