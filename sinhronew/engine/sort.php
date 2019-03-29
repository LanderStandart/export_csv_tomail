<div class="row">
 <div class="col-6"></div>
  <div class="col-3">
   <div class="btn-group btn-group-toggle btn-sm" data-toggle="buttons" style="font-size:.6rem"> <span>Сортировка:&nbsp;</span> 
     <label class="btn btn-secondary active btn-sm" id="sort" style="font-size:.6rem" >
     <input type="radio" name="sort" id="sort" autocomplete="off" checked> Статус
     </label>
     <label class="btn btn-secondary btn-sm" id="abc" style="font-size:.6rem">
     <input type="radio" name="options" id="option2" autocomplete="off"> АБС
     </label>
   </div>
  </div><div class="col-2"> 
      <div class="btn-group btn-group-toggle btn-sm" data-toggle="buttons" style="font-size:.6rem"> <span>Фильтр:&nbsp;</span> 
         <label class="btn btn-secondary  btn-sm" id="error" style="font-size:.6rem" >
         <input type="radio" name="error" id="error" autocomplete="off" > Проблемы
         </label>
         <label class="btn btn-secondary active btn-sm" id="all" style="font-size:.6rem">
         <input type="radio" name="all" id="all" autocomplete="off" checked> Все
         </label>
       </div>
   </div>
</div>


<script type="text/javascript">
var 
rarr=document.getElementsByName("error");
sort=document.getElementsByName("sort");
 $(\"#abc").click(function(){
    if (rarr[0].checked) { $('#content').load('./client.php?sort=abce');} 
    if (!rarr[0].checked) { $('#content').load('./client.php?sort=abc');}
 });
$('#sort').click(function(){
  if (rarr[0].checked) {
      $('#content').load('./client.php?sort=sorte');
     } else {
   $('#content').load('./client.php?sort=sort');}
 });
 $('#all').click(function(){
  if (sort[0].checked) {
      $('#content').load('./client.php?sort=sort');
     } else {
   $('#content').load('./client.php?sort=abc');}
 });
  $('#error').click(function(){
  if (sort[0].checked) {
      $('#content').load('./client.php?sort=sorte');
     } else {
   $('#content').load('./client.php?sort=abce');}
 });

</script>