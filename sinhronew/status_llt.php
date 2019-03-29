<?php
$query=$db->getrow('SELECT timeserver,updcard,diff_min FROM SIN_LLT where prof_id='.$id);
if ($query['diff_min']>30){$al=';color: red;';}else{$al='';}
echo '<div style="min-height:1rem"></div>
<div style="font-size:0.9rem"><div> Система лояльности </div>
<div style="font-size:0.7rem"> Время сервера: '.$query['timeserver'].'</div>
<div style="font-size:0.7rem"> Обновление карт: '.$query['updcard'].'</div>
<div style="font-size:0.7rem'.$al.'"> Последнее обновление '.$query['diff_min'].' мин. назад</div>
</div>'

?>