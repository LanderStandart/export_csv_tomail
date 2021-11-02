<?php
// сюда нужно вписать токен вашего бота
define('TELEGRAM_TOKEN', '714403255:AAEFPWXntiPud-DleKI3HHG20qzbDN4ERdM');

// сюда нужно вписать ваш внутренний айдишник
define('TELEGRAM_CHATID', '483403057');

include_once("declare.php");

class userclass{
 var $db;
 var $default_trn;



 function init(){
  $this->db = ibase_connect($GLOBALS["DB_DATABASENAME"], $GLOBALS["DB_USER"], $GLOBALS["DB_PASSWD"]) or die("db connect error " . ibase_errmsg());
  $this->default_trn = ibase_trans(IBASE_WRITE + IBASE_COMMITTED + IBASE_REC_VERSION + IBASE_NOWAIT, $this->db) or die(" error start transaction".ibase_errmsg());
}

function query($trn, $sql){
  if ($trn==0){$trn=$this->default_trn;}
  return ibase_query($trn,$sql) or die(" error prepare ".ibase_errmsg()."(".$sql.")");
//  $res = ibase_execute($q,$_POST["MACHINEUUID"],$_POST["SHIFT_ID"]) or die(" error exec ".ibase_errmsg()."(".$sql.")");
}

function initdata($datestart)
{      $currentdate = $datestart;
  $format = 'Ymd';
  $currentdate = DateTime::createFromFormat($format, $currentdate);
  $currentdate =$currentdate->format('d.m.Y');
//$currentdate=date("d.m.Y", time() - 86400);
$sql = "EXECUTE PROCEDURE PR_PHARMIT_OUT(?)";
$sth = ibase_prepare($sql); 
ibase_execute($sth,$currentdate);

}

// function initdata()
// {
// $currentdate=date("d.m.Y", time() - 86400);
// $sql = "EXECUTE PROCEDURE PR_PHARMIT_OUT(?)";
// $sth = ibase_prepare($sql);	
// ibase_execute($sth,$currentdate);

// }

//получаем токен для передачи
function putConfirm($FileID,$count,$profile){
$base_url = $GLOBALS["CLIENT_URL_FILE_ID"];  
$url = $base_url."/".$FileID."_".$count;
print_r($url); 
$ch = curl_init();
curl_setopt_array($ch, array(
  CURLOPT_URL => $url,
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_SSL_VERIFYPEER => false,
  CURLOPT_SSL_VERIFYHOST => false,
  CURLOPT_ENCODING => "",
  CURLOPT_POSTFIELDS => "",
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_TIMEOUT => 30,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => "PUT",
  CURLOPT_HTTPHEADER => array(
    "Accept: */*",
    "Accept-Encoding: gzip, deflate",
    "Authorization: ".$GLOBALS["AUTORIZ"][$profile],
    "Cache-Control: no-cache",
    "Connection: keep-alive",
    "Content-Length: 0",
 
    "Host: api.pharmit.kz",
    "Postman-Token: d3cb4eb9-0575-45b5-bc43-d15597e3a180,7b27ba2f-10c8-47d0-b021-06d5d53bd816",
    "User-Agent: PostmanRuntime/7.16.3",
    "cache-control: no-cache"
  ),
));

$data = curl_exec($ch);

$err = curl_error($ch);

if ($err) {
  echo "cURL Error #:" . $err;
  return $err;
}
//$auth_string = json_decode($data, true);
return $data;

}

//GET-запрос
//$GLOBALS["CLIENT_URL_FILE_ID"] токкен для загрузки
//$GLOBALS["CLIENT_URL_LOAD"] - запросить пропущенные данные
function getQUERY($Data,$profile){ 
$base_url =$GLOBALS["CLIENT_URL_LOAD"];//$url;  

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
    "Accept: */*",
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
}



//получаем токен для передачи
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
    "Accept: */*",
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
}

function putData($Data,$profile)
{
$base_url = $GLOBALS["CLIENT_URL_LOAD"];    
$curl = curl_init();
curl_setopt_array($curl, array(
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
    "Accept: */*",
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

$response = curl_exec($curl);
$err = curl_error($curl);
$info = curl_getinfo($curl, CURLINFO_HTTP_CODE);
curl_close($curl);
if($info<>200){print_r($Data);print_r('<br>-------<br>');
  $this->message_to_telegram($Data);
}

if ($err) {
  echo "cURL Error #:" . $err;
  return $err;
} else {
	$respon = json_decode($response,true);
  return $respon;
}
}

function message_to_telegram($text)
{
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
$FileID=$this->getFileID($datesale,$profile);print_r('GET FILE_ID<BR>');
$sql="SELECT  * from PHARMIT_OUT where PROFILE_ID=".$profile;
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
              $res = $res.']';
              $load = $this->putData($res,$profile);print_r('PUT DATA <br>');
              $res = '[';
              $count_pac = 0;
            }

}
 if (($count_pac!=$maxpacket)or($count_pac!=0)){ 
    $res = substr($res,0,-1);
    $res = $res.']'; 
      $load = $this->putData($res,$profile); print_r('PUT DATA <br>');
      $res = '[';
     
  }
$resul=$this->putConfirm($FileID,$count,$profile);print_r('PUT CONFIRM <br>');
if ($resul==$count){
  $sql = "DELETE FROM PHARMIT_OUT where PROFILE_ID=".$profile;
  $sth = ibase_prepare($sql); 
  ibase_execute($sth);
  $this->message_to_telegram($GLOBALS["LOGINS"][$profile].' выгружено в PharmIT - '.$resul.' записей успешно');
}
else
{
  $this->message_to_telegram($GLOBALS["LOGINS"][$profile].' загружено в PharmIT - '.$resul.'из '.$count.' записей не успешно'); 
}

}      

}
?>
