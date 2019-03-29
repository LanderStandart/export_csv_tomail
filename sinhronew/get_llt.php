<?php


$url=$db->getone('SELECT url from SIN_LLT');


 

  if (check_domain_availible($url)!== FALSE){
   $xml=simplexml_load_file($url);
   
    $timeserver=$xml->timeserver;
    $updcard=$xml->updcard;
    $diffmin=$xml->diffmin;

   $db->query('UPDATE SIN_LLT set updcard="'.$updcard.'", timeserver="'.$timeserver.'", diff_min='.$diffmin);
   } 
  
    

 
?>