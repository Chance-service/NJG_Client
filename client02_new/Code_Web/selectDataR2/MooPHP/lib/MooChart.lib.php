<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooChart {
	private $data = array();
	private $xName = '';
	private $yName = '';
	private $title = '';
	private $chartFile = '';
	private $type = '';

	/**
	 * 设置图表数据
	 *
	 * @param array $data
	 * @param string $name
	 */
	static public function setData($data, $name = '') {
		$chart = self::getInstance();
		$name = $name !== '' ? $name : 'default';
		$chart->data[$name] = $data;
	}

	/**
	 * 设置图表类型
	 *
	 * @param string $type
	 */
	static public function setType($type) {
		$chart = self::getInstance();
		$chart->type = $type;
		$chart->chartFile = str_replace('\\', '/', MOOCHART_CHART_DIR) . '/' . $type . '.swf';
	}

	/**
	 * 设置图表标题
	 *
	 * @param string $title
	 */
	static public function setTitle($title) {
		$chart = self::getInstance();
		$chart->title = $title;
	}

	/**
	 * 设置横坐标
	 *
	 * @param string $name
	 */
	static public function setX($name) {
		$chart = self::getInstance();
		$chart->xName = $name;
	}

	/**
	 * 设置纵坐标
	 *
	 * @param string $name
	 */
	static public function setY($name) {
		$chart = self::getInstance();
		$chart->yName = $name;
	}

	/**
	 * 生成图表
	 *
	 * @param int $width
	 * @param int $height
	 * @return string
	 */
	static public function render($width = '100%', $height = 250) {
		!$width && $width = '100%';
		$chart = self::getInstance();
		$dataXml = $chart->createDataXml();
		$return = $chart->createChart($dataXml, $width, $height);
		$chart->reset();
		return $return;
	}

	/**
	 * 生出数据xml
	 *
	 * @return string
	 */
	private function createDataXml() {
		$chart = self::getInstance();
		$count = count($chart->data);
		if (!$count) {
			return false;
		}

		$xml = "<chart caption='{$chart->title}' xAxisName='{$chart->xName}' yAxisName='{$chart->yName}' showValues='0'>\n";
		if (in_array(strtoupper($chart->type), array('PIE2D', 'Pie3D'))) {
			$data = current($chart->data);
			foreach ($data as $k => $v) {
				$xml .= "<set label='{$k}' value='{$v}' />\n";
			}
		} else {
			$currentData = current($chart->data);
			if (!$currentData) {
				return false;
			}
			$keys = array_keys($currentData);

			$xml .= "<categories>\n";
			foreach ($keys as $k) {
				$xml .= "<category label='{$k}' />\n";
			}
			$xml .= "</categories>\n";

			foreach ($chart->data as $name => $row) {
				$xml .= "<dataset seriesName='{$name}'>\n";
				foreach ($row as $k => $v) {
					$xml .= "<set value='{$v}' />\n";
				}
				$xml .= "</dataset>\n";
			}
		}
		$xml .= '</chart>';
		return $xml;
	}

	/**
	 * 重置
	 *
	 */
	private function reset() {
		$chart = self::getInstance();
		$chart->xName = '';
		$chart->yName = '';
		$chart->title = 'default';
		$chart->data = array();
	}

	/**
	 * 单键 &&  工厂
	 *
	 * @return object
	 */
	static private function getInstance() {
		if (is_object($this) && $this instanceof MooChart) {
			return $this;
		}
		static $chart = null;
		if (!$chart) {
			$chart = new MooChart();
			$chart->reset();
		}
		return $chart;
	}

	/**
	 * 生成图表xml
	 *
	 * @param string $dataXml
	 * @param int $width
	 * @param int $height
	 * @return string
	 */
	private function createChart($dataXml, $width, $height) {
		$strFlashVars = "&chartWidth={$width}&chartHeight={$height}&debugMode=0";
		$strFlashVars .= "&dataXML={$dataXml}";

		$HTML_chart = "
		<object classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0' width='{$width}' height='{$height}' id='{$this->title}'>
		<param name='allowScriptAccess' value='always' />
		<param name='movie' value='{$this->chartFile}'/>		
		<param name='FlashVars' value=\"$strFlashVars&registerWithJS=0\" />
		<param name='quality' value='high' />
		<param name='wmode' value='transparent' />
		<embed src='{$this->chartFile}' FlashVars=\"$strFlashVars&registerWithJS=0\" quality='high' width='{$width}' height='{$height}' name='{$this->title}' allowScriptAccess='always' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer' wmode='transparent' />
		</object>";
		return $HTML_chart;
	}
}