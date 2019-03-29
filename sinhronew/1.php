<?php
   $str1 = "мкр.Карасу, ул.Озерная 137А";
   $str2 = "Алматы Озерная 137 А";
      $var = similar_text($str1,$str2);
   $var1 = similar_text($str1, $str2, $tmp);
   // параметр $tmp передаем по ссылке
   echo('езультат выполнения функции similar_text() для строк $str и $str1 в количестве символов:');
   echo("<br>"); echo("$var"); echo("<br>");
   echo("и в процентах:"); echo("<br>");
   echo($tmp); // для вывода информации в процентах обращаемся к $tmp
?>