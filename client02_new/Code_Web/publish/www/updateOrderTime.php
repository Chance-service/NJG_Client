<?php
require_once 'common.php';

$rs = MooObj::get('Control_ExcelConfMaker')->updateOrderTime();

v($rs);