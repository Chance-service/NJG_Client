<?php
class Control_InitServer_showLastLog {

	function showLastLog() {
		
		$initServerLog = MooObj::get('InitServer_Log')->getExecDetail();
		
		MooView::set('pubLog', $initServerLog);
		MooView::render('initServerView');
	}
}