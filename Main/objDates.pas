unit objDates;

interface

uses
  Windows, Messages, Classes, SysUtils,

  // DB-Komponenten
  DB, ADODB,

  // Eigene Funtionen
  _define, objPricer, objIntegerList, funcCommon;

type
  // Termine
  TADate = class
  private
    FID: integer;
    FActive: boolean;
    FTitle: string;
    FShort: string;
    FDate: TDateTime;
    FPrice: string;

    FPricer: TPricer;
  public
    constructor Create;

    procedure Assign(aDate: TADate; withID: boolean = true);

    property ID: integer read FID write FID;
    property Active: Boolean read FActive write FActive;
    property Title: string read FTitle write FTitle;
    property Short: string read FShort write FShort;
    property Date: TDateTime read FDate write FDate;
    property Price: string read FPrice write FPrice;
  end;

  TDates = class
  private
    FDB: TADOConnection;
    FQuery: TADOQuery;
    FPricer: TPricer;

    FDates: TList;
    FDeleted: TIntegerList;

    FUseDB: Boolean;

    function getDate(Index: integer): TADate;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Save;
    procedure Clear;

    procedure setDB(var Database: TADOConnection; var Query: TADOQuery);

    function New: TADate;
    function Delete(dateID: integer): Boolean;

    function Count: integer;
    function indexOf(dateID: integer): integer;
    function byID(dateID: integer): TADate;

    property Pricer: TPricer read FPricer write FPricer;
    property Items[Index: Integer]: TADate read getDate; default;
    property useDB: Boolean read FUseDB;
  end;

implementation

{****************** TADate ******************}

constructor TADate.Create;
begin
  inherited Create;

  FID := -1;
  FActive := false;
  FTitle := '';
  FShort := '';
  FDate := Now;
end;

procedure TADate.Assign(aDate: TADate; withID: boolean = true);
begin
  if withID then FID := aDate.ID;
  FActive := aDate.Active;
  FTitle := aDate.Title;
  FShort := aDate.Short;
  FDate := aDate.Date;
  FPrice := aDate.Price;
end;


{****************** TDates ******************}

constructor TDates.Create;
begin
  inherited Create;

  FDates := TList.Create;
  FDeleted := TIntegerList.Create;

  FUseDB := false;
end;

destructor TDates.Destroy;
begin
  FDeleted.Free;
  FDates.Free;

  inherited Destroy;
end;

procedure TDates.Load;
var aDate: TADate;
begin
  if not FUseDB then exit;

  // Bisherige Daten löschen
  FDates.Clear;
  FDeleted.Clear;

  // Laden
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(QUERY_DATES_LOAD);

  try
    FQuery.Open;
  except
    raise Exception.Create('Unable to load dates table');
  end;
                           
  while not FQuery.Eof do begin
    try
      aDate := New;
      aDate.ID := FQuery.FieldByName('id').AsInteger;
      aDate.Active := FQuery.FieldByName('active').AsBoolean;
      aDate.Title := FQuery.FieldByName('title').AsString;
      aDate.Short := FQuery.FieldByName('short').AsString;
      aDate.Date := FQuery.FieldByName('date').AsDateTime;
      aDate.Price := FQuery.FieldByName('price').AsString;
    finally
      FQuery.Next;
    end;
  end;
end;

procedure TDates.Clear;
begin
  FDates.Clear;
end;

procedure TDates.Save;
var i: integer;
    aDate: TADate;
    fmtSettings: TFormatSettings;
begin
  if not FuseDB then exit;

  for i := 0 to FDates.Count-1 do begin
    aDate := Items[i];

    if FQuery.Active then FQuery.Close;
    FQuery.Sql.Clear;

    // Format-Settings (für 6.00 statt 6,00)
    getLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT,fmtSettings);
    fmtSettings.DecimalSeparator := '.';

    // Neues Datum in DB einfügen
    if (aDate.ID = -1) then begin
      FQuery.Sql.Add(Format(QUERY_DATES_NEW,[
        Integer(aDate.Active),sqlEsc(aDate.Title),sqlEsc(aDate.Short),
        FormatDateTime('dd.mm.yyyy',aDate.Date),aDate.Price
      ]));

      try
        FQuery.ExecSQL;
      except
        // FEHLERBEHANDLUNG
        raise Exception.Create('Unable to add new date');
      end;

      // Letzte ID lesen
      FQuery.Sql.Clear;
      FQuery.Sql.Add(QUERY_DATES_LASTID);

      try
        FQuery.Open;
      except
        // FEHLERBEHANDLUNG
        raise Exception.Create('Unable to add new date');
      end;

      if FQuery.Eof then Exception.Create('Unable to add new date');

      try
        aDate.ID := FQuery.Fields[0].AsInteger;
      except
        Exception.Create('Unable to add new date');
      end;
    end

    // Bestehendes Datum speichern
    else begin
      FQuery.Sql.Add(Format(QUERY_DATES_EDIT,[
        Integer(aDate.Active),sqlEsc(aDate.Title),sqlEsc(aDate.Short),
        FormatDateTime('dd.mm.yyyy',aDate.Date),aDate.Price,aDate.ID
      ]));

      try
        FQuery.ExecSQL;
      except
        // FEHLERBEHANDLUNG
        raise Exception.Create('Unable to edit date');
      end;
    end;
  end;

  // Löschen der entfernte Termine

  // Datum in DB löschen
  for i := 0 to FDeleted.Count-1 do begin
    if FQuery.Active then FQuery.Close;

    FQuery.Sql.Clear;
    FQuery.Sql.Add(Format(QUERY_DATES_DELETE,[FDeleted[i]]));

    try
      FQuery.ExecSQL;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to delete date');
    end;
  end;
end;

function TDates.getDate(Index: integer): TADate;
var pDate: ^TADate;
begin
  Result := nil;
  if (FDates.Count > Index) and (Index >= 0) then begin
    pDate := FDates[Index];
    Result := pDate^;
  end;
end;

function TDates.New: TADate;
var pDate: ^TADate;
begin
  System.New(pDate);
  pDate^ := TADate.Create;
  pDate^.FPricer := FPricer;
  
  FDates.Add(pDate);

  Result := pDate^;
end;

function TDates.Delete(dateID: integer): Boolean;
var index: integer;
    pDate: ^TADate;
begin
  Result := false;

  // ID vorhanden?
  index := indexOf(dateID);
  if index = -1 then exit;

  // in die Löschliste einfügen
  FDeleted.Add(dateID);

  // Aus der aktuellen Liste löschen
  pDate := FDates.Items[index];
  FDates.Extract(pDate);

  Result := true;
end;

function TDates.Count: integer;
begin
  Result := FDates.Count;
end;

function TDates.indexOf(dateID: integer): integer;
var i: integer;
    pDate: ^TADate;
begin
  Result := -1;

  for i := 0 to FDates.Count-1 do begin
    pDate := FDates.Items[i];
    if pDate^.ID <> dateID then continue;

    Result := i;
    exit;
  end;
end;

function TDates.byID(dateID: integer): TADate;
var idx: integer;
begin
  Result := nil;

  idx := indexOf(dateID);
  if idx = -1 then exit;

  Result := Items[idx];
end;

procedure TDates.setDB(var Database: TADOConnection; var Query: TADOQuery);
begin
  if (not (Database is TADOConnection)) or (not (Query is TADOQuery)) then begin
    FUseDB := false;
    exit;
  end;

  FUseDB := true;

  FDB := Database;
  FQuery := Query;
end;


end.
