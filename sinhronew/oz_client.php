<?php
 include('./header.php');
 $id=$_GET['id'];
echo'<div class="row" style="min-height:1rem"> </div>';

echo '<div class="row" style="min-height:15rem" >';
echo '<div class="col-3" style="font-size: 1.2rem;">';
echo '<div>Клиенты:</div> </div>';

echo '<div class="col-8">';
echo'<div class="table-row">';

$clients=$db->query('SELECT name FROM OZ_CLIENTS where p_id='.$id);
echo '<table class="table profile" >';

while ($row=mysqli_fetch_row($clients)) {
		echo '<tr><td class="profID">'.$row[0].'</td></tr>';
}


?>