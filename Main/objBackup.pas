unit objBackup;

interface

uses
  Windows, Messages, SysUtils, ExtCtrls, DateUtils,

  _define, objJimbo, objComplex,

  funcCommon;

type
  TBackup = class
  private
    FEnabled: boolean;
    FTimer: TTimer;
    FInterval: cardinal;
    FBackupDir: string;
    FLastBackup: TDateTime;
    FProject: TJimbo;
    FAccessExt: boolean;

    procedure setInterval(Value: cardinal);
    procedure setEnabled(Value: boolean);

    function getInterval: cardinal;
    function getEnabled: boolean;

    procedure OnTimer(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    function Backup: boolean;
    procedure ImportSettings(Settings: TComplex);
    procedure ExportSettings(const Settings: TComplex);

    property Enabled: boolean read getEnabled write setEnabled;
    property Interval: cardinal read FInterval write FInterval;
    property LastBackup: TDateTime read FLastBackup write FLastBackup;
    property BackupDir: string read FBackupDir write FBackupDir;
    property Project: TJimbo read FProject write FProject;
    property AccessExt: boolean read FAccessExt write FAccessExt;
  end;

implementation

constructor TBackup.Create;
begin
  inherited Create;

  FEnabled := false;
  FBackupDir := '***';
  FProject := nil;
  FLastBackup := 0;
  FAccessExt := false;

  FTimer := TTimer.Create(nil);
  FTimer.Enabled := false;
  FTimer.Interval := 60*1000; {60 seconds}
  FTimer.OnTimer := OnTimer;

  setInterval(1000); {1000 minutes}
end;

destructor TBackup.Destroy;
begin
  FTimer.Free;

  inherited Destroy;
end;

function TBackup.getInterval: cardinal;
begin
  Result := FInterval div 60000;
end;

procedure TBackup.setInterval(Value: cardinal);
begin
  try
    FInterval := Value * 60000;
  except
    FTimer.Enabled := false;
  end;
end;

function TBackup.getEnabled: boolean;
begin
  Result := FTimer.Enabled;
end;

procedure TBackup.setEnabled(Value: boolean);
begin
  FTimer.Enabled := Value;
end;

function TBackup.Backup: boolean;
var bFilename: string;
    Attrs: integer;
    fmtSet: TFormatSettings;
begin
  Result := false;

  if not Assigned(FProject) then exit;
  if not FProject.Opened then exit;
  if not DirectoryExists(FBackupDir) then exit;
  if not FileExists(FProject.Filename) then exit;

  getLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT,fmtSet);
  DateTimeToString(bFilename,'_yy_mm_dd',Now,fmtSet);

  bFilename :=
    // Altstadtfest (ohne .jidb)
    copy(
      ExtractFilename(FProject.Filename),
      1,
      Length(ExtractFilename(FProject.Filename)) - Length(ExtractFileExt(FProject.Filename))
    )

    // Datums-String
    + bFilename

    // Extension
    + ifThenElse(FAccessExt,COMMON_EXT_MSACCESS,COMMON_EXT_PROJECT);

  Result := CopyFile(pChar(FProject.Filename),pChar(FBackupDir+bFilename),false);
  if Result then FLastBackup := Now;
end;

procedure TBackup.ImportSettings(Settings: TComplex);
begin
  FInterval := Settings['Interval'].asInt;
  FBackupDir := Settings['BackupDir'].asStr;
  FLastBackup := Settings['LastBackup'].asFloat;
  FAccessExt := Settings['AccessExt'].asBool;

  FTimer.Enabled := Settings['Enabled'].asBool;
end;

procedure TBackup.ExportSettings(const Settings: TComplex);
begin
  Settings['Interval'].asInt := FInterval;
  Settings['BackupDir'].asStr := FBackupDir;
  Settings['LastBackup'].asFloat := FLastBackup;
  Settings['AccessExt'].asBool := FAccessExt;

  Settings['Enabled'].asBool := FTimer.Enabled;
end;                                          

procedure TBackup.OnTimer(Sender: TObject);
begin
  // check every 60 seconds
  if CompareDateTime(FLastBackup+FInterval/60/24,Now) > 1 then exit;

  Backup;
end;

end.
