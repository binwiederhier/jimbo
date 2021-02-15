unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, PngSpeedButton, IniFiles, uDownloadFile,
  ComCtrls,

  funcVersion;

const
  FILENAME_INI             = 'jimbo.ini';
  FILENAME_PROGRAM         = 'jimbo.exe';

  SECTION_COMMON           = 'Common';
  SECTION_UPDATE           = 'Update';

  NAME_VERSIONSTR          = 'Version';
  NAME_UPDATEURL           = 'updateURL';
  NAME_RELEASEURL          = 'releaseURL';
                                                          
type
  TfrmMain = class(TForm)
    btnStart: TButton;
    Memo1: TMemo;
    lbStatusCpt: TLabel;
    lbStatus: TLabel;
    sbCustomerInfo: TPngSpeedButton;
    prgBar: TProgressBar;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FUpdateRunning: Boolean;
    FUrlReleaseFile: string;
    FUrlUpdateFile: string;
    FCurrentVersion: string;
    FOnlineVersion: string;

    function getTempFile(Extension: string): string;

    procedure waitForJimbo;
    procedure readSettings;
    procedure downloadRelease;
    procedure downloadUpdate;

    procedure viewStart;
    procedure viewCancel;
  public
    DL: TDownloadFile;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function TfrmMain.getTempFile(Extension: string): string;
var Buffer: array[0..MAX_PATH] of Char;
begin
  GetTempPath(SizeOf(Buffer) - 1, Buffer);
  GetTempFileName(Buffer, '~', 0, Buffer);
  Result := Buffer;
end;

// Warten bis die Jimbo-Anwendung beendet wurde
procedure TfrmMain.waitForJimbo;
var mHandle: THandle;
begin
  lbStatus.Caption := 'Warten auf Jimbo ...';
  Application.ProcessMessages;

  repeat
    mHandle := CreateMutex(nil,true,'SilversunJimbo');
    Application.ProcessMessages; Sleep(30);
  until (not FUpdateRunning) or (GetLastError <> ERROR_ALREADY_EXISTS);

  if mHandle <> 0 then CloseHandle(mHandle);
end;

procedure TfrmMain.readSettings;
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + FILENAME_INI);

  FCurrentVersion := Ini.ReadString(SECTION_COMMON,NAME_VERSIONSTR,'');
  FUrlReleaseFile := Ini.ReadString(SECTION_UPDATE,NAME_UPDATEURL,'#');

  Ini.Free;
end;

procedure TfrmMain.downloadRelease;
var tempList: TStrings;
    tempFile: string;
    Ini: TIniFile;
begin
  lbStatus.Caption := 'Verbinde zu ' + FUrlReleaseFile;
  Application.ProcessMessages;

  // Download
  DL.URL := FUrlReleaseFile;
  DL.Resume; Sleep(50);

  while DL.Running do begin
    if DL.bytesMax > 0 then prgBar.Position := DL.bytesLoaded div DL.bytesMax;
    Application.ProcessMessages; Sleep(50);
  end;

  if not DL.Success then exit;

  tempList := TStringList.Create;
  tempFile := getTempFile('jimbo');

  try
    tempList.Text := DL.Result;
    tempList.SaveToFile(tempFile);
  except
    showmessage('fehlgeschlagen');
    exit;
  end;

  tempList.Free;

  // Update-Ini lesen + löschen
  Ini := TIniFile.Create(tempFile);
  FOnlineVersion := Ini.ReadString(SECTION_UPDATE,NAME_VERSIONSTR,'');
  FUrlUpdateFile := Ini.ReadString(SECTION_UPDATE,NAME_UPDATEURL,'');
  FUrlReleaseFile := Ini.ReadString(SECTION_UPDATE,NAME_RELEASEURL,'');
  Ini.Free;

  deleteFile(tempFile);
end;

procedure TfrmMain.downloadUpdate;
var tempList: TStrings;
    tempFile: string;
    Ini: TIniFile;
begin
  lbStatus.Caption := 'Verbinde zu ' + FUrlUpdateFile;
  Application.ProcessMessages;

  // Download
  DL.Reset;
  DL.URL := FUrlUpdateFile;
  DL.Resume; Sleep(50);
                
  while DL.Running do begin
    if DL.bytesMax > 0 then prgBar.Position := DL.bytesLoaded div DL.bytesMax;
    Application.ProcessMessages; Sleep(50);
  end;

  if not DL.Success then exit;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  // <Abbrechen>
  viewCancel;

  // ## Jimbo muss geschlossen sein
  waitForJimbo;
  if not FUpdateRunning then begin viewStart; exit; end;

  // ## Jimbo-Ini lesen
  readSettings;
  if not FUpdateRunning then begin viewStart; exit; end;

  if FCurrentVersion = '' then begin
    showmessage('Fehler beim Lesen der Konfiguration von Jimbo.'#13#10'Bitte versuchen Sie das Progr  ');

    viewStart;
    exit;
  end;

  // Update-Datei herunterladen
  downloadRelease;
  if not FUpdateRunning then begin viewStart; exit; end;

  if FOnlineVersion = '' then begin
    showmessage('Fehler beim Lesen der Update-Datei.');

    viewStart;
    exit;
  end;

  if (versionCompare(FOnlineVersion,FCurrentVersion) < 0) then begin
    showmessage('up to date');

    viewStart;
    exit;
  end;

  if messageDlg('das programm ('+FCurrentVersion+') muss aktualisert werden - ' + FOnlineVersion + ' - machen?',mtConfirmation,[mbYes,mbNo],0) = mrNo then begin
    viewStart;
    exit;
  end;

  // Updaten
  downloadUpdate;
  if not FUpdateRunning then begin viewStart; exit; end;


  viewStart;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DL := TDownloadFile.Create;
  viewStart;

end;

procedure TfrmMain.btnCancelClick(Sender: TObject);
begin
  DL.Terminate;

  lbStatus.Caption := 'Wird beendet ...';
  Application.ProcessMessages;
end;

procedure TfrmMain.viewStart;
begin
  FUpdateRunning := false;

  btnStart.Caption := 'Update';
  btnStart.OnClick := btnStartClick;
  lbStatus.Caption := '';

  FUpdateRunning := false;
  FUrlReleaseFile := '';
  FCurrentVersion := '';
  FOnlineVersion := '';

  Application.ProcessMessages;
end;

procedure TfrmMain.viewCancel;
begin
  FUpdateRunning := true;

  btnStart.Caption := 'Abbrechen';
  btnStart.OnClick := btnCancelClick;
  lbStatus.Caption := 'Update starten ...';

  Application.ProcessMessages;
end;


end.
