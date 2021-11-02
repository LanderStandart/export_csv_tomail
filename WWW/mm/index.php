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
<title>Стандарт-М:: Сводный менеджер</title>
<link href="_res/_main.css" rel="stylesheet" type="text/css">
<?php echo $user->html_head; ?> 
</head>
<body>
<div class="header"><?php echo $user->html_header; ?></div>
<div class="menu"><?php echo $user->html_menu; ?></div>
<div class="wrap">
  <div id="d_content" class="content"><?php echo $user->html_content; ?></div>
</div>
<div class="bottom">НВП Стандарт-Н</div>
</body>
</html>
