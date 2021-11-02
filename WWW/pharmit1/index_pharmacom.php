<?php
include './engine/user.lib.php';
 $user = new userclass();
  $user->init();
//  $user->initdata();

$maxpacket = $GLOBALS["MAX_PACKET"];
//$currentdate = date("Ymd")-1;
if (isset($_GET['datesale'])) {
	$currentdate = $_GET['datesale'];
	$format = 'dmY';
	$currentdate = DateTime::createFromFormat($format, $currentdate);
    $currentdate =$currentdate->format('Ymd');}
	else {$currentdate = date("Ymd")-1;}

$user->initdata($currentdate);
$datesale = '{DateSale:'.$currentdate.'}';


$lload='';
 $FileID=$user->getFileID($datesale);
//  $FileID = 11222;

// print_r($s['access_token']);

$sql="SELECT  * from PHARMIT_OUT";
$count = 0;$count_pac = 0;
$sth = ibase_prepare($sql);	
$result=ibase_execute($sth);
$res='[';
  while ($row=ibase_fetch_row($result))
{
	$str ='{   "typeid":"'.$row[0].'",
			   "DateId":"'.$row[1].'", 
			   "ExternalGoodId":"'.$row[2].'",
			   "ProducerName":"'.str_replace('"',' ',iconv("cp1251", "utf-8",$row[4])).'",
			   "GoodName":"'.str_replace('"','',iconv("cp1251", "utf-8",$row[3])).'",
			   "Quantity":"'.$row[5].'",
			   "WholesalePriceKzt":"'.$row[6].'",
			   "PriceKzt":"'.$row[7].'",		   		   
			   "Pharm":"'.str_replace('"','',iconv("cp1251", "utf-8", $row[8])).'",
			   "PharmBin":"'.$row[9].'",
			   "Pharmaddress":"'.str_replace('"','',iconv("cp1251", "utf-8", $row[10])).'",
			   "Index":"'.$row[11].'",
			   "LocalityName":"",
			   "PharmX":"",
			   "PharmY":"",
			   "DistribName":"'.str_replace('"','',iconv("cp1251", "utf-8",$row[20])).'",
			   "DistribBin":"'.$row[21].'",
			   "DistribAdress":"'.str_replace('"','',iconv("cp1251", "utf-8",$row[22])).'",
			   "ProviderSaleId":"'.$row[23].'",
			   "FileId":"'.$FileID.'"
			
		}
		 ' ;     
	$res = $res.$str.',';
	$count++;$count_pac++;
			    
	if ($count_pac == $maxpacket) {
		$res = substr($res,0,-1);
		$res = $res.']';// print_r($res);
		$load = $user->putData($res);
		$lload=$lload.$load;
		//print_r($count); print_r('<br>');
		$res = '[';
		//print_r($load);
		//print_r($res);
		$count_pac = 0;
	}

}
 if (($count_pac!=$maxpacket)or($count_pac!=0)){ 
		$res = substr($res,0,-1);
		$res = $res.']'; 
	    $load = $user->putData($res);
 	    $lload=$lload.$load; 
 	    $res = '[';
 	   // print_r($load);
		//print_r($res);
 	}
$resul=$user->putConfirm($FileID,$count);
print_r($GLOBALS["CLIENT_URL_FILE_ID"].'/'.$FileID.'_'.$count);
//print_r($lload);
//print_r('POST<br>');
//$user->message_to_telegram('Фармаком Загружено в PharmIT - '.$resul.'из '.$count.' записей успешно');
if ($resul==$count){
	//$sql = "DELETE FROM PHARMIT_OUT where uuid=uuid";
//	$sth = ibase_prepare($sql);	
//	ibase_execute($sth);
	$user->message_to_telegram('Фармаком выгружено в PharmIT - '.$resul.' записей успешно');
}
else
{
  $user->message_to_telegram('Фармаком Загружено в PharmIT - '.$resul.'из '.$count.' записей успешно');	
}

?>
