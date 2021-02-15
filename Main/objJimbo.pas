unit objJimbo;

interface

uses
  Windows, Messages, Classes, SysUtils, Math, Graphics, JPEG,

  // DB-Komponenten
  DB, ADODB,

  // Eigene Objekte
  _define, objMap, objMaps, objShopDates, objShopTypes, objCustomerTypes,
  objDates, objIntegerList, objPricer, objShops, objCustomers,

  // Eigene Funktionen
  funcCommon;


type
  // Vordeklarationen
  TJimbo = class;

  // Hauptprogramm
  TJimbo = class
  private
    // Datenbank-Verbindung
    FDB: TADOConnection;
    FQuery: TADOQuery;

    // Common
    FTitle: string;
    FFilename: string;
    FPrice: string;
    FOther: string;

    // Karte (Pfad zur Karte)
    FMaps: TMaps;
    FMapFile: string;
    FMapKey: string;
    FPosition: TPoint;

    FOpened: Boolean;

    // Preisberechnung
    FPricer: TPricer;

    // Stände
    FShops: TShops;
    FShopDates: TShopDates;
    FShopTypes: TShopTypes;

    // Kunden
    FCustomers: TCustomers;
    FCustomerTypes: TCustomerTypes;

    // Datum / Termine
    FCurrentDateID: integer;
    FDates: TDates;

    // Standard-Einstellungen
    FCommonShopTypeID: integer;
    FCommonCustomerTypeID: integer;

    procedure setTitle(Title: string);
    procedure setOther(Other: string);
    procedure setPosition(Position: TPoint);
    procedure setMapFile(Filename: string);
    procedure setMapKey(Key: string);
    procedure setCurrentDateID(ID: integer);
    procedure setCommonShopTypeID(ID: integer);
    procedure setCommonCustomerTypeID(ID: integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;

    // Datenbank
    procedure Open(Filename: string; keepCommon: boolean = false);
    procedure Close;

    // Sonstige
    function checkDate(dateID, shopID: integer): Boolean;

    function PriceCalc(shopID: integer): double;
    function PriceTest_OLD(priceStr: string): boolean;

    // Eigenschaften
    property Title: string read FTitle write setTitle;
    property Other: string read FOther write setOther;

    property Position: TPoint read FPosition write setPosition;
    property DateID: integer read FCurrentDateID write setCurrentDateID;
    property ShopTypeID: integer read FCommonShopTypeID write setCommonShopTypeID;
    property CustomerTypeID: integer read FCommonCustomerTypeID write setCommonCustomerTypeID;

    property MapFile: string read FMapFile write setMapFile;
    property MapKey: string read FMapKey write setMapKey;

    property Filename: string read FFilename write FFilename;
    property Opened: Boolean read FOpened;

    property Pricer: TPricer read FPricer;

    property Customers: TCustomers read FCustomers;
    property CustomerTypes: TCustomerTypes read FCustomerTypes;

    property Shops: TShops read FShops;
    property ShopDates: TShopDates read FShopDates;
    property ShopTypes: TShopTypes read FShopTypes;

    property Dates: TDates read FDates;
  end;


implementation




{****************** TJimbo ******************}

constructor TJimbo.Create;
begin
  inherited Create;

  FDB := TADOConnection.Create(nil);
  FQuery := TADOQuery.Create(FDB);
  FQuery.Connection := FDB;

  FPricer := TPricer.Create;
  FPricer.useCache := true;

  FShops := TShops.Create;
  FShopDates := TShopDates.Create;
  FShopTypes := TShopTypes.Create;

  FCustomers := TCustomers.Create;
  FCustomerTypes := TCustomerTypes.Create;

  FDates := TDates.Create;

  FShops.setDB(FDB,FQuery);
  FShopDates.setDB(FDB,FQuery);
  FShopTypes.setDB(FDB,FQuery);

  FCustomers.setDB(FDB,FQuery);
  FCustomerTypes.setDB(FDB,FQuery);

  FDates.setDB(FDB,FQuery);
  FDates.Pricer := FPricer;

  with FPricer do begin
    Fields['K'].asFloat := 0;
    Fields['B'].asFloat := 0;
    Fields['L'].asFloat := 0;
    Fields['S'].asFloat := 0;
    Fields['T'].asInt := 0;
  end;

  Reset;
end;

destructor TJimbo.Destroy;
begin
  FDates.Free;

  FCustomerTypes.Free;
  FCustomers.Free;

  FShopTypes.Free;
  FShopDates.Free;
  FShops.Free;

  FPricer.Free;

  FQuery.Free;
  FDB.Free;

  inherited Destroy;
end;

procedure TJimbo.Reset;
begin
//  FMaps.Clear;
  FCurrentDateID := -1;
end;

procedure TJimbo.setTitle(Title: string);
begin
  if not FOpened then exit;

  // Eigenschaft speichern
  FTitle := Title;

  // In der Datenbank speichern
  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[sqlEsc(FTitle),'title']));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to set the title');
  end;
end;

procedure TJimbo.setOther(Other: string);
begin
  if not FOpened then exit;

  // Eigenschaft speichern
  FOther := Other;

  // In der Datenbank speichern
  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[sqlEsc(FOther),'other']));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to set the other');
  end;
end;

procedure TJimbo.setCurrentDateID(ID: integer);
begin
  if FDates.indexOf(ID) = -1 then begin
    FCurrentDateID := -1;
    exit;
  end;

  FCurrentDateID := ID;

  // In der Datenbank speichern
  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[IntToStr(FCurrentDateID),'dateid']));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to set the date-id');
  end;
end;

procedure TJimbo.setCommonShopTypeID(ID: integer);
begin
  if FShopTypes.indexOf(ID) = -1 then begin
    FCommonShopTypeID := -1;
    exit;
  end;

  FCommonShopTypeID := ID;

  // In der Datenbank speichern
  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[IntToStr(FCommonShopTypeID),'shoptypeid']));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to set the shop-type-id');
  end;
end;

procedure TJimbo.setCommonCustomerTypeID(ID: integer);
begin
  if FCustomerTypes.indexOf(ID) = -1 then begin
    FCommonCustomerTypeID := -1;
    exit;
  end;

  FCommonCustomerTypeID := ID;

  // In der Datenbank speichern
  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[IntToStr(FCommonCustomerTypeID),'customertypeid']));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to set the customer-type-id');
  end;
end;

procedure TJimbo.setPosition(Position: TPoint);
begin
  // X
  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[IntToStr(Position.X),'x']));

  try FQuery.ExecSQL;
  except raise Exception.Create('Unable to set the position'); end;

  // Y
  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[IntToStr(Position.Y),'y']));

  try FQuery.ExecSQL;
  except raise Exception.Create('Unable to set the position'); end;
end;


procedure TJimbo.setMapFile(Filename: string);
begin
  // FEHLERBEHANDLUNG
  //if not FileExists(FMapDir+ExtractFileName(Filename)) then raise Exception.Create('Der Map ''' + ExtractFileName(Filename) + '.dll'' wurde nicht gefunden');

  // Eigenschaft speichern
  FMapFile := ExtractFileName(Filename);

  // In der Datenbank speichern
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[sqlEsc(FMapFile),'mapfile']));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to set the map file');
  end;
end;

procedure TJimbo.setMapKey(Key: string);
begin
  // Eigenschaft speichern
  FMapKey := Key;

  // In der Datenbank speichern
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_COMMON_SET_FIELD,[sqlEsc(FMapKey),'mapkey']));

  try
    FQuery.ExecSQL;
  except
    raise Exception.Create('Unable to set the map key');
  end;
end;


procedure TJimbo.Open(Filename: string; keepCommon: boolean = false);
var i, j, cnt, customerID: integer;
    Tab: TStrings;
    tempStr, tempVal: string;

    Customer: TCustomer;
    Shop: TShop;
    ShopRef: PShop;
begin
  // FEHLERBEHANDLUNG
  if not FileExists(Filename) then raise Exception.Create('Die Projektdatei wurde nicht gefunden');

  // Einstellungen
  FFilename := Filename;
  FDB.ConnectionString := Format(ACCESS_CONNECTION_STRING,[sqlEsc(Filename),'']);

  // Erster Versuch
  try
    FDB.Open;
    FDB.Close;
  except
    raise Exception.Create('Fehler beim Verbinden zur Datenbank');
    exit;
  end;

  // Tabellen auf existenz Prüfen
  Tab := TStringList.Create;
  FDB.GetTableNames(Tab);

  cnt := 0; for i := 0 to Tab.Count-1 do begin
    if Tab[i] = TABLE_CUSTOMERS then inc(cnt)
    else if Tab[i] = TABLE_SHOPS then inc(cnt)
    else if Tab[i] = TABLE_COMMON then inc(cnt);
  end;

  // Fehler
  if cnt < 3 then raise Exception.Create('No Connection to Database');

  Tab.Free;

  // Common-Einstellungen laden
  if not keepCommon then begin
    if FQuery.Active then FQuery.Close;

    FQuery.Sql.Clear;
    FQuery.Sql.Add(QUERY_COMMON_LOAD);

    try
      FQuery.Open;
    except
      raise Exception.Create('Unable to load common-settings table');
    end;

    while not FQuery.Eof do begin
      tempStr := Trim(FQuery.FieldByName('name').AsString);
      tempVal := Trim(FQuery.FieldByName('value').AsString);

      try
        if tempStr = 'mapfile' then FMapFile := tempVal
        else if tempStr = 'mapkey' then FMapKey := tempVal
        else if tempStr = 'title' then FTitle := tempVal
        else if tempStr = 'dateid' then FCurrentDateID := StrToIntDef(tempVal,1)
        else if tempStr = 'shoptypeid' then FCommonShopTypeID := StrToIntDef(tempVal,1)
        else if tempStr = 'customertypeid' then FCommonCustomerTypeID := StrToIntDef(tempVal,1)
        else if tempStr = 'x' then FPosition.X := StrToIntDef(tempVal,0)
        else if tempStr = 'y' then FPosition.Y := StrToIntDef(tempVal,0)
        else if tempStr = 'price' then FPrice := tempVal
        else if tempStr = 'other' then FOther := tempVal;
      finally
        FQuery.Next;
      end;
    end;
  end;

  // Termine laden
  // Typen laden
  // Termin/Shop-Verknüfungen laden
  FCustomerTypes.Load;

  FShopTypes.Load;
  FShopDates.Load;

  FDates.Load;

  // Kunden laden

  // Wichtig: Beide gleichzeitig laden, da sich beide Objekte
  // gegenseitig referenzieren.

  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(QUERY_CUSTOMERS_LOAD);

  try
    FQuery.Open;
  except
    raise Exception.Create('Unable to load customers table');
  end;

  while not FQuery.Eof do begin
    Customer := FCustomers.New;

    // Felder lesen
    Customer.setID(FQuery.FieldByName('id').AsInteger);
    Customer.cID := FQuery.FieldByName('cid').AsInteger;
    Customer.typeID := FQuery.FieldByName('typeid').AsInteger;

    tempStr := Trim(FQuery.FieldByName('sex').AsString);
    if Length(tempStr) <> 1 then Customer.Sex := '-'
    else Customer.Sex := LowerCase(tempStr)[1];

    Customer.Company := Trim(FQuery.FieldByName('company').AsString);
    Customer.Lastname := Trim(FQuery.FieldByName('lastname').AsString);
    Customer.Firstname := Trim(FQuery.FieldByName('firstname').AsString);
    Customer.Address := Trim(FQuery.FieldByName('address').AsString);

    try Customer.ZIP := FQuery.FieldByName('zip').AsInteger;
    except Customer.ZIP := 0; end;

    Customer.City := Trim(FQuery.FieldByName('city').AsString);
    Customer.Phone := Trim(FQuery.FieldByName('phone').AsString);
    Customer.eMail := Trim(FQuery.FieldByName('email').AsString);
    Customer.Other := Trim(FQuery.FieldByName('other').AsString);

    // Hinzufügen
    FQuery.Next;
  end;

  // Shops laden
  FQuery.Close;
  FQuery.Sql.Clear;                                              
  FQuery.Sql.Add(QUERY_SHOPS_LOAD);

  try
    FQuery.Open;
  except
    raise Exception.Create('Unable to load shops table');
  end;

  while not FQuery.Eof do begin
    Shop := FShops.New;

    // Felder lesen
    Shop.ID := FQuery.FieldByName('id').AsInteger;

    Shop.setDimension(FQuery.FieldByName('width').AsInteger,FQuery.FieldByName('height').AsInteger);
    Shop.setPosition(FQuery.FieldByName('x').AsInteger,FQuery.FieldByName('y').AsInteger);
    Shop.Angle := FQuery.FieldByName('angle').AsInteger;

    Shop.TypeID := FQuery.FieldByName('typeid').AsInteger;
    Shop.TypeStr := FQuery.FieldByName('typestr').AsString;
    Shop.locationID := FQuery.FieldByName('locationid').AsInteger;

    Shop.Address := Trim(FQuery.FieldByName('address').AsString);
    Shop.Other := Trim(FQuery.FieldByName('other').AsString);

    // Customer-Objekt raussuchen
    Shop.customerID := FQuery.FieldByName('customerid').AsInteger;

    // Hinzufügen
    FQuery.Next;
  end;

  FOpened := true;
end;

procedure TJimbo.Close;
begin
  // Datenbankverbindung schließen
  FQuery.Close;
  FDB.Close;

  // Kunden und Shops löschen
  FCustomers.Close;
  FShops.Close;

  FShopDates.Clear;
  FDates.Clear;

  Reset;

  FOpened := false;
end;

function TJimbo.checkDate(dateID, shopID: integer): Boolean;
begin
  Result := FShopDates.indexOf(dateID,shopID) <> -1;
end;

function TJimbo.PriceCalc(shopID: integer): double;
var priceStr: string;

    tmpStr: string;
    tmpFloat: double;
    tmpInt, i, j: integer;

    fmtSet: TFormatSettings;

    Customer: TCustomer;
    CustomerType: TCustomerType;

    Shop: TShop;
    ShopType: TShopType;
begin
  Result := 0;

  getLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT,fmtSet);
//  fmtSet.DecimalSeparator := '.';

  // Shop
  Shop := Shops.byID(shopID);
  if not (Shop is TShop) then exit;

  priceStr := '';
  Result := 0;

  for i := 0 to Dates.Count-1 do begin
    //priceStr := priceStr + Dates[i].Price;
    //if i < Dates.Count-1 then priceStr := priceStr + ' + ';
    if ShopDates.indexOf(Dates[i].ID,shopID) = -1 then continue;

    // Breite und Länge
    Pricer.Fields['B'].asFloat := Shop.Width;
    Pricer.Fields['L'].asFloat := Shop.Height;

    //if pos('B',priceStr) > 0 then priceStr := stringReplace(priceStr,'B',floatToStr(Shop.Width),[rfReplaceAll]);
    //if pos('L',priceStr) > 0 then priceStr := stringReplace(priceStr,'L',floatToStr(Shop.Height),[rfReplaceAll]);

    // Kundentyp
    //if pos('K',priceStr) > 0 then begin
    if pos('K',Dates[i].Price) > 0 then begin
      Customer := Customers.byID(Shop.customerID);

      if not (Customer is TCustomer) then tmpFloat := 0
      else begin
        CustomerType := CustomerTypes.byID(Customer.typeID);
        if not (CustomerType is TCustomerType) then tmpFloat := 0
        else tmpFloat := CustomerType.Multiplier;
      end;

      //priceStr := stringReplace(priceStr,'K',floatToStr(tmpFloat,fmtSet),[rfReplaceAll]);
      Pricer.Fields['K'].asFloat := tmpFloat;
    end;

    // Stand-Typ
    if pos('S',Dates[i].Price) > 0 then begin
//    if pos('S',priceStr) > 0 then begin
      ShopType := ShopTypes.byID(Shop.typeID);

      if not (ShopType is TShopType) then tmpFloat := 0
      else tmpFloat := ShopType.Multiplier;

      //priceStr := stringReplace(priceStr,'S',floatToStr(tmpFloat,fmtSet),[rfReplaceAll]);
      Pricer.Fields['K'].asFloat := tmpFloat;
    end;

    // Anzahl der Tage
    if pos('T',Dates[i].Price) > 0 then begin
//    if pos('T',priceStr) > 0 then begin
      tmpInt := 0;

      for j := 0 to Dates.Count-1 do begin
        if ShopDates.indexOf(Dates[j].ID,Shop.ID) = -1 then continue;
        inc(tmpInt);
      end;

      //priceStr := stringReplace(priceStr,'T',intToStr(tmpInt),[rfReplaceAll]);
      Pricer.Fields['K'].asInt := tmpInt;
    end;

    if not Pricer.Calculate(Dates[i].Price,tmpFloat) then begin
      Result := -1;
      exit;
    end;

    Result := Result + tmpFloat;
  end;

  //priceStr := tmpStr;
//  if not Pricer.Calculate(priceStr,Result) then Result := -1;
end;

function TJimbo.PriceTest_OLD(priceStr: string): boolean;
var i: integer;
    fields: array[0..4] of char;
begin
  fields[0] := 'K';
  fields[1] := 'B';
  fields[2] := 'L';
  fields[3] := 'S';
  fields[4] := 'T';

  if priceStr = '' then priceStr := FPrice;

//  for i := 0 to Length(fields)-1 do priceStr := stringReplace(priceStr,fields[i],10+random(200),[rfReplaceAll]);

  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add('SELECT '+ priceStr + ' AS `price`');

  try
    FQuery.Open;
  except
    Result := false;
    exit;
  end;

  Result := true;
end;

end.
