unit uMutex;

interface

implementation

uses
  Windows, SysUtils, Dialogs;

var
  mHandle: THandle;

initialization
  mHandle := CreateMutex(nil,true,'SilversunJimbo');
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    MessageDlg('Die Anwendung läuft bereits',mtInformation,[mbOK],0);
    Halt;
  end;

finalization
  if mHandle <> 0 then CloseHandle(mHandle)

end.
