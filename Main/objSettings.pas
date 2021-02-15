unit objSettings;

interface

uses
  Windows, Messages, Classes, SysUtils, Forms,

  objCustomers, objShops, objIntegerList,

  objComplex,

  funcCommon, funcVersion;

const
  LASTFILES_MAX                      = 5;

  DEFAULT_UPDATE_INTERVAL            = 7;
  DEFAULT_UPDATE_URL                 = 'http://www.silversun.de/jimbo/release.upd';

type
  TMRUList = class
  private
    FList: TStringList;
    FMaxCount: integer;

    function getCount: integer;
    function getFile(Index: integer): string;
    procedure setMaxCount(Value: integer);
  public
    constructor Create;
    destructor Destroy; override;

    function Add(Filename: string): integer;
    function Delete(Filename: string): integer; overload;
    function Delete(Index: integer): integer; overload;

    property Files[Index: integer]: string read getFile; default;
    property Count: integer read getCount;
    property MaxCount: integer read FMaxCount write setMaxCount;
  end;

  TSettings = class
  private
    // XML File
    FFilename: string;
    FSettings: TComplex; {all settings}
    FDefaultCpx: TComplex;

    // Common
    FVersion: string; { wird vom Programm *nur* geschrieben }
    FOpenLast: boolean;

    // Update
    FUpdateInterval: integer;
    FUpdateURL: string;

    // Letzte Dateien
    FLastFiles: TMRUList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Save;

    function Cpx: TComplex;
    function DefaultCpx: TComplex;

    // XML File
    property Filename: string read FFilename write FFilename;

    // Common
    property Version: string read FVersion write FVersion;
    property OpenLast: boolean read FOpenLast write FOpenLast;

    // Last Files
    property lastFiles: TMRUList read FLastFiles write FLastFiles;

    // Update
    property updateInterval: integer read FUpdateInterval write FUpdateInterval;
    property updateURL: string read FUpdateURL write FUpdateURL;
  end;

implementation

{****************** TMRUList ******************}

constructor TMRUList.Create;
begin
  inherited Create;

  FList := TStringList.Create;
  FMaxCount := LASTFILES_MAX;
end;

destructor TMRUList.Destroy;
begin
  FList.Free;

  inherited Destroy;
end;

function TMRUList.Add(Filename: string): integer;
begin
  Delete(Filename);
  FList.Insert(0,Filename);

  if (FList.Count > FMaxCount) then FList.Delete(FList.Count-1);
  Result := FList.Count;
end;

function TMRUList.Delete(Filename: string): integer;
var i: integer;
begin
  i := 0; while (i < FList.Count) do begin
    if (LowerCase(FList[i]) <> LowerCase(Filename)) then begin
      inc(i);
      continue;
    end;

    FList.Delete(i);
  end;

  Result := FList.Count;
end;

function TMRUList.Delete(Index: integer): integer;
begin
  if (Index < 0) or (Index >= FList.Count) then begin
    Result := FList.Count;
    exit;
  end;

  FList.Delete(Index);
  Result := FList.Count;
end;

function TMRUList.getCount: integer;
begin
  Result := FList.Count;
end;

function TMRUList.getFile(Index: integer): string;
begin
  // FEHLERBEHANDLUNG
  if (Index < 0) or (Index >= FList.Count) then raise Exception.Create('Out of bounds oder so');

  Result := FList[Index];
end;

procedure TMRUList.setMaxCount(Value: integer);
begin
  if Value <= 0 then exit;

  // MaxCount vergrˆﬂern
  if Value >= FMaxCount then begin
    FMaxCount := Value;
    exit;
  end;

  // MaxCount verkleinern (‹berschuss entfernen)
  FMaxCount := Value;
  while FMaxCount < FList.Count do FList.Delete(FList.Count-1);
end;


{****************** TSettings ******************}

constructor TSettings.Create;
begin
  inherited Create;

  FLastFiles := TMRUList.Create;

  FSettings := TComplex.Create;
  FDefaultCpx := TComplex.Create;
end;

destructor TSettings.Destroy;
begin
  FSettings.Free;
  FDefaultCpx.Free;

  FLastFiles.Free;

  inherited Destroy;
end;

function TSettings.DefaultCpx: TComplex;
begin
  Result := FDefaultCpx;
  if FDefaultCpx.Count > 0 then exit;

  with FDefaultCpx do begin
    with Items['Common'] do begin
      Items['Version'].asStr := versionInfo.FileVersion;
      Items['OpenLast'].asBool := false;

      Items['UpdateInterval'].asInt := DEFAULT_UPDATE_INTERVAL;
      Items['UpdateURL'].asStr := DEFAULT_UPDATE_URL;
    end;

    with Items['Last'].asList do ;

    // lvCustomers
    with Items['Lists']['Customers'] do begin
      Items['FindField'].asInt := cfFieldToId(cfLastname);
      Items['FindQuery'].asStr := '';

      Items['SortField'].asInt := cfFieldToId(cfLastname);
      Items['SortAsc'].asBool := true;

      with Items['Captions'] do begin
        Hidden := true;

        asList[0].asStr := 'Name';
        asList[1].asStr := 'Vorname';
        asList[2].asStr := 'Firma';
        asList[3].asStr := 'Straﬂe';
        asList[4].asStr := 'PLZ';
        asList[5].asStr := 'Ort';
        asList[6].asStr := 'Telefon';
        asList[7].asStr := 'eMail';
        asList[8].asStr := 'Zusatz';
        asList[9].asStr := 'Kd-Nr.';
      end;

      with Items['Widths'] do begin
        asList[0].asInt := 50;
        asList[1].asInt := 50;
        asList[2].asInt := 50;
        asList[3].asInt := 50;
        asList[4].asInt := 50;
        asList[5].asInt := 50;
        asList[6].asInt := 50;
        asList[7].asInt := 50;
        asList[8].asInt := 50;
        asList[9].asInt := 50;
      end;

      with Items['Order'] do begin
        asList[0].asInt := 0;
        asList[1].asInt := 1;
        asList[2].asInt := 2;
        asList[3].asInt := 3;
        asList[4].asInt := 4;
        asList[5].asInt := 5;
        asList[6].asInt := 6;
        asList[7].asInt := 7;
        asList[8].asInt := 8;
        asList[9].asInt := 9;
      end;
    end;

    // lvCustomerShops
    with Items['Lists']['Shops'] do begin
      Items['SortField'].asInt := sfFieldToId(sfAddress);
      Items['SortAsc'].asBool := true;

      with Items['Captions'] do begin
        Hidden := true;

        asList[0].asStr := 'St-Nr.';
        asList[1].asStr := 'Typ';
        asList[2].asStr := 'Standort';
        asList[3].asStr := 'Maﬂe';
        asList[4].asStr := 'Termin';
        asList[5].asStr := 'Zusatz';
        asList[6].asStr := 'Preis';
      end;

      with Items['Widths'] do begin
        asList[0].asInt := 50;
        asList[1].asInt := 50;
        asList[2].asInt := 50;
        asList[3].asInt := 50;
        asList[4].asInt := 50;
        asList[5].asInt := 50;
        asList[6].asInt := 50;
      end;

      with Items['Order'] do begin
        asList[0].asInt := 0;
        asList[1].asInt := 1;
        asList[2].asInt := 2;
        asList[3].asInt := 3;
        asList[4].asInt := 4;
        asList[5].asInt := 5;
        asList[6].asInt := 6;
      end;
    end;

    // lvMax
    with Items['Lists']['Max'] do begin
      Items['FindField'].asInt := 2; {Nachname}
      Items['FindQuery'].asStr := '';

      Items['SortField'].asInt := 2; {Nachname}
      Items['SortAsc'].asBool := true;

      with Items['Captions'] do begin
        Hidden := true;

        asList[0].asStr := 'Kd-Nr.';
        asList[1].asStr := 'Kd-Typ';
        asList[2].asStr := 'Name';
        asList[3].asStr := 'Vorname';
        asList[4].asStr := 'Straﬂe';
        asList[5].asStr := 'PLZ';
        asList[6].asStr := 'Ort';

        asList[7].asStr := 'St-Nr.';
        asList[8].asStr := 'St-Typ.';
        asList[9].asStr := 'Maﬂe';
        asList[10].asStr := 'Termin';
        asList[11].asStr := 'Standort';
        asList[12].asStr := 'Preis';
      end;

      with Items['Widths'] do begin
        asList[0].asInt := 50;
        asList[1].asInt := 50;
        asList[2].asInt := 50;
        asList[3].asInt := 50;
        asList[4].asInt := 50;
        asList[5].asInt := 50;
        asList[6].asInt := 50;

        asList[7].asInt := 50;
        asList[8].asInt := 50;
        asList[9].asInt := 50;
        asList[10].asInt := 50;
        asList[11].asInt := 50;
        asList[12].asInt := 50;
      end;

      with Items['Order'] do begin
        asList[0].asInt := 0;
        asList[1].asInt := 1;
        asList[2].asInt := 2;
        asList[3].asInt := 3;
        asList[4].asInt := 4;
        asList[5].asInt := 5;
        asList[6].asInt := 6;

        asList[7].asInt := 7;
        asList[8].asInt := 8;
        asList[9].asInt := 9;
        asList[10].asInt := 10;
        asList[11].asInt := 11;
        asList[12].asInt := 12;
      end;

      // 1 = Customer, 2 = Shop, 0 = Spezialfeld (z.B. Preis, ...)
      with Items['Types'] do begin
        Hidden := true;

        asList[0].asInt := 1;
        asList[1].asInt := 1;
        asList[2].asInt := 1;
        asList[3].asInt := 1;
        asList[4].asInt := 1;
        asList[5].asInt := 1;
        asList[6].asInt := 1;

        asList[7].asInt := 2;
        asList[8].asInt := 2;
        asList[9].asInt := 2;
        asList[10].asInt := 2;
        asList[11].asInt := 2;
        asList[12].asInt := 2;
      end;

      with Items['ID'] do begin
        Hidden := true;

        asList[0].asInt := cfFieldToId(cfCID);
        asList[1].asInt := cfFieldToId(cfType);
        asList[2].asInt := cfFieldToId(cfLastname);
        asList[3].asInt := cfFieldToId(cfFirstname);
        asList[4].asInt := cfFieldToId(cfAddress);
        asList[5].asInt := cfFieldToId(cfZIP);
        asList[6].asInt := cfFieldToId(cfCity);

        asList[7].asInt := sfFieldToId(sfID);
        asList[8].asInt := sfFieldToId(sfType);
        asList[9].asInt := sfFieldToId(sfSize);
        asList[10].asInt := sfFieldToId(sfDate);
        asList[11].asInt := sfFieldToId(sfAddress);
        asList[12].asInt := sfFieldToId(sfPrice);
      end;

    end;

    with Items['Backup'] do begin
      Items['Enabled'].asBool := false;
      Items['Interval'].asInt := 60;
      Items['BackupDir'].asStr := '***';
      Items['LastBackup'].asFloat := 0;
    end;

    with Items['Layout'] do begin
      Items['Theme'].asStr := 'Default';
      Items['ShowNavigator'].asBool := true;
      Items['ShowView'].asBool := true;
      Items['WindowState'].asInt := Integer(wsNormal);
    end;
  end;
end;

function TSettings.Cpx: TComplex;
begin
  Result := FSettings;
end;

procedure TSettings.Load;
var i, aCount: integer;
    Filename, tempStr: string;
begin
  Cpx.Assign(DefaultCpx,true);
  try Cpx.LoadFromFile(FFilename,false);
  except end;

  if Cpx['Lists']['Customers']['Widths'].asList.Count <> DefaultCpx['Lists']['Customers']['Widths'].asList.Count then
    Cpx['Lists']['Customers']['Widths'].Assign(DefaultCpx['Lists']['Customers']['Widths']);

  if Cpx['Lists']['Customers']['Order'].asList.Count <> DefaultCpx['Lists']['Customers']['Order'].asList.Count then
    Cpx['Lists']['Customers']['Order'].Assign(DefaultCpx['Lists']['Customers']['Order']);

  if Cpx['Lists']['Shops']['Widths'].asList.Count <> DefaultCpx['Lists']['Shops']['Widths'].asList.Count then
    Cpx['Lists']['Shops']['Widths'].Assign(DefaultCpx['Lists']['Shops']['Widths']);

  if Cpx['Lists']['Shops']['Order'].asList.Count <> DefaultCpx['Lists']['Shops']['Order'].asList.Count then
    Cpx['Lists']['Shops']['Order'].Assign(DefaultCpx['Lists']['Shops']['Order']);

  Cpx['Lists']['Customers']['Captions'].Assign(DefaultCpx['Lists']['Customers']['Captions']);
  Cpx['Lists']['Shops']['Captions'].Assign(DefaultCpx['Lists']['Shops']['Captions']);

  for i := 0 to Cpx['Last'].asList.Count-1 do begin
    if not FileExists(Cpx['Last'].asList[i].asStr) then continue;
    FLastFiles.Add(Cpx['Last'].asList[i].asStr);
  end;
end;

procedure TSettings.Save;
var i, fCount: integer;
begin
  with FSettings['Common'] do begin
    Items['Version'].asStr := FVersion;
    Items['OpenLast'].asBool := FOpenLast;
  end;

  with FSettings['Update'] do begin
    Items['UpdateInterval'].asInt := FUpdateInterval;
    Items['UpdateURL'].asStr := FUpdateURL;
  end;

  with FSettings['Last'].asList do begin
    Clear;

    if (FLastFiles.Count > LASTFILES_MAX) then fCount := LASTFILES_MAX
    else fCount := FLastFiles.Count;

    for i := 0 to fCount-1 do Items[i].asStr := FLastFiles[i];
  end;

  FSettings.saveToFile(FFilename);
end;


end.
