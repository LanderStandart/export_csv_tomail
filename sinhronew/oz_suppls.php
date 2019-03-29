<?php
 include('./header.php');
echo'<div class="row" style="min-height:1rem"> </div>';

echo '<div class="row" style="min-height:15rem" >';
echo '<div class="col-3" style="font-size: 1.2rem;">';
echo '<div>Поставщики:</div> </div>';

echo '<div class="col-8">';
echo'<div class="table-row">';

$supp=$db->query('SELECT name,id FROM SUPPLIERS ');

$send='<img src=./images/send.png width=15rem>';
$receiv='<img src=./images/receiv.png width=15rem>';
$price='<img src=./images/price.png width=15rem>';
while ($row=mysqli_fetch_row($supp)) {
		$status=$db->query('SELECT send,receiv,price FROM SUPPLIERS where id='.$row[1]);
		while ($row1=mysqli_fetch_row($status)) {
			$sendID=$row1[0];
			$receivID=$row1[1];
			$priceID=$row1[2];
			if ($sendID==1){$send='<img src=./images/send.png width=15rem>';}else{$send='';}
			if ($receivID==1){$receiv='<img src=./images/receiv.png width=15rem>';}else{$receiv='';}
			if ($priceID==1){$price='<img src=./images/price.png width=10rem>';}else{$price='';}
		}
		echo '<button class="btn btn-outline-dark" style="width:150px;margin:3px">'.$price.$send.$receiv.$row[0].'</button>';
}


?>