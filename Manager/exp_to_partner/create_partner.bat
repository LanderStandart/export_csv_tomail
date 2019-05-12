@echo off
echo Start %time%
echo Create logs.txt


set db_path='localhost:E:\Clients\ˆ‘\ztrade\ztrade.fdb'
set source_path=%__CD__%
echo logs>%source_path%logs.txt



echo Create Table,Triggers,Procedure >%source_path%logs.txt
for %%i in (*.sql) do (
IBESCRIPT.exe -N -D%db_path% -USYSDBA -Pmasterkey  %source_path%%%i
echo %%i>>%source_path%logs.txt
)





echo ***Complited***
pause
echo Stop %time%
rem isql.exe  localhost:%db_path% -user SYSDBA -password masterkey -i %script_path%