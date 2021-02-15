unit objCustomerTypes;

interface

uses
  Windows, Messages, Classes, Graphics, SysUtils,

  // DB-Komponenten
  DB, ADODB,

  // Eigene Funtionen
  _define, objIntegerList, funcCommon;

type
  // Shop-Typen
  TCustomerType = class
  private
    FID: integer;
    FTitle: string;
    FMultiplier: double;
  public
    constructor Create;
    procedure Assign(aType: TCustomerType; withID: boolean = true);

    property ID: integer read FID write FID;
    property Title: string read FTitle write FTitle;
    property Multiplier: double read FMultiplier write FMultiplier;
  end;

  TCustomerTypes = class
  private
    FDB: TADOConnection;
    FQuery: TADOQuery;

    FTypes: TList;
    FDeleted: TIntegerList;

    FUseDB: Boolean;

    function getType(Index: integer): TCustomerType;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Save;
    procedure Clear;

    procedure setDB(var Database: TADOConnection; var Query: TADOQuery);

    function New: TCustomerType;
    function Delete(typeID: integer): Boolean;

    function Count: integer;

    function byID(ID: integer): TCustomerType;
    function indexOf(typeID: integer): integer;

    property Items[Index: Integer]: TCustomerType read getType; default;
    property useDB: Boolean read FUseDB;
  end;



implementation

{****************** TCustomerType ******************}

constructor TCustomerType.Create;
begin
  inherited Create;

  FID := -1;
  FTitle := '';
  FMultiplier := 0;
end;

procedure TCustomerType.Assign(aType: TCustomerType; withID: boolean = true);
begin
  if withID then FID := aType.ID;
  FTitle := aType.Title;
  FMultiplier := aType.Multiplier;
end;


{****************** TCustomerTypes ******************}

constructor TCustomerTypes.Create;
begin
  inherited Create;

  FTypes := TList.Create;
  FDeleted := TIntegerList.Create;

  FUseDB := false;
end;

destructor TCustomerTypes.Destroy;
begin
  FDeleted.Free;
  FTypes.Free;

  inherited Destroy;
end;

procedure TCustomerTypes.Load;
var aType: TCustomerType;
begin
  // Bisherige Typen löschen
  FTypes.Clear;
  FDeleted.Clear;

  // Laden
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(QUERY_CUSTOMERTYPES_LOAD);

  try
    FQuery.Open;
  except
    raise Exception.Create('Unable to load types table');
  end;

  while not FQuery.Eof do begin
    try
      aType := New;
      aType.ID := FQuery.FieldByName('id').AsInteger;
      aType.Title := FQuery.FieldByName('title').AsString;
      aType.Multiplier := FQuery.FieldByName('multiplier').AsFloat;
    finally
      FQuery.Next;
    end;
  end;
end;

procedure TCustomerTypes.Clear;
begin
  FTypes.Clear;
end;

procedure TCustomerTypes.Save;
var i: integer;
    aType: TCustomerType;
begin
  if not FuseDB then exit;

  for i := 0 to FTypes.Count-1 do begin
    aType := Items[i];

    if FQuery.Active then FQuery.Close;
    FQuery.Sql.Clear;

    // Neues Datum in DB einfügen
    if (aType.ID = -1) then begin
      FQuery.Sql.Add(Format(QUERY_CUSTOMERTYPES_NEW,[
        sqlEsc(aType.Title),
        aType.Multiplier
      ]));

      try
        FQuery.ExecSQL;
      except
        // FEHLERBEHANDLUNG
        raise Exception.Create('Unable to add new type');
      end;

      // Letzte ID lesen
      FQuery.Sql.Clear;
      FQuery.Sql.Add(QUERY_CUSTOMERTYPES_LASTID);

      try
        FQuery.Open;
      except
        // FEHLERBEHANDLUNG
        raise Exception.Create('Unable to add new type');
      end;

      if FQuery.Eof then Exception.Create('Unable to add new type');

      try
        aType.ID := FQuery.Fields[0].AsInteger;
      except
        Exception.Create('Unable to add new type');
      end;
    end
                    
    // Bestehendes Datum speichern
    else begin
      FQuery.Sql.Add(Format(QUERY_CUSTOMERTYPES_EDIT,[
        sqlEsc(aType.Title),
        aType.Multiplier,
        aType.ID
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
    FQuery.Sql.Add(Format(QUERY_CUSTOMERTYPES_DELETE,[FDeleted[i]]));

    try
      FQuery.ExecSQL;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to delete date');
    end;
  end;
end;

function TCustomerTypes.getType(Index: integer): TCustomerType;
var pType: ^TCustomerType;
begin
  Result := nil;
  if (FTypes.Count > Index) and (Index >= 0) then begin
    pType := FTypes[Index];
    Result := pType^;
  end;
end;

function TCustomerTypes.byID(ID: integer): TCustomerType;
var index: integer;
    pType: ^TCustomerType;
begin
  index := indexOf(ID);
  if (index = -1) then begin
    Result := nil;
    exit;
  end;

  pType := FTypes[index];
  Result := pType^;
end;


function TCustomerTypes.New: TCustomerType;
var pDate: ^TCustomerType;
begin
  System.New(pDate);
  pDate^ := TCustomerType.Create;

  FTypes.Add(pDate);

  Result := pDate^;
end;

function TCustomerTypes.Delete(typeID: integer): Boolean;
var index: integer;
    pDate: ^TCustomerType;
begin
  Result := false;

  // ID vorhanden?
  index := indexOf(typeID);
  if index = -1 then exit;

  // in die Löschliste einfügen
  FDeleted.Add(typeID);

  // Aus der aktuellen Liste löschen
  pDate := FTypes.Items[index];
  FTypes.Extract(pDate);

  Result := true;
end;

function TCustomerTypes.Count: integer;
begin
  Result := FTypes.Count;
end;

function TCustomerTypes.indexOf(typeID: integer): integer;
var i: integer;
    pType: ^TCustomerType;
begin
  Result := -1;

  for i := 0 to FTypes.Count-1 do begin
    pType := FTypes.Items[i];
    if pType^.ID <> typeID then continue;

    Result := i;
    exit;
  end;
end;

procedure TCustomerTypes.setDB(var Database: TADOConnection; var Query: TADOQuery);
begin
  if not ((Database is TADOConnection) and (Query is TADOQuery)) then exit;

  FUseDB := true;
  FDB := Database;
  FQuery := Query;
end;


end.

