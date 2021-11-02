<?php
//<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
//<meta http-equiv="Content-Language" content="ru" />
//проверка
  include_once("../declare.php");
  
function ut_getfilter($qr,$field){
  if (trim($qr)==""){return "";}
  $b=$qr[0]==" ";
  $b=true;
  $a=explode(" ",$qr);
  $rtn="";
  for ($i=0;$i<sizeof($a);$i++)
  { //echo $i."=".$a[$i]."<br>";
    if (trim($a[$i])=="") {continue;}
	if ($b)
	{
	  $rtn.=$field." containing '".$a[$i]."' and ";
	}
	else
	{
	  $rtn.=$field." starting with '".$a[$i]."' and ";
	  $b=true;
	}
  }
  return substr($rtn,0,strlen($rtn)-5);
}
  
function getDetail($trn, $ware_id, &$izg, &$country, &$i, &$profiles_count, &$min_price, &$max_price){
  $sql="select
  wb.global_id,
  wb.mmbsh,
  (select p.caption from g\$profiles p where p.id=wb.g\$profile_id) as sprofile_id,
  wb.seria,
  round(wb.quant,2),
  round(wb.price_o,2),
  round(wb.nac,2),
  round(wb.price,2),
  wb.bcode_izg,
  iif((wb.godendo is null) or (wb.godendo<'2000-01-01'),'',(select s from UTPR_DATETOSTR(wb.godendo))),
  wb.docagent,
  iif((wb.docdate is null) or (wb.docdate<'2000-01-01'),'',(select s from UTPR_DATETOSTR(wb.docdate))),
  sizg,
  scountry
from warebase_g wb
where quant>0 and ware_id='".$ware_id."'
order by wb.g\$profile_id";  
//echo $sql;
  $q=ibase_query($trn,$sql) or die("error: query ".ibase_errmsg()." [".$sql."]");
  $rtn=""; $izg=""; $profiles_count=0; $min_price=999999999;$max_price=0; $last_profile_id="";
  while ($row=ibase_fetch_row($q)){
    $i++;
    $rtn.="<tr>
    <td class=\"t_profiles_td_odd\">".$row[2]."</td>
    <td>".$row[3]."</td>
    <td class=\"t_profiles_td_odd\">".$row[4]."</td>
    <td>".$row[5]."</td>
    <td class=\"t_profiles_td_odd\">".$row[6]."</td>
    <td>".$row[7]."</td>
    <td class=\"t_profiles_td_odd\">".$row[8]."</td>
    <td>".$row[9]."</td>
    <td class=\"t_profiles_td_odd\">".$row[10]."</td>
    <td>".$row[11]."</td>
  </tr>";
    if ($izg==""){$izg=$row[12]; $country=$row[13];}
	if ($min_price>$row[7]) {$min_price=$row[7];}
	if ($max_price<$row[7]) {$max_price=$row[7];}
	if ($last_profile_id!=$row[2]) {$profiles_count++;}
	$last_profile_id=$row[2];
  }
  if ($rtn=="") {return "";}
  $rtn=iconv('utf-8','windows-1251', "<table class=\"t_profiles\"><tr calss=\"t_profiles_header\"> 
    <td>Профиль</td>
    <td>Серия</td>
    <td>Остаток</td>
    <td>Закуп. цена</td>
    <td>Наценка</td>
    <td>Розн. цена</td>
    <td>ШК изг</td>
    <td>Годен до</td>
    <td>Контрагент</td>
    <td>Дата прихода</td>
  </tr>").$rtn."</table>";
  return $rtn;
}
  
  function init(){
    session_start();
    if (!isset($_SESSION["user_ip"])){throw new Exception("error: wrong session");}
    if ($_SESSION["user_ip"]!=$_SERVER["REMOTE_ADDR"]) {throw new Exception("error: another session");}
    $db = ibase_connect($GLOBALS["DB_DATABASENAME"], $GLOBALS["DB_USER"], $GLOBALS["DB_PASSWD"]) or die("db connect error " . ibase_errmsg());
	$trn = ibase_trans(IBASE_WRITE + IBASE_COMMITTED + IBASE_REC_VERSION + IBASE_NOWAIT, $db) or die(" error start transaction".ibase_errmsg());
	$num=0; 
    if (isset($_GET["query"])){ // новый запрос!
//	  echo "{".$_GET["query"]."}";
	  $query=iconv('utf-8', 'windows-1251', trim($_GET["query"]));
//	  echo "[".$query."]";
	  
	  $num=0;
	  if ($query=="") {$where="";}else{
	    $query=ut_getfilter($query,"sname");
		$where = " where ".$query;
	  }
	  $_SESSION["LAST_QUERY"]=$query;
	} else { // запрос продолжения списка
	  if (!isset($_SESSION["LAST_QUERY"])){die("error: LAST_QUERY");}
	  $query=$_SESSION["LAST_QUERY"];
      $sname=$_SESSION["LAST_SNAME"];
	  $num=$_SESSION["LAST_NUM"];
	  if ($num==-1) {return;}
	  $global_id=$_SESSION["LAST_GLOBAL_ID"];	
	  if ($query==""){
	    $where = " where SNAME>? and ID>? ";
	  }else{
	    $where = " where (".$query.") and (SNAME>? and ID>?) ";
	  }
	}	
	$sql="select id, sname from wares ".$where." order by sname, id";
//	echo $sql;
//	return;
    if ($num==0){
	  $q=ibase_query($trn,$sql) or die("error: query ".ibase_errmsg()." [".$sql."]");
	}else{
	  $prep=ibase_prepare($trn,$sql) or die("error: prepare ".ibase_errmsg()." [".$sql."]");
	  $q=ibase_execute($prep,$sname, $global_id);
	}
    $i=0;
	while ($row=ibase_fetch_row($q)){
	  $num++;
	  $global_id=$row[0];
	  $sname=$row[1];
	  $s=getDetail($trn, $row[0], $izg, $country,$i, $profiles_count, $min_price, $max_price);
	  if ($s==""){continue;}
	  $i++;
	  $s1="<b>".$sname."</b>";
	  if ($izg!=""){$s1.=", ".$izg;}
	  if ($country!=""){$s1.=", ".$country;}
	  $s1.= iconv('utf-8', 'windows-1251'," (профилей: <b>$profiles_count</b>, цены:  <b>$min_price - $max_price</b>)");
//	  $s="<tr><td><a href=\"#\" onClick=\"showHide(id_$num); return false;\">++</a></td><td>".$s1."</td></tr><tr id=\"id_$num\" style=\"display: none;\"><td></td><td>".$s."</td></tr>";
	  $s="<tr><td><a href=\"#\" onClick=\"showHide(id_$num); return false;\">++</a></td><td onClick=\"showHide(id_$num); return false;\">".$s1."</td></tr><tr id=\"id_$num\" style=\"display: none;\"><td></td><td>".$s."</td></tr>";
	  echo iconv('windows-1251', 'utf-8', $s);
	  if ($i>100) {break;}
	}
	if ($i>0){
	  $_SESSION["LAST_NUM"]=$num;
	  $_SESSION["LAST_SNAME"]=$sname;
	  $_SESSION["LAST_GLOBAL_ID"]=$global_id;		
	} else {
	  $_SESSION["LAST_NUM"]=-1;
	  $_SESSION["LAST_SNAME"]="";
	  $_SESSION["LAST_GLOBAL_ID"]="";
	  echo "Не найдено";
	}	
  }
  init();
//  echo '<div>112233</div>';
/*
select
  wb.global_id,
  wb.mmbsh,
  (select p.caption from g$profiles p where p.id=wb.g$profile_id) as sprofile_id,
  w.sname,
  wb.seria,
  wb.quant,
  wb.price_o,
  wb.nac,
  wb.price,
  wb.bcode_izg,
  wb.godendo,
  wb.docagent,
  wb.docdate
from wares w inner join warebase_g wb on w.id=wb.ware_id
 where w.sname containing 'оп' and w.sname containing '11'
 and w.sname>=' Оправа  Fortuna 038-F  (с 11/4)' and wb.global_id>4065154
order by w.sname, wb.global_id
*/
?>