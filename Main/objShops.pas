unit objShops;

interface

uses
  Windows, Messages, Classes, SysUtils, Math,

  // DB-Komponenten
  DB, ADODB,

  // Eigene Objekte
  _define, 

  // Eigene Funktionen
  funcCommon;

type
  TFourPoints = array[0..3] of TPoint;

  TShop = class;
  pShop = ^TShop;

  TShopField = (sfID, sfSize, sfType, sfAddress, sfOther, sfPrice, sfDate);

  TShop = class
  private
    // DB / Referenzen
    FuseDB: Boolean;
    FDB: TADOConnection;
    FQuery: TADOQuery;

    // Identifizier' dich!
    FID: integer;
    FCustomerID: integer;

    // Position
    FWidth: double;
    FHeight: double;
    FX: integer;
    FY: integer;
    FAngle: integer;
    FAddress: string;
    FOther: string;
    FPrice: double;
    FFactor: double;

    FHighlighted: Boolean;

    // Polygon Punkte (Performance)
    FPoints: TFourPoints;

    // Design
    FTypeID: integer;
    FTypeStr: string;
    FLocationID: integer;

    procedure setID(ID: integer);
    procedure setAngle(Angle: integer);

    function getPixelWidth: integer;
    function getPixelHeight: integer;
    //function getPrice: double;
  public
    constructor Create;
    destructor Destroy; override;

    procedure setDB(const Database: TADOConnection; const Query: TADOQuery);

    procedure setDimension(Width, Height: double);
    procedure setPosition(X, Y: integer);

    function getRect(Relative: Boolean; Offset: integer): TRect;
    function getPoints(Relative: Boolean; Offset: integer): TFourPoints;

    procedure Save;
    procedure Delete;

//    procedure EmptyCache;

    function isMovePoint(X, Y: integer): Boolean;
    function isRotatePoint(X, Y: integer): Boolean;

    function hasOwner: Boolean;

    // Eigenschaften
    property useDB: Boolean read FuseDB;

    property ID: integer read FID write setID;

    property Width: double read FWidth;
    property Height: double read FHeight;

    property PixelWidth: integer read getPixelWidth;
    property PixelHeight: integer read getPixelHeight;

    property X: integer read FX;
    property Y: integer read FY;
    property Angle: integer read FAngle write setAngle;

    property CustomerID: integer read FCustomerID write FCustomerID;
    property LocationID: integer read FLocationID write FLocationID;
    property TypeID: integer read FTypeID write FTypeID;
    property TypeStr: string read FTypeStr write FTypeStr; {wird nicht gespeichert!} 

    property Address: string read FAddress write FAddress;
    property Other: string read FOther write FOther;

    // Variable gepufferte Werte (gelesen aus den jew. Objekten)

    // Diese Werte werden gespeichert und müssen manuell aktualisiert
    // werden. Sie dienen lediglich der Sortierbeschleunigung.

    // Änderungen an diesen Werten haben keine Wirkung!

//    property TypeStr: string read FTypeStr write FTypeStr;
  //  property
//    property Date: TADate read FDate write FDate; 
    property Price: double read FPrice write FPrice; // nur als cache (nicht berechnet!!!)
  end;

  // Stände
  TShops = class
  private
    // DB / Referenzen
    FuseDB: Boolean;
    FDB: TADOConnection;
    FQuery: TADOQuery;

    // Stände
    FShops: TList;

    function getShop(Value: integer): TShop;
  public
    constructor Create;
    destructor Destroy; override;

    procedure setDB(const Database: TADOConnection; const Query: TADOQuery);

    function New: TShop;
    function Count: integer; overload;
    function Count(customerID: integer): integer; overload;
    function Exists(shopID: integer): boolean;

    procedure Add(const Shop: TShop);
    procedure Delete(ID: integer; fromDB: Boolean);
    procedure Close;

    function byID(ID: integer): TShop;
    function byCustomer(customerID: integer): TShops;

    function Find(Field: TShopField; aPattern: string = ''): TShops;
    procedure sortBy(Field: TShopField; Ascending: boolean = true);

    property useDB: Boolean read FuseDB;
    property Shops[Index: integer]: TShop read getShop; default;
  end;


function sfIdToField(Id: integer): TShopField;
function sfFieldToId(Field: TShopField): integer;

implementation

function sfIdToField(Id: integer): TShopField;
begin
  case Id of
    0: Result := sfID;
    1: Result := sfSize;
    2: Result := sfType;
    3: Result := sfAddress;
    4: Result := sfOther;
    5: Result := sfPrice;
    6: Result := sfDate;
    else Result := sfID;
  end;
end;

function sfFieldToId(Field: TShopField): integer;
begin
  case Field of
    sfID: Result := 0;
    sfSize: Result := 1;
    sfType: Result := 2;
    sfAddress: Result := 3;
    sfOther: Result := 4;
    sfPrice: Result := 5;
    sfDate: Result := 6;
    else Result := 0;
  end;
end;


{** Callback-Funktion für die Sortierung **}

function shopSortID(pShop1, pShop2: Pointer): integer;
begin
  Result := CompareValue(TShop(pShop1^).ID,TShop(pShop2^).ID);
end;

function shopSortSize(pShop1, pShop2: Pointer): integer;
begin
  Result := CompareValue(TShop(pShop1^).Width,TShop(pShop2^).Width);
end;

function shopSortType(pShop1, pShop2: Pointer): integer;
begin
  Result := 0;
end;

function shopSortAddress(pShop1, pShop2: Pointer): integer;
begin
  Result := AnsiCompareText(TShop(pShop1^).Address,TShop(pShop2^).Address);
end;

function shopSortOther(pShop1, pShop2: Pointer): integer;
begin
  Result := AnsiCompareText(TShop(pShop1^).Other,TShop(pShop2^).Other);
end;

function shopSortPrice(pShop1, pShop2: Pointer): integer;
begin
  Result := 0;
end;

function shopSortDate(pShop1, pShop2: Pointer): integer;
begin
  Result := 0;
end;

{****************** TShop ******************}

constructor TShop.Create;
begin
  inherited Create;

  FuseDB := false;
  FDB := nil;
  FQuery := nil;

  FID := -1;
  FWidth := 200;
  FHeight := 100;
  FX := 0;
  FY := 0;
  FPrice := 0;

  FAngle := 0;
  FFactor := 15.135173005011991266978182240993;

  FHighlighted := false;

  FTypeID := -1;
  FLocationID := -1;
end;

destructor TShop.Destroy;
begin
  inherited Destroy;
end;

procedure TShop.setDB(const Database: TADOConnection; const Query: TADOQuery);
begin
  if (not (Database is TADOConnection)) or (not (Query is TADOQuery)) then begin
    FuseDB := false;
    exit;
  end;

  FuseDB := true;

  FDB := Database;
  FQuery := Query;
end;


function TShop.getRect(Relative: Boolean; Offset: integer): TRect;
var i: integer;
    minP, maxP: TPoint;
    Points: TFourPoints;
begin
  Points := getPoints(Relative,Offset);

  if length(Points) = 0 then begin
    Result := Classes.Rect(0,0,0,0);
    exit;
  end;

  minP := Points[0];
  maxP := Points[0];

  for i := 0 to length(Points)-1 do begin
    minP.X := Min(minP.X,Points[i].X);
    minP.Y := Min(minP.Y,Points[i].Y);

    maxP.X := Max(maxP.X,Points[i].X);
    maxP.Y := Max(maxP.Y,Points[i].Y);
  end;

  minP := Point(minP.X - Offset,minP.Y - Offset);
  maxP := Point(maxP.X + Offset,maxP.Y + Offset);

  Result := Classes.Rect(minP,maxP);
end;

procedure TShop.setID(ID: integer);
begin
  FID := ID;
end;

{procedure TShop.setOwner(const Owner: TCustomer);
begin
  // FEHLERBEHANDLUNG: REICHT DAS AUS??
  FOwner := Owner;
  if (Owner is TCustomer) then FOwnerID := Owner.ID;
end;}

procedure TShop.setDimension(Width, Height: double);
begin
  if (Width <= 0) or (Height <= 0) then exit;

  FWidth := Width;
  FHeight := Height;

  FPoints := getPoints(false,SHOP_PAINTER_OFFSET);
end;

procedure TShop.setPosition(X, Y: integer);
begin
  if (X <= 0) or (Y <= 0) then exit;

  FX := X;
  FY := Y;

  FPoints := getPoints(false,SHOP_PAINTER_OFFSET);
end;

procedure TShop.setAngle(Angle: integer);
begin
  FAngle := Angle mod 359;
  if FAngle < 0 then inc(FAngle,359);
  
  FPoints := getPoints(false,SHOP_PAINTER_OFFSET);
end;

function TShop.getPixelWidth: integer;
begin
  Result := Round(FFactor*FWidth);
end;

function TShop.getPixelHeight: integer;
begin
  Result := Round(FFactor*FHeight);
end;

{function TShop.getPrice: double;
begin
  Result := 5;
end;    }

function TShop.getPoints(Relative: Boolean; Offset: integer): TFourPoints;
var alpha, len, w1, w2: Real;
    minP, maxP: TPoint;
    i: integer;
begin
  alpha := degtorad(FAngle);
  len := sqrt(sqr(PixelHeight/2)+sqr(PixelWidth/2));

  // Beide Innenwinkel errechnen
  w1 := radtodeg(arctan(PixelWidth/PixelHeight));
  w2 := 90-w1;
                                                
  // Punkte berechnen und setzen
  Result[0] := Point(
    round(FX+len*sin(degtorad(90+w2)+alpha)),
    round(FY-len*cos(degtorad(90+w2)+alpha))
  );

  Result[1] := Point(
    round(FX-len*sin(degtorad(w1)+alpha)),
    round(FY+len*cos(degtorad(w1)+alpha))
  );

  Result[2] := Point(
    round(FX-len*sin(degtorad(90-w2)-alpha)),
    round(FY-len*cos(degtorad(90-w2)-alpha))
  );

  Result[3] := Point(
    round(FX+len*sin(degtorad(180-w1)-alpha)),
    round(FY+len*cos(degtorad(180-w1)-alpha))
  );

  if (Relative) then begin
    minP := Result[0];
    maxP := Result[0];

    for i := 0 to length(Result)-1 do begin
      minP.X := Min(minP.X,Result[i].X);
      minP.Y := Min(minP.Y,Result[i].Y);

      maxP.X := Max(maxP.X,Result[i].X);
      maxP.Y := Max(maxP.Y,Result[i].Y);
    end;

    for i := 0 to length(Result)-1 do begin
      Result[i].X := Result[i].X - minP.X + Offset;
      Result[i].Y := Result[i].Y - minP.Y + Offset;
    end;
  end;
end;

{function TShop.isHighlighted: Boolean;
begin
  Result := FHighlighted;
end;

function TShop.isSelected: Boolean;
begin
  Result := FSelected;
end;
 }
// Nick: Ratchet (aus VB uebersetzt)
// URL: http://www.blitzforum.de/viewtopic.php?t=15490
function TShop.isMovePoint(X, Y: integer): Boolean;
var Count, TmpX, TmpY, Checked, i, j: integer;
    Poly: array of integer;
begin
  setLength(Poly,Length(FPoints)*2);

  // Punkt Array erstellen
  j := 0; for i := 0 to Length(FPoints)-1 do begin
    Poly[j] := FPoints[i].X; inc(j);
    Poly[j] := FPoints[i].Y; inc(j);
  end;

  // Pruefen ob der Punkt innerhalb der Action liegt
  Count := Length(FPoints);
  Checked := 0;

  for i := 1 to Count do begin
    if (i = Count) then begin
      TmpX := Poly[0];
      TmpY := Poly[1];
    end else begin
      TmpX := Poly[i*2];
      TmpY := Poly[i*2+1];
    end;

    if ((TmpX - Poly[i*2-2]) * (Y - TmpY) - (X - TmpX) * (TmpY - Poly[i*2-1]) > 0) then inc(Checked);
  end;

  Result := (Checked = Count);
end;

function TShop.isRotatePoint(X, Y: integer): Boolean;
var i: integer;
begin
  Result := false;

  for i := 0 to Length(FPoints)-1 do begin
    if (abs(FPoints[i].X - X - ceil(ROTATE_POINT_RADIUS/2)) > ROTATE_POINT_RADIUS) or (abs(FPoints[i].Y - Y - ceil(ROTATE_POINT_RADIUS/2)) > ROTATE_POINT_RADIUS) then continue;
    Result := true; exit;
  end;
end;

function TShop.hasOwner: Boolean;
begin
//  Result := FOwner is TCustomer;
  Result := (FCustomerID <> -1) and (FCustomerID <> 0)
end;

procedure TShop.Save;
begin
  if not FuseDB then exit;

  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;

  // Neuer Shop
  if FID <= 0 then begin
    FQuery.Sql.Add(
      Format(QUERY_SHOPS_NEW,[
         FCustomerID, FTypeID, FLocationID, FWidth, FHeight,
         FX, FY, FAngle, sqlEsc(FAddress), FPrice, sqlEsc(FOther)
      ])
    );

    try
      FQuery.ExecSQL;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to add new shop');
    end;

    // Letzte ID lesen

    FQuery.Sql.Clear;
    FQuery.Sql.Add(QUERY_SHOPS_LASTID);

    try
      FQuery.Open;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to add new shop');
    end;

    if FQuery.Eof then Exception.Create('Unable to add new shop');

    try
      FID := FQuery.Fields[0].AsInteger;
    except
      Exception.Create('Unable to add new shop');
    end;
  end
                                   

  // Bestehender Shop
  else begin
    FQuery.Sql.Add(
      Format(QUERY_SHOPS_EDIT,[
         FCustomerID, FTypeID, FLocationID, FWidth, FHeight,
         FX, FY, FAngle, sqlEsc(FAddress), FPrice, sqlEsc(FOther), FID
      ])
    );

    try
      FQuery.ExecSQL;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to edit shop');
    end;
  end;
end;

procedure TShop.Delete;
begin
  // Wichtig: Den Besitzer des Shops _nicht_ davon in Kenntnis setzen.
  // Das muss manuell geschehen, da sonst eine Rekursion entsteht.

  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_SHOPS_DELETE,[FID]));

  try
    FQuery.ExecSQL;
  except
    // FEHLERBEHANDLUNG
    raise Exception.Create('Unable to delete shop');
  end;
end;

{procedure TShop.Assign(Shop: TShop);
begin
  Shop.
end;    }


{****************** TShops ******************}

constructor TShops.Create;
begin
  inherited Create;

  FuseDB := false;
  FDB := nil;
  FQuery := nil;

  FShops := TList.Create;
end;

destructor TShops.Destroy;
begin
  // Hier nicht (!) die FCustomers-Objekte freigeben
  // Das muss manuell in Close() ausgelöst werden.

  FShops.Free;
  inherited Destroy;
end;

procedure TShops.setDB(const Database: TADOConnection; const Query: TADOQuery);
var i: integer;
begin
  if (not (Database is TADOConnection)) or (not (Query is TADOQuery)) then begin
    for i := 0 to Count-1 do Shops[i].setDB(nil,nil);
    FuseDB := false; exit;
  end;

  for i := 0 to Count-1 do Shops[i].setDB(FDB,FQuery);
  FuseDB := true;

  FDB := Database;
  FQuery := Query;
end;

function TShops.Count: integer;
begin

  Result := FShops.Count;
end;

function TShops.Count(customerID: integer): integer;
var i: integer;
begin
  Result := 0;

  for i := 0 to Count-1 do begin
    if Shops[i].customerID <> customerID then continue;
    inc(Result);
  end;
end;

function TShops.Exists(shopID: integer): boolean;
var i: integer;
begin
  Result := false;

  for i := 0 to Count-1 do begin
    if (Shops[i].ID <> shopID) then continue;

    Result := true;
    exit;
  end;
end;

function TShops.New: TShop;
var PShop: ^TShop;
begin
  System.New(PShop);
  PShop^ := TShop.Create;

  if FuseDB then PShop^.setDB(FDB,FQuery);

  FShops.Add(PShop);

  Result := PShop^;
end;

procedure TShops.Add(const Shop: TShop);
var pShop: ^TShop;
begin
  System.New(pShop);
  pShop^ := Shop;

  FShops.Add(pShop);
end;

procedure TShops.Delete(ID: integer; fromDB: Boolean);
var i: integer;
    Shop: TShop;
    PShop: ^TShop;
begin
  Shop := byID(ID);
  if not (Shop is TShop) then exit;

  // Aus der DB löschen
  if fromDB then Shop.Delete;

  // Aus der Shopliste löschen
  for i := 0 to FShops.Count-1 do begin
    PShop := FShops[i];
    if (not (PShop^ is TShop)) or (PShop^.ID <> ID) then continue;

    FShops.Extract(PShop); break;
  end;
end;

procedure TShops.Close;
begin
  while FShops.Count > 0 do begin
    Shops[0].Free;
    FShops.Delete(0);
  end;
end;

function TShops.getShop(Value: integer): TShop;
var PShop: ^TShop;
begin
  Result := nil;
  if (FShops.Count > Value) and (Value >= 0) then begin
    PShop := FShops[Value];
    Result := PShop^;
  end;
end;


{procedure TShops.setSelection(Index: integer);
var i: integer;
begin
  for i := 0 to FShops.Count-1 do begin
    if (i = Index) then Self[i].setSelection(true)
    else if (Self[i].isSelected) then Self[i].setSelection(false);
  end;
end;
 }
function TShops.byID(ID: integer): TShop;
var i: integer;
    Shop: PShop;
begin
  Result := nil;

  for i := 0 to FShops.Count-1 do begin
    Shop := FShops[i];
    if (not (Shop^ is TShop)) or (Shop^.ID <> ID) then continue;

    Result := Shop^; break;
  end;
end;

function TShops.byCustomer(customerID: integer): TShops;
var i: integer;
    Shop: TShop;
begin
  Result := TShops.Create;

  for i := 0 to Count-1 do begin
    Shop := Shops[i];

    if (not (Shop is TShop)) or (Shop.customerID <> customerID) then begin
      continue;
    end;

    Result.Add(Shop);
  end;

  if Result.Count = 0 then begin
    freeAndNil(Result);
    exit;
  end;

  // Result ->
end;

function TShops.Find(Field: TShopField; aPattern: string = ''): TShops;
var i: integer;
    aString: string;

begin
  Result := TShops.Create;
  aPattern := Trim(AnsiLowerCase(aPattern));

  // Keine Pattern: Alle Kunden
  if aPattern = '' then begin
    for i := 0 to Count-1 do Result.Add(Shops[i]);
    exit;
  end;

  for i := 0 to Count-1 do begin
    // sfID, sfSize, sfType, sfAddress, sfOther, sfPrice, sfDate

    case Field of
      sfID: aString := intToStr(Shops[i].ID);
      sfSize: aString := Format('%2.2f x %2.2f',[Shops[i].Width,Shops[i].Height]);
    //  sfType: aString := Shops[i].Company;
      sfAddress: aString := Shops[i].Address;
      sfOther: aString := Shops[i].Other;
//      sfPrice: aString := Customers[i].City;
//      sfDate: aString := Customers[i].Phone;
    end;

    aString := AnsiLowerCase(aString);

    if (Pos(aPattern,aString) > 0) or Like(aString,aPattern) then Result.Add(Shops[i]);
  end;
end;

procedure TShops.sortBy(Field: TShopField; Ascending: boolean = true);
begin
  // sfID, sfSize, sfType, sfAddress, sfOther, sfPrice, sfDate

  case Field of
    sfID: FShops.Sort(shopSortID);
    sfSize: FShops.Sort(shopSortSize);
    sfType: FShops.Sort(shopSortType);
    sfAddress: FShops.Sort(shopSortAddress);
    sfOther: FShops.Sort(shopSortOther);
    sfPrice: FShops.Sort(shopSortPrice);
    sfDate: FShops.Sort(shopSortDate);
  end;

  if not Ascending then listReverse(FShops);
end;


end.
 