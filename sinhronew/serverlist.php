<?php
include('./header.php');

$url=$db->query('SELECT id,nameserver,url FROM SERVERNAME ');
echo'<div class="row" style="min-height:1rem"> </div>';
echo '<div class="row" >';
echo '<div class="col-3" style="font-size: 1.2rem;">Список серверов:<br></div>';
echo '<div class="col-8">';
echo'<div class="table">';
echo '<table class="table">';
while ($row=mysqli_fetch_row($url)) {
	echo '<tr class="profile" >';
	echo '<td class="profID" style="width:5%">'.$row[0].'</td>';
	echo '<td  style="width:25%">'.$row[1].'</td>';
	echo '<td  style="width:70%">'.$row[2].'</td>';
	echo'<td><a  href=""> <button data-toggle="modal" data-target="#EditServ" type="button" style="padding:unset" name="'.$row[0].'" class="btn btn-outline-light"><img src="./images/edit.png" width=15px  </button></a></td>';
	echo '</tr>';}
echo'</table></div>';
?>


<!-- The Modal -->
          <div class="modal" id="EditServ">
            <div class="modal-dialog">
              <div class="modal-content">

                <!-- Modal Header -->
                <div class="modal-header">
                  <h4 class="modal-title">Добавление нового сервера</h4>
                  <button type="button" class="close" data-dismiss="modal">&times;</button>

                </div>

                <!-- Modal body -->
                <form action="./editserv.php" method="post">
                  <div class="modal-body">
                  
                      <div class="form-group">
                        <label for="nameserver">Имя сервера:</label>
                        <input type="nameserver" class="form-control" name="nameserver" id="nameserver" value="xxx">
                      </div>
                      <div class="form-group">
                        <label for="url">URL:</label>
                        <input type="url" class="form-control" name="url" id="url">
                      </div>
                  </div>
                  <!-- Modal footer -->
                  <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Добавить</button>
                    <button type="button" class="btn btn-danger" data-dismiss="modal">Отмена</button>
                  </div>
                </form>
              </div>
            </div>
          </div>