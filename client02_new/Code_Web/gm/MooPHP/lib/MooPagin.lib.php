<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 数据库分页类
 * 
 * expample:
 * 
 * $data = Pagin::getPage($pg, $total);
 * print_r($data);
 */
class MooPagin implements MooPaginInterface {
	/**
	 * 执行分页查询，并获取分页数据
	 *
	 * @param int $pg
	 * @param int $total
	 * @param int $perPage
	 * @param int $linkNum
	 * @return array
	 */
	static public function getPage($pg, $total, $perPage = 20, $linkNum = 10) {
		$pg		= intval($pg);
		$total	= intval($total);
		
		$linkNum = intval($linkNum);
		$linkNum = $linkNum < 1 ? 10 : $linkNum;
		
		$perPage = intval($perPage);
		$perPage = $perPage < 1 ? 20 : $perPage;
		
		
		// 统计一共有多少条数句
		if (!$total) {
			return array('current' => 0, 'pages' => 0, 'total' => 0, 'rows' => 0, 'link' => '', 'links' => array());
		}
		
		// 分页操作
		$page = self::_page($pg, $total, $perPage, $linkNum);
		
		// 生成分页链接
		$page['link'] = self::_makeLink($page, $linkNum, $page['total'], $page['rows'], $page['pages']);
		
		return $page;
	}
	
	/**
	 * 用于计算分页的方法
	 *
	 * @param int    $pg		cuttent page
	 * @param int    $total		all rows number
	 * @param int    $rows		show rows per page
	 * @param int    $linkNum	show lins per page
	 * @return array
	 */
	static private function _page($pg, $total, $rows, $linkNum) {
		// 当前页号
		$currentPage = intval($pg);
		
		// 每页行数
		$rows = intval($rows);
		$rows < 1 ? $rows = 15 : false;
		
		// 每页显示链接数
		$linkNum = intval($linkNum);
		
		// 计算一共有多少页
		$pages = ceil($total / $rows);
		
		// 判断当前页是否在规定页数内
		$currentPage > $pages ? $currentPage = $pages : true;
		$currentPage < 1 ? $currentPage = 1 : true;
		
		// 本页显示的页号
		$links = array();
		
		// 本页开始的页号
		$linkStart = $currentPage - ceil($linkNum / 3);
		$linkStart + $linkNum > $pages ? $linkStart = $pages - $linkNum + 1 : false;
		$linkStart < 1 ? $linkStart = 1 : false;
		for($i = 0; $i < $linkNum; $i++) {
			if ($linkStart + $i > $pages) {
				break;
			}
			$links[] = $linkStart + $i;
		}
		
		return array('current' => $currentPage, 'pages' => $pages, 'total' => $total, 'rows' => $rows, 'links' => $links);
	}

	/**
	 * 生成分页链接
	 * @param array $data
	 * @param int $linkNum
	 * @return string
	 */
	static private function _makeLink($data, $linkNum, $total, $rows, $pages) {
		// 获取url
		$url = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['SCRIPT_NAME'];
		
		// 整理url后的参数
		$queryString = $_SERVER['QUERY_STRING'] ? '&' . $_SERVER['QUERY_STRING'] : '';
		$queryString = preg_replace('/&?cpg=[0-9]*/', '', $queryString);
		
		// 配置导航链接
		$prveOneNum = $data['current'] - 1;
		$nextOneNum = $data['current'] + 1;
		
		// 前一页
		$prveOne = $prveOneNum > 0 ? "<a href='{$url}?cpg={$prveOneNum}{$queryString}'>上一页</a>\n" : '';
		// 后一页
		$nextOne = $nextOneNum <= $data['pages'] ? "<a href='{$url}?cpg={$nextOneNum}{$queryString}'>下一页</a>\n" : '';
		$linkspage = "";
		foreach ($data['links'] as $link) {
			if ($link != $data['current']) {
				$linkspage .= "<a href='{$url}?cpg={$link}{$queryString}'>{$link}</a>\n";
			} else {
				$linkspage .= "<span><b>{$link}</b></span>\n";
			}
		}
		if ($data['links'][0] > 1) {
			$tmp = "<a href='{$url}?cpg=1{$queryString}'>1</a>\n";
			if ($data['links'][0] > 2) {
				$tmp .= '&nbsp;<span>...</span>&nbsp;';
			}
			$linkspage = $tmp . $linkspage;
		}
		$lastLink = array_pop($data['links']);
		if ($pages > $lastLink) {
			if ($pages > $lastLink +1) {
				$linkspage .= '<span>...</span>&nbsp;';
			}
			$linkspage .= "<a href = '{$url}?cpg={$pages}{$queryString}'>{$pages}</a>\n";
		}
		//$goto = $data['pages'] > $linkNum ? '<input class="gotxt" type="text" name="cpg" value="" size=1 /> <input class="gobt" type="submit" value="go">' : '';
		
		return "
			<div class='pager'>
			<form onsubmit='location.href=\"?cpg=\" + document.getElementById(\"goPg\").value + \"{$queryString}\";return false'>
			<!--{$total}条数据，{$pages}页&nbsp;|&nbsp;-->{$prveOne}{$linkspage}{$nextOne}{$goto}
			</form>
			</div>";
	}
}
