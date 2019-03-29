<?php
if ($_SERVER['REQUEST_METHOD']=='POST'){
	$nameserver = $_POST['nameserver'];
	$url = $_POST['url'];	
}
include('./engine/user.lib.php');
$user = new userclass();
$user->init();  
 $db=$user->db;

$SQL='INSERT INTO SERVERNAME (nameserver,url,sort,timeserver,status) values("'.$nameserver.'","'.$url.'",10,0,0)';
$db->query($SQL);

header("Location:./serverlist.php");
?>