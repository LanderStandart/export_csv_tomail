<?php
//Создаем подключение к БД
//include('mysql.php');



 include('./header.php');

 
if (isset($_GET['refresh'])) {$refresh=$_GET['refresh'];}else {$refresh=0;}
//Определяем текущее время и время обновления данных
//$currentdate=$user->currentdate;
echo '
<div class="row">
 <div class="col-8"></div>
  <div class="col-2">
   <div class="btn-group btn-group-toggle btn-sm" data-toggle="buttons" style="font-size:.6rem"> <span>Сортировка:&nbsp;</span> 
     <label class="btn btn-secondary active btn-sm" id="sort" style="font-size:.6rem" >
     <input type="radio" name="sort" id="sort" autocomplete="off" checked> Статус
     </label>
     <label class="btn btn-secondary btn-sm" id="abc" style="font-size:.6rem">
     <input type="radio" name="sort" id="option2" autocomplete="off"> АБС
     </label>
   </div>
  </div>
</div>
  ';

echo "
<script type=\"text/javascript\">

 $('#abc').click(function(){
     $('#content').load('./client.php?sort=abc');
   
 });
$('#sort').click(function(){
 $('#content').load('./client.php?sort=sort');
 });


</script>";

include ('./client.php');//echo "</div>";
include ('./footer.php');


 ?>