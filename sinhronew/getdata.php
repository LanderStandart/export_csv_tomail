<?php
include('./engine/user.lib.php');
$user = new userclass();
$user->init();  
$db=$user->db;

$now=$db->getOne('SELECT updatenow FROM UPDATE_TIME');
  $currentdate=new \DateTime (date ("Y-m-d H:i:s"));
      $currentdate->settimezone(new DateTimeZone('Europe/Samara'));

//if ($now==0){

//$db->query('UPDATE UPDATE_TIME set updatenow=1');
//include('mysql.php');
 $opts = array(
     'host'    => '192.168.67.239',
     'user'    => 'zclientxp',
     'pass'      => 'Rjk.itdj',
     'charset'   => 'cp1251',
     'db'      => 'zclientxp'
  );
 //Получаем данные по малоходовке
  $db1 = new SafeMySQL($opts);
  $s =  "select ";
  $s .= "c.client_name as caption, z.post_id as id, max(z.insert_dt) as dt ";
  $s .= "from zprice_info z ";
  $s .= "left join zclients c on c.id=z.post_id ";
  $s .= "where 1=1 ";
  $s .= "and z.status=0 ";
  $s .= "and z.post_id in (844,934,935,699,922,1248) ";
  $s .= "group by z.post_id ";
  $s .= "order by max(z.insert_dt) asc ";
$malohod=$db1->query($s);

while ($row4=mysqli_fetch_row($malohod)) {
  
  $caption=iconv('cp1251','utf-8',$row4[0]); $post_id=iconv('cp1251','utf-8',$row4[1]); $dt=iconv('cp1251','utf-8',$row4[2]);
  //$db->query('INSERT into MALOHOD (caption,post_id,dt) VALUES ("'.$caption.'",'.$post_id.',"'.$dt.'")'); 
  $db->query('UPDATE MALOHOD set dt="'.$dt.'" where post_id='.$post_id.';');
 }

libxml_use_internal_errors(true);
$start = microtime(true);
$sort =0;
$server_update=false;

function check_domain_availible($domain)
  {
  if (!filter_var($domain, FILTER_VALIDATE_URL))
    return false;

  $curlInit = curl_init($domain);
  
  curl_setopt($curlInit, CURLOPT_CONNECTTIMEOUT, 10);
  curl_setopt($curlInit, CURLOPT_HEADER, true);
  curl_setopt($curlInit, CURLOPT_NOBODY, true);
  curl_setopt($curlInit, CURLOPT_RETURNTRANSFER, true);
  $code=11;
  $response = curl_exec($curlInit);
  if (!curl_errno($curlInit)){ $code = curl_getinfo($curlInit,CURLINFO_HTTP_CODE);}

  curl_close($curlInit);
  
  if (($response)and($code!==404)and ($code!==502))
   //if ($response)
    return true;
  return false;
  }



function CheckStatus($url,$db,$name,$server_update,$idserv){//Запрашиваем у сервера синронизации клиента его статус
  if (check_domain_availible($url)!== FALSE){
      $sort=10;
  //        Определяем текущее время и время обновления данных
      $currentdate=new \DateTime (date ("Y-m-d H:i:s"));
      $currentdate->settimezone(new DateTimeZone('Europe/Samara'));
      $xml=simplexml_load_file($url);
      
  if (isset($xml->nameserver)){  
         $nameserver=$xml->nameserver;
         $timeserver=$xml->timeserver;
         $db->query('UPDATE SERVERNAME set sort=10, status=1,timeserver="'.$timeserver.'" where url="'.$url.'"');
         // if ($server_update){
         //     $command="INSERT INTO SERVERNAME (nameserver,timeserver,url,sort) values('".$nameserver."','".$timeserver."','".$url."',10)";
         //       $db->query($command);}
            
          foreach ($xml as $profile) {
              if ($profile->id >0) {
                  $timeserv=new \DateTime ($profile->date);
                  $timeserv->settimezone(new DateTimeZone('Europe/Samara'));
                  $diff1=($currentdate->diff($timeserv));
      $diff1=$diff1->days;
                  //Cортировка по времени последнего пакета
                  $sprofile=$profile->sprofile;
                  $sprofile=str_replace("\"", "", $sprofile);
                   if ($profile->flag<0){$sort=2;} elseif (($diff1>30)and ($sort>8)) {$sort=9;} elseif (($diff1>7)and ($sort>6)) {$sort=6;}elseif (($diff1>1)and ($sort>3)) {$sort=3;}elseif ($diff1<=1){$sort=5;}
                   // $sql='SELECT count(status) FROM SIN_STAT_PROFILES where SIN_STAT_PROFILES.idserv='.$id.' and SIN_STAT_PROFILES.status=0';
                   // if ($db->getone($sql) )
                    if ($profile->vip){$command="INSERT INTO SINHRO_TMP  (data,nameserver,timeserver,profile_id,profile_name,flag,url,status,sort,vip,idserv) VALUES (\"".$profile->date."\",\"".$nameserver."\",\"".$timeserver."\",".$profile->id.",\"".$sprofile."\",".$profile->flag.",\"".$url."\",\"".$profile->status."\",".$sort.",".$profile->vip.",".$idserv.")";} 
                     else {
                    $command="INSERT INTO SINHRO_TMP  (data,nameserver,timeserver,profile_id,profile_name,flag,url,status,sort,vip,idserv) VALUES (\"".$profile->date."\",\"".$nameserver."\",\"".$timeserver."\",".$profile->id.",\"".$sprofile."\",".$profile->flag.",\"".$url."\",\"".$profile->status."\",".$sort.",0,".$idserv.")";
                    }
                 
                 if ($db->query($command)) ;
              
              }
          }
           
  }}
      else{
        $command="UPDATE SERVERNAME set status=0 where url='".$url."' ; ";
        $db->query($command);
          } 
} 

function getDataAll($id,$user,$db,$server_update){

$user->logFile('Start getdate');
 $db->query("DELETE FROM SINHRO_TMP WHERE idserv=".$id);
$user->logFile('clear table SINHRO_TMP'); 
//if ($id==1) {include('get_llt.php');}
//include('get_llt.php');
//$user->logFile('GetLLT');
//print_r($diffmin);
 //if ($server_update){$db->query("TRUNCATE TABLE SERVERNAME ");}   
 $links = $db->query('SELECT url,id,nameserver from SERVERNAME where id='.$id);       
   while($row=mysqli_fetch_row($links)){
    CheckStatus($row[0],$db,$row[2],$server_update,$row[1]);  
    $user->logFile('Get '.$row[2].' from '.$row[0]);
    }
 
$user->logFile('Clear SINHRO');
$db->query("DELETE FROM SINHRO WHERE idserv=".$id);
$user->logFile('Insert new data in SINHRO');
$db->query('INSERT INTO SINHRO (profile_id,profile_name,nameserver,timeserver,data,flag,sort,vip,url,status,idserv) SELECT profile_id,profile_name,nameserver,timeserver,data,flag,sort,vip,url,status,idserv FROM SINHRO_TMP where idserv='.$id); 
$user->logFile('End GetDate');
}


if ($db->getOne('SELECT updatenow from UPDATE_TIME')=='0'){
$db->query('UPDATE UPDATE_TIME set updatenow=1'); 
 $links = $db->query('SELECT url,id,nameserver from SERVERNAME');       
   while($row=mysqli_fetch_row($links)){
    getDataAll($row[1],$user,$db,$server_update); 
    $user->logFile('Get '.$row[2].' from '.$row[0]);
    }
include('get_llt.php');
  $command="UPDATE UPDATE_TIME set LASTUPDATE='".$currentdate->format('Y-m-d H:i:s')."';";
           $db->query($command);
$db->query('UPDATE UPDATE_TIME set updatenow=0');            }

header("Location:./index.php");

//}