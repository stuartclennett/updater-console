program phoenix;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Winapi.Windows,
  Winapi.Messages,
  ShellApi,
  tlHelp32,
  System.classes,
  ioutils,
  functionsServiceControl2 in '..\SharedCode\functionsServiceControl2.pas',
  FunctionsCommandLine in '..\SharedCode\FunctionsCommandLine.pas';

type
  TUpdaterOption = (uoIsService, uoNoRestart);
  TUpdaterOptions = set of TUpdaterOption;

  EUpdaterException = class(Exception);
  EMissingRunningApp = class(EUpdaterException);
  EMissingNewApp = class(EUpdaterException);
  EMissingServiceName = class(EUpdaterException);
  ECannotDeleteOldFile = class(EUpdaterException);
  ECannotRenameFile = class(EUpdaterException);
  ECannotTerminateApp = class(EUpdaterException);
  EServiceControlException = class(EUpdaterException);
  EFailedToStartService = class(EUpdaterException);
  EFailedToStopService = class(EUpdaterException);

function Kill(ExeFileName: string): boolean;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  aEXEFileName: string;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  aEXEFileName := TPath.GetFileName(ExeFileName);
  Result := True; // true means it's NOT running as this function is designed to make sure the process isn't running
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(aExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(aExeFileName))) then
      result := TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), fProcessEntry32.th32ProcessID), 0); // false result means it couldn't terminate existing app
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure Lazarus(ExeName: string; Params: string);
var
  StartInfo    : TStartupInfo;
  ProcessInfo  : TProcessInformation;
  aPath        : PWideChar;
begin

//  ShellExecute(0, 'open', PWideChar(ExeName), PWideChar(Params), '', SW_SHOW);

  // will raise an appropriate exception
  FillChar(StartInfo, SizeOf(StartInfo), 0);
  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.lpReserved := nil;
  StartInfo.lpDesktop := nil;
  StartInfo.lpTitle := nil;
  StartInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := SW_SHOW;
  StartInfo.cbReserved2 := 0;
  StartInfo.lpReserved2 := nil;

  if Params = EmptyStr then
    aPath := PWideChar(ExeName)
  else
    aPath := PWideChar(ExeName + ' ' + Params);

  if not CreateProcess(nil, aPath, nil, nil, True, HIGH_PRIORITY_CLASS, nil, nil, StartInfo, ProcessInfo) then
    RaiseLastOSError;

end;

procedure Main;
var
  aServiceName,
  aOldFilename,
  aRunningApp,
  aNewApp, aNewCommandLine,
  P             : string;
  Options       : TUpdaterOptions;
  I             : Integer;
  aIsTerminated : boolean;
  aStatus: TServiceControlStatus;
  x: Cardinal;
  elapsed: Cardinal;
const
  OLD_EXT = '.old';
begin

  WriteLn(GetCurrentDir);

  aRunningApp := GetParamStr(1);
  aNewApp := GetParamStr(2);
  aNewCommandLine := '';
  Options := [];
  if GetParamCount > 2 then
    for I := 3 to GetParamCount do
    begin
      P := GetParamStr(I);
      if (p = '-s') then
        Include(Options, uoIsService);
      if (p = '-n') then
        Include(Options, uoNoRestart);
      if Copy(p, 1, 4) = '-sn:' then
        aServiceName := Copy(p, 5, length(p));
      // -p = passthru, so we will add the text of the param to the new command line when restarting
      if Copy(p, 1, 3) = '-p:' then
        aNewCommandLine := aNewCommandLine + Copy(p, 4, length(p));
    end;

  if not TPath.IsPathRooted(aRunningApp) then
    aRunningApp := TPath.Combine(GetCurrentDir, aRunningApp);

  if not FileExists(aRunningApp) then
    raise EMissingRunningApp.Create(aRunningApp + ' does not exist');

  if not TPath.IsPathRooted(aNewApp) then
    aNewApp := TPath.Combine(GetCurrentDir, aNewApp);

  if not fileExists(aNewApp) then
    raise EMissingNewApp.Create(aNewApp + ' does not exist');

  WriteLn('Running = ' + aRunningApp);
  WriteLn('New = ' + aNewApp);

  if (uoIsService in Options) and (not (uoNoRestart in Options)) and (aServiceName = EmptyStr) then
    raise EMissingServiceName.Create('Missing service name for isService requiring restart');

  // pass the same filename for both params and it'll just restart !
  if not SameText(aRunningApp, aNewApp) then
  begin

    WriteLn('The two files are different.. entering renaming protocol');

    aOldFilename := TPath.ChangeExtension(aRunningApp, OLD_EXT);

    if FileExists(aOldFileName) then
      if not System.SysUtils.DeleteFile(aOldFileName) then
        raise ECannotDeleteOldFile.Create('Cannot delete ' + aOldFilename);

    if not RenameFile(aRunningApp, aOldFilename) then
      raise ECannotRenameFile.Create('Cannot rename ' + aRunningApp + ' to ' + aOldFilename);

    if not RenameFile(aNewApp, aRunningApp) then
      raise ECannotRenameFile.Create('Cannot rename ' + aNewApp+ ' to ' + aRunningApp);

  end else
    WriteLn('The two files are the same -- skipping the rename protocol');

  // restarting
  if not (uoNoRestart in Options) then
  begin
    WriteLn('Starting the restart protocol');

    if uoIsService in Options then
    begin
      // we've checked for exceptions (ie missing service name earlier in the list)
      aStatus := TServiceControl.GetServiceStatus(aServiceName);

      case aStatus of
        svFailedAccess: raise EServiceControlException.Create('Failed to access the service ' + aServiceName);
        svFailedSCMAccess: raise EServiceControlException.Create('Failed to access the service control manager');
      end;

      // we wait for the status to resolve itself if it's pending in anyway
      x := GetTickCount;
      while (elapsed < 10000) and (aStatus in [svStartPending, svStopPending, svContinuePending, svPausePending]) do
      begin
        elapsed := GetTickCount - x;
        aStatus := TServiceControl.GetServiceStatus(aServiceName);
      end;

      if aStatus in [svStopped] then
        WriteLn('Service ' + aServiceName + ' is already stopped');

      WriteLn('Starting ' + aServiceName);

      // if it's alive.. we stop it
      if aStatus in [svRunning] then
        if not TServiceControl.StopServer(aServiceName, False) then
          raise EFailedToStopService.Create('Could not stop ' + aServiceName);

      aStatus := TServiceControl.GetServiceStatus(aServiceName);

      if aStatus = svStopped then
        if not TServiceControl.StartServer(aServiceName, False) then
          raise EFailedToStartService.Create('Could not start ' + aServiceName);

      if aStatus in [svRunning] then
        WriteLn('Service ' + aServiceName + ' is running');

    end else
    begin
      // how to terminate and restart the -- see KillAqrepl DLL !
      WriteLn('Stopping app ' + aRunningApp );

      aIsTerminated := kill(aRunningApp);  // or wasn't running in the first place
      if not aIsTerminated then
        raise ECannotTerminateApp.Create('Cannot terminate app ' + aRunningApp);
      WriteLn('Starting app ' + aRunningApp );
      Lazarus(aRunningApp, aNewCommandLine);
      WriteLn('App ' + aRunningApp + ' started');
    end;
  end;


end;

begin
  try
    Main();
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ReadLn;
    end;
  end;
end.
