<?php
//Формируем страницу вывода данных
$id=$_GET['id'];
//Создаем подключение к БД
//include('mysql.php');
 include('./header.php');

$currentdate=$user->currentdate;

$url=$db->getone('SELECT url FROM SERVERNAME where id="'.$id.'"');
$nameserver=$db->getone('SELECT nameserver FROM SERVERNAME where id="'.$id.'"');
$status=$db->getone('SELECT status FROM SERVERNAME where id="'.$id.'"');
echo'<div class="row" style="min-height:1rem"> </div>';
echo '<div class="row" style="min-height:15rem" ><div class="col-3" style="font-size: 1.2rem;text-align:center"><div><img src="./images/server.png" ></div><div>'.$nameserver.'</div><div style="word-wrap: break-word;">';
echo "<a href=\"".$url."\" style=\"font-size:12px\">".$url."</a></div>";
if ($id==1){include('status_llt.php');}
echo'<a href="./getdata_client.php?id='.$id.'"> <img src="./images/update.png" </a></div>';

$sql='SELECT profile_name,profile_id,flag,status,data,sort,url,vip,idserv  FROM SINHRO where idserv="'.$id.'" and profile_id>0 and flag<>0 ORDER BY vip desc ,flag,sort ';
echo '<div class="col-8">';
echo'<div class="table">';

$result=$db->query($sql);
$sql='SELECT count(status) FROM SIN_STAT_PROFILES where SIN_STAT_PROFILES.idserv='.$id.' and SIN_STAT_PROFILES.status=1';
$profile_s=$db->getone($sql);
//$ns=$result->fetchArray();
echo '<table class="table profile" >';
if ((mysqli_num_rows($result)==0) and ($status==0) and ($profile_s==0)){include_once('./tmpl/bad.php');} 
  elseif ((mysqli_num_rows($result)==0) and ($status==1)and ($profile_s==0)) {include_once('./tmpl/good.php');} else {
while ($row=mysqli_fetch_row($result)) {
  $lastpackretdate=new \DateTime ($row[4]);       
  $diff=$currentdate->diff($lastpackretdate); 
  $per=$diff->days;
  $hour=$diff->h;
  $profile_status=$user->CheckProfile($row[8],$row[1]);

  if ($row[7]==1){$vip=' style="background-color: #ffd6d6;"';$vipN=' - VIP';}else {$vip='';$vipN=' style="background-color: #f2f3f0"';}
  
  if ($profile_status==0){echo '<tr class="profile"'.$vip.' >';}else{echo '<tr class="profileoff"'.$vip.' >';}
  if ($row[2]<0){echo '<td class="profID"><img src="./images/err.png" width=10px hspace=2px vspace=2px>';} 
  if (($row[2]>0) and ($per<1) and ($hour<3)){echo '<td class="profID"><img src="./images/timeok.png" width=10px hspace=2px vspace=2px>';}
  elseif (($row[2]>0) and ($per<1) and ($hour>3)){echo '<td class="profID"><img src="./images/timeok1.png" width=10px hspace=2px vspace=2px>';}      
  elseif (($row[2]>0) and ($per<7)){echo '<td class="profID"><img src="./images/time.png" width=10px hspace=2px vspace=2px>';}   
  elseif (($row[2]>0) and ($per>6)){echo '<td class="profID"><img src="./images/timedead.png" width=10px hspace=2px vspace=2px>';}  
  echo'Профиль ID:'.$row[1].' </td>'; 
  echo'<td>'.$row[0].'</td><td style="font:bold 12px arial"> '.$row[3].'</td><td>'.$lastpackretdate->format('d-m-Y H:i:s').'</td>';
  echo '<td>';
  if ($profile_status==0){echo'<a href="./cng_prf.php?idserv='.$row[8].'&profile_id='.$row[1].'&status=1"> <button type="button" style="padding:unset" class="btn btn-outline-light"><img src="./images/eyeon.png" width=20px hspace=2px vspace=2px title="Отслеживаем"></button></a>';}
   else{echo'<a href="./cng_prf.php?idserv='.$row[8].'&profile_id='.$row[1].'&status=0"><button type="button" style="padding:unset" class="btn btn-outline-light"><img src="./images/eyeoff.png" width=20px hspace=2px vspace=2px title="Неотслеживаем"></button></a>';}
  echo "</tr>";
}
 }
echo "</table>"; 
echo "</div>";echo "</div>"; echo "</div>"; 
 
echo'<div class="row" >';
//$db->close();
echo'<div class="col-3">';
echo '<a href=./index.php><button class="btn btn-outline-secondary"  style="width:300px"> <<Назад </button></a>';
echo'</div><div style="width:100%"><hr></div>';
echo'<div class="footer">';


echo '</div>';
echo "</div></body>";