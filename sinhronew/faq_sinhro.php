<?php
include('./header.php');
$html=file_get_contents("https://goo.gl/i4igox");
$delstr='<!DOCTYPE html>';
$html=str_replace($delstr,'',$html);
$delstr='<link rel="stylesheet" href="http://wiki.standart-n.ru/load.php?debug=false&amp;lang=ru&amp;modules=mediawiki.legacy.commonPrint%2Cshared%7Cmediawiki.skinning.interface%7Cmediawiki.ui.button%7Cskins.vector.styles&amp;only=styles&amp;skin=vector&amp;*" />';
$insstr='<link rel="stylesheet" href="http://wiki.standart-n.ru/load.php?debug=false&amp;lang=ru&amp;modules=mediawiki.legacy.commonPrint%2Cshared%7Cmediawiki.skinning.interface&amp;only=styles&amp;skin=vector&amp;*" />';
$html=str_replace($delstr,$insstr,$html);

$delstr='<div class="printfooter">';
$insstr='<!--<div class="printfooter">';
$html=str_replace($delstr,$insstr,$html);

$delstr='<!-- Yandex.Metrika counter --><script';
$insstr='--><!-- Yandex.Metrika counter --><script';
$html=str_replace($delstr,$insstr,$html);




echo "<div class='container'>";

echo $html;
echo "</div";
