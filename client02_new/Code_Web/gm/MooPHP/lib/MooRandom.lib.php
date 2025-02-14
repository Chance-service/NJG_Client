<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooRandom {
	function rand($from = null, $to = null) {
		srand((float)microtime() * 1000000);
		if (isset($from) && isset($to)) {
			return mt_rand($from, $to);
		} elseif (isset($from)) {
			return mt_rand(0, $from);
		} else {
			return mt_rand();
		}
	}

	/**
	 * 计算几率
	 * @param $probability
	 * @return boolean
	 */
	function getProbability($probability, $precision = 1000) {
		if (!$probability) {
			return false;
		}
		
		if ($precision < 100) {
			$precision = 100;
		}

		if ($probability >= 100) {
			return true;
		} elseif ($probability >= 70) {
			return MooRandom::rand(1, $precision) > 0.3 * $precision;
		} else {
			$probability = ($probability / 100) * $precision;
			$rand = array();
			for($i = 1; $i <= $probability; $i++) {
				$key = MooRandom::rand(1, $precision);
				$rand[$key] = 1;
			}

			return (boolean)$rand[MooRandom::rand(1, $precision)];
		}
	}
}