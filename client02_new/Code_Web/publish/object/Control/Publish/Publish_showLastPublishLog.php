<?php
class Control_Publish_showLastPublishLog {

	function showLastPublishLog() {
		
		$pubLog = MooObj::get('Publish_Log')->getExecDetail();
		
		MooView::set('pubLog', $pubLog);
		MooView::render('publishView');
	}
}