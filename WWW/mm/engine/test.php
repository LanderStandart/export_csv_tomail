<?php
//<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
//<meta http-equiv="Content-Language" content="ru" />
//проверка
  include_once("../declare.php");
  function init(){
    session_start();
//    if (!isset($_SESSION["user_ip"])){throw new Exception("error: wrong session");}
//    if ($_SESSION["user_ip"]!=$_SERVER["REMOTE_ADDR"]) {throw new Exception("error: another session");}
    if (!isset($_SESSION["LAST_SNAME"]))//{throw new Exception("error: wrong session (sname)");}
	{
	  $sname="";
	}else{
	  $sname=$_SESSION["LAST_SNAME"];
	}
	if (!isset($_SESSION["LAST_GLOBAL_ID"]))//{throw new Exception("error: wrong session (GLOBAL_ID)");}
	{
	  $global_id=0;
	}else{
	  if (!is_numeric($_SESSION["LAST_GLOBAL_ID"])){throw new Exception("error: wrong format (GLOBAL_ID)");}
      $global_id=$_SESSION["LAST_GLOBAL_ID"];
	}
	if (!isset($_SESSION["LAST_NUM"]))//{throw new Exception("error: wrong session (num)");}
	{
	  $num=0;
	}else{
	  if (!is_numeric($_SESSION["LAST_NUM"])){throw new Exception("error: wrong format (LAST_NUM)");}
      $num=$_SESSION["LAST_NUM"];
	}
	if (!isset($_SESSION["QUERY"]))//{throw new Exception("error: wrong session (num)");}
	{
	  $query="";
	}else{
      $query=" and ";
	}
	
	
    $db = ibase_pconnect($GLOBALS["DB_DATABASENAME"], $GLOBALS["DB_USER"], $GLOBALS["DB_PASSWD"]) or die("db connect error " . ibase_errmsg());
	$trn = ibase_trans(IBASE_WRITE + IBASE_COMMITTED + IBASE_REC_VERSION + IBASE_NOWAIT, $db) or die(" error start transaction".ibase_errmsg());
	$sql="select
  first 100
  wb.global_id,
  wb.mmbsh,
  (select p.caption from g$profiles p where p.id=wb.g$profile_id) as sprofile_id,
  sname,
  wb.seria,
  wb.quant,
  wb.price_o,
  wb.nac,
  wb.price,
  wb.bcode_izg,
  wb.godendo,
  wb.docagent,
  wb.docdate
from
WAREBASE_G wb
where (sname>? and GLOBAL_ID>?)
 and sname containing 'оправа'
order by SNAME,GLOBAL_ID";
  }
//  init();
//  echo '<div>112233</div>';
print_r $sql;
  echo '<tr>
  <td>12</td>
  <td>34</td>
  <td>56</td>
</tr>
';
?>