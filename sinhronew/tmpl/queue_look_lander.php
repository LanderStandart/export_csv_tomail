<?php
header('Content-Type: text/xml; charset=utf-8');

function convert($str){
  return iconv("Windows-1251","UTF-8",$str);}

$xw = xmlwriter_open_memory();
xmlwriter_set_indent($xw, 1);

$res = xmlwriter_set_indent_string($xw, ' ');
xmlwriter_start_document($xw, '1.0', 'utf-8');
xmlwriter_start_element($xw,"profiles");
xmlwriter_start_element($xw,"nameserver");
  xmlwriter_text($xw,"МедКом");
  xmlwriter_end_element($xw);
  

  

include("declare.php");

  $g_db = ibase_connect($GLOBALS["DB_DATABASENAME"], $GLOBALS["DB_USER"], $GLOBALS["DB_PASSWD"]) or die(" error fbdb connect ".ibase_errmsg());
  $it = ibase_trans(IBASE_WRITE + IBASE_COMMITTED + IBASE_REC_VERSION + IBASE_NOWAIT, $g_db) or die(" error start transaction".ibase_errmsg());
//$set =ibase_query("SET CMNT,PROFILE_ID,SPROFILE,EXEVER,INSERTDT,MSECS,ENDFLAG,ENDTEXT,VIP UTF8");

  $sqltext="select current_timestamp from rdb\$database";
  
  $qList = ibase_query($it, $sqltext);
  if (!$qList) {die(" error ".ibase_errmsg()."(".$sqltext.")");}
    $row = ibase_fetch_row($qList);

  xmlwriter_start_element($xw,"timeserver");
  xmlwriter_text($xw,$row[0]);
  xmlwriter_end_element($xw);



  
  $sqltext="select CMNT,PROFILE_ID,SPROFILE,EXEVER,INSERTDT,MSECS,ENDFLAG,ENDTEXT from UTPR_QUEUE_LOOK";
  $qList = ibase_query($it, $sqltext);
  if (!$qList) {die(" error ".ibase_errmsg()."(".$sqltext.")");}


  $i=0;
    while ($row = ibase_fetch_row($qList))
  {
  
  $i++;
  xmlwriter_start_element($xw,"profile");
   xmlwriter_start_element($xw,"id");
   xmlwriter_text($xw,convert($row[1]));
   xmlwriter_end_element($xw);

   xmlwriter_start_element($xw,"sprofile");
   xmlwriter_text($xw,convert($row[2]));
   xmlwriter_end_element($xw);

   xmlwriter_start_element($xw,"status");
   xmlwriter_text($xw,convert($row[0]));
   xmlwriter_end_element($xw);
  
   xmlwriter_start_element($xw,"date");
   xmlwriter_text($xw,convert($row[4]));
   xmlwriter_end_element($xw);

   xmlwriter_start_element($xw,"flag");
   xmlwriter_text($xw,convert($row[6]));
   xmlwriter_end_element($xw);
 xmlwriter_end_element($xw);
   
  
  } 
  xmlwriter_end_element($xw);
echo xmlwriter_output_memory($xw);
?>