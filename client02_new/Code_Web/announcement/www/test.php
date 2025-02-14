<?php
require_once 'common.php';

$file = ROOT_PATH . "/www/hwgj_r2_French_2015-05-09_09_46_04.txt";
v($file);

$contents = MooFile::readAll($file);

var_dump($contents);

$contents	= 	str_replace("\n",' ', $contents);

var_dump($contents);

$res = MooFile::write("hwgj_r2_French_2015-05-09_09_46_04.txt.bak", $contents);
v($res);

