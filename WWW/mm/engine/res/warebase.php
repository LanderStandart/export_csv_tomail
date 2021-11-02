<form id="wb_query" method="get"><label><input name="query" type="text" onClick="if(event.keyCode==13){return false;}"></label><input value="Поиск" type="submit" onClick="resetWBTable(warebase_table); getAjax('engine/ajax_wb.php?query='+wb_query.query.value,warebase_table); return false;"></form>

<table id="warebase_table" class="t_wares">
  <tr> 
    <td width="50px">&nbsp;</td>
  </tr>
</table>
<div id="console" style="padding: 3px; background:#CCCCCC; float: left; vertical-align: center; font-size: 12px; text-align: left;"><img src="../../_res/process.gif" width="16" height="16"></div>
<br>