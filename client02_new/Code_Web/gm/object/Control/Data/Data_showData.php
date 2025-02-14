<?php
class Control_Data_showData {

	function showData() {
		$startDate 	= 	date('Y-m-d', time());
		$endDate 	= 	date('Y-m-d', time());
		
		MooView::set('startDate', $startDate);
		MooView::set('endDate', $endDate);
		
		$statistics = 0;
		MooView::set('statistics', $statistics);
		
		MooView::set('data', $res);
		MooView::set('data2', $res);	
		MooView::set('data3', $res);
	
		MooView::render('dataView2');
	}
}