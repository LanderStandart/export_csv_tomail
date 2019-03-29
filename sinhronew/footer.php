<?php
echo'<div class="row footer">';
echo '<div class="time">';
echo '&#169;2018 Lander';
echo '</div><div style="width:100px"> </div>';
echo '<div class="legend">';
echo "<div><img src=./images/timeok.png width=15px hspace=2px > - Не было синхронизации несколько часов </div>";
echo "<div><img src=./images/timeok1.png width=15px hspace=2px > - Не было синхронизации меньше суток </div>";
echo "<div><img src=./images/time.png width=15px hspace=2px > - Не было синхронизации более одних суток </div>";
echo "<div><img src=./images/ok.jpg  width=13rem hspace=3px > - Все хорошо </div>";
echo '</div> <div style="width:100px"> </div><div class="legend">';
echo "<div><img src=./images/timedead.png width=15px hspace=2px > - Не было синхронизации более недели </div>";
echo "<div><img src=./images/err.png width=15px hspace=2px > - Ошибка в пакете </div>";
echo "<div><img src=./images/errserv.jpg width=15px hspace=2px > - Сервер не отвечает </div>";
echo "<div><img src=./images/llt.png width=15rem hspace=2px > - Нет синхронизации системы лояльности  </div>";
echo "</div>";
echo "</div></body>";
?>