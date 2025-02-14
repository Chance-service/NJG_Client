<?php
class Control_showIndex {
	/**
	 * 提示信息
	 *
	 * @param  $message  提示内容
	 * @param  $url  跳转地址
	 * @return  $second  停留时间
	 */
	function showIndex() {
		
		$startdate 	= date("Y-m-d", time()-7 * 86400);
		$endTime	= date('Y-m-d');
		MooView::set('startTime', $startdate);
		MooView::set('endTime', $endTime);
		MooView::render('index');
	}
}