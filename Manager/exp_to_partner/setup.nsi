; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------
!include "MUI2.nsh"
Name "TMS - Выгрузка в Партнер"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "tms_sm.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "install_left_man.bmp"
!define MUI_WELCOMEPAGE_TITLE "Установка TMS - Выгрузка в Партнер"
!define MUI_WELCOMEPAGE_TEXT " Установим все необходимые процедуры, таблицы и скрипты для организации выгрузки в систему ''ПАРТНЕР''. \
							   Для дальнейшей настройки потребуется запустить ТМС - Настройка выгрузки Партнер"
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Отменить установку?"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "Установка прервана!"
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "Теперь все готово!"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "Для дальнейшей настройки потребуется запустить ТМС - Настройка выгрузки Партнер"


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH 
!insertmacro MUI_LANGUAGE "Russian"
; The name of the installer





; The file to write
OutFile "./exp_to_partner.exe"

; The default installation directory
InstallDir c:\Standart-n\exp_to_partner

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
!define PATH "c:\Standart-n\exp_to_partner"
!define DBpath "localhost:C:\Standart-N\base\ztrade.fdb"
; ; Pages

; Page directory
; Page instfiles

; ;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File create_TMS.sql
  File IBEScript.exe
  File PARTNER_LOAD.sql
  File PARTNER_LOAD_BEGIN.sql
  File PARTNER_LOAD_MOVE.sql
  File PR_LOAD_MOVE_PARTNER.sql
  File PR_LOAD_PARTNER.sql
  File TMS_PARTNER.hex
  File TMS_PARTNER_SETUP.hex

  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D${DBpath} -USYSDBA -Pmasterkey ${PATH}\create_TMS.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D${DBpath} -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D${DBpath} -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD_BEGIN.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D${DBpath} -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD_MOVE.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D${DBpath} -USYSDBA -Pmasterkey ${PATH}\PR_LOAD_MOVE_PARTNER.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D${DBpath} -USYSDBA -Pmasterkey ${PATH}\PR_LOAD_PARTNER.sql'
 

  
SectionEnd ; end the section



	

