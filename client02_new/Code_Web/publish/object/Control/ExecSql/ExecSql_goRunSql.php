<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_goRunSql {
	
	public $msgList = array();
	public $excsqlList = array();
	private $dbconf;
	private $action;
	private $actiondec;  // 行为描述
	private $channel;
	private $server;

	function goRunSql($platform, $serverId, $action, $gameTag) {
		if(!$platform) {		
			$rs = "error platform name";
			return $rs;
		}
	
		if ($action == 'ok') {
			$this->actiondec = "执行sql";
			$this->action = "OK";
		} else {
			$this->actiondec = "查看变化";
			$this->action = "NO";
		}
		
		$this->channel = $platform;
		$this->server  = $serverId;
		
		define('ROOT_PATH',dirname(dirname(__FILE__)));
		
		$execsqldbconfigName =  $gameTag."_execsqldbconfig";		
		$CONF 	= MooConfig::get($execsqldbconfigName);
		
		$this->dbconf 	= $CONF[$platform][$serverId];
		
		if (!$this->dbconf) {
			$rs = "dbconf error!";
			return $rs;
		}
		
		$gameSqlName = $gameTag."_game";
		// 要之行的 sqlmingc
		$rs = $this->executeSQL($gameSqlName);
		
		if ($action == 'ok') {
			$rs = "<br>=========================================执行成功!!!!!!!!!========执行日志如下：====================<br>".$rs."<br>=========================================执行完毕!!!!!!!!!=========================================";
		}
		
		return $rs;
	}
	
 	function executeSQL($key) {	
		
 		
		$message = "\n".date('Y-m-d H:i:s') ."--".$this->channel."--".$this->server."服--".$this->actiondec. " ======================== $key  ====================\n"."<br><br>";
		$LOG_PATH = ROOT_PATH.'/tools/log/'.$key.'_' .date('Ymd'). '.log';
			
		/*************数据库连接*******************/
		@$link = mysql_connect($this->dbconf['host'], $this->dbconf['user'], $this->dbconf['pwd']);	
		if (!$link) {
			return  ('connect error:' . mysql_error() . "\n");
		}
		if (!@mysql_select_db($this->dbconf['dbName'])) {
			$query = @mysql_query("create database " . ' '.$this->dbconf['dbName']);
			if (!@$query) {
				return ('create db error:' . mysql_error() . "\n");
			}			 	
			if (!@mysql_select_db($this->dbconf['dbName'])) {
				 return ('select db error:' . mysql_error() . "\n");
			}
		}
		
		mysql_set_charset($this->dbconf['char']);
		/**************************************/
	
		/*****************处理字符串，去掉一些注释的代码**********************/
		$sql = file_get_contents(ROOT_PATH . '/tools/sql/'.$key.'.sql');
		// 去除如/***/的注释
		$sql = preg_replace("[(/\*)+.+(\*/;\s*)]", '', $sql);
		// 去除如--类的注释
		$sql = preg_replace("(--.*?\n)", '', $sql);
		
		/*****************处理字符串，去掉一些注释的代码**********************/
	
		preg_match_all("/CREATE\s+TABLE\s+IF NOT EXISTS.+?(.+?)\s*\((.+?)\)\s*(ENGINE|TYPE)\s*\=(.+?;)/is", $sql, $matches);
		$newtables = empty($matches[1])?array():$matches[1];
		$newsqls = empty($matches[0])?array():$matches[0];
	
		$totalNum = count($newtables);
		for ($num = 0; $num < $totalNum; $num++) {
			$newcols = $this->getcolumn($newsqls[$num]);
			$newtable = $newtables[$num];
			$oldtable = $newtable;
	
			$checksql = "SHOW CREATE TABLE {$newtable}";
			$query = mysql_query($checksql);
			
			if (!$query) {
				$usql = $newsqls[$num];
				$usql = str_replace($oldtable, $newtable, $usql);
				$this->execQuery($usql);
			} else {
				$value = mysql_fetch_array($query);
				
				// 判断注释
				if ($comment = $this->checkTableComment($newsqls[$num], $value['Create Table'])) {
					$usql = "ALTER TABLE ".$newtable." COMMENT =  '{$comment}'";
					$this->execQuery($usql);
				}
				
				$oldcols = $this->getcolumn($value['Create Table']);
				$updates = array();
				$allfileds =array_keys($newcols);
				foreach ($newcols as $key => $value) {
					if($key == 'PRIMARY') {
						if($value != $oldcols[$key]) {
							if(!empty($oldcols[$key])) {
								$usql = "RENAME TABLE ".$newtable." TO ".$newtable . '_bak';
								$this->execQuery($usql);
							}
							$updates[] = "ADD PRIMARY KEY $value";
						}
					} elseif ($key == 'KEY') {
						foreach ($value as $subkey => $subvalue) {
							if(!empty($oldcols['KEY'][$subkey])) {
								if($subvalue != $oldcols['KEY'][$subkey]) {
									$updates[] = "DROP INDEX `$subkey`";
									$updates[] = "ADD INDEX `$subkey` $subvalue";
								}
							} else {
								$updates[] = "ADD INDEX `$subkey` $subvalue";
							}
						}
					} elseif ($key == 'UNIQUE') {
						foreach ($value as $subkey => $subvalue) {
							if(!empty($oldcols['UNIQUE'][$subkey])) {
								if($subvalue != $oldcols['UNIQUE'][$subkey]) {
									$updates[] = "DROP INDEX `$subkey`";
									$updates[] = "ADD UNIQUE INDEX `$subkey` $subvalue";
								}
							} else {
								$usql = "ALTER TABLE  ".$newtable." DROP INDEX `$subkey`";
								$this->execQuery($usql);
								$updates[] = "ADD UNIQUE INDEX `$subkey` $subvalue";
							}
						}
					} else {
						if(!empty($oldcols[$key])) {
							if(strtolower($value) != strtolower($oldcols[$key])) {
								$updates[] = "CHANGE `$key` `$key` $value";
							}
						} else {
							$i = array_search($key, $allfileds);
							$fieldposition = $i > 0 ? 'AFTER `'.$allfileds[$i-1].'`' : 'FIRST';
							$updates[] = "ADD `$key` $value $fieldposition";
						}
					}
				}
				if ($updates) {
					$usql = "ALTER TABLE ".$newtable." ".implode(', ', $updates);
					$this->execQuery($usql);
				} else {
					$this->checkColumnDiff($newcols, $oldcols);
				}
			}
		}

		// 输出信息并存入
		$message .= $this->formatMessage();		
		file_put_contents($LOG_PATH, $message, FILE_APPEND);
		
		return  $message;				
	}

	function execQuery($sql) {
		
		$res = true;
		
		if ($this->action == 'OK') {
			$res = mysql_query($sql);
		}
		if (!$res) {
			$debug = debug_backtrace();
			$this->msgList[] = ('line ' . $debug[0]['line'] . ' : ' . 'sql wrong:' . $sql . '  ' . mysql_error());
		} else {
			// 记录
			$this->excsqlList[] = $sql;
		}
		
	}

	/**
	 * 
	 * 检索两个数组的键值顺序是否一致，若不一致列出具体的信息
	 */
	function checkColumnDiff($newCols, $oldCols) {
		
		if (array_keys($newCols) == array_keys($oldCols)) {
			return false;
		}
		if (count($newCols) != count($oldCols)) {
			return false;
		}
		$size = count($newCols);
		
		for ($i=0; $i < $size; $i++) {
			$newCol = key($newCols);
			$oldCol = key($oldCols);
			
			if (!empty($newCol) && !in_array($newCol, array('KEY', 'INDEX', 'UNIQUE', 'PRIMARY')) 
					&& $newCol != $oldCol) {
				$this->msgList[] = ("字段顺序不正确: 第" . ($i+1) . "个字段 sql中字段为 {$newCol} 数据库中字段为 {$oldCol}" );
			}
			next($newCols);
			next($oldCols);
		}
			
	}

	function checkTableComment($newSql, $oldSql) {
		if (!$newSql || !$oldSql) {
			return false;
		}
		
		// 获取最后一行
		$newlastSql = array_pop(explode("\n", $newSql));
		$oldlastSql = array_pop(explode("\n", $oldSql));
		$newComment = '';
		$oldComment = '';
		if (preg_match("/COMMENT\='(.*)'/is", $newlastSql, $matchs))
			$newComment = $matchs[1];
	
		if (!$newComment) 
			return false;
			
		if (preg_match("/COMMENT\='(.*)'/is", $oldlastSql, $matchs))
			$oldComment = $matchs[1];
	
			
		if ($newComment == $oldComment) 
			return false;
			
		return $newComment;
	}



	function remakesql($value) {
		$value = trim(preg_replace("/\s+/", ' ', $value));
		$value = str_replace(array('`',', ', ' ,', '( ' ,' )', 'mediumtext'), array('', ',', ',','(',')','text'), $value);
		return $value;
	}

	function getcolumn($creatsql) {
	
		preg_match("/\((.+)\)\s*(ENGINE|TYPE)\s*\=/is", $creatsql, $matchs);
	
		$cols = explode("\n", $matchs[1]);
		$newcols = array();
		foreach ($cols as $value) {
			$value = trim($value);
			if(empty($value)) continue;
			$value = $this->remakesql($value);
			if(substr($value, -1) == ',') $value = substr($value, 0, -1);
	
			$vs = explode(' ', $value);
			$cname = $vs[0];
	
			if($cname == 'KEY' || $cname == 'INDEX' || $cname == 'UNIQUE') {
	
				$name_length = strlen($cname);
				if($cname == 'UNIQUE') $name_length = $name_length + 4;
	
				$subvalue = trim(substr($value, $name_length));
				$subvs = explode(' ', $subvalue);
				$subcname = $subvs[0];
				$newcols[$cname][$subcname] = trim(substr($value, ($name_length+2+strlen($subcname))));
	
			}  elseif($cname == 'PRIMARY') {
	
				$newcols[$cname] = trim(substr($value, 11));
	
			}  else {
	
				$newcols[$cname] = trim(substr($value, strlen($cname)));
			}
		}
		return $newcols;
	}
	
		function formatMessage() {
			$showMessage = " ";
			if (!$this->excsqlList && !$this->msgList) {
				$showMessage .= "当前sql已是最新无需更新!\n";
			} else {
				if($this->msgList) {
					$showMessage .= "error message:<br>\n ";
					foreach ($this->msgList as $v) {
						$showMessage .= $v . "\n
	*********************<br>\n\n";
					}
				}
				$showMessage .= "exec sql :\n<br>";	
				foreach ($this->excsqlList as $v) {
					$showMessage .= $v . "\n
	__-------------------------------------------------------------------------------------------__\n\n";
				}
			}
			return $showMessage;
		}
}
