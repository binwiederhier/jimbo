unit objShopDates;

interface

uses
  Windows, Messages, Classes, SysUtils,

  // DB-Komponenten
  DB, ADODB,

  // Eigene Funtionen
  _define, objIntegerList, funcCommon;

type
  // Termine/Shops Verknüpfung
  TShopDate = record
    dateID: integer;
    shopID: integer;
  end;

  TShopDates = class
  private
    FDB: TADOConnection;
    FQuery: TADOQuery;

    FShopDates: TList;
    FDeleted: TIntegerList;

    FUseDB: Boolean;

    procedure setShopDate(Index: integer; Value: TShopDate);
    function getShopDate(Index: integer): TShopDate;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Clear;
    
    function Count: integer;

    procedure setDB(var Database: TADOConnection; var Query: TADOQuery);

    procedure Add(dateID, shopID: integer); overload;
    procedure Add(shopDate: TShopDate); overload;

    function indexOf(dateID, shopID: integer): integer; overload;
    function indexOf(shopDate: TShopDate): integer; overload;

    procedure deleteShop(shopID: integer);

    function usedCount(dateID: integer): integer;

    property Items[Index: Integer]: TShopDate read getShopDate write setShopDate; default;
    property useDB: Boolean read FUseDB;
  end;

implementation

{****************** TShopDates ******************}

constructor TShopDates.Create;
begin
  inherited Create;

  FShopDates := TList.Create;
  FDeleted := TIntegerList.Create;

  FUseDB := false;
end;

destructor TShopDates.Destroy;
begin
  FDeleted.Free;
  FShopDates.Free;

  inherited Destroy;
end;

procedure TShopDates.Load;
var pShopDate: ^TShopDate;
begin
  // Bisherige Daten löschen
  FShopDates.Clear;
  FDeleted.Clear;

  // Laden
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(QUERY_SHOPDATES_LOAD);

  try
    FQuery.Open;
  except
    raise Exception.Create('Unable to load shopdates table');
  end;

  while not FQuery.Eof do begin
    try
      System.New(pShopDate);

      pShopDate^.dateID := FQuery.FieldByName('dateid').AsInteger;
      pShopDate^.shopID := FQuery.FieldByName('shopid').AsInteger;

      FShopDates.Add(pShopDate);
    finally
      FQuery.Next;
    end;
  end;
end;

procedure TShopDates.Clear;
begin
  FShopDates.Clear;
end;

procedure TShopDates.setDB(var Database: TADOConnection; var Query: TADOQuery);
begin
  if (not (Database is TADOConnection)) or (not (Query is TADOQuery)) then begin
    FUseDB := false;
    exit;
  end;

  FUseDB := true;
  
  FDB := Database;
  FQuery := Query;
end;

procedure TShopDates.setShopDate(Index: integer; Value: TShopDate);
var pShopDate: ^TShopDate;
begin
  pShopDate := FShopDates.Items[Index];

  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_SHOPDATES_EDIT,[
    Value.dateID,
    Value.shopID,
    pShopDate^.dateID,
    pShopDate^.shopID
  ]));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to update shopdate');
  end;

  pShopDate^.dateID := Value.dateID;
  pShopDate^.shopID := Value.shopID;
end;

function TShopDates.getShopDate(Index: integer): TShopDate;
var pShopDate: ^TShopDate;
begin
  pShopDate := FShopDates.Items[Index];
  Result := pShopDate^;
end;

procedure TShopDates.Add(dateID, shopID: integer);
var shopDate: TShopDate;
begin
  shopDate.dateID := dateID;
  shopDate.shopID := shopID;

  Add(shopDate);
end;

procedure TShopDates.Add(shopDate: TShopDate);
var pShopDate: ^TShopDate;
begin
  System.New(pShopDate);
  pShopDate^ := shopDate;

  FShopDates.Add(pShopDate);

  // In der DB speichern
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_SHOPDATES_NEW,[
    shopDate.dateID,
    shopDate.shopID
  ]));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to add shopdate');
  end;
end;             

procedure TShopDates.deleteShop(shopID: integer);
var i: integer;
    pShopDate: ^TShopDate;
begin
  // Aus der aktuellen Liste löschen
  i := 0; while i < FShopDates.Count do begin
    pShopDate := FShopDates[i];
    if pShopDate^.shopID <> shopID then begin
      inc(i);
      continue;
    end;

    FShopDates.Delete(i);
  end;

  // Aus der DB löschen
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_SHOPDATES_DELETESHOP,[shopID]));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to add shopdate');
  end;
end;

function TShopDates.indexOf(dateID, shopID: integer): integer;
var i: integer;
    pShopDate: ^TShopDate;
begin
  Result := -1;

  for i := 0 to FShopDates.Count-1 do begin
    pShopDate := FShopDates.Items[i];
    if (pShopDate^.dateID <> dateID) or (pShopDate^.shopID <> shopID) then continue;

    Result := i;
    exit;
  end;
end;

function TShopDates.indexOf(shopDate: TShopDate): integer;
begin
  Result := indexOf(shopDate.dateID,shopDate.shopID);
end;

function TShopDates.usedCount(dateID: integer): integer;
var i: integer;
    pShopDate: ^TShopDate;
begin
  Result := 0;

  for i := 0 to FShopDates.Count-1 do begin
    pShopDate := FShopDates.Items[i];
    if (pShopDate^.dateID <> dateID) then continue;

    inc(Result);
  end;
end;

function TShopDates.Count: integer;
begin
  Result := FShopDates.Count;
end;


end.
 