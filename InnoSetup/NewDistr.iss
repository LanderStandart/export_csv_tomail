#define ProductName "��� ��������-�, ������������� ��������"
#define Version "2.0.272.62"    
#define Version_K "2.2.1.78"                       
#define Version_M "2.273.58"                                             
;#define  FullName "1"
#define servername "127.0.0.1"
                                                                 
[GUID]
{C4E8CF4A-A0E9-4FC4-9AC3-2FBB1EA57107}
                                                                        
[Setup]
AppID={{D94C018C-55F3-4E61-8FD0-1659CDC420B4}
AppName={code:Info}
AppVerName={code:Info}
AppPublisher=��� ��������-�
AppPublisherURL=http://www.standart-n.ru/
AppSupportURL=http://www.standart-n.ru/
AppUpdatesURL=http://www.standart-n.ru/
AppCopyright=��� ��������-�
VersionInfoVersion={#Version}
VersionInfoCompany=��� ��������-�
VersionInfoDescription={code:Info}

  VersionInfoTextVersion=������������� �����������
  OutputBaseFilename=AT_ALL_server

VersionInfoCopyright=��� ��������-�
VersionInfoProductName={#ProductName}
VersionInfoProductVersion={#Version}                                                   
DefaultDirName=C:\Standart-N
DefaultGroupName=��� ��������-�\������������� ��������
Compression=lzma/Max
SolidCompression=true
OutputDir=\\lander\Share\distr
;OutputDir=\\supa\standartn\html\files\lander
WizardImageFile=\\ALECSANDR\projects\distribs\manager\imgs\install_left_man.bmp
WizardSmallImageFile=\\ALECSANDR\projects\distribs\manager\imgs\install_right_man.bmp                            
SetupIconFile=\\ALECSANDR\projects\distribs\manager\imgs\logo_manager.ico
DirExistsWarning=no
InternalCompressLevel=Max
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\Manager\logo_manager.ico
;PASSWORD=Lbcnhb,enbd

#include <idp.iss>

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Types]
Name: "Pharma"; Description: "������������ - ������"
Name: "PharmaKZ"; Description: "������������ - ������ ���������"
Name: "dress"; Description: "������������ - ������"
Name: "food"; Description: "������������ - ����������� �������"
Name: "hoz"; Description: "������������ - �������������"
Name: "tech"; Description: "������������ - ������������ �������"

[Components]
Name: "base"; Description: "��������� ���� � �������������� ��"; Types: dress food hoz Pharma PharmaKZ tech
Name: "kassa"; Description: "��������� ��� �������"; Types: food dress hoz Pharma PharmaKZ tech
Name: "manager"; Description: "��������� ��� ���������"; Types: dress food hoz Pharma PharmaKZ tech
Name: "Pharma"; Description: "���� ��"; Types: Pharma
Name: "PharmaKZ"; Description: "���� ��"; Types: PharmaKZ

Name: "dop"; Description: "��������� �������������� ��������"; Types: tech PharmaKZ Pharma hoz food dress
Name: "help"; Description: "�������� ���������"; Types: tech PharmaKZ Pharma hoz food dress
Name: "dress"; Description: "�� ������"; Types: dress
Name: "food"; Description: "�� ��������"; Types: food
Name: "hoz"; Description: "�� ���������"; Types: hoz
Name: "tech"; Description: "�� ������������ �������"; Types: tech

[Tasks]

;����
Name: "copybase"; Description: "���������� ��"; GroupDescription: "���� ������"; Flags: checkedonce; Components: base
Name: "copyServiceMngr"; Description: "���������� ������ ��������"; GroupDescription: "���� ������"; Flags: checkedonce; Components: base
Name: "install_nnCron"; Description: "���������� ����������� �������"; GroupDescription: "���� ������"; Flags: checkedonce; Components: base
Name: "ip"; Description: "���������� IPv6"; GroupDescription: "���� ������"; Flags: checkedonce; Components: base
Name: "copydtclient"; Description: "�������������: ������"; GroupDescription: "���� ������"; Flags: checkedonce; Components: base
;������� ���������
Name: "copyman"; Description: "���������� ��� �������� {#Version_M}"; GroupDescription: "������� ���������"; Flags: checkedonce; Components: manager
Name: "copykas"; Description: "���������� ��� ������ {#Version_K}"; GroupDescription: "������� ���������"; Flags: checkedonce; Components: kassa
Name: "install_driverT"; Description: "���������� ������� ��������� ������������"; GroupDescription: "������� ���������"; Flags: checkedonce; Components: kassa
Name: "install_po_SHK"; Description: "���������� �������������� �� ��� ������� ��"; GroupDescription: "������� ���������"; Flags: checkedonce; Components: kassa
;���� ��
Name: "copyost"; Description: "���������� �������� ��������-� (OST.exe)"; GroupDescription: "���� ��"; Flags: checkedonce; Components: Pharma
Name: "copysprav"; Description: "���������� ���������� ������������� �������"; GroupDescription: "���� ��"; Flags: checkedonce; Components: PharmaKZ Pharma
Name: "copyzclientxp"; Description: "���������� ����� �����"; GroupDescription: "���� ��"; Flags: checkedonce; Components: PharmaKZ Pharma

;��������������
Name: "copyeconv"; Description: "���������� ��������� ����������� ���������"; GroupDescription: "��������������"; Flags: checkedonce; Components: Dop
Name: "install_mail"; Description: "���������� Mail Project (����� ��. ��������� ����� �����)"; GroupDescription: "��������������"; Flags: checkedonce; Components: Dop
Name: "copydiscount"; Description: "���������� ���������� �������"; GroupDescription: "��������������"; Flags: unchecked; Components: Dop
Name: "copysms"; Description: "������ ��� ��������"; GroupDescription: "��������������"; Flags: unchecked; Components: dop
Name: "copyexport"; Description: "���������� �������� ������� �������������"; GroupDescription: "��������������"; Flags: unchecked; Components: dop
;�������
Name: "install_vnc"; Description: "���������� VNC-������+STN-������"; GroupDescription: "���. ���������:"; Flags: checkedonce; Components: help
Name: "install_TeamViewer"; Description: "���������� TeamViewer 5"; GroupDescription: "���. ���������:"; Flags: checkedonce; Components: help
Name: "install_AmmyAdmin"; Description: "���������� AmmyAdmin"; GroupDescription: "���. ���������:"; Flags: checkedonce; Components: help

;������
Name: "copyIBExpert"; Description: "���������� IBExpert"; GroupDescription: "�����"; Flags: checkedonce
Name: "install_server"; Description: "���������� ������ Firebird SQL Server 2.5"; GroupDescription: "�����"; Flags: checkedonce
Name: "firewall"; Description: "��������� ����������� � �������������"; GroupDescription: "�����"; Flags: checkedonce
Name: "install_ChromeSetup"; Description: "���������� Google Chrome (��� ������ PDF)"; GroupDescription: "�����"; Flags: checkedonce
Name: "install_DBFNavigator"; Description: "���������� DBFNavigator"; GroupDescription: "�����"; Flags: checkedonce
Name: "install_TotalCMD"; Description: "���������� Total Commander"; GroupDescription: "�����"; Flags: checkedonce
Name: "install_FAR"; Description: "���������� FAR 3.0.4"; GroupDescription: "�����"; Flags: checkedonce
Name: "install_7zip"; Description: "���������� 7-zip"; GroupDescription: "�����"; Flags: checkedonce

[Registry]
Root: "HKCU"; Subkey: "Software\Standart-N"
Root: "HKCU"; Subkey: "Software\Standart-N"; ValueType: string; ValueName: "Name"; ValueData: "{#ProductName}"; Flags: createvalueifdoesntexist uninsdeletekey
Root: "HKCU"; Subkey: "Software\Standart-N"; ValueType: string; ValueName: "FullName"; ValueData: "{code:Info}"; Flags: createvalueifdoesntexist uninsdeletekey
Root: "HKCU"; Subkey: "Software\Standart-N"; ValueType: string; ValueName: "Version"; ValueData: "{#Version}"; Flags: createvalueifdoesntexist uninsdeletekey
;Root: "HKCU"; Subkey: "Software\Standart-N"; ValueType: string; ValueName: "Version_AT"; ValueData: "{#Version_AT}"; Flags: createvalueifdoesntexist uninsdeletekey
Root: "HKCU"; Subkey: "Software\Standart-N"; ValueType: string; ValueName: "Path"; ValueData: "{app}"; Flags: createvalueifdoesntexist uninsdeletekey
Root: "HKCU"; Subkey: "Software\Standart-N\��� ��������"; ValueType: string; ValueName: "Name"; ValueData: "��� ��������"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copyman
Root: "HKCU"; Subkey: "Software\Standart-N\��� ��������"; ValueType: string; ValueName: "Version"; ValueData: "{#Version_M}"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copyman
Root: "HKCU"; Subkey: "Software\Standart-N\��� ��������"; ValueType: string; ValueName: "Path"; ValueData: "{app}\Manager"; Flags: uninsdeletekey; Tasks: copyman
Root: "HKCU"; Subkey: "Software\Standart-N\��� ������"; ValueType: string; ValueName: "Name"; ValueData: "��� ������"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copykas
Root: "HKCU"; Subkey: "Software\Standart-N\��� ������"; ValueType: string; ValueName: "Version"; ValueData: "{#Version_K}"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copykas
Root: "HKCU"; Subkey: "Software\Standart-N\��� ������"; ValueType: string; ValueName: "Path"; ValueData: "{app}\Kassir"; Flags: uninsdeletekey; Tasks: copykas
Root: "HKCU"; Subkey: "Software\Standart-N\���������� �������"; ValueType: string; ValueName: "Name"; ValueData: "���������� �������"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copydiscount
Root: "HKCU"; Subkey: "Software\Standart-N\���������� �������"; ValueType: string; ValueName: "Version"; ValueData: "1.0"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copydiscount
Root: "HKCU"; Subkey: "Software\Standart-N\���������� �������"; ValueType: string; ValueName: "Path"; ValueData: "{app}\discount"; Flags: uninsdeletekey; Tasks: copydiscount
Root: "HKCU"; Subkey: "Software\Standart-N\��������� ����������� ���������"; ValueType: string; ValueName: "Name"; ValueData: "��������� ����������� ���������"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copyeconv
Root: "HKCU"; Subkey: "Software\Standart-N\��������� ����������� ���������"; ValueType: string; ValueName: "Version"; ValueData: "1.1.20.0"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copyeconv
Root: "HKCU"; Subkey: "Software\Standart-N\��������� ����������� ���������"; ValueType: string; ValueName: "Path"; ValueData: "{app}\Econv"; Flags: uninsdeletekey; Tasks: copyeconv
Root: "HKCU"; Subkey: "Software\Standart-N\�������� ��������-�"; ValueType: string; ValueName: "Name"; ValueData: "�������� ��������-�"; Flags: createvalueifdoesntexist uninsdeletekey; Components: Pharma; Tasks: copyost
Root: "HKCU"; Subkey: "Software\Standart-N\�������� ��������-�"; ValueType: string; ValueName: "Path"; ValueData: "{app}\Ost"; Flags: uninsdeletekey; Components: Pharma; Tasks: copyost
Root: "HKCU"; Subkey: "Software\Standart-N\�������� ��������-�"; ValueType: string; ValueName: "Version"; ValueData: "1.2.0.45"; Flags: createvalueifdoesntexist uninsdeletekey; Components: Pharma; Tasks: copyost
Root: "HKCU"; Subkey: "Software\Standart-N\���������� ������������� �������"; ValueType: string; ValueName: "Name"; ValueData: "���������� ������������� �������"; Flags: createvalueifdoesntexist uninsdeletekey; Components: PharmaKZ Pharma; Tasks: copysprav
Root: "HKCU"; Subkey: "Software\Standart-N\���������� ������������� �������"; ValueType: string; ValueName: "Version"; ValueData: "3.1.0.0"; Flags: createvalueifdoesntexist uninsdeletekey; Components: PharmaKZ Pharma; Tasks: copysprav
Root: "HKCU"; Subkey: "Software\Standart-N\���������� ������������� �������"; ValueType: string; ValueName: "Path"; ValueData: "{app}\PharmInfo"; Flags: uninsdeletekey; Components: PharmaKZ Pharma; Tasks: copysprav
Root: "HKCU"; Subkey: "Software\Standart-N\VGMCSend"; ValueType: string; ValueName: "Name"; ValueData: "VGMCSend"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copyman
Root: "HKCU"; Subkey: "Software\Standart-N\VGMCSend"; ValueType: string; ValueName: "Version"; ValueData: "1.1.0.0"; Flags: createvalueifdoesntexist uninsdeletekey; Tasks: copyman
Root: "HKCU"; Subkey: "Software\Standart-N\VGMCSend"; ValueType: string; ValueName: "Path"; ValueData: "{app}\VGMCSend"; Flags: uninsdeletekey; Tasks: copyman

[Icons]
Name: "{group}\��������"; Filename: "{app}\Manager\ManagerXP2.exe"; WorkingDir: "{app}\Manager"; IconFilename: "{app}\Manager\logo_manager.ico"; IconIndex: 0; Tasks: copyman
Name: "{commondesktop}\��������"; Filename: "{app}\Manager\ManagerXP2.exe"; WorkingDir: "{app}\Manager"; IconFilename: "{app}\Manager\logo_manager.ico"; IconIndex: 0; Tasks: copyman
Name: "{group}\������"; Filename: "{app}\Kassir\zkassa.exe"; WorkingDir: "{app}\Kassir"; IconFilename: "{app}\Kassir\zkassa.exe"; IconIndex: 0; Tasks: copykas
Name: "{commondesktop}\������"; Filename: "{app}\Kassir\zkassa.exe"; WorkingDir: "{app}\Kassir"; IconFilename: "{app}\Kassir\zkassa.exe"; IconIndex: 0; Tasks: copykas
Name: "{group}\����������������� ����"; Filename: "{app}\IBExpert\IBExpert.exe"; WorkingDir: "{app}\IBExpert"; IconFilename: "{app}\IBExpert\IBExpert.exe"; IconIndex: 0; Tasks: copyIBExpert
Name: "{commondesktop}\����������������� ����"; Filename: "{app}\IBExpert\IBExpert.exe"; WorkingDir: "{app}\IBExpert"; IconFilename: "{app}\IBExpert\IBExpert.exe"; IconIndex: 0; Tasks: copyIBExpert
Name: "{group}\���������� ��������"; Filename: "{app}\Instruction\instruction_manager.pdf"; WorkingDir: "{app}\Instruction"; IconFilename: "{app}\Instruction\instruction_manager.pdf"; IconIndex: 0; Tasks: copyman
Name: "{commondesktop}\���������� ��������"; Filename: "{app}\Instruction\instruction_manager.pdf"; WorkingDir: "{app}\Instruction"; IconFilename: "{app}\Instruction\instruction_manager.pdf"; IconIndex: 0; Tasks: copyman
Name: "{group}\���������� ������"; Filename: "{app}\Instruction\instruction_kassir.pdf"; WorkingDir: "{app}\Instruction"; IconFilename: "{app}\Instruction\instruction_kassir.pdf"; IconIndex: 0; Tasks: copykas
Name: "{commondesktop}\���������� ������"; Filename: "{app}\Instruction\instruction_kassir.pdf"; WorkingDir: "{app}\Instruction"; IconFilename: "{app}\Instruction\instruction_kassir.pdf"; IconIndex: 0; Tasks: copykas
Name: "{group}\��������� ����������� ���������"; Filename: "{app}\Econv\EConvNew.exe"; WorkingDir: "{app}\Econv"; IconFilename: "{app}\Econv\EConvNew.exe"; IconIndex: 0; Tasks: copyeconv
Name: "{commondesktop}\��������� ����������� ���������"; Filename: "{app}\Econv\EConvNew.exe"; WorkingDir: "{app}\Econv"; IconFilename: "{app}\Econv\EConvNew.exe"; IconIndex: 0; Tasks: copyeconv
Name: "{group}\�������� ��������-�"; Filename: "{app}\Ost\Ost.exe"; WorkingDir: "{app}\Ost"; IconFilename: "{app}\Ost\Ost.exe"; Components: Pharma; Tasks: copyost
Name: "{commondesktop}\�������� ��������-�"; Filename: "{app}\Ost\Ost.exe"; WorkingDir: "{app}\Ost"; IconFilename: "{app}\Ost\Ost.exe"; Components: Pharma; Tasks: copyost
Name: "{group}\���������� ������������� �������"; Filename: "{app}\PharmInfo\PharmInfo.exe"; WorkingDir: "{app}\PharmInfo"; IconFilename: "{app}\PharmInfo\PharmInfo.exe"; Components: PharmaKZ Pharma; Tasks: copysprav
Name: "{commondesktop}\���������� ������������� �������"; Filename: "{app}\PharmInfo\PharmInfo.exe"; WorkingDir: "{app}\PharmInfo"; IconFilename: "{app}\PharmInfo\PharmInfo.exe"; Components: PharmaKZ Pharma; Tasks: copysprav
Name: "{commonstartup}\���������� ������������� �������"; Filename: "{app}\PharmInfo\PharmInfo.exe"; WorkingDir: "{app}\PharmInfo"; IconFilename: "{app}\PharmInfo\PharmInfo.exe"; Parameters: "update"; Components: PharmaKZ Pharma; Tasks: copysprav
Name: "{group}\AmmyAdmin"; Filename: "{app}\AmmyAdmin\a3.exe"; WorkingDir: "{app}\AmmyAdmin"; IconFilename: "{app}\AmmyAdmin\a3.exe"; IconIndex: 0; Tasks: install_AmmyAdmin
Name: "{commondesktop}\���� �����"; Filename: "{app}\AmmyAdmin\a3.exe"; WorkingDir: "{app}\AmmyAdmin"; IconFilename: "{app}\AmmyAdmin\a3.exe"; IconIndex: 0; Tasks: install_AmmyAdmin
Name: "{group}\Total Commander"; Filename: "{app}\Total Commander\TOTALCMD.EXE"; WorkingDir: "{app}\Total Commander"; IconFilename: "{app}\Total Commander\TOTALCMD.EXE"; IconIndex: 0; Tasks: install_TotalCMD
Name: "{commondesktop}\Total Commander"; Filename: "{app}\Total Commander\TOTALCMD.EXE"; WorkingDir: "{app}\Total Commander"; IconFilename: "{app}\Total Commander\TOTALCMD.EXE"; IconIndex: 0; Tasks: install_TotalCMD
Name: "{commondesktop}\nnCron �����������"; Filename: "{pf}\nnCron\tm.exe"; WorkingDir: "{pf}\nnCron"; Flags: createonlyiffileexists; IconFilename: "{pf}\nnCron\tm.exe"; IconIndex: 0; Parameters: "xReg"; Tasks: install_nnCron
Name: "{commonstartup}\������ �������������"; Filename: "{app}\DistributeClient\DistributeClient.exe"; WorkingDir: "{app}\DistributeClient"; IconFilename: "{app}\DistributeClient\DistributeClient.exe"; IconIndex: 0; Tasks: copydtclient
Name: "{commondesktop}\������ �������������"; Filename: "{app}\DistributeClient\DistributeClient.exe"; WorkingDir: "{app}\DistributeClient"; IconFilename: "{app}\DistributeClient\DistributeClient.exe"; IconIndex: 0; Tasks: copydtclient
Name: "{commondesktop}\�������� ������"; Filename: "{app}\Stn Support\STNRemote\STNRemote.exe"; WorkingDir: "{app}\Stn Support\STNRemote"; IconFilename: "{app}\Stn Support\STNRemote\STNRemote.exe"; IconIndex: 0
Name: "{commondesktop}\MailProject"; Filename: "{app}\MailProject\MailProject.exe"; WorkingDir: "{app}\MailProject"; IconFilename: "{app}\MailProject\MailProject.exe"; IconIndex: 0; Tasks: install_mail

[Files]
Source: "c:\standart-n\wamp\www\files\UNZIP.EXE"; DestDir: "{tmp}"; Flags: deleteafterinstall

;��������
Source: \\ALECSANDR\projects\distribs\manager\ManagerXP2.exe; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\first_profile.asni; DestDir: {app}\Manager\�������; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\flower iris.asni; DestDir: {app}\Manager\�������; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\first_profile_base.asni; DestDir: {app}\Manager\�������; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\dbconnect.ini; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\dbf.ini; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\elnaklgrid.ini; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\�����\*.ini; DestDir: {app}\Manager\�����; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\�����\*.asni; DestDir: {app}\Manager\�������; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\*.dll; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\AutoUpdater\update.ini; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\AutoUpdater\wget.exe; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\AutoUpdater\update.bat; DestDir: {app}\Manager; Tasks: copyman;
Source: \\ALECSANDR\projects\distribs\manager\imgs\logo_manager.ico; DestDir: {app}\Manager; Tasks: copyman;
;�������������
Source: \\ALECSANDR\projects\distribs\DistributeClient\*.*;  DestDir: {app}\DistributeClient; Tasks:copydtclient;
;������
Source: \\ALECSANDR\projects\distribs\zkassa\zkassa.exe; DestDir: {app}\Kassir; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\zkassa\default.z; DestDir: {app}\Kassir; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\zkassa\options.ini; DestDir: {app}\Kassir; DestName: options.ini; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\zkassa\*.dll; DestDir: {app}\Kassir; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\manager\�����\*.z; DestDir: {app}\Kassir\�������; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\sbrf\*.*; DestDir: {app}\Kassir\sbrf; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\zkassa\msvcr71\msvcr71.dll; DestDir: {sys}; Tasks: copykas; Check: "not IsWin64";
Source: \\ALECSANDR\projects\distribs\zkassa\msvcr71\msvcr71.dll; DestDir: {syswow64}; Tasks: copykas; Check: "IsWin64";
Source: \\ALECSANDR\projects\distribs\AutoUpdater\update.ini; DestDir: {app}\Kassir; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\AutoUpdater\wget.exe; DestDir: {app}\Kassir; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\AutoUpdater\update.bat; DestDir: {app}\Kassir; Tasks: copykas;
Source: \\ALECSANDR\projects\distribs\manager\imgs\logo.ico; DestDir: {app}\Kassir; Tasks: copykas;
;��������� ��������
Source: \\ALECSANDR\projects\distribs\manager\ServiceMngr\*.*; DestDir: {app}\ServiceMngr; Flags: recursesubdirs createallsubdirs; Tasks: copyServiceMngr;

[Code]
#ifdef UNICODE
  #define AW "W"
#else
  #define AW "A"
#endiftype
  TPositionStorage = array of Integer;
type
    HMONITOR = THandle;
  TMonitorInfo = record
    cbSize: DWORD;
    rcMonitor: TRect;
    rcWork: TRect;
    dwFlags: DWORD;
  end;

 var 
 servername,FullName:String;
 nnCronPage: TInputOptionWizardPage;
 nncronNeed:Boolean;
 DriverPage: TInputOptionWizardPage;
  CompPageModified: Boolean;
  CompPagePositions: TPositionStorage;
 const
  MONITOR_DEFAULTTONULL = $0;
  MONITOR_DEFAULTTOPRIMARY = $1;
  MONITOR_DEFAULTTONEAREST = $2;

function GetMonitorInfo(hMonitor: HMONITOR; out lpmi: TMonitorInfo): BOOL;
  external 'GetMonitorInfo{#AW}@user32.dll stdcall';
function MonitorFromWindow(hwnd: HWND; dwFlags: DWORD): HMONITOR;
  external 'MonitorFromWindow@user32.dll stdcall';

procedure CenterForm(Form: TForm; Horz, Vert: Boolean);
var
  X, Y: Integer;
  Monitor: HMONITOR;
  MonitorInfo: TMonitorInfo;
begin
  if not (Horz or Vert) then
    Exit;
  Monitor := MonitorFromWindow(Form.Handle, MONITOR_DEFAULTTONEAREST);
  MonitorInfo.cbSize := SizeOf(MonitorInfo);
  if GetMonitorInfo(Monitor, MonitorInfo) then
  begin
    if not Horz then
      X := Form.Left
    else
      X := MonitorInfo.rcWork.Left + ((MonitorInfo.rcWork.Right -
        MonitorInfo.rcWork.Left) - Form.Width) div 2;
    if not Vert then
      Y := Form.Top
    else
      Y := MonitorInfo.rcWork.Top + ((MonitorInfo.rcWork.Bottom -
        MonitorInfo.rcWork.Top) - Form.Height) div 2;
    Form.SetBounds(X, Y, Form.Width, Form.Height);
  end;
end;

procedure SaveComponentsPage(out Storage: TPositionStorage);
begin
  SetArrayLength(Storage, 10);

  Storage[0] := WizardForm.Height;
  Storage[1] := WizardForm.NextButton.Top;
  Storage[2] := WizardForm.BackButton.Top;
  Storage[3] := WizardForm.CancelButton.Top;
  Storage[4] := WizardForm.TasksList.Height;
  Storage[5] := WizardForm.OuterNotebook.Height;
  Storage[6] := WizardForm.InnerNotebook.Height;
  Storage[7] := WizardForm.Bevel.Top;
  Storage[8] := WizardForm.BeveledLabel.Top;
  Storage[9] := WizardForm.ComponentsDiskSpaceLabel.Top;
end;

procedure LoadComponentsPage(const Storage: TPositionStorage;
  HeightOffset: Integer);
begin
  if GetArrayLength(Storage) <> 10 then
    RaiseException('Invalid storage array length.');

  WizardForm.Height := Storage[0] + HeightOffset;
  WizardForm.NextButton.Top := Storage[1] + HeightOffset;
  WizardForm.BackButton.Top := Storage[2] + HeightOffset;
  WizardForm.CancelButton.Top := Storage[3] + HeightOffset;
  WizardForm.TasksList.Height := Storage[4] + HeightOffset;
  WizardForm.OuterNotebook.Height := Storage[5] + HeightOffset;
  WizardForm.InnerNotebook.Height := Storage[6] + HeightOffset;
  WizardForm.Bevel.Top := Storage[7] + HeightOffset;
  WizardForm.BeveledLabel.Top := Storage[8] + HeightOffset;
  WizardForm.ComponentsDiskSpaceLabel.Top := Storage[9] + HeightOffset;
end;

function Info(Param:string):String;
var ComputerName : string;
begin
   if FullName <> '' then
    Result:=FullName else Result:='��� ��������-�, ������������� ��������';//ExpandConstant('{Fullname}');;
end;

function IsWindowsVersionOrNewer(Major, Minor: Integer): Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result :=
    (Version.Major > Major) or
    ((Version.Major = Major) and (Version.Minor >= Minor));
end;

function IsWindowsXPOrNewer: Boolean;
begin
  Result := IsWindowsVersionOrNewer(5, 1);
end;

function IsWindowsVistaOrNewer: Boolean;
begin
  Result := IsWindowsVersionOrNewer(6, 0);
end;

function IsWindows7OrNewer: Boolean;
begin
  Result := IsWindowsVersionOrNewer(6, 1);
end;

procedure SetIPv6(del: Boolean);
var
  WindowsVersion: Integer;
  ResultCode: Integer;
  Command: String;
begin
  Command := 'REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v KeepAliveTime /t REG_DWORD /d 60000 /f';
  exec(ExpandConstant('{cmd}'), '/C ' + Command, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Command := 'REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v KeepAliveInterval /t REG_DWORD /d 10000 /f';
  Exec(ExpandConstant('{cmd}'), '/C ' + Command, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Command := 'REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v TCPMaxDataRetransmissions /t REG_DWORD /d 3 /f';
  Exec(ExpandConstant('{cmd}'), '/C ' + Command, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  if del then begin
        Command := 'reg add HKLM\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters /v DisabledComponents /t reg_dword /d 0xff /f';
        Exec(ExpandConstant('{cmd}'), '/C ' + Command, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
        Log(SysErrorMessage(ResultCode));  
        end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  case PageID of        
    DriverPage.ID: Result := not IsTaskSelected('install_driverT');
  end;
  //case PageID of
    //ServerPage.ID: Result := true;//not IsTaskSelected('install_server');
  //end;
  case PageID of
    nnCronPage.ID: Result := not IsTaskSelected('install_nnCron');
  end;
 
end;
 
procedure InitializeWizard();
  
begin
servername:='http://127.0.0.1';
    idpDownloadAfter(wpReady);
CompPageModified := False;
FullName:='fff';
//����������� nnCron
 if IsWindows7OrNewer then 
 begin
  nnCronPage := CreateInputOptionPage(wpSelectTasks, '����������� nnCron', '����������� nnCron',
       '���������� ��������� ������������ nnCron?', True, False);
  nnCronPage.Add('����������� nnCron 1.93 (��� Windows 7)');
  nnCronPage.Add('��������� ����������� Windows (��� Windows 7 � ����)');
  nnCronPage.SelectedValueIndex := 1;
 end;
 //�������� ��� � ���
  DriverPage := CreateInputOptionPage(wpSelectTasks, '������� ��������� ������������', '��� ������ � �������� ������������� ���������� ���������� �������',
    '� ����� ��������� �������� ���� �������� ������������?', True, False);
  DriverPage.Add('������� "���� v.8.14: ������� ���"');  
  DriverPage.Add('������� "�����-�: ������� �� v.4.14"'); 
  DriverPage.Add('������� "�����-�: USB ������� �� "');   
  DriverPage.Add('������� ������ MC2WIN');               
  DriverPage.SelectedValueIndex := 0;
  
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
   
function NeedFirebird:Boolean;
begin
Result:=True;
if RegKeyExists(HKLM,'SOFTWARE\Firebird Project\Firebird Server')then Result:=False;
end;

Function nnCronNeed1:Boolean;
Begin
if nnCronNeed then Result:=True else Result:=False;
end;
function Atol:Boolean;
begin
 if DriverPage.SelectedValueIndex=0 then Result:=True else Result:=False;
end;

function Shtrih:Boolean;
begin
 if DriverPage.SelectedValueIndex=1 then Result:=True else Result:=False;
end;

function ShtrihUSB:Boolean;
begin
 if DriverPage.SelectedValueIndex=2 then Result:=True else Result:=False;
end;

function Mebius:Boolean;
begin
 if DriverPage.SelectedValueIndex=3 then Result:=True else Result:=False;
end;

function InitializeSetup(): Boolean;
var
  FullName : string;
begin
   Result := true;
   if RegKeyExists(HKLM,'SOFTWARE\Firebird Project\Firebird Server') and (RegKeyExists(HKLM,'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FBDBServer_2_5_is1')=false) then
    begin
     Result:=false;
     MsgBox(''+#13#10+'��������!'+#13#10+'���� Firebird ������������� �� ����� ����������, �� ������������ ����������� ��� ������ ������ - 2.5.'#13#10+
       '��� ������ ������������� ���������� ������� ������� ��� �������� ������ ���� Firebird �� 2.5 � ����.', mbInformation, MB_OK);
    end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;

var Index:integer;
//ResultCode: integer;
begin
   Result := True;

 if CurpageID = wpSelectComponents then
  begin
    if IsComponentSelected('Pharma') then 
    FullName:='��� ��������-�, ������������� ��������, ������������ ������';
    if IsComponentSelected('PharmaKZ') then 
    FullName:='��� ��������-�, ������������� ��������, ������������ ������ ���������';
    if IsComponentSelected('dress') then 
    FullName:='��� ��������-�, ������������� ��������, ������������ ������';
    if IsComponentSelected('food') then 
    FullName:='��� ��������-�, ������������� ��������, ������������ ��������';
    if IsComponentSelected('hoz') then 
    FullName:='��� ��������-�, ������������� ��������, ������������ ������������� �������';
    if IsComponentSelected('tech') then 
    FullName:='��� ��������-�, ������������� ��������, ������������ �������';
   end;


   if CurPageID = wpSelectTasks then
   begin

     RegWriteStringValue(HKEY_CURRENT_USER,'Software\Standart-N','Path',ExpandConstant('{app}'));
     if IsTaskSelected('install_po_SHK') then
       begin
       if IsWindows7OrNewer then 
         idpAddFile(servername+'/Files/datasnip/datasnip.exe', ExpandConstant('{tmp}\com2kbd.exe'))
       else
         idpAddFile(servername+'/Files/com2kbd/com2kbd.exe', ExpandConstant('{tmp}\com2kbd.exe'));
       end;
    
     if IsTaskSelected('install_server') then
       begin
        if NeedFirebird then
         begin
          idpAddFile(servername+'/Files/firebird/firebird.conf', ExpandConstant('{tmp}\firebird.conf'))     
          if IsWin64 then
           idpAddFile(servername+'/Files/firebird/x64/fb25_x64.exe', ExpandConstant('{tmp}\fbserver.exe'))     
          else
           idpAddFile(servername+'/Files/firebird/win32/fb25_win32.exe', ExpandConstant('{tmp}\fbserver.exe'));     
         end;
       end;

    if IsTaskSelected('copyost') then
     begin
     idpAddFile(servername+'/Files/Ost/Ost.exe', ExpandConstant('{tmp}\Ost.exe'));     
     end;

    if IsTaskSelected('install_nnCron') and IsWindowsXPOrNewer and IsWindowsVistaOrNewer=False then 
     begin  
     idpAddFile(servername+'/Files/nnCron/nncron191.exe', ExpandConstant('{tmp}\nncron.exe'));  
     nnCronNeed:=True
     end;
         
    if IsTaskSelected('ip') then
          SetIPv6(true)
        else
          SetIPv6(false);


    if IsTaskSelected('copyIBExpert') then
     begin
      idpAddFile(servername+'/Files/IBExpert/IBExpert.exe', ExpandConstant('{tmp}\IBExpert.exe'));     
     end;

    if IsTaskSelected('copysprav') then
     begin
      idpAddFile(servername+'/Files/PharmInfo/PharmInfo.exe', ExpandConstant('{tmp}\PharmInfo.exe'));     
     end;
         if IsTaskSelected('copybase') then
     begin
      if IsComponentSelected('Pharma') then
      idpAddFile(servername+'/Files/base/Pharma/ztrade.zip', ExpandConstant('{tmp}\ztrade.zip'));

      if IsComponentSelected('dress') then
      idpAddFile(servername+'/Files/base/dress/ztrade.zip', ExpandConstant('{tmp}\ztrade.zip'));
    
      if IsComponentSelected('food') then
      idpAddFile(servername+'/Files/base/food/ztrade.zip', ExpandConstant('{tmp}\ztrade.zip'));       

      if IsComponentSelected('hoz') then
      idpAddFile(servername+'/Files/base/hoz/ztrade.zip', ExpandConstant('{tmp}\ztrade.zip'));

      if IsComponentSelected('tech') then
      idpAddFile(servername+'/Files/base/tech/ztrade.zip', ExpandConstant('{tmp}\ztrade.zip'));

      if IsComponentSelected('PharmaKZ') then
      idpAddFile(servername+'/Files/base/PharmaKZ/ztrade.zip', ExpandConstant('{tmp}\ztrade.zip'));
     end;

    if IsTaskSelected('copyeconv') then
     begin
      idpAddFile(servername+'/Files/Econv/Econv.exe', ExpandConstant('{tmp}\Econv.exe'));     
     end;
   
    if IsTaskSelected('install_mail') then
     begin
      idpAddFile(servername+'/Files/MailProject/MailProject.exe', ExpandConstant('{tmp}\MailProject.exe'));     
     end;
    
   if IsTaskSelected('copysms') then
     begin
      idpAddFile(servername+'/Files/SMS/msxml_4_sp2.msi', ExpandConstant('{tmp}\msxml_4_sp2.msi'));     
     end;
   
   if IsTaskSelected('install_vnc') then
     begin
      idpAddFile(servername+'/Files/vnc/VNCInstaller.exe', ExpandConstant('{tmp}\VNCInstaller.exe'));     
      idpAddFile(servername+'/Files/STN_Support/STNRemote.zip', ExpandConstant('{tmp}\STNRemote.zip'));
     end;
     
      if IsTaskSelected('install_TeamViewer') then
     begin
      idpAddFile(servername+'/Files/teamviewer/TeamViewer.exe', ExpandConstant('{tmp}\TeamViewer.exe'));     
     end;  
      
     if IsTaskSelected('install_AmmyAdmin') then
     begin
      idpAddFile(servername+'/Files/AmmyAdmin/a3.zip', ExpandConstant('{app}\AmmyAdmin\a3.zip'));     
     end;

     if IsTaskSelected('install_ChromeSetup') then
     begin
      idpAddFile(servername+'/Files/ChromeSetup/ChromeSetup.exe', ExpandConstant('{tmp}\ChromeSetup.exe'));     
     end;    
     if IsTaskSelected('install_DBFNavigator') then
     begin
      idpAddFile(servername+'/Files/DBFNavigator/DBFNavigator.exe', ExpandConstant('{tmp}\DBFNavigator.exe'));     
     end;
     
      if IsTaskSelected('install_TotalCMD') then
     begin
      idpAddFile(servername+'/Files/Total Commander/Total Commander.exe', ExpandConstant('{tmp}\Total Commander.exe'));     
     end;
     
       if IsTaskSelected('install_FAR') then
     begin
      idpAddFile(servername+'/Files/far/Far30b4040.x86.20140810.msi', ExpandConstant('{tmp}\Far30b4040.x86.20140810.msi'));     
     end;
     
      if IsTaskSelected('install_7zip') then
     begin
      if iswin64 then  
      idpAddFile(servername+'/Files/7z1602-x64.exe', ExpandConstant('{tmp}\7zip.exe'))
      else
      idpAddFile(servername+'/Files/7z1602.exe', ExpandConstant('{tmp}\7zip.exe'))     
     end;

     if IsTaskSelected('copyexport') then
     begin
      idpAddFile(servername+'/Files/Export/Export.exe', ExpandConstant('{tmp}\Export.exe'));     
     end;
      if IsTaskSelected('copydiscount') then
     begin
      idpAddFile(servername+'/Files/discount/discount.exe', ExpandConstant('{tmp}\discount.exe'));     
     end;
    if IsTaskSelected('copyzclientxp') then
     begin
      idpAddFile(servername+'/Files/ZClientXP4/ZClientXPInstaller.exe', ExpandConstant('{tmp}\ZClientXPInstaller.exe'));     
     end;
  end;
if IsTaskSelected('install_driverT') then
      begin
       case CurPageID of
        DriverPage.ID:
         begin
          if DriverPage.SelectedValueIndex = 0 then
           begin
             idpAddFile(servername+'/Files/ATOL/KKT_8_14_02_02_Full.exe', ExpandConstant('{tmp}\KKT_8_14_02_02_Full.exe'));
             idpAddFile(servername+'/Files/ATOL/EoU.zip', ExpandConstant('{app}\EoU.zip'));
           end;
          if DriverPage.SelectedValueIndex = 1 then
           begin
            idpAddFile(servername+'/Files/shtrih/drv.exe', ExpandConstant('{tmp}\drv.exe'));     
           end;
          if DriverPage.SelectedValueIndex = 2 then
           begin
             if IsWindowsVistaOrNewer then
              idpAddFile(servername+'/Files/shtrih/USB-RS232-Vista_Installer.exe', ExpandConstant('{tmp}\USB-RS232-Setup.exe'))     
             else
              idpAddFile(servername+'/Files/shtrih/USB-RS232-Setup.exe', ExpandConstant('{tmp}\USB-RS232-Setup.exe'));     
           end;
          if DriverPage.SelectedValueIndex = 3 then
           begin
            idpAddFile(servername+'/Files/MC2WIN/MC2WIN.exe', ExpandConstant('{tmp}\MC2WIN.exe'));     
           end;
         end;
        end;
       end;
 if IsTaskSelected('install_nnCron') and IsWindows7OrNewer then
       begin
        case CurPageID of
          nnCronPage.ID:
         begin
           if nnCronPage.SelectedValueIndex = 0 then
             begin
              nnCronNeed:=True
              idpAddFile(servername+'/Files/nnCron/nncron193b10.exe', ExpandConstant('{tmp}\nncron.exe'));
             end
           else 
             begin
              nnCronNeed:=False;
              idpAddFile(servername+'/Files/WinScheduler/1backup.xml', ExpandConstant('{tmp}\1������� ��������� �����.xml'));
              idpAddFile(servername+'/Files/WinScheduler/2deleteengpos.xml', ExpandConstant('{tmp}\2������� ������������ �������.xml'));
              idpAddFile(servername+'/Files/WinScheduler/3ClearBackup.xml', ExpandConstant('{tmp}\3�������� ������� ��������� �����.xml'));
              idpAddFile(servername+'/Files/WinScheduler/4Restore.xml', ExpandConstant('{tmp}\4����� � ������������ ����.xml'));
              idpAddFile(servername+'/Files/WinScheduler/5Shdwn.xml', ExpandConstant('{tmp}\5���������� ����������.xml'));
              idpAddFile(servername+'/Files/WinScheduler/6MailProject.xml', ExpandConstant('{tmp}\6��������� ����� ����� MailProject.xml'));
              idpAddFile(servername+'/Files/WinScheduler/7Malohod.xml', ExpandConstant('{tmp}\7������ ������������ ������.xml'));
              idpAddFile(servername+'/Files/WinScheduler/Shdwn.bat', ExpandConstant('{tmp}\Shdwn.bat'));
             end;  
         end;
       end;
      end;
end;

procedure OpenFirewall;
var
  WindowsVersion: Integer;
  ResultCode: Integer;
  WXPCommand,W7Command,W7Command1: String;
begin               
  WXPCommand := 'netsh firewall add portopening TCP'// 3050 "firebird"';
  W7Command := 'netsh advfirewall firewall add rule name="';//radmin" protocol=TCP dir=in localport=3050 action=allow';
  W7Command1 := '" protocol=TCP dir=in localport=';//3050 action=allow';
  WindowsVersion := GetWindowsVersion();
  case WindowsVersion of
    5:
    begin
      Exec(ExpandConstant('{cmd}'), '/C ' + WXPCommand + '3050 "firebird1"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Log(SysErrorMessage(ResultCode));
      Exec(ExpandConstant('{cmd}'), '/C ' + WXPCommand + '3055 "firebird2"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Log(SysErrorMessage(ResultCode));
      Exec(ExpandConstant('{cmd}'), '/C ' + WXPCommand + '4899 "radmin server"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Log(SysErrorMessage(ResultCode));
    end;
    else
      begin
      Exec(ExpandConstant('{cmd}'), '/C ' + W7Command + 'firebird1' + W7Command1 + '3050' + ' action=allow' , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Log(SysErrorMessage(ResultCode));
      Exec(ExpandConstant('{cmd}'), '/C ' + W7Command + 'firebird2' + W7Command1 + '3055' + ' action=allow' , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Log(SysErrorMessage(ResultCode));
      Exec(ExpandConstant('{cmd}'), '/C ' + W7Command + 'radmin server' + W7Command1 + '4899' + ' action=allow' , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Log(SysErrorMessage(ResultCode));
      
      
    end;
  end;


  Exec(ExpandConstant('{cmd}'), '/C ' + 'netsh advfirewall firewall add rule name="Manager1" dir=in program='+ExpandConstant('{app}')+'\Manager\ManagerXP2.exe action=allow', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'netsh advfirewall firewall add rule name="Manager2" dir=out program='+ExpandConstant('{app}')+'\Manager\ManagerXP2.exe action=allow', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'netsh advfirewall firewall add rule name="Kassir1" dir=in program='+ExpandConstant('{app}')+'\Kassir\zkassa.exe action=allow', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'netsh advfirewall firewall add rule name="Kassir2" dir=out program='+ExpandConstant('{app}')+'\Kassir\zkassa.exe action=allow', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'netsh advfirewall firewall add rule name="FireBird Server" dir=in action=allow program="C:\Program Files\Firebird\Firebird_2_5\bin\fbserver.exe" enable=yes','', SW_HIDE, ewWaitUntilTerminated, ResultCode); 
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'netsh advfirewall firewall add rule name="FireBird Server" dir=out action=allow program="C:\Program Files\Firebird\Firebird_2_5\bin\fbserver.exe" enable=yes','', SW_HIDE, ewWaitUntilTerminated, ResultCode); 
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'powercfg -x -monitor-timeout-ac 0', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'powercfg -x -standby-timeout-ac 0', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));
  Exec(ExpandConstant('{cmd}'), '/C ' + 'powercfg -x -disk-timeout-ac 0', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Log(SysErrorMessage(ResultCode));


end; 

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurpageID = wpSelectTasks then
  begin
    SaveComponentsPage(CompPagePositions);
    LoadComponentsPage(CompPagePositions, 200);
    CenterForm(WizardForm, False, True);
    CompPageModified := True;
  end
  else
  if CompPageModified then
  begin
    LoadComponentsPage(CompPagePositions, 0);
    CompPageModified := False;
  end;
  
 
end;

function GetDriveType(nDrive: string): Longint;
  external 'GetDriveTypeA@kernel32.dll stdcall';

procedure CurStepChanged(CurStep: TSetupStep);
var
 f,i,d:string;
 cmdString: String;
 ResultCode:integer;
 ErrorCode: Integer;  
  langUser: String;
  intvalue: Integer; 
  strBackUp: String;
  strProt: String;

begin
 RegQueryStringValue(HKEY_LOCAL_MACHINE, 'Software\Firebird Project\Firebird Server\Instances', 'DefaultInstance',f);
 f:=f+'firebird.conf';
 d:='#RemoteAuxPort = 0';
 i:='RemoteAuxPort = 3055';
 if IsTaskSelected('install_server') then CngFile(f,i,d,CurStep);
 //������� ����� ��� �������/���������� � ����������� ���� � ��� � ������� (���� ���� D ����, �� �� ����, ����� ������ �� ���� C)
  if CurStep =  ssInstall then
  Begin
     //���� ��� ����� D 'DRIVE_FIXED'(3) �� ����� ������ �� ���, ����� ������ �� ���� C
     IF GetDriveType('d:\') = 3 Then
         Begin
           strBackUp:= 'D:\STANDART-N\BackUp';
           strProt:= 'D:\STANDART-N\Prot';
           IF Not FileExists(strBackUp) Then  ForceDirectories(strBackUp);
           IF Not FileExists(strProt) Then  ForceDirectories(strProt);           
           RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Standart-N', 'PathBackUp',strBackUp);
           RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Standart-N', 'PathProt',strProt);
           //MsgBox(strProt, mbInformation, MB_OK);
         End
     Else
         Begin
           strBackUp:= 'C:\STANDART-N\BackUp';
           strProt:= 'C:\STANDART-N\Prot';
           IF Not FileExists(strBackUp) Then  ForceDirectories(strBackUp);
           IF Not FileExists(strProt) Then  ForceDirectories(strProt);           
           RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Standart-N', 'PathBackUp',strBackUp);
           RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Standart-N', 'PathProt',strProt);
         End;
  End;
  
  {����������� �����}
  if CurStep =  ssDone then //ssPostInstall
  begin
    cmdString := '';
    //���������� ���� ��
    if GetUILanguage and $3FF = $09 then langUser:='All'; {LangEnglish}
    if GetUILanguage and $3FF = $19 then langUser:='���'; {LangRUS}
    If (Trim(langUser) <> '') then
    Begin
      {��������� � ������ ����� ������������ "���|ALL"}
       cmdString := '/c cacls "' +ExpandConstant('{app}')+ '" /T /E /G ' + langUser + ':F';                     
       //MsgBox(cmdString, mbInformation, MB_OK);
       ShellExec('', ExpandConstant('{cmd}'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ErrorCode)
      {����������� ����� � ��������� ������������ ������ ������}
       cmdString := '/c net share "STANDART-N='+ExpandConstant('{app}')+'" /GRANT:' + langUser + ',FULL';
       ShellExec('', ExpandConstant('{cmd}'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) //��� Win7, 8

       cmdString := '/c net share "STANDART-N='+ExpandConstant('{app}')+'"';       
       ShellExec('', ExpandConstant('{cmd}'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) //��� WinXP
    end;
  end;

 if (CurStep = ssPostInstall) and (nnCronPage.SelectedValueIndex = 1) then
 begin
    cmdString :=  '/Create /XML "'+ExpandConstant('{tmp}\1������� ��������� �����.xml')+'" /TN "1������� ��������� �����"';
           Exec(ExpandConstant('{sys}\schtasks.exe'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

           cmdString :=  '/Create /XML "'+ExpandConstant('{tmp}\2������� ������������ �������.xml')+'" /TN "2������� ������������ �������"';
            Exec(ExpandConstant('{sys}\schtasks.exe'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

           cmdString :=  '/Create /XML "'+ExpandConstant('{tmp}\3�������� ������� ��������� �����.xml')+'" /TN "3�������� ������� ��������� �����"';
            Exec(ExpandConstant('{sys}\schtasks.exe'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

           cmdString :=  '/Create /XML "'+ExpandConstant('{tmp}\4����� � ������������ ����.xml')+'" /TN "4����� � ������������ ����"';
           Exec(ExpandConstant('{sys}\schtasks.exe'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

           cmdString :=  '/Create /XML "'+ExpandConstant('{tmp}\5���������� ����������.xml')+'" /TN "5���������� ����������"';
            Exec(ExpandConstant('{sys}\schtasks.exe'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

           cmdString :=  '/Create /XML "'+ExpandConstant('{tmp}\6��������� ����� ����� MailProject.xml')+'" /TN "6��������� ����� ����� MailProject"';
           Exec(ExpandConstant('{sys}\schtasks.exe'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

           cmdString :=  '/Create /XML "'+ExpandConstant('{tmp}\7������ ������������ ������.xml')+'" /TN "7������ ������������ ������"';
           Exec(ExpandConstant('{sys}\schtasks.exe'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

  end;
  {����������� �����}
  if CurStep =  ssDone then //ssPostInstall
  begin
    OpenFirewall; //���������� ���������� �������
    cmdString := '';
    //���������� ���� ��
    if GetUILanguage and $3FF = $09 then langUser:='All'; {LangEnglish}
    if GetUILanguage and $3FF = $19 then langUser:='���'; {LangRUS}
    If (Trim(langUser) <> '') then
    Begin
      {��������� � ������ ����� ������������ "���|ALL"}
       cmdString := '/c cacls "' +ExpandConstant('{app}')+ '" /T /E /G ' + langUser + ':F';                     
       //MsgBox(cmdString, mbInformation, MB_OK);
       ShellExec('', ExpandConstant('{cmd}'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ErrorCode)
      {����������� ����� � ��������� ������������ ������ ������}
       cmdString := '/c net share "STANDART-N='+ExpandConstant('{app}')+'" /GRANT:' + langUser + ',FULL';
       ShellExec('', ExpandConstant('{cmd}'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) //��� Win7, 8

       cmdString := '/c net share "STANDART-N='+ExpandConstant('{app}')+'"';       
       ShellExec('', ExpandConstant('{cmd}'), cmdString , '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) //��� WinXP

    end;
 end;

 

end;




[run]
Filename: "{tmp}\com2kbd.exe";Parameters: " /silent"; Tasks:install_po_SHK; 
Filename: "{tmp}\KKT_8_14_02_02_Full.exe"; Tasks:install_driverT; Check: Atol; 
Filename: "{tmp}\drv.exe"; Tasks:install_driverT;Check: Shtrih; 
Filename: "{tmp}\USB-RS232-Setup.exe"; Tasks:install_driverT; Check:ShtrihUSB;
Filename: "{tmp}\MC2WIN.exe";Parameters: " /silent"; Tasks:install_driverT;Check:Mebius;
Filename: "{tmp}\fbserver.exe";Parameters: " /VERYSILENT"; Tasks:install_server; Check:NeedFirebird;
Filename: "{tmp}\Ost.exe";Parameters: " /silent"; Tasks:copyost;
Filename: "{tmp}\nncron.exe"; Tasks:install_nnCron;Check:nnCronNeed1;
Filename: "{tmp}\IBExpert.exe";Parameters: " /silent"; Tasks:copyIBExpert;
Filename: "{tmp}\PharmInfo.exe";Parameters: " /silent"; Tasks:copysprav;
Filename: "{tmp}\ZClientXPInstaller.exe"; Tasks:copyzclientxp;Filename: "{tmp}\Econv.exe";Parameters: " /silent"; Tasks:copyeconv;
Filename: "{tmp}\MailProject.exe";Parameters: " /silent"; Tasks:install_mail;
Filename: "{tmp}\discount.exe";Parameters: " /silent"; Tasks:copydiscount;
Filename: "{tmp}\msxml_4_sp2.msi"; Description: "������ ��� ��������"; Flags: nowait shellexec; Tasks: copysms;
Filename: "{tmp}\Export.exe";Parameters: " /silent"; Tasks:copyexport;
Filename: "{tmp}\VNCInstaller.exe"; Description: "���. ��������� VNC"; Flags: nowait shellexec; Tasks: install_vnc;
Filename: "{tmp}\TeamViewer.exe"; Description: "���������� TeamViewer 5"; Flags: nowait; Tasks: install_TeamViewer;
Filename: "{tmp}\ChromeSetup.exe"; Tasks:install_ChromeSetup;
Filename: "{tmp}\DBFNavigator.exe";Parameters: " /silent"; Tasks:install_DBFNavigator;
Filename: "{tmp}\Total Commander.exe";Parameters: " /silent"; Tasks:install_TotalCMD;
Filename: "{tmp}\Far30b4040.x86.20140810.msi";  Flags: nowait shellexec; Tasks: install_FAR;
Filename: "{tmp}\7zip.exe";Parameters: " /S"; Tasks:install_7zip;
Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\ztrade.zip -d -o {app}\base\";Tasks:copybase;
Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\STNRemote.zip -d -o {app}\Stn Support\STNRemote\";Tasks:install_vnc;
Filename: "{tmp}\UNZIP.EXE"; Parameters: "{app}\AmmyAdmin\a3.zip -d -o {app}\AmmyAdmin\";Tasks:install_AmmyAdmin;


      
