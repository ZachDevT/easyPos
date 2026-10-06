[Setup]
AppId={{EASYPOS-12345678-ABCD}
AppName=EasyPOS
AppVersion=1.0
AppPublisher=ZachDevT
DefaultDirName={autopf}\EasyPOS
DefaultGroupName=EasyPOS
OutputDir=Output
OutputBaseFilename=YellowPos_Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\easypos.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\EasyPOS"; Filename: "{app}\easypos.exe"
Name: "{autodesktop}\EasyPOS"; Filename: "{app}\easypos.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\easypos.exe"; Description: "{cm:LaunchProgram,EasyPOS}"; Flags: nowait postinstall skipifsilent
