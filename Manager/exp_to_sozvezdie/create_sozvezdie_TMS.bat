@echo off
set db_path='localhost:E:\Clients\ùêàë\ztrade\ztrade.fdb'
set script_path=E:\TMS\Manager\exp_to_sozvezdie\create_TMS.sql
echo Create Table,Triggers,Procedure /n

IBESCRIPT.exe -N -D%db_path% -USYSDBA -Pmasterkey  %script_path%
echo ***Complited***
pause

rem isql.exe  localhost:%db_path% -user SYSDBA -password masterkey -i %script_path%