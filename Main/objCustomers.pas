unit objCustomers;

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
  TCustomer = class;
  pCustomer = ^TCustomer;

  TCustomerField = (cfLastname, cfFirstname, cfCompany, cfAddress, cfZIP, cfCity, cfPhone, cfeMail, cfOther, cfType, cfCID);

  // Kunde
  TCustomer = class
  private
    // DB / Referenzen
    FuseDB: Boolean;
    FDB: TADOConnection;
    FQuery: TADOQuery;

    // Identifizier' dich!
    FID: integer;
    FCID: integer;
    FTypeID: integer;

    FSex: Char;
    FFirstname: string;
    FLastname: string;
    FCompany: string;
    FAddress: string;
    FZIP: integer;
    FCity: string;
    FPhone: string;
    FeMail: string;
    FOther: string;

    //FShops: TShops;

    procedure setSex(Sex: Char);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TCustomer);

    procedure setDB(const Database: TADOConnection; const Query: TADOQuery);

    procedure Save;
    procedure Delete;
    procedure setID(ID: integer);

    property useDB: Boolean read FuseDB;
    property ID: integer read FID;
    property cID: integer read FCID write FCID;
    property typeID: integer read FTypeID write FTypeID;

    property Sex: Char read FSex write setSex;
    property Lastname: string read FLastname write FLastname;
    property Firstname: string read FFirstname write FFirstname;
    property Company: string read FCompany write FCompany;
    property Address: string read FAddress write FAddress;
    property ZIP: integer read FZIP write FZIP;
    property City: string read FCity write FCity;
    property Phone: string read FPhone write FPhone;
    property eMail: string read FeMail write FeMail;
    property Other: string read FOther write FOther;

    //property Shops: TShops read FShops;
  end;

  // Kunden
  TCustomers = class
  private
    // DB / Referenzen
    FuseDB: Boolean;
    FDB: TADOConnection;
    FQuery: TADOQuery;

    // Kunden
    FCustomers: TList;

    function getCustomer(Value: integer): TCustomer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure setDB(const Database: TADOConnection; const Query: TADOQuery);

    function New: TCustomer;
    procedure addCopy(Customer: TCustomer);
    procedure Delete(customerID: integer; fromDB: Boolean);

    function Count: integer;
    function Exists(customerID: integer): boolean;
    procedure Close;

    function NextCID: integer;

    function byID(ID: integer): TCustomer;
    function Find(FieldID: TCustomerField; aPattern: string = ''): TCustomers;
    procedure sortBy(Field: TCustomerField; Ascending: boolean = true);

    property useDB: Boolean read FuseDB;
    property Customers[Index: integer]: TCustomer read getCustomer; default;
  end;

function cfIdToField(Id: integer): TCustomerField;
function cfFieldToId(Field: TCustomerField): integer;

implementation

function cfIdToField(Id: integer): TCustomerField;
begin
  case Id of
    0: Result := cfLastname;
    1: Result := cfFirstname;
    2: Result := cfCompany;
    3: Result := cfAddress;
    4: Result := cfZIP;
    5: Result := cfCity;
    6: Result := cfPhone;
    7: Result := cfeMail;
    8: Result := cfOther;
    9: Result := cfCID;
    10: Result := cfType;
    else Result := cfLastname;
  end;
end;

function cfFieldToId(Field: TCustomerField): integer;
begin
  case Field of
    cfLastname: Result := 0;
    cfFirstname: Result := 1;
    cfCompany: Result := 2;
    cfAddress: Result := 3;
    cfZIP: Result := 4;
    cfCity: Result := 5;
    cfPhone: Result := 6;
    cfeMail: Result := 7;
    cfOther: Result := 8;
    cfCID: Result := 9;
    cfType: Result := 10;
    else Result := 0;
  end;
end;


{** Callback-Funktion für die Sortierung **}

function customerSortCID(pCust1, pCust2: Pointer): integer;
begin
  Result := CompareValue(TCustomer(pCust1^).cID,TCustomer(pCust2^).cID);
end;

function customerSortLastname(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).Lastname,TCustomer(pCust2^).Lastname);
end;

function customerSortFirstname(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).Firstname,TCustomer(pCust2^).Firstname);
end;

function customerSortCompany(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).Company,TCustomer(pCust2^).Company);
end;

function customerSortAddress(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).Address,TCustomer(pCust2^).Address);
end;

function customerSortZIP(pCust1, pCust2: Pointer): integer;
begin
  Result := CompareValue(TCustomer(pCust1^).ZIP,TCustomer(pCust2^).ZIP);
end;

function customerSortCity(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).City,TCustomer(pCust2^).City);
end;

function customerSortPhone(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).Phone,TCustomer(pCust2^).Phone);
end;

function customerSortEMail(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).eMail,TCustomer(pCust2^).eMail);
end;

function customerSortType(pCust1, pCust2: Pointer): integer;
begin
  Result := 0;
end;

function customerSortOther(pCust1, pCust2: Pointer): integer;
begin
  Result := AnsiCompareText(TCustomer(pCust1^).Other,TCustomer(pCust2^).Other);
end;

{**************** TCustomer ****************}

constructor TCustomer.Create;
begin
  inherited Create;

  FDB := nil;
  FQuery := nil;

  FID := -1;
  FTypeID := -1;

  FSex := '-';
  FFirstname := '';
  FLastname := '';
  FCompany := '';
  FAddress := '';
  FZIP := 0;
  FCity := '';
  FPhone := '';
  FeMail := '';

  //FShops := TShops.Create;
end;

destructor TCustomer.Destroy;
begin
  //FShops.Free;
  inherited Destroy;
end;

procedure TCustomer.Assign(Source: TCustomer);
begin
  FID := Source.ID;
  FSex := Source.Sex;
  FTypeID := Source.typeID;
  FFirstname := Source.Firstname;
  FLastname := Source.Lastname;
  FCompany := Source.Company;
  FAddress := Source.Address;
  FZIP := Source.ZIP;
  FPhone := Source.Phone;
  FeMail := Source.eMail;
  FOther := Source.Other;
end;

procedure TCustomer.setDB(const Database: TADOConnection; const Query: TADOQuery);
begin
  if (not (Database is TADOConnection)) or (not (Query is TADOQuery)) then begin
//    FShops.setDB(nil,nil);
    FuseDB := false; exit;
  end;

//  FShops.setDB(Database,Query);
  FuseDB := true;

  FDB := Database;
  FQuery := Query;
end;

procedure TCustomer.setSex(Sex: Char);
begin
  case Sex of
    'M', 'm': FSex := 'm';
    'F', 'f': FSex := 'f';
    else FSex := '-';
  end;
end;

procedure TCustomer.Save;
begin
  if not FuseDB then exit;

  if FQuery.Active then FQuery.Close;
  FQuery.Sql.Clear;

  // Neuer Kunde
  if FID <= 0 then begin
    FQuery.Sql.Add(
      Format(QUERY_CUSTOMERS_NEW,[
         FCID, sqlEsc(FFirstname), sqlEsc(FLastname), sqlEsc(FCompany), sqlEsc(FAddress),
         FZIP, sqlEsc(FCity), sqlEsc(FSex), FTypeID, sqlEsc(FPhone),
         sqlEsc(FeMail), sqlEsc(FOther)
      ])
    );

    try
      FQuery.ExecSQL;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to add new customer');
    end;

    // Letzte ID lesen

    FQuery.Sql.Clear;
    FQuery.Sql.Add(QUERY_CUSTOMERS_LASTID);

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


  // Bestehender Kunde
  else begin
    FQuery.Sql.Add(
      Format(QUERY_CUSTOMERS_EDIT,[
         FCID, sqlEsc(FFirstname), sqlEsc(FLastname), sqlEsc(FCompany), sqlEsc(FAddress),
         FZIP, sqlEsc(FCity), sqlEsc(FSex), FTypeID, sqlEsc(FPhone),
         sqlEsc(FeMail), sqlEsc(FOther), FID
      ])
    );

//    showmessage(FQuery.Sql.Text);

    try
      FQuery.ExecSQL;
    except
      // FEHLERBEHANDLUNG
      raise Exception.Create('Unable to edit customer');
    end;
  end;
end;

procedure TCustomer.Delete;
begin
  if FQuery.Active then FQuery.Close;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(Format(QUERY_CUSTOMERS_DELETE,[FID]));

  try
    FQuery.ExecSQL;
  except
    // FEHLERBEHANDLUNG
    raise Exception.Create('Unable to delete customer');
  end;
end;

procedure TCustomer.setID(ID: integer);
begin
  FID := ID;
end;


{****************** TCustomers ******************}

constructor TCustomers.Create;
begin
  inherited Create;

  FuseDB := false;
  FDB := nil;
  FQuery := nil;

  FCustomers := TList.Create;
end;

destructor TCustomers.Destroy;
begin
  // Hier nicht (!) die FCustomers-Objekte freigeben
  // Das muss manuell in Close() ausgelöst werden.

  FCustomers.Free;
  inherited Destroy;
end;

procedure TCustomers.setDB(const Database: TADOConnection; const Query: TADOQuery);
var i: integer;
begin
  if (not (Database is TADOConnection)) or (not (Query is TADOQuery)) then begin
    for i := 0 to Count-1 do Customers[i].setDB(nil,nil);
    FuseDB := false; exit;
  end;

  for i := 0 to Count-1 do Customers[i].setDB(FDB,FQuery);
  FuseDB := true;

  FDB := Database;
  FQuery := Query;
end;

function TCustomers.Count: integer;
begin
  Result := FCustomers.Count;
end;

function TCustomers.Exists(customerID: integer): boolean;
var i: integer;
begin
  Result := false;

  for i := 0 to Count-1 do begin
    if (Customers[i].ID <> customerID) then continue;

    Result := true;
    exit;
  end;
end;


function TCustomers.New: TCustomer;
var pCustomer: ^TCustomer;
begin
  System.New(PCustomer);
  PCustomer^ := TCustomer.Create;
  if FUseDB then PCustomer^.setDB(FDB,FQuery);

  FCustomers.Add(PCustomer);

  Result := PCustomer^;
end;

procedure TCustomers.addCopy(Customer: TCustomer);
var PCustomer: ^TCustomer;
begin
  // Keine wirkliche Kopie!!!!!!
  // siehe http://groups.google.com/group/de.comp.lang.delphi.misc/browse_thread/thread/77754569dc80a4be/b18930ef17d75ada?lnk=st&q=group%3A*delphi*+kopie+objekt+erzeugen&rnum=4&hl=de#b18930ef17d75ada
  System.New(PCustomer);
  PCustomer^ := Customer;
  FCustomers.Add(PCustomer);
end;

procedure TCustomers.Delete(customerID: integer; fromDB: Boolean);
var i: integer;
    Customer: TCustomer;
    pCustomer: ^TCustomer;
begin
  Customer := byID(customerID);
  if not (Customer is TCustomer) then exit;

  // Aus der DB löschen
  if fromDB then Customer.Delete;

  // Aus der Kundenliste löschen
  for i := 0 to FCustomers.Count-1 do begin
    pCustomer := FCustomers[i];
    if (not (pCustomer^ is TCustomer)) or (pCustomer^.ID <> customerID) then continue;

    FCustomers.Extract(pCustomer); break;
  end;
end;

procedure TCustomers.Close;
begin
  while FCustomers.Count > 0 do begin
    Customers[0].Free;
    FCustomers.Delete(0);
  end;
end;

function TCustomers.NextCID: integer;
begin
  // Letzte cID lesen
  Result := 0;

  FQuery.Sql.Clear;
  FQuery.Sql.Add(QUERY_CUSTOMERS_LASTCID);

  try
    FQuery.Open;
  except
    exit;
  end;

  if FQuery.Eof then exit;

  try
    Result := FQuery.Fields[0].AsInteger+1;
  except
    exit;
  end;
end;

function TCustomers.getCustomer(Value: integer): TCustomer;
var Customer: PCustomer;
begin
  Result := nil;
  if (FCustomers.Count > Value) and (Value >= 0) then begin
    Customer := FCustomers[Value];
    Result := Customer^;
  end;
end;

function TCustomers.byID(ID: integer): TCustomer;
var i: integer;
    Customer: PCustomer;
begin
  Result := nil;

  for i := 0 to FCustomers.Count-1 do begin
    Customer := FCustomers[i];
    if (Customer^.ID <> ID) then continue;

    Result := Customer^;
    break;
  end;
end;

function TCustomers.Find(FieldID: TCustomerField; aPattern: string = ''): TCustomers;
var i: integer;
    aString: string;
begin
  Result := TCustomers.Create;
  aPattern := Trim(AnsiLowerCase(aPattern));

  // Keine Pattern: Alle Kunden
  if aPattern = '' then begin
    for i := 0 to Count-1 do Result.addCopy(Customers[i]);
    exit;
  end;

  for i := 0 to Count-1 do begin
    // cfLastname, cfFirstname, cfCompany, cfAddress, cfZIP, cfCity,
    // cfPhone, cfeMail, cfOther, cfType, cfCID

    case FieldID of
      cfCID: aString := intToStr(Customers[i].cID);
      cfLastname: aString := Customers[i].Lastname;
      cfFirstname: aString := Customers[i].Firstname;
      cfCompany: aString := Customers[i].Company;
      cfAddress: aString := Customers[i].Address;
      cfZIP: aString := intToStr(Customers[i].ZIP);
      cfCity: aString := Customers[i].City;
      cfPhone: aString := Customers[i].Phone;
      cfeMail: aString := Customers[i].eMail;
    end;

    aString := AnsiLowerCase(aString);

    if (Pos(aPattern,aString) > 0) or Like(aString,aPattern) then Result.addCopy(Customers[i]);
  end;
end;

procedure TCustomers.sortBy(Field: TCustomerField; Ascending: boolean = true);
begin
  case Field of
    cfCID: FCustomers.Sort(customerSortCID);
    cfLastname: FCustomers.Sort(customerSortLastname);
    cfFirstname: FCustomers.Sort(customerSortFirstname);
    cfCompany: FCustomers.Sort(customerSortCompany);
    cfAddress: FCustomers.Sort(customerSortAddress);
    cfZIP: FCustomers.Sort(customerSortZIP);
    cfCity: FCustomers.Sort(customerSortCity);
    cfPhone: FCustomers.Sort(customerSortPhone);
    cfEMail: FCustomers.Sort(customerSortEMail);
    cfOther: FCustomers.Sort(customerSortOther);
  end;

  if not Ascending then listReverse(FCustomers);
end;




end.
