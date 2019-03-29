<?php
 include('./header.php');
echo'<div class="row" style="min-height:1rem"> </div>';

echo '<div class="row" style="min-height:15rem" >';
echo '<div class="col-3" style="font-size: 1.2rem;">';
echo '<div>Клиенты:</div> </div>';

echo '<div class="col-8">';
echo'<div class="table-row">';

$clients=$db->query('SELECT name,id FROM OZ_CLIENTS where p_id=0');


while ($row=mysqli_fetch_row($clients)) {
		echo '<a href=./oz_client.php?id='.$row[1].'><button class="btn btn-outline-dark" style="width:150px;margin:3px">'.$row[0].'</button></a>';
}


?>