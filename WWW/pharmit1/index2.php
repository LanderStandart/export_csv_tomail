<?php

include './engine/user.lib.php';
 $user = new userclass();
  $user->init();
$id=2;
//$GLOBALS["CLIENT_URL_FILE_ID"] токкен для загрузки
//$GLOBALS["CLIENT_URL_LOAD"] - запросить пропущенные данные
var_dump( $user->getQUERY('',1));



?>
