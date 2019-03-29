<?php
include('./header.php');

//include('mysql.php');

$url=$db->query('SELECT id,nameserver,url FROM SERVERNAME ');
echo'<div class="row" style="min-height:1rem"> </div>';
echo '<div class="row" >';
echo '<div class="col-3" style="font-size: 1.2rem;">Список серверов:<br></div>';
echo '<div class="col-8">';
echo'<div class="table">';
echo '<table class="table">';
while ($row=mysqli_fetch_row($url)) {
	echo '<tr class="profile" >';
	echo '<td><form action="./ds.php" method="post">
		  <button type="submit"  class="btn btn-outline-danger btn-circle"
		   name="prof_id" id="prof_id" value='.$row[0].'   >X</button>
		   </form></td>';
	echo '<td class="profID" style="width:5%">'.$row[0].'</td>';
	echo '<td  style="width:25%">'.$row[1].'</td>';
	echo '<td  style="width:70%">'.$row[2].'</td>';
	echo '</tr>';}
echo'</table></div>';
 echo'
<!-- The Modal -->
<div class="modal" id="delser">
  <div class="modal-dialog">
    <div class="modal-content">

      <!-- Modal Header -->
      <div class="modal-header">
        <h4 class="modal-title id="delserLabel"">Удаление</h4>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">&times;</button>
      </div>
      
      <!-- Modal body -->
      <div class="modal-body">
        <form action="./ds.php" method="post">
       <div class="form-group">
      Удалить сервер 
  </div>
    
      </div>

      <!-- Modal footer -->
      <div class="modal-footer">
        <button type="submit" class="btn btn-primary">Удалить</button>
        <button type="button" class="btn btn-danger" data-dismiss="modal">Отмена</button>
      </div>
</form>
    </div>
  </div>
</div>';

?>