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
!insertmacro MUI_PAGE_COMPONENTS 
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH 
!insertmacro MUI_LANGUAGE "Russian"
; The name of the installer

Var DBpath



; The file to write
OutFile "./exp_to_partner.exe"

; The default installation directory
InstallDir c:\Standart-n\exp_to_partner

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
!define PATH "c:\Standart-n\exp_to_partner"

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
  StrCpy $DBpath "provizor2:d:\standart-n\db\ztrade.fdb"
  ; Put file there
  File create_TMS.sql 
  File create_G$PROFILES.sql
  File PARTNER_LOAD.sql
  File PARTNER_LOAD_BEGIN.sql
  File PARTNER_LOAD_MOVE.sql
  File PR_LOAD_MOVE_PARTNER.sql
  File PR_LOAD_PARTNER.sql
  File create_params.sql
  File TMS_PARTNER.hex
  File TMS_PARTNER_SETUP.hex
  File DELETE.sql
	
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\create_params.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\create_TMS.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\create_G$PROFILES.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\DELETE.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD_BEGIN.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD_MOVE.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PR_LOAD_MOVE_PARTNER.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PR_LOAD_PARTNER.sql'

 

  
SectionEnd ;

Section /o "для сетей" MULTI ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
 StrCpy $DBpath "localhost:d:\Standart-N\base_s\ztrade_s.fdb" 
  ; Put file there
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\create_TMS.sql
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\PARTNER_LOAD.sql
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\PARTNER_LOAD_BEGIN.sql
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\PARTNER_LOAD_MOVE.sql
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\PR_LOAD_MOVE_PARTNER.sql
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\PR_LOAD_PARTNER.sql
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\create_params.sql
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\999803.hex
  File e:\TMS\MANAGER\exp_to_partner\multi_profile\999804.hex

  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\create_TMS.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD_BEGIN.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PARTNER_LOAD_MOVE.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PR_LOAD_MOVE_PARTNER.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\PR_LOAD_PARTNER.sql'
  nsExec::ExecTOLog '"${PATH}\IBEScript.exe" -N -D$DBpath -USYSDBA -Pmasterkey ${PATH}\create_params.sql'
 

  
SectionEnd 



	

