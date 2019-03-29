<?php 
 include('./header.php');

$select= array ("Алматы","Актау","Актобе","Астана","Атырау", "Актюбинск","Балхаш" ,"Есик","Караганда","Кокшетау","Костанай","Кызылорда","Павлодар","Петропавловск","Семей","Семипалатинск", "Тылдыкорган","Тараз","Усть-Каменогорск","Уральск", "Шымкент")
 ?>

<body>


<br><form action="view.php" method="post">


Введите ИИН или БИН клиента
<p><input name="inn" type="text"></p>
Город
<select name="city">
 <?php  
  foreach ($select as $value) {
  	echo'<option value='.$value.'>'.$value.'</option>';	
    }
   ?> 
</select><br>

и его Улицу
<p><input name="adres" type="text"></p>

<p><input type='submit' value='Послать'></p>

</form>

<i>На текущий момент поиск происходит по следующим поставщикам - Аманат, Медсервис, Инкар, СтоФарм,Рауза <br><br></i>
</body>