<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<?php
//<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
//<meta http-equiv="Content-Language" content="ru" />
// кодировка должна быть уникод utf-8
//http://cf:8080/kzf/mastermanager/
  include_once("engine/user.lib.php");
  $user = new userclass();
  $user->init();  
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="ru" />
<title>Стандарт-М:: Сводные остатки</title>
<link href="_res/_main.css" rel="stylesheet" type="text/css">
<?php echo $user->html_head; ?> 
</head>
<body>
<div class="wrap">
  <div id="d_content" class="content"><?php echo $user->html_content; ?></div>
</div>
</body>
</html>
