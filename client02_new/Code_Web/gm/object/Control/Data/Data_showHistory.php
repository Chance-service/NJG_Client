<?php
class Control_Data_showHistory {

	function showHistory() {
		$date 	= 	date('Y-m-d', time());
		
		MooView::set('date', $date);
	
		MooView::render('dataHistoryView2');
	}
}