<?php
// сюда нужно вписать токен вашего бота
define('TELEGRAM_TOKEN', '714403255:AAEFPWXntiPud-DleKI3HHG20qzbDN4ERdM');

// сюда нужно вписать ваш внутренний айдишник
define('TELEGRAM_CHATID', '483403057');

include_once("declare.php");

class userclass{
 var $db;
 var $default_trn;


function MyCURL($url,$type,$autriz,$POSTFIELDS,$json)
//$url - путь куда запрос
//$type - тип запроса PUT/POST/GET
//$autriz - параметры авторизации(токен)
//$POSTFIELDS - данные для передачи
//$json - 0 - не расходируем ответ 1- раскодируем
{


    

$header = array(
    "Accept: */*",
    "Accept-Encoding: gzip, deflate",
    "Authorization: ".$autriz,
    "Cache-Control: no-cache",
    "Connection: keep-alive",
    "Content-Type: application/json",
    "Content-Length:".strlen($POSTFIELDS),
    "Host: api.pharmit.kz",
    "Postman-Token: d3cb4eb9-0575-45b5-bc43-d15597e3a180,7b27ba2f-10c8-47d0-b021-06d5d53bd816",
    "User-Agent: LanderPOST 0.1.2",
    "cache-control: no-cache"
  );



$ch = curl_init();

switch ($type)
{
   case "POST":
            curl_setopt($ch, CURLOPT_POST, 1);

            if ($POSTFIELDS)
                curl_setopt($ch, CURLOPT_POSTFIELDS, $POSTFIELDS);
            break;
   case "PUT":
            curl_setopt($ch, CURLOPT_PUT, 1);
            $header[6]='Content-Length:';
            unset($header[5]);
            break;
   case "GET":
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'GET');
            unset($header[6]);
            unset($header[5]);
            break;            
   default:
            if ($POSTFIELDS)
                $url = sprintf("%s?%s", $url, http_build_query($POSTFIELDS));
}

curl_setopt($ch,CURLOPT_POSTFIELDS,$POSTFIELDS);
curl_setopt($ch,CURLOPT_HTTPHEADER,$header);
curl_setopt($ch,CURLOPT_URL,$url);


curl_setopt_array($ch, array(
  
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_SSL_VERIFYPEER => false,
  CURLOPT_SSL_VERIFYHOST => false,
  CURLOPT_ENCODING => "",
 
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_CONNECTTIMEOUT =>400,
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_TIMEOUT => 5000,
  
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1
));
 


$data = curl_exec($ch);

$err = curl_error($ch);
$info = curl_getinfo($ch, CURLINFO_HTTP_CODE);

//$message='-----------------------'."\n".$header."Response:"."\n".$data."\n"."Code answer:"."\n".$info."\n";
$message='Добрая'."\n".$type."\n".implode("\n",$header)."\n".$url."\n"."Response:"."\n".$data."\n"."Code answer:"."\n".$info."\n";
file_put_contents(__DIR__ . '/log.txt', $message . PHP_EOL, FILE_APPEND);

$this->message_to_telegram($message);
print_r('-----------------------');
print_r($header);
print_r($url.'<br>');
print_r('Response:<br><pre>');
print_r($data);
print_r('</pre><BR>Code answer:');//print_r($header);
print_r($info);print_r('<br>');

if ($err) {
  echo "cURL Error #:" . $err;
  return $err;
}
if ($json==0){return $data;}{ return json_decode($data, true);}

}


 function init(){
  $this->db = ibase_connect($GLOBALS["DB_DATABASENAME"], $GLOBALS["DB_USER"], $GLOBALS["DB_PASSWD"]) or die("db connect error " . ibase_errmsg());
  $this->default_trn = ibase_trans(IBASE_WRITE + IBASE_COMMITTED + IBASE_REC_VERSION + IBASE_NOWAIT, $this->db) or die(" error start transaction".ibase_errmsg());
}

function query($trn, $sql){
  if ($trn==0){$trn=$this->default_trn;}
  return ibase_query($trn,$sql) or die(" error prepare ".ibase_errmsg()."(".$sql.")");
//  $res = ibase_execute($q,$_POST["MACHINEUUID"],$_POST["SHIFT_ID"]) or die(" error exec ".ibase_errmsg()."(".$sql.")");
}

function initdata($date)
{
//$currentdate=date("d.m.Y", time() - 86400);  
$sql = "EXECUTE PROCEDURE PR_PHARMIT_OUT('".$date."')";
$sth = ibase_prepare($sql);	
ibase_execute($sth);
file_put_contents(__DIR__ . '/log.txt', $sql . PHP_EOL, FILE_APPEND);

}

//получаем токен для передачи
function putConfirm($FileID,$count,$profile){
$base_url = $GLOBALS["CLIENT_URL_FILE_ID"];  
$url = $base_url."/".$FileID."_".$count;
print_r($url);
$res = $this->MyCURL($url,"PUT",$GLOBALS["AUTORIZ"][$profile],"",0); 
return $res;

}
//получаем токен для передачи
//получаем токен для передачи
function getFileID($Data,$profile){
if (isset($profile)){
  $autriz=$GLOBALS["AUTORIZ"][$profile];} 
else
  {$autriz=$GLOBALS["AUTORIZ"]["0"];} 

$base_url = $GLOBALS["CLIENT_URL_FILE_ID"];  
//print_r($autriz);
$auth_string=$this->MyCURL($base_url,'POST',$autriz,$Data,1);
//print_r($auth_string.'<br>');
return $auth_string;

}
/*
function getFileID($Data,$profile){
$base_url = $GLOBALS["CLIENT_URL_FILE_ID"];  

$ch = curl_init();
curl_setopt_array($ch, array(
  CURLOPT_URL => $base_url,
  CURLOPT_RETURNTRANSFER => true,
  
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_TIMEOUT => 50,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => "POST",
  CURLOPT_POSTFIELDS => $Data,
  CURLOPT_SSL_VERIFYPEER => false,
  CURLOPT_SSL_VERIFYHOST => false,
  CURLOPT_HTTPHEADER => array(
    "Accept: *//*",
    "Accept-Encoding: gzip, deflate",
    "Authorization: ".$GLOBALS["AUTORIZ"][$profile],
    "Cache-Control: no-cache",
    "Connection: keep-alive",    
    "Content-Type: application/json",
    "Host: api.pharmit.kz",
    "User-Agent: LanderPOST/0.1.3",
    "cache-control: no-cache"
  ),
));

$data1 = curl_exec($ch);
$err = curl_error($ch);

if ($err) {
  echo "cURL Error #:" . $err;
  return $err;
}
$auth_string = json_decode($data1, true);
return $auth_string;
}               */

function putData($Data,$profile)
{
$base_url = $GLOBALS["CLIENT_URL_LOAD"];    
$this->MyCURL($base_url,"POST",$GLOBALS["AUTORIZ"][$profile],$Data,1);
}

function message_to_telegram($text)
{   file_put_contents(__DIR__ . '/log.txt', $text . PHP_EOL, FILE_APPEND);
    $ch = curl_init();
    curl_setopt_array(
        $ch,
        array(
            CURLOPT_URL => 'https://api.telegram.org/bot' . TELEGRAM_TOKEN . '/sendMessage',
            CURLOPT_POST => TRUE,
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_TIMEOUT => 10,
            CURLOPT_POSTFIELDS => array(
                'chat_id' => TELEGRAM_CHATID,
                'text' => $text,
            ),
        )
    );
    $response = curl_exec($ch);
   

}

    // $file_url- можно передавать url любого файла до 50 МБ
    //$token - token бота 
    //$chatID - ID чата куда отправляем файл
    function SendTelFile($file_url) {
        $ch = curl_init($file_url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_HEADER, false);
        $html = curl_exec($ch);
        //print_r('https://api.telegram.org/bot'.TELEGRAM_TOKEN.'/sendDocument?caption=Вложение&chat_id='.TELEGRAM_CHATID);
        curl_close($ch);
        file_put_contents(basename($file_url), $html);
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL =>  'https://api.telegram.org/bot'.TELEGRAM_TOKEN.'/sendDocument?caption=Вложение&chat_id='.TELEGRAM_CHATID,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: multipart/form-data'
            ],
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => [
                'document' => curl_file_create(basename($file_url), mime_content_type(basename($file_url)), basename($file_url))
            ]
        ]);
        $data = curl_exec($curl);
        print_r($data);
        curl_close($curl);
      }


function CompilePacket($datesale,$profile)
{
$maxpacket = $GLOBALS["MAX_PACKET"];  
	$format = 'dmY';
	$ctdate = DateTime::createFromFormat($format, $datesale);
	$date1 =$ctdate->format('d.m.Y');
	$date2 = $ctdate->format('Ymd');
$datesale = '{DateSale:'.$date2.'}';

$FileID=$this->getFileID($datesale,$profile);print_r('GET FILE_ID<BR>');
print($datesale);

//        $ctdate =$ctdate->format('d.m.Y');
print_r($date1);
$this->initdata($date1);
$sql="SELECT  * from PHARMIT_OUT where PROFILE_ID=".$profile;
//$sql="SELECT  * from PHARMIT_OUT";

$this->message_to_telegram($datesale);
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
                   "FileId":"'.$FileID.'",
                   "QuantityBalance":"'.$row[26].'"                
              }
               ' ;     
            $res = $res.$str.',';
            $count++;$count_pac++;
                    
            if ($count_pac == $maxpacket) {
              $res = substr($res,0,-1);
              $res = $res.']';
	      file_put_contents(__DIR__ . '/packet/'.$FileID.'.packet'.$count.'.txt', $res . PHP_EOL, FILE_APPEND);
              $load = $this->putData($res,$profile);print_r('POST DATA-'.$count.' <br>');
              $res = '[';
              $count_pac = 0;
            }

}
 if (($count_pac!=$maxpacket)or($count_pac!=0)){ 
    $res = substr($res,0,-1);
    $res = $res.']'; 
    file_put_contents(__DIR__ . '/packet/'.$FileID.'.packet'.$count.'.txt', $res . PHP_EOL, FILE_APPEND);
    file_put_contents(__DIR__ . '/log.txt', 'PUT DATA' . PHP_EOL, FILE_APPEND);
 
      $load = $this->putData($res,$profile); print_r('PUT DATA --<br>');
      $res = '[';
     
  }
file_put_contents(__DIR__ . '/log.txt', 'PUT CONFIRM' . PHP_EOL, FILE_APPEND);
print_r('END LOAD DATA<br>');
$resul=$this->putConfirm($FileID,$count,$profile);print_r('PUT CONFIRM <br>');
if ($resul==$count){
  //$sql = "DELETE FROM PHARMIT_OUT where PROFILE_ID=".$profile;
 // $sth = ibase_prepare($sql); 
 // ibase_execute($sth);
  $this->message_to_telegram($GLOBALS["LOGINS"][$profile].' выгружено в PharmIT - '.$resul.' записей успешно');
}
else
{
  $this->message_to_telegram($GLOBALS["LOGINS"][$profile].' загружено в PharmIT - '.$resul.'из '.$count.' записей не успешно'); 
}

}      
 function initdata_decade($datestart,$type)
{   if (isset($datestart)) {$currentdate = $datestart;}else {$currentdate=date;}
  $format = 'Ymd';
  $currentdate = DateTime::createFromFormat($format, $currentdate);
  if ($type==1) {$period=10;}
  elseif ($type==2){$period=20;}
  elseif ($type==0){$period=30;}

  $startdate = $currentdate-$period;
  $currentdate =$currentdate->format('d.m.Y');
  $startdate =$startdate->format('d.m.Y'); 


$sql = "EXECUTE PROCEDURE PR_PHARMIT_OUT_DECADE(?,?)";
$sth = ibase_prepare($sql); 
ibase_execute($sth,$startdate,$currentdate);

}

function CompileDecadePacket($datesale,$profile=null,$month=null)
//$datesale 20191004
{
    
//проверяем указан ли профиль в противном случае выводим все без фильтрации
if (isset($profile)){
  $sql="SELECT  * from PHARMIT_OUT_DECADE where PROFILE_ID=".$profile;} 
else
  {$sql="SELECT  typeid,tender,goodname,producername,pharm, pharmaddress,Barcode,quantity from PHARMIT_OUT_DECADE
group by typeid,tender,goodname,producername,pharm, pharmaddress,Barcode,quantity";}

$datestart = DateTime::createFromFormat('Ymd',$datesale);


$day = $datestart->format('d');
if ($day >24){$decade='2';}
elseif ($day>14){$decade='1';}

//Определяем Выгрузка за месяц или декадная
if (isset($month))
    {$prefix = 'MonthSale:';
     $datesale = $prefix.$datestart->format('Ym');$decade=0;}
     // {MonthSale:202011} YYYYMM
else {$prefix='DecadeSale:';
     $datesale=$prefix.$datestart->format('Ym').$decade;}
     // {DecadeSale:2020112}YYYYMMD

//запускаем сбор данных для выгрузки
$this->initdata_decade($datestart->format('d.m.Y'),$decade);

$maxpacket = $GLOBALS["MAX_PACKET"]; 
//POST https://api.pharmit.kz/api/loadhistories/ 
$FileID=$this->getFileID($datesale,$profile);


$count = 0;$count_pac = 0;
$sth = ibase_prepare($sql); 
$result=ibase_execute($sth);
$res='[';
  while ($row=ibase_fetch_row($result))
{
            $str ='{"typeid":"'.$row[0].'",
                   "Tender":"'.$row[1].'", 
                   "GoodName":"'.str_replace('"','',iconv("cp1251", "utf-8",$row[2])).'",
                   "ProducerName":"'.str_replace('"',' ',iconv("cp1251", "utf-8",$row[3])).'",
                   "Pharm":"'.str_replace('"','',iconv("cp1251", "utf-8", $row[4])).'",
                   "Pharmaddress":"'.str_replace('"','',iconv("cp1251", "utf-8", $row[5])).'",
                   "Barcode":"'.$row[6].'",
                   "Quantity":"'.$row[7].'"
                
              }
               ' ;     
            $res = $res.$str.',';
            $count++;$count_pac++;
                    
            if ($count_pac == $maxpacket) 
                    {print_r('<bt>'.$count_pac.'<br>');
                  $res = substr($res,0,-1);
                  $res = $res.']';
        
                  $load = $this->putData($res,$profile);print_r('PUT DATA <br>');
                  $res = '[';
                  $count_pac = 0;
             }

}
 if (($count_pac!=$maxpacket)or($count_pac!=0)){ print_r('<bt>'.$count_pac.'<br>');
    $res = substr($res,0,-1);
    $res = $res.']'; 
      $load = $this->putData($res,$profile); print_r('PUT DATA <br>');
      $res = '[';
     
  }
print_r('PUT CONFIRM <br>');
$resul=$this->putConfirm($FileID,$count,$profile);
if ($resul==$count){
  if (isset($profile)){
  // $sql = "DELETE FROM PHARMIT_OUT where PROFILE_ID=".$profile;}
  // else {$sql = "DELETE FROM PHARMIT_OUT ";}
  $sth = ibase_prepare($sql); 
  ibase_execute($sth);
  $this->message_to_telegram('фармаком'.' выгружено в PharmIT - '.$resul.' записей успешно');
}
else
{
  $this->message_to_telegram('Farmakom'.' загружено в PharmIT - '.$resul.'из '.$count.' записей не успешно'); 
}

     

}


}
?>
