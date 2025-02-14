<?php
class Control_Recharge_fetchOrder {

	function fetchOrder() {
		
		$game 	= MooForm::request('game');
		$orderid 	= MooForm::request('orderId');
		$fetchOrder = MooConfig::get('main.rechargeUrl.fetch_order');
		
		if (!$game) {
			MooView::render('fetchOrder2');
		} else {
			$url = $fetchOrder."?game=".$game."&orderid=".$orderid;
			
			$rs = MooUtil::curl_send($url);
			$res = MooJson::decode($rs, true);
			$res = array($res);
			MooView::set('data', $res);
			MooView::set('nowGame', $game);
			MooView::render('fetchOrder2');
		}
	}
}