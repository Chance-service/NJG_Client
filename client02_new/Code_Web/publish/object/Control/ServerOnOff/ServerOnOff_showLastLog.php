<?php
class Control_ServerOnOff_showLastLog {

	function showLastLog() {
		
		$serverOnOffLog = MooObj::get('ServerOnOff_Log')->getExecDetail();
		
		MooView::set('pubLog', $serverOnOffLog);
		MooView::render('serverOnOffView');
	}
}