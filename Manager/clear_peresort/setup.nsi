; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------
!include "MUI2.nsh"
Name "TMS - Убрать пересорт"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "tms_sm.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "install_left_man.bmp"
!define MUI_WELCOMEPAGE_TITLE "Установка TMS - Убрать пересорт"
!define MUI_WELCOMEPAGE_TEXT " Установим все необходимые процедуры, таблицы и скрипты."
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Отменить установку?"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "Установка прервана!"
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "Теперь все готово!"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "Для дальнейшей настройки потребуется запустить ТМС - Настройка выгрузки Партнер"

!define MUI_DIRECTORYPAGE_TEXT_TOP "Укажите директорию с установленным АРМ Менеджер "

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH 
!insertmacro MUI_LANGUAGE "Russian"
; The name of the installer



Var DBpath
var PATH
var APPDIR

!define MUI_DIRECTORYPAGE_VARIABLE $APPDIR


; The file to write
OutFile "./clear_peresort.exe"

; The default installation directory
InstallDir c:\Standart-n\clear_peresort

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------

; ; Pages

; Page directory
; Page instfiles

; ;--------------------------------

; The stuff to install
Section





!define PATH $INSTDIR

 ;MessageBox MB_OK $APPDIR

;MessageBox MB_OK $INSTDIR
  ReadINIStr $DBpath $INSTDIR\dbconnect.ini dbParams DatabaseName
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  StrCpy $PATH $INSTDIR
;MessageBox MB_OK $PATH
;MessageBox MB_OK $DBpath

;  StrCpy $DBpath "SERVER:C:\Standart-N\base\ztrade.fdb"
  ; Put file there
  File IBEScript.exe
  File create_TMS.sql 
  File PR_CLEAR_PERESORT.sql
  File TMS_source.txt
	
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey "${PATH}\create_TMS.sql"'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey "${PATH}\PR_CLEAR_PERESORT.sql"'


 

  
SectionEnd ;



	

