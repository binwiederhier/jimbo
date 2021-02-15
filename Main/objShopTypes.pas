unit objShopTypes;

interface

uses
  Windows, Messages, Classes, Graphics, SysUtils,

  // DB-Komponenten
  DB, ADODB,

  // Eigene Funtionen
  _define, objIntegerList, funcCommon;

type
  // Shop-Typen
  TShopType = class
  private
    FID: integer;
    FTitle: string;
    FColor: TColor;
    FBorderColor: TColor;
    FVisible: boolean;
    FAlpha: byte;
    FMultiplier: double;
  public
    constructor Create;
    procedure Assign(aType: TShopType; withID: boolean = true);

    property ID: integer read FID write FID;
    property Title: string read FTitle write FTitle;
    property Color: TColor read FColor write FColor;
    property borderColor: TColor read FBorderColor write FBorderColor;
    property Visible: Boolean read FVisible write FVisible;
    property Alpha: Byte read FAlpha write FAlpha;
    property Multiplier: double read FMultiplier write FMultiplier;
  end;

  TShopTypes = class
  private
    FDB: TADOConnection;
    FQuery: TADOQuery;

    FTypes: TList;
    FDeleted: TIntegerList;

    FUseDB: Boolean;

    function getType(Index: integer): TShopType;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Save;
    procedure Clear;

    procedure setDB(var Database: TADOConnection; var Query: TADOQuery);

    function New: TShopType;
    function Delete(typeID: integer): Boolean;

    function Count: integer;

    function byID(ID: integer): TShopType;
    function indexOf(typeID: integer): integer;

    property Items[Index: Integer]: TShopType read getType; default;
    property useDB: Boolean read FUseDB;
  end;



implementation

{****************** TShopType ******************}

constructor TShopType.Create;
begin
  inherited Create;

  FID := -1;
  FTitle := '';
  FColor := clWhite;
  FBorderColor := clBlack;
  FVisible := true;
  FAlpha := 255;
  FMultiplier := 0;
end;

procedure TShopType.Assign(aType: TShopType; withID: boolean = true);
begin
  if withID then FID := aType.ID;
  FTitle := aType.Title;
  FColor := aType.Color;
  FBorderColor := aType.borderColor;
  FVisible := aType.Visible;
  FAlpha := aType.Alpha;
  FMultiplier := aType.Multiplier;
end;

{****************** TTypes ******************}

constructor TShopTypes.Create;
begin
  inherited Create;

  FTypes := TList.Create;
  FDeleted := TIntegerList.Create;

  FUseDB := false;
end;

destructor TShopTypes.Destroy;
begin
  FDeleted.Free;
  FTypes.Free;

  inherited Destroy;
end;

procedure TShopTypes.Load;
var aType: TShopType;
begin
  // Bisherige Typen löschen
  FTypes.Clear;
  FDeleted.Clear;

  // Laden
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(QUERY_SHOPTYPES_LOAD);

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
      aType.Color := StringToColor(FQuery.FieldByName('color').AsString);
      aType.borderColor := StringToColor(FQuery.FieldByName('bcolor').AsString);
      aType.Visible := FQuery.FieldByName('visible').AsBoolean;
      aType.Alpha := Byte(FQuery.FieldByName('alpha').AsInteger);
      aType.Multiplier := FQuery.FieldByName('multiplier').AsFloat;
    finally
      FQuery.Next;
    end;
  end;
end;

procedure TShopTypes.Clear;
begin
  FTypes.Clear;
end;

procedure TShopTypes.Save;
var i: integer;
    aType: TShopType;
begin
  if not FuseDB then exit;

  for i := 0 to FTypes.Count-1 do begin
    aType := Items[i];

    if FQuery.Active then FQuery.Close;
    FQuery.Sql.Clear;

    // Neues Datum in DB einfügen
    if (aType.ID = -1) then begin
      FQuery.Sql.Add(Format(QUERY_SHOPTYPES_NEW,[
        sqlEsc(aType.Title),
        sqlEsc(ColorToString(aType.Color)),
        sqlEsc(ColorToString(aType.borderColor)),
        Integer(aType.Visible),
        aType.Alpha
      ]));

      try
        FQuery.ExecSQL;
      except
        // FEHLERBEHANDLUNG
        raise Exception.Create('Unable to add new type');
      end;

      // Letzte ID lesen
      FQuery.Sql.Clear;
      FQuery.Sql.Add(QUERY_SHOPTYPES_LASTID);

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
      FQuery.Sql.Add(Format(QUERY_SHOPTYPES_EDIT,[
        sqlEsc(aType.Title),
        sqlEsc(ColorToString(aType.Color)),
        sqlEsc(ColorToString(aType.borderColor)),
        Integer(aType.Visible),
        aType.Alpha,

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
    FQuery.Sql.Add(Format(QUERY_SHOPTYPES_DELETE,[FDeleted[i]]));

    try
      FQuery.ExecSQL;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to delete date');
    end;
  end;
end;

function TShopTypes.getType(Index: integer): TShopType;
var pType: ^TShopType;
begin
  Result := nil;
  if (FTypes.Count > Index) and (Index >= 0) then begin
    pType := FTypes[Index];
    Result := pType^;
  end;
end;

function TShopTypes.byID(ID: integer): TShopType;
var index: integer;
    pType: ^TShopType;
begin
  index := indexOf(ID);
  if (index = -1) then begin
    Result := nil;
    exit;
  end;

  pType := FTypes[index];
  Result := pType^;
end;


function TShopTypes.New: TShopType;
var pDate: ^TShopType;
begin
  System.New(pDate);
  pDate^ := TShopType.Create;

  FTypes.Add(pDate);

  Result := pDate^;
end;

function TShopTypes.Delete(typeID: integer): Boolean;
var index: integer;
    pDate: ^TShopType;
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

function TShopTypes.Count: integer;
begin
  Result := FTypes.Count;
end;

function TShopTypes.indexOf(typeID: integer): integer;
var i: integer;
    pType: ^TShopType;
begin
  Result := -1;

  for i := 0 to FTypes.Count-1 do begin
    pType := FTypes.Items[i];
    if pType^.ID <> typeID then continue;

    Result := i;
    exit;
  end;
end;

procedure TShopTypes.setDB(var Database: TADOConnection; var Query: TADOQuery);
begin
  if not ((Database is TADOConnection) and (Query is TADOQuery)) then exit;

  FUseDB := true;
  FDB := Database;
  FQuery := Query;
end;


end.

