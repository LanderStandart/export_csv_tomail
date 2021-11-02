<?php
//unlink(__DIR__ . '/engine/log.txt');
include './engine/user.lib.php';
 $user = new userclass();
  $user->init();
$profile= $_GET['id'];
if (!isset($profile)){
 $profile =$argv[1];}
 $datesale=$argv[2];

//	print_r($date1);
$datesale = '{DateSale:'.$Nodate.'}';
	print_r($datesale);
	//$user->CompileDecadePacket($date1,$GLOBALS["PROFILE_GROUP"][$profile]);





?>
