function getAjax(url, div_id){
  var request; 
  if(window.XMLHttpRequest){ 
      request = new XMLHttpRequest(); 
  } else if(window.ActiveXObject){ 
      request = new ActiveXObject("Microsoft.XMLHTTP");  
  } else { 
      return; 
  }  
  request.onreadystatechange = function(){        
        switch (request.readyState) {
          case 1: print_console("<img src=\"_res/process_gray.gif\" width=\"16\" height=\"16\">&nbsp; выполнение запроса..."); break
          case 2: print_console("<img src=\"_res/process_gray.gif\" width=\"16\" height=\"16\">&nbsp; запрос отправлен"); break
          case 3: print_console("<img src=\"_res/process_gray.gif\" width=\"16\" height=\"16\">&nbsp; получение данных..."); break
          case 4:{
           if(request.status==200){     
                        print_console("4. Обмен завершен."); 
						div_id.innerHTML += request.responseText; 
						print_console("<a href=\"#\" onclick=\"getAjax('engine/ajax_wb.php',warebase_table); return false;\">еще записи...</a>");
                     }else if(request.status==404){
                        print_console("Ошибка: запрашиваемый скрипт не найден!");
                     }
                      else print_console("Ошибка: сервер вернул статус: "+ request.status);
           
            break
            }
        }       
    } 
    request.open ('GET', url, true); 
    request.send (''); 
  } 

  function print_console(text){
    document.getElementById("console").innerHTML = text; 
  }
  
function resetWBTable(div_id){
div_id.innerHTML="";
return;
div_id.innerHTML='<table id="warebase_table">'+
'<tr>'+
'    <td>&nbsp;</td>'+
'    <td>Профиль</td>'+
'    <td>Серия</td>'+
'    <td>Остаток</td>'+
'    <td>Закуп. цена</td>'+
'    <td>Наценка</td>'+
'    <td>Розн. цена</td>'+
'    <td>ШК изг</td>'+
'    <td>Годен до</td>'+
'    <td>Контрагент</td>'+
'    <td>Дата прихода</td>'+
'</tr>'+
'</table>';
};

function showHide(element_id) {
//  alert("~~!!!"+element_id.style.display);
   if (element_id.style.display!="none"){
     element_id.style.display="none";
   } else {
     element_id.style.display="";
   }
//   alert("~~"+element_id.style.display);
}