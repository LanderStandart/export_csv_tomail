<?php
//unlink(__DIR__ . '/engine/log.txt');
include './engine/user.lib.php';
 $user = new userclass();
  $user->init();
$profile= $_GET['id'];
if (!isset($profile)){
 $profile =$argv[1];}


if (isset($profile)){
  $autriz=$GLOBALS["AUTORIZ"][$profile];} 
else
  {$autriz=$GLOBALS["AUTORIZ"]["0"];} 

$url ='https://api.pharmit.kz/api/values?startDate=20210501' ;  


$response= $user->MyCURL($url,'GET',$autriz,'',1);
$noDates = $response['noDates'];
var_dump($response);
$i=0;
foreach ($noDates as  $Date) {
	$format = 'Ymd';
  	$Nodate = DateTime::createFromFormat($format, $Date);
	$date1 = $Nodate;
  	$Nodate =$Nodate->format('Ymd');
  	$i=$i++;

	$date1 =$date1->format('dmY');
//        $user->initdata($date1);

//	print_r($date1);
$datesale = '{DateSale:'.$Nodate.'}';
	print_r($datesale);
	$user->CompilePacket($date1,$GLOBALS["PROFILE_GROUP"][$profile]);
	//	$urls='http://localhost:8080/pharmit/index.php?datesale='.$Nodate.'&id='.$profile;
//	echo shell_exec("d:/wamp/bin/php/php5.5.12/php.exe checkdate.php ".$id." ".$Nodate);
//	print_r($urls);
//	$user->MyCURL($urls,'GET','','',0);
        sleep(30);
 	//$result = file_get_contents('http://192.168.2.130:8080/pharmit1/index.php?datesale='.$Nodate);
//var_dump($result);
}



?>
