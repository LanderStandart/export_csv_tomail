<?php
//Формируем страницу вывода данных

//Создаем подключение к БД
//include('mysql.php');
 include ('./header.php');

//  $db = new SafeMySQL($opts);
$color='';
$currentdate=new \DateTime (date ("Y-m-d H:i:s"));
$currentdate->settimezone(new DateTimeZone('Europe/Samara'));
echo'<div class="row" style="min-height:1rem"> </div>';
echo '<div class="row" style="min-height:15rem" >';

echo'<div class="col-3" style="font-size: 1.2rem;">Актуальность прайсов малоходовки:</div>';
echo '<div class="col-8">';
echo'<div class="table"><table class="table profile" style="margin-left:15px">';
echo '<tr  style="background-color: #d3dbe0">
      <th> ID </th>
      <th style="width:20rem"> Профиль</th>
      <th> Дата обновления </th></tr>';
  $malohod=$db->query('SELECT caption,post_id,dt from MALOHOD');

  while ($row=mysqli_fetch_row($malohod)) {
  	$dataUPD= new \Datetime ($row[2]);
    $diff=$currentdate->diff($dataUPD); 
                  $per=$diff->days;
                  $perH=$diff->h;
    if (($per>0)or ($perH>10)){$color=' style="background-color: antiquewhite"';}else {$color=' style="background-color: #f2f3f0"';}
echo '<tr'.$color.' ><td>'.$row[1].'</td> <td>'.$row[0].'</td>'; echo '<td>'.$dataUPD->format('d-m-Y H:i:s').'</td></tr>';  	
  	
  }


echo ""; 
echo "</table>"; 
echo "</div></div></div>"; 

//$db->close();
echo '<a href=./index.php><button class="btn btn-outline-secondary"  style="width:300px"> <<Назад </button></a>';
echo'<div style="width:100%"><hr></div>';
echo'<div class="footer">';


echo '</div>';
echo "</div></body>";

?>