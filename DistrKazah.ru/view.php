<?php
if ($_SERVER['REQUEST_METHOD']=='POST'){
	$inn = $_POST['inn'];
	$adres = $_POST['adres'];
}

$adres=mb_strtolower($adres);
$medservice = simplexml_load_file('https://online.medservice.kz/viortis/service.php?secret=standartnruik711mj4L3oCjwcKie3x8&city_id=1020&type=CLIENT&BIN='.$inn);
$medservices = simplexml_load_file('https://online.medservice.kz/viortis/service.php?secret=standartnruik711mj4L3oCjwcKie3x8&city_id=1010&type=CLIENT&BIN='.$inn);
$inkar = simplexml_load_file('http://2.133.92.203:53000//HttpAdapter/HttpMessageServlet?interfaceNamespace=urn:krs:onlineKab:ERP:AddressDelivery&interface=si_AddressDelivery_Site_sync_out&senderService=BC_Site&qos=BE&j_username=Site&j_password=2NaJWlNI&sap-language=EN&RNN=111&BIN='.$inn.'&XML=%3C?xml%20version=%221.0%22%20encoding=%22UTF-8%22?%3E%20%3Cns0:mt_AddressDelivery_req%20xmlns:ns0=%22urn:krs:ERP:Wiedmann:AddressDelivery%22%3E%20%3C/ns0:mt_AddressDelivery_req%3E');
$amanat_doc=simplexml_load_file('http://api.amanat.kz/?secret=4a98f4c4be0e11e5afbf001e67922ec1&type=CONTRACTS&BIN='.$inn);
$amanat_clients =simplexml_load_file('http://api.amanat.kz/?secret=4a98f4c4be0e11e5afbf001e67922ec1&type=CLIENT&BIN='.$inn); 
$stofarm_doc = simplexml_load_file('http://api.stopharm.kz/provisor?secret=9fc94a07f87e2816ee5722ad7517a9ce&type=contracts&BIN='.$inn); 
$stopharm_clients = simplexml_load_file('http://api.stopharm.kz/provisor?secret=9fc94a07f87e2816ee5722ad7517a9ce&type=CLIENT&BIN='.$inn); 

echo "БИН/ИИН клиента - ".$inn.'<br>';
echo "Адрес клиента -".$adres.'<br>';
echo "------------------------------------<br>";

echo '<br>'."Инкар:".'<br>';
//Парсим ответ от сервера Инкар
foreach ($inkar as $clients) {
	# code...
	foreach ($clients as $client) {

		foreach ($client->address as $adr) {
		   $pos = stripos(mb_strtolower($adr), $adres);
		   if ($pos!==false) {echo $client->id.'<br>'.$client->address.'<br>'.'1001|'.$inn.'|'.$client->id.'<br>';}	
		}}}
echo '<br>'."Медсервис:".'<br>';
echo "Головной:".'<br>';
//Парсим ответ от сервера Медсервис
foreach ($medservices as $clients) {
	# code...
	foreach ($clients as $client) {

		foreach ($client->address as $adr) {
		   echo '1020|'.str_replace('ID','', $client->id) .'<br>';
		}}}
echo "Точка:".'<br>';
foreach ($medservice as $clients) {
	# code...
	foreach ($clients as $client) {

		foreach ($client->address as $adr) {
		   $pos = stripos(mb_strtolower($adr), $adres);
		   if ($pos!==false) {echo $client->id.'<br>'.$client->address.'<br>'.'1020|'.$client->id.'<br>';}	
		}}}

//Парсим ответ от сервера Аманат
echo '<br>'."Аманат:".'<br>';		
	   $amanat_doc_id = $amanat_doc->contracts->contract->id;
		
foreach ($amanat_clients as $clients) {
	# code...
	foreach ($clients as $client) {

		foreach ($client->address as $adr) {
		   $pos = stripos(mb_strtolower($adr), $adres);
		   if ($pos!==false) {echo $amanat_doc_id.'|'.$client->id.'|001<br>';}	
		}}}
//Парсим ответ от сервера СтоФарм
echo '<br>'."Стофарм:".'<br>';		
	   $stofarm_doc_id = $stofarm_doc->contracts->i['id'];

foreach ($stopharm_clients as $clients) {
	# code...
	foreach ($clients as $client) {

		foreach ($client->address as $adr) {
		   $pos = stripos(mb_strtolower($adr), $adres);
		   if ($pos!==false) {echo $stofarm_doc_id.'|'.$client->id.' - номер прайса 003 <br>';}	
		}}}





