<?php
require_once 'common.php';

$fileName = ROOT_PATH . "\doc\excel\cs_1.xsl";

v($fileName);

$cs1 = MooObj::get('Control_ExcelConfMaker_Excel')->read($fileName ,'UTF-8', 0);

v($cs1);