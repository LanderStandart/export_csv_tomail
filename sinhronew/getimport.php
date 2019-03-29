<?php
if (isset($_GET["id"])) {$id=$_GET["id"];}
if (isset($_GET["client_id"])) {$client_id=$_GET["client_id"];}
if (isset($_GET["id_to_import"])) {$id_to_import=$_GET["id_to_import"];}
if (isset($_GET["import_dt"])) {$import_dt=$_GET["import_dt"];}
if (isset($_GET["filename"])) {$filename=$_GET["filename"];}
// http://192.168.67.62/sinhro/getimport.php?id=1&client_id=2&id_to_import=3&import_dt=2018-10-22%2013:58:49&filename=15019$20180701103330.ost

include('./engine/user.lib.php');
$user = new userclass();
$user->init();
if ((isset($id)) and (isset($client_id)) and (isset($id_to_import))and (isset($import_dt))and (isset($filename)))
{
$user->db->query('INSERT INTO IMPORT_FROM_DB set client_id=?i,id_to_import=?i,import_dt=?s,filename=?s',$client_id,$id_to_import,$import_dt,$filename);}

?>