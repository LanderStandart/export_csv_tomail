;Начальные установки
#define Name      "Standart WAMP server"
#define Version   "_alpha0.0.2"
#define Publisher "Lander"
#define URL       "http://www.standart-n.ru/"
#define ExeName   "StandartWAMP.exe"
#define Paths      "C:\Standart-N\WAMP"

 [Setup]
 AppId={{89C487C6-B037-400F-8586-C7EF1E7CCE05}
 AppName={#Name}
 AppVersion={#Version}
 AppPublisher={#Publisher}
 AppSupportURL={#URL}
 AppPublisherURL={#URL}
 AppUpdatesURL={#URL}
 AppCopyright={#Publisher}


 DefaultDirName={#Paths} 
 DefaultGroupName=НВП Стандарт-Н\ВебСервер
 OutputBaseFilename=Standart-N_WAMP_server_x86_x64+{#Version}
 

 Compression=lzma/Max
 SolidCompression=true
 InternalCompressLevel=Max

 SetupIconFile=e:\WEB\Standart-N_WAMP_server.ico
 WizardImageFile=e:\WEB\WAMPlogo.bmp
 WizardSmallImageFile=e:\WEB\WAMPlogo.bmp

 

 OutputDir=e:\standart-n\WAMP DirExistsWarning=no

[Languages]
 Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

 

[Files]
;Apache
Source: "E:\WEB\64\Apache\httpd-2.4.33-win64-VC11\*.*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs;Check:iswin64; 
Source: "E:\WEB\32\Apache\httpd-2.4.33-win32-VC11\*.*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs 32bit;Check:not IsWin64;

;Apache config
Source: "E:\WEB\httpd.conf"; DestDir: "{app}\Apache\conf"; Flags: overwritereadonly ignoreversion
;PHP
Source: "E:\WEB\64\php\php-5.6.34-Win32-VC11-x64\*.*"; DestDir: "{app}\php"; Flags: recursesubdirs createallsubdirs;Check:iswin64; 
Source: "E:\WEB\32\php\php-5.6.34-Win32-VC11-x86\*.*"; DestDir: "{app}\php"; Flags: recursesubdirs createallsubdirs;Check:not IsWin64;

;php config
Source: "E:\WEB\php.ini"; DestDir: "{app}\php"; Flags: ignoreversion overwritereadonly
;Library for Firebird
Source: "e:\WEB\fbclient.dll"; DestDir: "{win}"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "e:\WEB\fbclient.dll"; DestDir: "{sys}"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "e:\WEB\fbclient.dll"; DestDir: "{app}\Apache\bin"; Flags: onlyifdoesntexist uninsneveruninstall

Source: "e:\WEB\gds32.dll"; DestDir: "{win}"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "e:\WEB\gds32.dll"; DestDir: "{sys}"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "e:\WEB\gds32.dll"; DestDir: "{app}\Apache\bin"; Flags: onlyifdoesntexist uninsneveruninstall
;service QUEUE
Source: "E:\WEB\QueueService\*.*"; DestDir: "{app}\QueueService"
;scripts
Source: "E:\WEB\Sinhro\*.*"; DestDir: "{app}\www\sinhro"; Flags: recursesubdirs createallsubdirs
;Database
Source: "E:\WEB\ZTRADE_G.FDB"; DestDir: {code:Getparam}; Flags: onlyifdoesntexist
;Visual C++
Source: "E:\WEB\64\VC11\vcredist_x64.exe"; DestDir: "{app}"; Flags: deleteafterinstall ;Check:iswin64;
Source: "E:\WEB\32\VC11\vcredist_x86.exe"; DestDir: "{app}"; Flags: deleteafterinstall ;Check:not IsWin64;

[Dirs]
Name:"{app}\logs"
Name:"{app}\tmp"

[Run]
Filename: "{app}\vcredist_x64.exe"; Flags: 64bit; Check: iswin64
Filename: "{app}\vcredist_x86.exe"; Flags: 32bit; Check: not iswin64
Filename: "{app}\Apache\bin\httpd.exe"; Parameters: "-k install"; Flags: nowait
Filename: "{app}\Apache\bin\ApacheMonitor.exe"; Flags: nowait
Filename: "{app}\QueueService\*.*"; Parameters: "/install"; Flags: nowait

[UninstallDelete]
Type: files; Name: "{app}\Apache\bin\fbclient.dll"
Type: files; Name: "{app}\Apache\bin\gds32.dll"

[Code]
var
  ConfigPage: TWizardPage;
  IPEdit: TNewEdit;
  PathBDEdit: TNewEdit;
  IP, Pathbd: string;
// обработчик нажатия кнопки Next на нашей страничке
function OnConfigPage_NextButtonClick(Sender: TWizardPage): Boolean;
  
begin
  IP := IPEdit.Text; // здесь лежит введенный логин
  PathBD := PathBDEdit.Text; // здесь лежит введенный пасс

  // здесь можно с ними что-то сделать

  Result := True; // можно продолжать установку
end;

procedure CreateCustomConfigPage;
var
  IPLabel: TLabel;
  PathBDLabel: TLabel;
begin
// Создание страницы Config
  ConfigPage := CreateCustomPage(wpSelectTasks, 'CustomPageCaption', 'CustomPageText');
  ConfigPage.OnNextButtonClick := @OnConfigPage_NextButtonClick; // обработчик нажатия кнопки Next

// IP
  IPLabel := TLabel.Create(WizardForm);
  IPLabel.Parent := ConfigPage.Surface;
  IPLabel.Left := 0;
  IPLabel.Top := 0;
  IPLabel.Caption := 'Адрес сервера синхронизации (IP):';

  IPEdit := TNewEdit.Create(WizardForm);
  IPEdit.Parent := ConfigPage.Surface;
  IPEdit.Left := 0;
  IPEdit.Top := IPLabel.Top + IPLabel.Height + 6;
  IPEdit.Width := 200;

// Path to Database
  PathBDLabel := TLabel.Create(WizardForm);
  PathBDLabel.Parent := ConfigPage.Surface;
  PathBDLabel.Left := 0;
  PathBDLabel.Top := IPEdit.Top + IPEdit.Height + 6;
  PathBDLabel.Caption := 'Путь установки БД Ztrade_g:';

  PathBDEdit := TNewEdit.Create(WizardForm);
  PathBDEdit.Parent := ConfigPage.Surface;
  PathBDEdit.Left := 0;
  PathBDEdit.Top := PathBDLabel.Top + PathBDLabel.Height + 6;
  PathBDEdit.Width := 200;
  PathBDEdit.Text:='C:\Standart-N\base_g';
  
end;

procedure InitializeWizard();
begin
  CreateCustomConfigPage;
end;

 function Getparam(Param: String):String;
begin 
 result :=PathBD;
end;

 function GetIP(Param: String):String;
begin 
 result :=IP;
end;


procedure CngFile(f,i,d:string;CurStep: TSetupStep);
var
  UnicodeStr: string;
  ANSIStr: AnsiString;
begin
  if (CurStep = ssPostInstall) then
  begin
  LoadStringFromFile(ExpandConstant(f), ANSIStr)
  UnicodeStr := String(ANSIStr);
  StringChangeEx(UnicodeStr, d, i, False)
  SaveStringToFile(ExpandConstant(f), AnsiString(UnicodeStr), False);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
 f,i,d:string;
begin
//правим конфиг Apache
f:='{app}\Apache\conf';
d:='DocumentRoot "c:/standart-n/wamp/www/"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='DocumentRoot "'+i+'/www/"';
CngFile(f,i,d,CurStep);

d:='ServerRoot "c:/standart-n/wamp/apache/"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='ServerRoot "'+i+'/apache/"';
CngFile(f,i,d,CurStep);

d:='<Directory "c:/standart-n/wamp/www/">';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='<Directory "'+i+'/www/"';
CngFile(f,i,d,CurStep);

d:='ErrorLog "c:/standart-n/wamp/logs/apache_error.log"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='ErrorLog "'+i+'/logs/apache_error.log"';
CngFile(f,i,d,CurStep);

d:='    CustomLog "c:/standart-n/wamp/logs/access.log" common';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='    CustomLog "'+i+'/logs/access.log" common';
CngFile(f,i,d,CurStep);

d:='<Directory "c:/standart-n/wamp/apache/cgi-bin">';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='<Directory "'+i+'/apache/cgi-bin">';
CngFile(f,i,d,CurStep);
//------------------------------------------------------------
//правим конфиг PHP
f:='{app}\php';
d:='error_log = "c:/standart-n/wamp/logs/php_error.log"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='error_log = "'+i+'/logs/php_error.log"';
CngFile(f,i,d,CurStep);

d:='extension_dir = "c:/standart-n/wamp/php/ext/"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='extension_dir = "'+i+'/php/ext/"';
CngFile(f,i,d,CurStep);

d:='upload_tmp_dir = "c:/standart-n/wamp/tmp"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='upload_tmp_dir = "'+i+'/tmp"';
CngFile(f,i,d,CurStep);

d:='session.save_path = "c:/standart-n/wamp/tmp"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='session.save_path = "'+i+'/tmp"';
CngFile(f,i,d,CurStep);

d:='zend_extension = "c:/standart-n/wamp/php/zend_ext/php_xdebug-2.2.5-5.5-vc11.dll"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='zend_extension = "'+i+'/php/zend_ext/php_xdebug-2.2.5-5.5-vc11.dll"';
CngFile(f,i,d,CurStep);

d:='xdebug.profiler_output_dir = "c:/standart-n/wamp/tmp"';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','/',True)
i:='xdebug.profiler_output_dir = "'+i+'/tmp"';
CngFile(f,i,d,CurStep);
//----------------------------------------------------------------------------------
//QUEUE Service Config
f:='{app}\QueueService\QueueService.ini';
d:='DatabaseName=localhost:C:\Standart-N\Base_G\ZTRADE_G.FDB';
i:=ExpandConstant('{code:Getparam}');
//StringChangeEx(i,'\','/',True)
i:='DatabaseName=localhost:'+i+'\ZTRADE_G.FDB';
CngFile(f,i,d,CurStep);

d:='url=http:localhost/sinhro/engine/d_queue_do.php';
i:=ExpandConstant('{code:GetIP}');
//StringChangeEx(i,'\','/',True)
i:='url=http:'+i+'/sinhro/engine/d_queue_do.php';
CngFile(f,i,d,CurStep);//----------------------------------------------------------------------------------
//declare.php

f:='{app}\www\sinhro\ENGINE\declare.php';
d:='$GLOBALS["DB_DATABASENAME"]="localhost:C:\\STANDART-N\\base_g\\ztrade_g.fdb";';
i:=ExpandConstant('{code:Getparam}');
StringChangeEx(i,'\','\\',True)
i:='$GLOBALS["DB_DATABASENAME"]="localhost:'+i+'\\ZTRADE_G.FDB';
CngFile(f,i,d,CurStep);

d:='$GLOBALS["PATH_ROOT"]="c:\\standart-n\\wamp\\www\\sinhro\\engine\\";';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','\\',True)
i:='$GLOBALS["PATH_ROOT"]="'+i+'\\www\\sinhro\\engine\\";';
CngFile(f,i,d,CurStep);
d:='$GLOBALS["PATH_USERS"]="c:\\standart-n\\wamp\\www\\sinhro\\engine\\users\\";';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','\\',True)
i:='$GLOBALS["PATH_USERS"]="'+i+'\\www\\sinhro\\engine\\users\\";';
CngFile(f,i,d,CurStep);

d:='$GLOBALS["QUEUEDIR"]="c:\\standart-n\\wamp\\www\\sinhro\\engine\\queue\\";';
i:=ExpandConstant('{app}');
StringChangeEx(i,'\','\\',True)
i:='$GLOBALS["QUEUEDIR"]="'+i+'\\www\\sinhro\\engine\\queue\\";';
CngFile(f,i,d,CurStep);
//----------------------------------------------------------------------------------
end;