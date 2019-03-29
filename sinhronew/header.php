<?php
include('./engine/user.lib.php');
$user = new userclass();
$user->init();  

header('Content-Type: text/html; charset=utf-8');
echo'<head><link rel="stylesheet" href="./css/app.css">
 <link rel="stylesheet" href="./css/style.css">
 <script src="./js/jquery.min.js"></script>
   <script src="./js/popper.min.js"></script>
     <script src="./js/bootstrap.min.js"></script>
     <link rel="shortcut icon" href="favicon.ico">
 <title>Управление клиентами Стандарт-Н  </title>    
</head>';
 $db=$user->db;

 

  $s='SELECT COUNT(id) FROM MALOHOD where CAST(dt as Date)<CURRENT_DATE ';  
  $malohod=$db->getone($s);
  if ($malohod!=0){$count=$malohod;}else {$count='';}
 
 print_r($user->html_menu); 

 

?>