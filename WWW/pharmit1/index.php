<?php
include './engine/user.lib.php';
 $user = new userclass();
  $user->init();
  


//$currentdate = date("Ymd")-1;
//$datesale = '{DateSale:'.$currentdate.'}';

//$id= $_GET['id'];
if (isset($_GET['id'])){$id= $_GET['id'];}//else{$id='';}
if (isset($_GET['datesale'])){$$currentdate= $_GET['datesale'];}//else{$id='';}

if (!isset($id)){
 $id =$argv[1];}
if (!isset($currentdate)){
 $currentdate =$argv[2];}
/*if (isset($currentdate)) {
	$format = 'dmY';
	$currentdate = DateTime::createFromFormat($format, $currentdate);
        $date1 = $currentdate;
	$currentdate =$currentdate->format('Ymd');
	$date1 =$date1->format('d.m.Y');}
	else {$currentdate = date("Ymd")-1;
 	$date =date("d.m.Y")-1; }
print_r($date1);                     }*/
//$user->initdata($date1);
$datesale = '{DateSale:'.$currentdate.'}';


//if ($id==0){
if (isset($id)){
	//$user->initdata();
        $user->message_to_telegram($GLOBALS["PROFILE_GROUP"][$id]);
	$user->CompilePacket($currentdate,$GLOBALS["PROFILE_GROUP"][$id]);

}
else {
	$user->CompilePacket($datesale,$GLOBALS["PROFILE_GROUP"][$id]);
}

 // foreach ($GLOBALS["PROFILE_GROUP"] as $key){
 // 	    $user->initdata();
	// 	$user->CompilePacket($datesale,$key);
	// 	sleep (300);
	// }




?>
