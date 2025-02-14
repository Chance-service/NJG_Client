<?php
class Control_Recharge_fetchOrderByPuid {

	function fetchOrderByPuid() {
		
		$game 	= MooForm::request('game');
		$puid 	= MooForm::request('puid');
		$fetchOrder = MooConfig::get('main.rechargeUrl.fetch_recharge');
		
		if (!$game) {
			MooView::render('fetchOrderPuid2');
		} else {
			$url = $fetchOrder."?game=".$game."&puid=".$puid;
			
			$rs = MooUtil::curl_send($url);
			$res = MooJson::decode($rs, true);
			
			MooView::set('data', $res);
			MooView::set('nowGame', $game);
			MooView::render('fetchOrderPuid2');
		}
	}
}