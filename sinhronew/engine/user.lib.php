<?php
include('mysql.php');
class userclass{
  var $db;
  var $currentdate;
  var $alert_upd;
  var $html_menu;
  var $count;
  var $freshDB;
  var $ListServ;
  var $ListServ1;


function init(){
	//session_start();
	$opts = array(
      'host'    => 'localhost',
      'user'    => 'homestead',
      'pass'      => 'bezparolya',
      'charset'   => 'utf8',
      'db'      => 'SINHRO'
  	);
	 $db = $this->db = new SafeMySQL($opts); 

	 $currdate=new \DateTime (date ("Y-m-d H:i:s"));
	 $currdate->settimezone(new DateTimeZone('Europe/Samara'));
	 $this->currentdate=$currdate;
	 $this->needUPD();$this->Malohod();
	 $this->SetMenu();
}


 function ServNameShort($nameserver){//Слова исключения из названия
  $nameserver=str_replace("Сеть",' ',$nameserver);
  $nameserver=str_replace("аптек",' ',$nameserver);
  $nameserver=str_replace("г. Шымкент",' ',$nameserver);
 return $nameserver;

 }

 function needUPD(){
	 $freshDB=$this->db->getOne('SELECT LASTUPDATE from UPDATE_TIME');
	 $freshDB=new \DateTime ($freshDB);

	 //$freshDB->settimezone(new DateTimeZone('Europe/Samara'));
	 $this->freshDB=$freshDB->format('d-m-Y H:i:s');
	 $diff1=$this->currentdate->diff($freshDB);
	 $diff_i=$diff1->i ;
	 $diff_h=$diff1->h;
  //  print_r($this->currentdate);
	 // print_r($diff_i.'<br>');
  //  print_r($diff_h);
	 if (($diff_i>10)or((abs($diff_h))>0)){$this->alert_upd='<a class="badge badge-danger" data-toggle="modal" data-target="#Update" href="#"> Обновить</a>';}else {$this->alert_upd='';}
	}

 function SetMenu(){
 	$this->html_menu=file_get_contents("./engine/menu.php");
  $UpdateNOW=$this->db->getOne('SELECT updatenow from UPDATE_TIME');
  if ($UpdateNOW==1){$this->alert_upd='<span class="badge badge-warning"> Обновляем</span>';
  $this->html_menu=str_replace(":=disabled=:",'disabled',$this->html_menu);}
  else{$this->html_menu=str_replace(":=disabled=:",' ',$this->html_menu);}
 	$this->html_menu=str_replace(":=alert_upd=:",$this->alert_upd,$this->html_menu);
 	$this->html_menu=str_replace(":=count=:",$this->count,$this->html_menu);

 	}
function logFile($textLog) {
  return;
$file = 'http://192.168.67.30/sinhronew/logs/logFile.txt';
$text = '=======================\n';
$text .= print_r($textLog);//Выводим переданную переменную
$text .= '\n'. date('Y-m-d H:i:s') .'\n'; //Добавим актуальную дату после текста или дампа массива
$fOpen = fopen($file,'a');
fwrite($fOpen, $text);
fclose($fOpen);
}

 function Malohod(){  
   $malohod=$this->db->getone('SELECT COUNT(id) FROM MALOHOD where CAST(dt as Date)<CURRENT_DATE');
   if ($malohod!=0){$this->count=$malohod;}else {$this->count='';}
 }
 function ListServ($sort,$where){
 	return $this->ListServ=$this->db->query('SELECT nameserver,status,sort,id FROM SERVERNAME '.$where.' ORDER BY '.$sort);
 }
 //  function ListServ1(){
 // 	return $this->ListServ1=$this->db->query('SELECT nameserver,status,sort,id FROM SERVERNAME ORDER BY nameserver');
 // }
function SumVIP($profile){
	return $this->db->getOne('SELECT SUM(vip) FROM SINHRO WHERE vip is not null and idserv="'.$profile.'"');
}

function CountFlag($profile){
	return $this->db->getOne('SELECT count(flag) FROM SINHRO WHERE  idserv='.$profile.' and (SELECT status FROM SIN_STAT_PROFILES where SIN_STAT_PROFILES.idserv=SINHRO.idserv and SIN_STAT_PROFILES.profile_id=SINHRO.profile_id)=0');
}

//OR ($this->CountFlag($row[3])>0)
function CountServ($profile){
  return $this->db->getOne('SELECT count(flag) FROM SINHRO WHERE  idserv='.$profile.'');
}
function CheckServ($id){
  return $this->db->query('SELECT status FROM SERVERNAME WHERE  id='.$id.'');
}
function CheckProfile($idserv,$profile){
  return $this->db->getOne('SELECT status FROM SIN_STAT_PROFILES WHERE  idserv='.$idserv.' and profile_id='.$profile.'');
}

function CorrStr($string) {
 $string=str_replace("\"", "", $string);
 return $string;
}
function GetClient($sort){
 //print_r($sort);
	//if ($sort!=='sort'){$sql=$this->ListServ('nameserver');}else{$sql=$this->ListServ('sort');}

  if ($sort=='sorte')
    {
      $sql=$this->ListServ('sort','where sort<>10');
    }elseif($sort=='abce'){$sql=$this->ListServ('nameserver','where sort<>10');} 
    elseif($sort=='abc'){$sql=$this->ListServ('nameserver','');}
    else {$sql=$this->ListServ('sort','');}
	while ($row=mysqli_fetch_row($sql)) {
  $timeok=0;$timedead=0;$time=0;$err=0;$timeok1=0;$ps=0;
  $vip=$this->SumVIP($row[3]);
  if ($vip>0) {$str=';background-color: #ffd6d6';} else {$str='';} //Если ошибка на профиле со статусом ВИП
  if (($row[1]==0) ) {$str=$str.';border-color: #ef0a1b;border-width: .1rem;';} else {$str=$str.'';} //нет связи с сервером
  if ($this->CountFlag($row[3])>0){$count=$this->CountFlag($row[3]);} else {$count='';}
  echo '<a href="./profiles.php?id='.$row[3].'" <button class="btn btn-outline-dark" style="width:155px;margin:3px'.$str.'"><div>'.$this->ServNameShort($row[0]).'</div>';
        if ($row[3]==1){
        $diff_min=$this->db->getone('SELECT diff_min from SIN_LLT where prof_id='.$row[3]);
        if ($diff_min>30){echo '<img src=./images/llt.png class="icon-status" style="width:.7rem">';}
        }

  if (($row[1]>0) and ($row[2]<10)){
  $stat=$this->db->query('SELECT flag,data from SINHRO where idserv='.$row[3].' and (SELECT status FROM SIN_STAT_PROFILES where SIN_STAT_PROFILES.idserv=SINHRO.idserv and SIN_STAT_PROFILES.profile_id=SINHRO.profile_id)=0');
   while($row1=mysqli_fetch_row($stat)){
     if (($row1[0]>0)and ($this->CountFlag($row[3])>0) ){
                  $lastpackretdate=new \DateTime ($row1[1]);       
                  $diff=$this->currentdate->diff($lastpackretdate); 
                  $per=$diff->days;
                  $hour=$diff->h;
                //  echo $per.'--'.$hour.'*';
                  if (($per<1)and($timeok==0) and ($hour<3)){echo '<img src=./images/timeok.png class="icon-status">';$timeok=1;}
                  elseif (($per<=1)and($timeok1==0) and ($hour>=3)){echo '<img src=./images/timeok1.png class="icon-status">';$timeok1=1; }
                  elseif (($per>1) and ($per<7)and ($time==0)){echo '<img src=./images/time.png class="icon-status">';$time=1;}
                  elseif (($per>7)and ($timedead==0)){echo '<img src=./images/timedead.png class="icon-status">';$timedead=1;}
                }
     if (($row1[0]== -1)and $err==0){echo '<img src=./images/err.png class="icon-status">';$err=1;}
                }
}elseif ($row[1]==0) {echo '<img src=./images/errserv.jpg class="icon-status">';$ps=1;} elseif ($row[2]==10) {echo '<img src=./images/ok.jpg class="icon-status">';$ps=1;}
if (($this->CountFlag($row[3])==0)and ($ps==0)) {echo '<img src=./images/ok.jpg class="icon-status">';
$sql1='UPDATE SERVERNAME set SORT=10 where id='.$row[3];
$dd=$this->db->query($sql1);}

echo '<span class="badge badge-light">'.$count.'</span></button></a>';

}  }
}
?>