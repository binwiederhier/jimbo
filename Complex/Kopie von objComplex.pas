{

  strings als PChar speichern??


  -------------
  TComplex-Handling wie folgt:

  var Cpx: TComplex;
  begin
    Cpx := TComplex.Create;

    Cpx['Title'].asStr := 'Jimbo';
    Cpx['Anzahl'].asInt := 988;

    for i := 0 to stringlist.count-1 do Cpx['Items'][i].asString := stringlist[i];
  end;

}
unit objComplex;

interface

uses
  Windows, Messages, Classes, SysUtils, XMLDoc, XMLIntf;

type
  //EComplexError = class(Exception);

  TComplex = class;
  TComplexType = (ctNull, ctStr, ctInt, ctFloat, ctComplex);

  pComplex = ^TComplex;

  TComplex = class
  private
    FIsDataMode: boolean;

    // Simple
    FName: string;
    FId: integer;

    FData: Pointer;
    FDataType: TComplexType;

    // Complex
    FPositionId: integer;
    FItemsId: TList;
    FIds: TList;

    FPositionName: integer;
    FItemsName: TList;
    FNames: TStrings;

    procedure clearAll;
    procedure clearData;

    procedure clearItems;
    procedure clearItemsId;
    procedure clearItemsName;

    function getStrFromDataType(dataType: TComplexType): string;
    function getDataTypeFromStr(aStr: string): TComplexType;

    procedure switchMode(isData: boolean);

    procedure switchId(Enabled: boolean);
    procedure switchName(Enabled: boolean);

    procedure getXMLTree(const Parent: TComplex; const xTop: IXMLNode);
    function setXMLTree(const Parent: TComplex; const xDoc: IXMLDocument; const xTop: IXMLNode; isStart: boolean): IXMLNode;

    function getItemsStr: string;

    function getDataInt: integer;
    function getDataStr: string;
    function getDataFloat: extended;

    function getAsStr: string;
    function getAsInt: integer;
    function getAsFloat: extended;

    procedure setAsStr(aStr: string);
    procedure setAsInt(aInt: integer);
    procedure setAsFloat(aFloat: extended);

    function getComplexById(Id: integer): TComplex;
    function getComplexByName(Name: string): TComplex;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset; virtual; abstract;
    function Next: TComplex; virtual; abstract;
    function Last: boolean; virtual; abstract;
    function Count: integer; virtual; abstract;

    procedure resetId;
    function nextId: TComplex;
    function lastId: boolean;
    function countId: integer;

    procedure resetName;
    function nextName: TComplex;
    function lastName: boolean;
    function countName: integer;

    function saveToFile(Filename: string): boolean;
    function loadFromFile(Filename: string): boolean;

    property asStr: string read getAsStr write setAsStr;
    property asInt: integer read getAsInt write setAsInt;
    property asFloat: extended read getAsFloat write setAsFloat;

    property dataType: TComplexType read FDataType;

    property Id: integer read FId;
    property Name: string read FName;
    property Ids[Id: integer]: TComplex read getComplexById;
    property Names[Name: string]: TComplex read getComplexByName;
  end;

 { IComplexSimple = interface
    property dataType: TComplexType;
    property Id: integer;
    property Name: string;

    property asStr: string;
    property asInt: integer;
    property asFloat: extened;
  end;

  IComplexStructure = interface
    procedure Reset;
    function Next: TComplex;
    function Last: boolean;
    function Count: integer;
  end;

  IComplexRoot = interface(IComplex)
    function saveToFile(Filename: string): boolean;
    function loadFromFile(Filename: string): boolean;
  end;


  TComplexName = class(IComplex)
  public
    function Count: integer;
    property Names; default;
  end;

  TComplexId = class(TComplex)
  public
    function Count: integer;
    property Ids; default;
  end;      }


implementation

constructor TComplex.Create;
begin
  FId := -1;
  FName := '';

  // Datamodus einschalten
  FIsDataMode := false;
  switchMode(true);
end;

destructor TComplex.Destroy;
begin
  if not FIsDataMode then begin
    FItemsId.Free;
    FIds.Free;

    FItemsName.Free;
    FNames.Free;
  end;
end;

procedure TComplex.switchId(Enabled: boolean);
begin
  case Enabled of
    true: begin
      if (FItemsId is TList) then exit;

      FPositionId := -1;
      FItemsId := TList.Create;
      FIds := TList.Create;
    end;

    false: begin
      if not (FItemsId is TList) then exit;

      clearItemsId;

      freeAndNil(FItemsId);
      freeAndNil(FIds);
    end;
  end;
end;

procedure TComplex.switchName(Enabled: boolean);
begin
  case Enabled of
    true: begin
      if (FItemsName is TList) then exit;

      FPositionName := -1;
      FItemsName := TList.Create;
      FNames := TStringList.Create;
    end;

    false: begin
      if not (FItemsName is TList) then exit;

      clearItemsName;

      freeAndNil(FItemsName);
      freeAndNil(FNames);
    end;
  end;
end;

procedure TComplex.switchMode(isData: boolean);
begin
  if isData = FIsDataMode then exit;

  // Setzen
  FIsDataMode := isData;

  case isData of
    // Datamodus EIN
    true: begin
      // Listen freigeben und leeren
      if FItemsId is TList then begin
        clearItems;

        FreeAndNil(FItemsId);
        FreeAndNil(FIds);

        FreeAndNil(FItemsName);
        FreeAndNil(FNames);
      end;

      // Pointer leeren
      if FData <> nil then clearData;
      FData := nil;

      // Datentyp setzen
      FDataType := ctNull;
    end;

    // Datamodus AUS
    false: begin
      // Listen erzeugen
      if not (FItemsId is TList) then begin
        FPositionId := -1;
        FItemsId := TList.Create;
        FIds := TList.Create;

        FPositionName := -1;
        FItemsName := TList.Create;
        FNames := TStringList.Create;
      end;

      // Pointer leeren
      if FData <> nil then clearData;
      FData := nil;

      // Datentyp setzen
      FDataType := ctComplex;
    end;
  end;
end;

{ get data: FDataType must be ctInt }
function TComplex.getDataInt: integer;
var pInt: pInteger;
begin
  if (FDataType <> ctInt) then begin
    Result := 0;
    exit;
  end;

  pInt := FData;
  Result := pInt^;
end;

{ get data: FDataType must be ctStr }
function TComplex.getDataStr: string;
var pStr: pString;
begin
  if (FDataType <> ctStr) then begin
    Result := '';
    exit;
  end;

  pStr := FData;
  Result := pStr^;
end;

{ get data: FDataType must be ctFloat }
function TComplex.getDataFloat: extended;
var pExt: pExtended;
begin
  if (FDataType <> ctFloat) then begin
    Result := 0;
    exit;
  end;

  pExt := FData;
  Result := pExt^;
end;

{ get data: FDataType must be ctComplex }
function TComplex.getItemsStr: string;
var Cpx: TComplex;
    Names, Ids: string;
begin
  if (FDataType <> ctComplex) then begin
    Result := '';
    exit;
  end;

  Names := ''; Ids := '';
  Result := 'TComplex[ Name{ %s }, Id{ %s } ]';
                          
  // Name Items
  resetName; while (not lastName) do begin
    Cpx := nextName;

    Names := Names + Cpx.Name + ' => ' + Cpx.asStr;
    if not lastName then Names := Names + ', ';
  end;

  // Id Items
  resetId; while (not lastId) do begin
    Cpx := nextId;

    Ids := Ids + intToStr(Cpx.Id) + ' => ' + Cpx.asStr;
    if not lastId then Ids := Ids + ', ';
  end;

  Result := Format(Result,[Names,Ids]);
end;

procedure TComplex.setAsStr(aStr: string);
var pStr: pString;
begin
  // Data-Modus setzen
  switchMode(true);

  New(pStr);
  pStr^ := aStr;

  FData := pStr;
  FDataType := ctStr;
end;

function TComplex.getAsStr: string;
begin
  case FDataType of
    ctNull: Result := '';
    ctFloat: Result := floatToStr(getDataFloat);
    ctInt: Result := intToStr(getDataInt);
    ctStr: Result := getDataStr;
    ctComplex: Result := getItemsStr;
    else Result := ''
  end;
end;

procedure TComplex.setAsInt(aInt: integer);
var pInt: pInteger;
begin
  // Data-Modus setzen
  switchMode(true);

  New(pInt);
  pInt^ := aInt;

  FData := pInt;
  FDataType := ctInt;
end;

function TComplex.getAsInt: integer;
begin
  case FDataType of
    ctNull: Result := 0;
    ctFloat: Result := Round(getDataFloat);
    ctInt: Result := getDataInt;
    ctStr: if not tryStrToInt(getDataStr,Result) then Result := 0;
    ctComplex: Result := 0;
    else Result := 0;
  end;
end;

procedure TComplex.setAsFloat(aFloat: extended);
var pExt: pExtended;
begin
  // Data-Modus setzen
  switchMode(true);

  New(pExt);
  pExt^ := aFloat;

  FData := pExt;
  FDataType := ctFloat;
end;

function TComplex.getAsFloat: extended;
begin
  case FDataType of
    ctNull: Result := 0;
    ctFloat: Result := getDataFloat;
    ctInt: Result := getDataInt;
    ctStr: if not tryStrToFloat(getDataStr,Result) then Result := 0;
    ctComplex: Result := 0;
    else Result := 0;
  end;
end;

function TComplex.getComplexById(Id: integer): TComplex;
var i, Index: integer;
    pCpx: pComplex;
    pInt: pInteger;
begin
  // Complex-Modus setzen
  switchMode(false);

  if (Id < 0) then Id := Abs(Id);

  Index := -1; for i := 0 to FIds.Count-1 do begin
    pInt := FIds[i];
    if pInt^ <> Id then continue;

    Index := i;
    break;
  end;

  // Neuen Complex anlegen
  if Index = -1 then begin
    New(pInt); pInt^ := Id;
    Index := FIds.Add(pInt);

    New(pCpx);
    pCpx^ := TComplex.Create;
    pCpx^.FId := Id;
    pCpx^.FName := '';

    FItemsId.Add(pCpx);
    Result := pCpx^;

    exit;
  end;

  // Complex lesen
  pCpx := FItemsId[Index];
  Result := pCpx^;
end;

function TComplex.getComplexByName(Name: string): TComplex;
var i, Index: integer;
    pCpx: pComplex;
begin
  // Complex-Modus setzen
  switchMode(false);

  Index := -1; for i := 0 to FNames.Count-1 do begin
    if FNames[i] <> Name then continue;

    Index := i;
    break;
  end;

  // Neuen Complex anlegen
  if Index = -1 then begin
    Index := FNames.Add(Name);

    New(pCpx);
    pCpx^ := TComplex.Create;
    pCpx^.FId := -1;
    pCpx^.FName := Name;

    FItemsName.Add(pCpx);
    Result := pCpx^;

    exit;
  end;

  // Complex lesen
  pCpx := FItemsName[Index];
  Result := pCpx^;
end;

procedure TComplex.clearAll;
begin
  clearData;
  clearItems;
end;

procedure TComplex.clearData;
begin
  if FData = nil then exit;

  fillChar(FData,SizeOf(FData),#0);
  dispose(FData);
end;

procedure TComplex.clearItems;
begin
  clearItemsId;
  clearItemsName;
end;

procedure TComplex.clearItemsId;
begin
  switchMode(false);

  FItemsId.Clear;
  FIds.Clear;
end;

procedure TComplex.clearItemsName;
begin
  switchMode(false);

  FItemsName.Clear;
  FNames.Clear;
end;


function TComplex.setXMLTree(const Parent: TComplex; const xDoc: IXMLDocument; const xTop: IXMLNode; isStart: boolean): IXMLNode;
var i: integer;

    cpxChild: TComplex;
    xItems, xItem: IXMLNode;
begin
  if Parent.dataType <> ctComplex then exit;

  if isStart then xItems := xDoc.DocumentElement
  else begin
    xItems := xDoc.CreateNode(getStrFromDataType(Parent.dataType));

    if (Parent.Name <> '') then xItems.Attributes['name'] := Parent.Name
    else if (Parent.Id <> -1) then xItems.Attributes['id'] := intToStr(Parent.Id);

    xTop.ChildNodes.Add(xItems);
  end;

  // Name Items
  Parent.resetName; while (not Parent.lastName) do begin
    cpxChild := Parent.nextName;
    if (cpxChild.dataType = ctNull) then continue;

    // Save Children
    if (cpxChild.dataType = ctComplex) then begin
      if Parent.Name <> '' then xItems.Attributes['name'] := Parent.Name;
      xItems.ChildNodes.Add(setXMLTree(cpxChild,xDoc,xItems,false));

      continue;
    end;

    xItem := xDoc.CreateNode(getStrFromDataType(cpxChild.dataType));

    if cpxChild.Name <> '' then xItem.Attributes['name'] := cpxChild.Name;
    xItem.Text := cpxChild.asStr;

    xItems.ChildNodes.Add(xItem);
  end;

  // Id Items
  Parent.resetId; while (not Parent.lastId) do begin
    cpxChild := Parent.nextId;
    if (cpxChild.dataType = ctNull) then continue;

    // Save Children
    if (cpxChild.dataType = ctComplex) then begin
      if Parent.Id <> -1 then xItems.Attributes['id'] := intToStr(Parent.Id);
      xItems.ChildNodes.Add(setXMLTree(cpxChild,xDoc,xItems,false));

      continue;
    end;

    xItem := xDoc.CreateNode(getStrFromDataType(cpxChild.dataType));

    if cpxChild.Id <> -1 then xItem.Attributes['id'] := intToStr(cpxChild.Id);
    xItem.Text := cpxChild.asStr;

    xItems.ChildNodes.Add(xItem);
  end;

  Result := xItems;
end;


function TComplex.saveToFile(Filename: string): boolean;
var xDoc: IXMLDocument;
    xTop, xTree: IXMLNode;
begin
  if (FDataType <> ctComplex) then begin
    Result := false;
    exit;
  end;

  xDoc := TXMLDocument.Create(nil);
  xDoc.Active := true;
  xDoc.Encoding := 'UTF-8';
  xDoc.Options := xDoc.Options + [doNodeAutoIndent];

  xTop := xDoc.CreateNode('complex');
  xDoc.ChildNodes.Add(xTop);

  // Recursive Addition of Elements
  setXMLTree(Self,xDoc,xTop,true);

  xDoc.SaveToFile(Filename);

  xDoc := nil;
end;

procedure TComplex.getXMLTree(const Parent: TComplex; const xTop: IXMLNode);
var i, attrId, tmpInt: integer;
    attrName: string;
    tmpFloat: extended;

    xChild: IXMLNode;
    cpxChild: TComplex;
begin     
  if xTop.NodeType = ntText then exit;

  for i := 0 to xTop.ChildNodes.Count-1 do begin
    xChild := xTop.ChildNodes[i];

    // Id od. Name
    if (not xChild.HasAttribute('id')) or (not tryStrToInt(xChild.Attributes['id'],attrId)) then attrId := -1;
    if (xChild.HasAttribute('name')) then attrName := xChild.Attributes['name']
    else attrName := '';

    // Neues Element
    if attrName <> '' then cpxChild := Parent.Names[attrName]
    else if attrId <> -1 then cpxChild := Parent.Ids[attrId]
    else continue;

    case xChild.isTextElement of
      // Recursion!
      false: getXMLTree(cpxChild,xChild);

      true: begin
        case getDataTypeFromStr(xChild.NodeName) of
          ctStr: cpxChild.asStr := xChild.Text;
          ctInt: begin
            if not tryStrToInt(xChild.Text,tmpInt) then tmpInt := 0;
            cpxChild.asInt := tmpInt;
          end;
          ctFloat: begin
            if not tryStrToFloat(xChild.Text,tmpFloat) then tmpFloat := 0;
            cpxChild.asFloat := tmpFloat;
          end;
        end;
      end;
    end;
  end;

end;

function TComplex.loadFromFile(Filename: string): boolean;
var xDoc: IXMLDocument;
    xTop, xTree: IXMLNode;
begin
  switchMode(false);              
  clearItems;               

  xDoc := TXMLDocument.Create(nil);
  xDoc.LoadFromFile(Filename);
  xDoc.Active := true;

  getXMLTree(Self,xDoc.DocumentElement);

  xDoc := nil;
end;

procedure TComplex.resetId;
begin
  FPositionId := -1;
end;

function TComplex.nextId: TComplex;
var pCpx: pComplex;
begin
  switchMode(false);

  Result := nil;
  if FPositionId >= FItemsId.Count-1 then exit;

  inc(FPositionId);
  pCpx := FItemsId[FPositionId];

  Result := pCpx^;
end;

function TComplex.lastId: boolean;
begin
  switchMode(false);
  Result := FPositionId = FItemsId.Count-1;
end;

function TComplex.countId: integer;
begin
  switchMode(false);
  Result := FItemsId.Count;
end;


procedure TComplex.resetName;
begin
  FPositionName := -1;
end;

function TComplex.nextName: TComplex;
var pCpx: pComplex;
begin
  switchMode(false);
              
  Result := nil;
  if FPositionName >= FItemsName.Count-1 then exit;

  inc(FPositionName);
  pCpx := FItemsName[FPositionName];

  Result := pCpx^;
end;

function TComplex.lastName: boolean;
begin
  switchMode(false);
  Result := FPositionName = FItemsName.Count-1;
end;

function TComplex.countName: integer;
begin
  switchMode(false);
  Result := FItemsName.Count;
end;

function TComplex.getStrFromDataType(dataType: TComplexType): string;
begin
  case dataType of
    ctNull: Result := 'null';
    ctFloat: Result := 'float';
    ctInt: Result := 'int';
    ctStr: Result := 'str';
    ctComplex: Result := 'complex';
    else Result := 'unknown';
  end;
end;

function TComplex.getDataTypeFromStr(aStr: string): TComplexType;
begin
  if aStr = 'float' then Result := ctFloat
  else if aStr = 'int' then Result := ctInt
  else if aStr = 'str' then Result := ctStr
  else if aStr = 'complex' then Result := ctComplex
  else Result := ctNull;
end;






{************** TComplexId *****************}
     {
function TComplexId.Count: integer;
begin
  Result := countId;
end;
      }



{************** TComplexName *****************}
       {
function TComplexName.Count: integer;
begin
  Result := countName;
end;
        }

end.
