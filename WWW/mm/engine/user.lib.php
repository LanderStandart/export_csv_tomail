<?php
//<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
//<meta http-equiv="Content-Language" content="ru" />
// кодировка должна быть уникод utf-8
/*
http://apur.standart-n.ru/sinhro/engine/mm

*/
include_once("declare.php");

class userclass{
  var $id = 0;
  var $fio = "";
  var $username = "";
  var $db;
  var $default_trn;
  var $user_ip;
  var $html_header;
  var $html_menu;
  var $html_content;
  var $html_head = "";
  
  function init(){
    session_start();
    $this->db = ibase_connect($GLOBALS["DB_DATABASENAME"], $GLOBALS["DB_USER"], $GLOBALS["DB_PASSWD"]) or die("db connect error " . ibase_errmsg());
	$this->default_trn = ibase_trans(IBASE_WRITE + IBASE_COMMITTED + IBASE_REC_VERSION + IBASE_NOWAIT, $this->db) or die(" error start transaction".ibase_errmsg());
	$this->html_header=file_get_contents("engine/res/header_def.php");
    if (!$this->checkuser()){ return;}
	$this->initobj();
	if (isset($_GET["warebase"])){$this->setcontent_warebase(); return;}
  }
function setcontent_regfrm($user_name, $error_msg){
  if ($user_name==""){
    if (isset($_SESSION["user_name"])){$user_name=$_SESSION["user_name"];}
  }
  $this->html_content=file_get_contents("engine/res/form_login.php");
  $this->html_content=str_replace(":=user_name=:",$user_name,$this->html_content);
  $this->html_content=str_replace(":=error_msg=:",$error_msg,$this->html_content);
}
function setheader(){
  $this->html_header=file_get_contents("engine/res/header.php");
  if ($this->fio=="") {$this->fio=$this->username;}
  $this->fio=iconv('windows-1251', 'utf-8', $this->fio);
  $this->html_header=str_replace(":=user_caption=:",$this->fio,$this->html_header);
}
function setmenu(){
  $this->html_menu=file_get_contents("engine/res/menu.php");
}
function query($trn, $sql){
  if ($trn==0){$trn=$this->default_trn;}
  return ibase_query($trn,$sql) or die(" error prepare ".ibase_errmsg()."(".$sql.")");
//  $res = ibase_execute($q,$_POST["MACHINEUUID"],$_POST["SHIFT_ID"]) or die(" error exec ".ibase_errmsg()."(".$sql.")");
}
function initobj(){
  $q=ibase_query($this->default_trn,"select username, fio from sp\$users where id=".$this->id);
  $row=ibase_fetch_row($q);
  $this->username=$row[0];
  $this->fio=$row[1];
  $this->setheader();
  $this->setmenu();
}

  function codebykey($s, $key)
  {
	$l=strlen($s);
	$k=strlen($key);
	$i=0; $t=0; $rtn="";
	while ($i<$l)
	{
	  $c=ord($s[$i]) ^ ord($key[$t]);
	  if ($c>30) {$rtn.=chr($c);}
//	  $s[$i]=chr(ord($s[$i]) ^ ord($key[$t]));
      $i++; $t++;
      if ($t>=$k) {$t=0;}  
	}
	return $rtn;
  }
  
function DateTimeToUnixTime($DelphiDate) {
  $SecPerDay = 86400;
  $Offset1970 = 25569;
  return abs(($DelphiDate - $Offset1970) * $SecPerDay);
}
  

function checkcurhour($s){
  $s=$this->codebykey($s,"kso*je3Jhj+");
  $d=$this->DateTimeToUnixTime($s/10000);
//  $srvtime = mktime() + 4*60*60;
  $srvtime = time()+ 4*60*60;
//  echo "client= ".$d."; srv-10= ".($srvtime-(15*60))."; srv+10=".($srvtime+(15*60))."  [".date("Y-m-d H:i:s",$d)." -- ".date("Y-m-d H:i:s",$srvtime)." -- ".date("Y-m-d H:i:s")."]";
  return (($d>=($srvtime-(15*60))) && ($d<=($srvtime+(15*60)))); 
}

function checkuser()
{
 try{ 
  if (isset($_GET["logout"])){ ibase_close($this->db); session_destroy(); throw new Exception("");}
  
  if (isset($_GET["prgkey"])){
    if ($this->checkcurhour($_GET["prgkey"])){
	$_SESSION["user_id"]=-100;
	$this->id=-100;
	$_SESSION["user_ip"]=$_SERVER["REMOTE_ADDR"];
//    $this->html_content="авторизация программа...".$this->showcurhourX($_GET["prgkey"]); 
	return true;   
	}else{
	  throw new Exception("Ошибка: не действительный код программы!");
	}
  }
  
  if (isset($_POST["user_name"])) {
    $_POST["user_name"]=trim($_POST["user_name"]);
	$_SESSION["user_name"]=$_POST["user_name"];
//	setcookie("user_name",$this->user_name,time()+3600000);
    if ($_POST["user_name"]=="") {throw new Exception("Ошибка: не введено имя пользователя!");}
    $psw=strtoupper(md5($_POST["user_psw"]));
	$prep=ibase_prepare($this->default_trn,"select id, status from SP\$USERS where username=? and USERPSW=? or (USERCODE=?)");
    $q=ibase_execute($prep,$_POST["user_name"],$psw,$psw);
	if (!$row=ibase_fetch_row($q)){throw new Exception("Ошибка: Неверное сочетание имени пользователя и пароля!");}
	if ($row[1]!=0){throw new Exception("Ошибка: Учетная запись отключена!");}
	$_SESSION["user_id"]=$row[0];
	$this->id=$row[0];
	$_SESSION["user_ip"]=$_SERVER["REMOTE_ADDR"];
//	$this->initobj();
    $this->html_content="авторизация...";
	return true;
  }
  else 
  {
    if (!isset($_SESSION["user_ip"])){throw new Exception("");}
    if ($_SESSION["user_ip"]==$_SERVER["REMOTE_ADDR"]) { // сессия начата, IP совпадает - продолжаем инициализацию
	  $this->id=$_SESSION["user_id"];
//	  $this->initobj();
      $this->html_content="авторизация - OK";
	  return true;
	}
    $this->setcontent_regfrm("","");
	return false;
  }
 } catch(Exception $e){
   $this->setcontent_regfrm("",$e->getMessage());
   return false;
 }
} 
function setcontent_warebase(){
  $this->html_head.="
<link href=\"_res/_table_wb.css\" rel=\"stylesheet\" type=\"text/css\">
<script type=\"text/javascript\" src=\"_res/ajax.js\"></script>";
  $this->html_content=file_get_contents("engine/res/warebase.php");
  if (isset($_GET["query"])){
    $s=iconv('windows-1251','utf-8', trim($_GET["query"]));
	$this->html_content.="<script type=\"text/javascript\"> wb_query.query.value=\"".$s."\"; resetWBTable(warebase_table); getAjax('engine/ajax_wb.php?query=".urlencode($s)."',warebase_table);</script>";
  }
  
}
}
?>