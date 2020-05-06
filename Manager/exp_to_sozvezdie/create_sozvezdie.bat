@echo off
set db_path='localhost:E:\Clients\Коньшина\ztrade.fdb'
set script_path=E:\TMS\Manager\exp_to_sozvezdie\create_all_to_db.sql
echo Create Table,Triggers,Procedure /n

IBESCRIPT.exe -N -D%db_path% -USYSDBA -Pmasterkey  %script_path%
echo ***Complited***
pause

rem isql.exe  localhost:%db_path% -user SYSDBA -password masterkey -i %script_path%