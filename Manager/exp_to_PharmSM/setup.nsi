; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------
!include "MUI2.nsh"
Name "TMS - Выгрузка в PharmSM"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "tms_sm.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "install_left_man.bmp"
!define MUI_WELCOMEPAGE_TITLE "Установка TMS - Выгрузка в PharmSM"
!define MUI_WELCOMEPAGE_TEXT " Установим все необходимые процедуры, таблицы и скрипты для организации выгрузки заказа в систему ''PharmSM''. "
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Отменить установку?"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "Установка прервана!"
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "Теперь все готово!"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "Для выгрузки  потребуется запустить ТМС - Выгрузка в PharmSM"


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS 
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH 
!insertmacro MUI_LANGUAGE "Russian"
; The name of the installer

Var DBpath



; The file to write
OutFile "./exp_to_pharmsm.exe"

; The default installation directory
InstallDir c:\Standart-n\exp_to_pharmsm

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
!define PATH "c:\Standart-n\exp_to_pharmsm"

; ; Pages

; Page directory
; Page instfiles

; ;--------------------------------

; The stuff to install
Section
	SetOutPath $INSTDIR
	File IBEScript.exe

SectionEnd




Section /o "для Аптеки" ALONE ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  StrCpy $DBpath "i5/3050:C:\Standart-N\base\ztrade.fdb"
  ; Put file there
  File create_TMS.sql 
  File OUT_PHARMSM.sql
  File PR_GET_PHARMSM.sql
  File 999805_TMS_EXPORT_TO_PHARMSM.txt
  
	
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\create_TMS.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\OUT_PHARMSM.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PR_GET_PHARMSM.sql' 

  
SectionEnd ;



	

