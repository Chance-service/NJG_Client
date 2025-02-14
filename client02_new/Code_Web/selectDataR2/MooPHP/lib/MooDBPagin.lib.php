<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 数据库分页类
 * 
 * expample:
 * 
 * $db = DBFactory::xxx();
 * MooDBPagin::setLinks(9);
 * MooDBPagin::setRows(20);
 * $data = MooDBPagin::getPage($db, 'SELECT s_name FROM sites WHERE s_id > :s_id GROUP BY u_flat_id', array('s_id' => 100));
 * print_r($data);
 */
class MooDBPagin implements MooDBPaginInterface {
	private $linkNum = 10;
	private $perPage = 20;
	
	/**
	 * 设置显示的连接数量
	 *
	 * @param int $linkNum
	 */
	static public function setLinks($linkNum) {
		$DBPagin = self::_getInstanse();
		$DBPagin->linkNum = intval($linkNum);
	}
	
	/**
	 * 设置每页显示的数据条数
	 *
	 * @param int $perPage
	 */
	static public function setRows($perPage) {
		$DBPagin = self::_getInstanse();
		$DBPagin->perPage = intval($perPage);
	}
	
	/**
	 * 执行分页查询，并获取分页数据
	 *
	 * @param object $dbh
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $cache
	 * @param int $totalCache
	 * @return array
	 */
	static public function getPage($dbh, $sql, $param = array(), $exit = true, $cache = 0, $totalCache = 0) {
		$DBPagin = self::_getInstanse();
		
		// 统计一共有多少条数句
		$total = $DBPagin->_totalRows($dbh, $sql, $param, $exit, $totalCache);
		if (!$total) {
			return array('current' => 0, 'pages' => 0, 'total' => 0, 'rows' => 0, 'link' => '', 'links' => array(), 'data' => array());
		}
		
		$rows = intval($DBPagin->perPage);
		$rows < 1 ? $rows = 20 : false;
		
		// 计算一共有多少页
		$pageNum = ceil($total / $rows);
		
		// 判断当前页是否在规定页数内
		$currentPage = intval(MooForm::request('cpg'));
		$currentPage > $pageNum ? $currentPage = $pageNum : true;
		$currentPage < 1 ? $currentPage = 1 : true;
		
		// 设置sql语句中用于limit的start
		$start = ($currentPage - 1) * $rows;
		
		// 获得分页数据
		$page = MooPagin::getPage($currentPage, $total, $rows, $DBPagin->linkNum);
		
		// 按分页取出数据
		$page['data'] = $DBPagin->_getPageData($dbh, $sql, $param, $exit, $start, $rows, $cache);
		
		return $page;
	}
	
	/**
	 * 统计总行数
	 *
	 * @param object $dbh
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $cache
	 * @return int
	 */
	static private function _totalRows($dbh, $sql, $param, $exit, $cache) {
		$cacheId = md5($sql);
		$cacheId = 'sqlCache/' . $cacheId[0] . '/' . $cacheId[1] . '/' . $cacheId;
		if ($cache && $totalRow = MooCache::get($cacheId)) {
			return $totalRow;
		}
		
		// 去掉OERDER语句提高统计效率
		$num = strpos(strtoupper($sql), ' ORDER ');
		if ($num) {
			$countSql = substr($sql, 0, $num);
		} else {
			$countSql = $sql;
		}
		$cutSql = null;
		preg_match('/\s+FROM\s+.*/si', $countSql, $cutSql);
		$countSql = 'SELECT 1 ' . $cutSql[0];
		$res = $dbh->query($countSql, $param, $exit);
		$totalRow = $res->rowCount();
		
		if ($cache) {
			MooCache::set($cacheId, $totalRow, $cache);
		}
		return $totalRow;
	}
	
	/**
	 * 获取分页之后的数据
	 *
	 * @param object $dbh
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $start
	 * @param int $rows
	 * @param int $cache
	 * @return array
	 */
	static private function _getPageData($dbh, $sql, $param, $exit, $start, $rows, $cache) {
		$pageSql = $sql . ' LIMIT ' . $start . ',' . $rows;
		return $dbh->getAll($pageSql, $param, $exit, $cache);
	}
	
	/**
	 * 单件
	 *
	 * @return object
	 */
	static private function _getInstanse() {
		if (is_object($this) && $this instanceof MooDBPagin) {
			return $this;
		}
		static $DBPagin = null;
		if (!$DBPagin) {
			$DBPagin = new MooDBPagin();
		}
		return $DBPagin;
	}
}