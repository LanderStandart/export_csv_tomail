<?php
if ($_SERVER['REQUEST_METHOD']=='POST'){
	$id = $_POST['prof_id'];		
}
include('./engine/user.lib.php');
$user = new userclass();
$user->init();  
 $db2=$user->db;
  $SQL='DELETE FROM SERVERNAME where id='.$id;
$db2->query($SQL);
$SQL='SELECT max(id) FROM SERVERNAME';
$inc=$db2->getone($SQL)+1;
$SQL='ALTER TABLE SERVERNAME AUTO_INCREMENT = '.$inc;
$db2->query($SQL);

header("Location:serverlist.php");


?>