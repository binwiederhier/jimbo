{

  TODO

  - dynamicLoading
  - PathAccess: boolean [ --> Items['Lists/Customer/Sort/Field'].asInt ]
  - PathSeparator: char [ ^^ ]
  - function CompareStructure(Complex: TComplex): boolean [ if same true ]

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
{$DEFINE DEBUG_COMPLEX}

unit objComplex;

interface

uses
  Windows, Messages, Classes, SysUtils, XMLDoc, XMLIntf
  {$IFDEF DEBUG_COMPLEX},Dialogs{$ENDIF};

const
  COMPLEX_VERSION    = '1.0';
  COMPLEX_COPYRIGHT  = '<!-- '#13#10
                     + '      Complex File Format ' + COMPLEX_VERSION + #13#10
                     + '      (c) May 2006, Philipp Heckel for Silversun GbR' + #13#10
                     + '//-->';

type                                        
  TComplexMode = (cmNone, cmSimple, cmList, cmComplex);
  TComplexType = (ctNull, ctStr, ctInt, ctFloat, ctBool, ctBinary, ctList, ctComplex);

  TComplex = class;
  TComplexList = class;
  pComplex = ^TComplex;

  TComplex = class
  private
    FOwner: TComplex;
    FMode: TComplexMode;

    FShowHidden: boolean;
    FHidden: boolean;
    {FDynamicLoading: boolean;}

    // Simple
    FName: string;
    FId: integer;

    FData: Pointer;
    FDataType: TComplexType;
    FDataLength: integer;

    // Complex
    FPosition: integer;
    FItems: TList;
    FList: TComplexList;

    procedure clearAll;
    procedure clearData;
    procedure clearItems;

    function getStrFromDataType(dataType: TComplexType): string;
    function getDataTypeFromStr(aStr: string): TComplexType;

    procedure modeSimple;
    procedure modeComplex;

    procedure getXMLTree(const Parent: TComplex; const xTop: IXMLNode);
    procedure setXMLTree(const Parent: TComplex; const xDoc: IXMLDocument; const xTop: IXMLNode; isStart: boolean);

    function getNewName: string;
    function getItemsStr: string;

    function getDataInt: integer;
    function getDataStr: string;
    function getDataFloat: extended;
    function getDataBool: boolean;
    function getDataBinary: pChar;

    function getAsInt: integer;
    function getAsStr: string;
    function getAsFloat: extended;
    function getAsBool: boolean;
    function getAsList: TComplexList;

    procedure setAsInt(aInt: integer);
    procedure setAsStr(aStr: string);
    procedure setAsFloat(aFloat: extended);
    procedure setAsBool(aBool: boolean);
    procedure setAsList(const aList: TComplexList);

    function getComplexById(Id: integer): TComplex;
    function getComplexByName(Name: string): TComplex;
  public
    constructor Create; overload;
    constructor Create(aOwner: TComplex); overload;
    destructor Destroy; override;

    procedure Assign(Source: TComplex; incHidden: boolean = false);

    procedure Reset;
    function Next: TComplex;
    function Last: boolean;
    function Count: integer;

    function Exists(Name: string): boolean; overload;
    function Exists(Id: integer): boolean; overload;

    function saveToFile(Filename: string): boolean;
    function loadFromFile(Filename: string; ResetStructure: boolean = true): boolean;

    procedure setAsBinary(const Data; Length: integer); overload;
    procedure getAsBinary(var Data; Length: integer = -1); overload;

    {$IFDEF DEBUG_COMPLEX} procedure Popup; {$ENDIF}

    {property dynamicLoading: boolean read FDynamicLoading write FDynamicLoading;}

    property asStr: string read getAsStr write setAsStr;
    property asInt: integer read getAsInt write setAsInt;
    property asFloat: extended read getAsFloat write setAsFloat;
    property asBool: boolean read getAsBool write setAsBool;

    property asList: TComplexList read getAsList write setAsList;

    property Mode: TComplexMode read FMode;
    property DataType: TComplexType read FDataType;
    property DataLength: integer read FDataLength;

    property Hidden: boolean read FHidden write FHidden;
    property ShowHidden: boolean read FShowHidden write FShowHidden;

    property Id: integer read FId;
    property Name: string read FName;

    property byId[Id: integer]: TComplex read getComplexById;
    property Items[Name: string]: TComplex read getComplexByName; default;
  end;

  TComplexList = class(TList)
  private
    function asStr: string;

    procedure setComplex(Index: integer; Value: TComplex);
    function getComplex(Index: integer): TComplex;
  public
    procedure Add(Value: TComplex);
    function indexOf(Value: TComplex): integer;

    property Items[Index: Integer]: TComplex read getComplex write setComplex; default;
  end;

implementation

{ fixes the hexToBin-Bugs from D5-D7 }
function hexToBinEx(Text, Buffer: pChar; bufSize: integer): integer;
const Convert: array['0'..'f'] of SmallInt =
      ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1,
       -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1,
       -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
       -1,10,11,12,13,14,15);
begin
  Result := bufSize; while Result > 0 do begin
    if not (Text[0] in ['0'..'f']) or not (Text[1] in ['0'..'f']) then break;
    Buffer[0] := Char((Convert[Text[0]] shl 4) + Convert[Text[1]]);

    inc(Buffer);
    inc(Text, 2);
    dec(Result);
  end;
end;

{uses yes/no instead of 0 and -1}
function boolToStrEx(B: boolean): string;
const boolStrs: array[boolean] of string = ('no', 'yes');
begin
  Result := boolStrs[B];
end;

function StrToBoolEx(S: string): boolean;
begin
  Result := S = 'yes';
end;


{************************* TComplex *************************}

constructor TComplex.Create;
begin
  Create(nil);
end;

constructor TComplex.Create(aOwner: TComplex);
begin
  inherited Create;

  FOwner := aOwner;
  {FDynamicLoading := false;}

  FId := -1;
  FName := '';

  FMode := cmNone;

  FData := nil;
  FDataType := ctNull;
  FDataLength := 0;

  FShowHidden := false;
  FHidden := false;

  // enable simple mode
  FMode := cmNone;

  // load owner settings
{  if Assigned(aOwner) then begin
    dynamicLoading := true;
  end;}
end;

destructor TComplex.Destroy;
var pCpx: pComplex;
begin
  case FMode of
    cmSimple: begin
      clearData;
    end;

    cmList: begin
      if Assigned(FList) then freeAndNil(FList);
    end;

    cmComplex: begin

      if Assigned(FItems) then begin
        while FItems.Count > 0 do begin
          pCpx := FItems[0];

          if Assigned(pCpx) and (pCpx^ is TComplex) then freeAndNil(pCpx^);
          FItems.Delete(0);
        end;
      end;

      freeAndNil(FItems);
    end;
  end;

  FDataType := ctNull;
  FDataLength := 0;

  //freeAndNil(Self);
  inherited Destroy;
end;

procedure TComplex.Assign(Source: TComplex; incHidden: boolean = false);
var i: integer;
    Buffer: pChar;
    Item: TComplex;
begin
  Hidden := Source.Hidden;
  ShowHidden := Source.ShowHidden;

  case Source.Mode of
    cmNone: ;

    cmSimple: begin
      modeSimple;

      case Source.DataType of
        ctInt: asInt := Source.asInt;
        ctStr: asStr := Source.asStr;
        ctFloat: asFloat := Source.asFloat;
        ctBool: asBool := Source.asBool;
        ctBinary: begin
          getMem(Buffer,Source.DataLength);

          Source.getAsBinary(Buffer,Source.DataLength);
          setAsBinary(Buffer,Source.DataLength);

          freeMem(Buffer,Source.DataLength);
        end;
      end;              
    end;

    cmList: begin
      //modeList;

      for i := 0 to Source.asList.Count-1 do begin
        if (not incHidden) and asList[i].Hidden then continue;

        asList[i].Assign(Source.asList[i],incHidden);
        asList[i].Hidden := Source.asList[i].Hidden;
        asList[i].ShowHidden := Source.asList[i].ShowHidden;
      end;
    end;

    cmComplex: begin
      modeComplex;

      for i := 0 to Source.FItems.Count-1 do begin
        Item := TComplex(Source.FItems[i]^);
        if (not incHidden) and Item.Hidden then continue;
 
        if Item.Name <> '' then Items[Item.Name].Assign(Item,incHidden)
        else if Item.Id <> -1 then byId[Item.Id].Assign(Item,incHidden);

        Item.Hidden := Item.Hidden;
        Item.ShowHidden := Item.ShowHidden;
      end;

      {

      hiddenBuffer := Source.ShowHidden;
      Source.ShowHidden := incHidden;

      Source.Reset; while (not Source.Last) do begin

        Item := Source.Next;
        if Item.Hidden and (not incHidden) then continue;

        if Item.Name <> '' then Items[Item.Name].Assign(Item,incHidden)
        else if Item.Id <> -1 then byId[Item.Id].Assign(Item,incHidden);
      end;

      Source.ShowHidden := hiddenBuffer;}
    end;
  end; {case}
end;

procedure TComplex.modeSimple;
begin
  // enable simple mode
  if FMode = cmSimple then exit;
  FMode := cmSimple;

  // disable complex mode
  if Assigned(FItems) and (FItems is TList) then begin
    clearItems;
    freeAndNil(FItems);
  end;

  // disable list mode
  if Assigned(FList) and (FList is TComplexList) then begin
    freeAndNil(FList);
  end;

  // empty pointer
  clearData;
end;

procedure TComplex.modeComplex;
begin
  // enable complex mode
  if FMode = cmComplex then exit;
  FMode := cmComplex;

  // create tlist
  if (not Assigned(FItems)) or (not (FItems is TList)) then begin
    FPosition := -1;
    FItems := TList.Create;
  end;

  // disable list mode
  if Assigned(FList) and (FList is TComplexList) then begin
    freeAndNil(FList);
  end;

  // empty pointer
  clearData;

  // set complex type
  FDataType := ctComplex;
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

{ get data: FDataType must be ctBool }
function TComplex.getDataBool: boolean;
var pBool: pBoolean;
begin
  if (FDataType <> ctBool) then begin
    Result := false;
    exit;
  end;

  pBool := FData;
  Result := pBool^;
end;

{ get data: FDataType must be ctBinary }
function TComplex.getDataBinary: pChar;
begin
  Result := FData;
end;

{ get data: FDataType must be ctComplex }
function TComplex.getItemsStr: string;
var Cpx: TComplex;
    Names, Name: string;
begin
  if (FDataType <> ctComplex) then begin
    Result := '';
    exit;
  end;

  Names := '';

  // Name Items
  Reset; while (not Last) do begin
    Cpx := Next;

    if Cpx.Name <> '' then Name := Cpx.Name
    else if Cpx.Id <> -1 then Name := intToStr(Cpx.Id)
    else Name := '?';

    Names := Names + Name + ' => ' + Cpx.asStr;
    if not Last then Names := Names + ', ';
  end;

  Result := 'TComplex[ ' + Names + ' ]';
end;

function TComplex.getNewName: string;
var i: integer;
begin
  i := 0; repeat
    inc(i);
    Result := 'TComplex' + intToStr(i);
  until not Exists(Result);
end;

procedure TComplex.setAsStr(aStr: string);
var pStr: pString;
begin
  modeSimple;

  New(pStr);
  pStr^ := aStr;
      
  FData := pStr;
  FDataType := ctStr;
  FDataLength := sizeOf(string);//Length(aStr)+1;
end;

function TComplex.getAsStr: string;
var pText: pChar;
begin
  case FDataType of
    ctNull: Result := '';
    ctFloat: Result := floatToStr(getDataFloat);
    ctInt: Result := intToStr(getDataInt);
    ctBool: Result := boolToStrEx(getDataBool);
    ctStr: Result := getDataStr;
    ctList: Result := FList.asStr;
    ctBinary: begin {return hex-string}
      // convert binary data to hex and copy to pText
      getMem(pText,FDataLength*2);
      binToHex(FData,pText,FDataLength);

      // convert to string
      Result := pText;
      setLength(Result,FDataLength*2);
    end;
    ctComplex: Result := getItemsStr;
    else Result := ''
  end;
end;

procedure TComplex.setAsInt(aInt: integer);
var pInt: pInteger;
begin
  modeSimple;

  New(pInt);
  pInt^ := aInt;

  FData := pInt;
  FDataType := ctInt;
  FDataLength := sizeOf(integer);
end;

function TComplex.getAsInt: integer;
begin
  case FDataType of
    ctNull: Result := 0;
    ctFloat: Result := Round(getDataFloat);
    ctInt: Result := getDataInt;
    ctBool: Result := Integer(getDataBool);
    ctStr: if not tryStrToInt(getDataStr,Result) then Result := 0;
    ctBinary: Result := 0;
    ctComplex: Result := 0;
    else Result := 0;
  end;
end;

procedure TComplex.setAsBool(aBool: boolean);
var pBool: pBoolean;
begin
  modeSimple;

  New(pBool);
  pBool^ := aBool;

  FData := pBool;
  FDataType := ctBool;
  FDataLength := sizeOf(boolean);
end;

function TComplex.getAsBool: boolean;
begin
  case FDataType of
    ctNull: Result := false;
    ctFloat: Result := getDataFloat <> 0;
    ctInt: Result := getDataInt <> 0;
    ctBool: Result := getDataBool;
    ctStr: Result := getDataStr <> '';
    ctBinary: Result := false;
    ctComplex: Result := false;
    else Result := false;
  end;
end;

procedure TComplex.setAsFloat(aFloat: extended);
var pExt: pExtended;
begin
  modeSimple;

  New(pExt);
  pExt^ := aFloat;

  FData := pExt;
  FDataType := ctFloat;
  FDataLength := sizeOf(extended);
end;

function TComplex.getAsFloat: extended;
begin
  case FDataType of
    ctNull: Result := 0;
    ctFloat: Result := getDataFloat;
    ctInt: Result := getDataInt;
    ctBool: Result := Integer(getDataBool);
    ctStr: if not tryStrToFloat(getDataStr,Result) then Result := 0;
    ctBinary: Result := 0;
    ctComplex: Result := 0;
    else Result := 0;
  end;
end;

procedure TComplex.setAsList(const aList: TComplexList);
begin
  clearAll;

  FMode := cmList;
  FDataType := ctList;
  FDataLength := 0;

  FList := aList;
end;

function TComplex.getAsList: TComplexList;
begin
  if (not Assigned(FList)) or (not (FList is TComplexList)) then FList := TComplexList.Create;

  FMode := cmList;
  FDataType := ctList;
  FDataLength := 0;

  Result := FList;
end;

procedure TComplex.setAsBinary(const Data; Length: integer);
var pData: pChar;
begin
  modeSimple;

  // copy data to new address
  getMem(FData,Length);
  Move(Pointer(Data)^,FData^,Length);

  //FData := pData;
  FDataType := ctBinary;
  FDataLength := Length;
end;

procedure TComplex.getAsBinary(var Data; Length: integer = -1);
begin
  modeSimple;

  if not (FDataType in [ctFloat, ctInt, ctBool, ctStr, ctBinary]) then exit;
  if Length = -1 then Length := FDataLength;

  Move(FData^,Pointer(Data)^,Length);
end;


{procedure TComplex.setAsBinary(Data: pChar; Length: integer);
var pData: pChar;
begin
  modeSimple;

  // copy data to new address
  getMem(pData,Length);
  Move(Data^,pData^,Length);

  FData := pData;
  FDataType := ctBinary;
  FDataLength := Length;
end;
}
{procedure TComplex.getAsBinary(var Data: pChar; Length: integer = -1);
var pData: pChar;
begin
  modeSimple;

  if not (FDataType in [ctFloat, ctInt, ctBool, ctStr, ctBinary]) then exit;
  if Length = -1 then Length := FDataLength;

  pData := pChar(FData);
  Move(pData^,Data^,Length);
end;
 }
{$IFDEF DEBUG_COMPLEX}
procedure TComplex.Popup;
begin
  showmessage(asStr);
end;
{$ENDIF}


function TComplex.getComplexById(Id: integer): TComplex;
var i, Index: integer;
    pCpx: pComplex;
begin
  modeComplex;

  if (Id < 0) then Id := Abs(Id);

  Index := -1; for i := 0 to FItems.Count-1 do begin
    pCpx := FItems[i];
    if pCpx^.Id <> Id then continue;

    Index := i;
    break;
  end;

  // Neuen Complex anlegen
  if Index = -1 then begin
    New(pCpx);
    pCpx^ := TComplex.Create(Self);
    pCpx^.FId := Id;
    pCpx^.FName := '';

    FItems.Add(pCpx);
    Result := pCpx^;

    exit;
  end;

  // Complex lesen
  pCpx := FItems[Index];
  Result := pCpx^;
end;

function TComplex.getComplexByName(Name: string): TComplex;
var i, Index: integer;
    pCpx: pComplex;
begin
  modeComplex;

  // Keinen leeren String erlauben
  if Name = '' then Name := getNewName;

  Index := -1; for i := 0 to FItems.Count-1 do begin
    pCpx := FItems[i];
    if pCpx^.Name <> Name then continue;

    Index := i;
    break;
  end;

  // Neuen Complex anlegen
  if Index = -1 then begin
    New(pCpx);
    pCpx^ := TComplex.Create;
    pCpx^.FId := -1;
    pCpx^.FName := Name;

    FItems.Add(pCpx);
    Result := pCpx^;

    exit;
  end;

  // Complex lesen
  pCpx := FItems[Index];
  Result := pCpx^;
end;

procedure TComplex.clearAll;
begin
  clearData;
  clearItems;
end;

procedure TComplex.clearData;
begin
  FDataType := ctNull;
  FDataLength := 0;

  if FData = nil then exit;

  fillChar(FData,sizeOf(FData),#0);
  Dispose(FData);

  FData := nil;
end;

procedure TComplex.clearItems;
var pCpx: pComplex;
begin
  if not Assigned(FItems) or not (FItems is TList) then exit;

  while FItems.Count > 0 do begin
    pCpx := FItems[0];

    if Assigned(pCpx) and (pCpx^ is TComplex) then freeAndNil(pCpx^);
    FItems.Delete(0);
  end;
end;

procedure TComplex.setXMLTree(const Parent: TComplex; const xDoc: IXMLDocument; const xTop: IXMLNode; isStart: boolean);
var i: integer;

    cpxChild: TComplex;
    xItems, xItem: IXMLNode;
begin
  if Parent.Hidden then exit;

  // TYPE: Simple /List type
  if Parent.Mode <> cmComplex then begin
    case isStart of
      true: xItem := xTop;
      false: xItem := xDoc.CreateNode(getStrFromDataType(Parent.dataType));
    end;

    if Parent.Name <> '' then xItem.Attributes['name'] := Parent.Name;
    if Parent.Id <> -1 then xItem.Attributes['id'] := intToStr(Parent.Id);

    case Parent.Mode of
      cmSimple: xItem.Text := Parent.asStr;

      cmList: begin
        for i := 0 to Parent.asList.Count-1 do
          setXMLTree(Parent.asList[i],xDoc,xItem,false);
      end;
    end;

    if not isStart then xTop.ChildNodes.Add(xItem);

    exit;
  end;

  // TYPE: Complex type
  case isStart of
    true: xItems := xDoc.DocumentElement;
    false: xItems := xDoc.CreateNode(getStrFromDataType(Parent.dataType));
  end;

  if (Parent.Name <> '') then xItems.Attributes['name'] := Parent.Name;
  if (Parent.Id <> -1) then xItems.Attributes['id'] := intToStr(Parent.Id);

  if not isStart then xTop.ChildNodes.Add(xItems);


  // Chilren
  Parent.Reset; while (not Parent.Last) do begin
    cpxChild := Parent.Next;
    if (cpxChild.dataType = ctNull) then continue;

    // Complex Item
    if (cpxChild.dataType = ctComplex) then begin
      if Parent.Name <> '' then xItems.Attributes['name'] := Parent.Name;
      if Parent.Id <> -1 then xItems.Attributes['id'] := intToStr(Parent.Id);

      setXMLTree(cpxChild,xDoc,xItems,false);
      continue;
    end;

    // Simple Item
    setXMLTree(cpxChild,xDoc,xItems,false);
  end;
end;


function TComplex.saveToFile(Filename: string): boolean;
var xDoc: IXMLDocument;
    xTop, xTree: IXMLNode;
    sCopy: TStrings;
begin
  xDoc := TXMLDocument.Create(nil);
  xDoc.Active := true;
  xDoc.Encoding := 'UTF-8';
  xDoc.Options := xDoc.Options + [doNodeAutoIndent];

  // Complex: Recursive Addition of Elements
  xTop := xDoc.CreateNode('complex');
  xTop.Attributes['version'] := '1.0';

  if (FDataType <> ctComplex) then xTop.Attributes['type'] := getStrFromDataType(FDataType);

  xDoc.ChildNodes.Add(xTop);

  setXMLTree(Self,xDoc,xTop,true);

  xDoc.SaveToFile(Filename);
  xDoc := nil;

  sCopy := TStringList.Create;
  sCopy.LoadFromFile(Filename);
  sCopy.Insert(1,COMPLEX_COPYRIGHT);
  sCopy.SaveToFile(Filename);
  sCopy.Free;
end;

procedure TComplex.getXMLTree(const Parent: TComplex; const xTop: IXMLNode);
var i, attrId, tmpInt, pLen: integer;
    attrName, tmpStr: string;
    tmpFloat: extended;
    pData, pHex, pTmp: pChar;

    xChild: IXMLNode;
    cpxChild: TComplex;
begin
  // TYPE: Simple
  if xTop.isTextElement then begin
    case getDataTypeFromStr(xTop.NodeName) of
      ctStr: Parent.asStr := xTop.Text;

      ctInt: begin
        if not tryStrToInt(xTop.Text,tmpInt) then tmpInt := 0;
        Parent.asInt := tmpInt;
      end;

      ctBool: begin
        Parent.asBool := strToBoolEx(xTop.Text);
      end;

      ctFloat: begin
        if not tryStrToFloat(xTop.Text,tmpFloat) then tmpFloat := 0;
        Parent.asFloat := tmpFloat;
      end;

      ctBinary: begin
        // shorten hex-string if not even
        if Length(xTop.Text) mod 2 = 1 then xTop.Text := copy(xTop.Text,1,Length(xTop.Text)-1);
        pLen := Length(xTop.Text) div 2;

        // copy hex-string to pHex
        getMem(pHex,pLen*2);

        tmpStr := xTop.Text;
        Move(pChar(tmpStr)^,pHex^,pLen*2);

        // convert hex to binary data
        getMem(pData,pLen);

        if hexToBinEx(pHex,pData,pLen) > 0 then begin
          freeMem(pHex,pLen*2); 
          freeMem(pData,pLen);

          exit;
        end;

        Parent.setAsBinary(pData,pLen);

        freeMem(pHex,pLen*2);
        freeMem(pData,pLen);
      end;
    end;

    exit;
  end

  else if (getDataTypeFromStr(xTop.NodeName) = ctList)
       or (xTop.hasAttribute('type') and (getDataTypeFromStr(xTop.Attributes['type']) = ctList)) then begin

    for i := 0 to xTop.ChildNodes.Count-1 do
      getXMLTree(Parent.asList[i],xTop.ChildNodes[i]);

    exit;
  end;

  for i := 0 to xTop.ChildNodes.Count-1 do begin
    xChild := xTop.ChildNodes[i];

    // Id od. Name
    if (not xChild.HasAttribute('id')) or (not tryStrToInt(xChild.Attributes['id'],attrId)) then attrId := -1;
    if (xChild.HasAttribute('name')) then attrName := xChild.Attributes['name']
    else attrName := '';

    // Neues Element
    if attrName <> '' then cpxChild := Parent[attrName]
    else if attrId <> -1 then cpxChild := Parent.byId[attrId]
    else continue;

    getXMLTree(cpxChild,xChild);
  end;

end;

function TComplex.loadFromFile(Filename: string; ResetStructure: boolean = true): boolean;
var xDoc: IXMLDocument;
    xTop, xTree: IXMLNode;
begin
  Result := false;

  modeComplex;
  if ResetStructure then clearItems;

  xDoc := TXMLDocument.Create(nil);
  try
    xDoc.LoadFromFile(Filename);
    xDoc.Active := true;
    getXMLTree(Self,xDoc.DocumentElement);

    Result := true;
  finally
    xDoc := nil;
  end;
end;

procedure TComplex.Reset;
begin
  FPosition := -1;
end;

function TComplex.Next: TComplex;
var i, iPos, Index: integer;
begin
  modeComplex;
 
  Result := nil;
  if FPosition >= Count-1 then exit;
      
  iPos := -1;
  Index := -1;

  for i := 0 to FItems.Count-1 do begin
    if TComplex(FItems[i]^).Hidden and (not FShowHidden) then continue;

    inc(iPos);

    if iPos = FPosition+1 then begin
      Index := i;
      break;
    end;
  end;

  if Index = -1 then exit;
  inc(FPosition);

  Result := TComplex(FItems[Index]^);
end;

function TComplex.Last: boolean;
begin
  modeComplex;
  Result := FPosition = Count-1;
end;

function TComplex.Count: integer;
var i: integer;
begin
  modeComplex;
  Result := 0;

  if FShowHidden then begin
    Result := FItems.Count;
    exit;
  end;

  for i := 0 to FItems.Count-1 do begin
    if TComplex(FItems[i]^).Hidden then continue;
    inc(Result);
  end;
end;

function TComplex.Exists(Name: string): boolean;
var i: integer;
begin
  modeComplex;
  Result := false;

  for i := 0 to FItems.Count-1 do begin
    if TComplex(FItems[i]^).Name <> Name then continue;

    Result := true;
    break;
  end;
end;

function TComplex.Exists(Id: integer): boolean;
var i: integer;
begin
  modeComplex;
  Result := false;

  for i := 0 to FItems.Count-1 do begin
    if TComplex(FItems[i]^).Id <> Id then continue;

    Result := true;
    break;
  end;
end;

function TComplex.getStrFromDataType(dataType: TComplexType): string;
begin
  case dataType of
    ctNull: Result := 'null';
    ctFloat: Result := 'float';
    ctInt: Result := 'int';
    ctBool: Result := 'bool';
    ctStr: Result := 'str';
    ctBinary: Result := 'binary';
    ctList: Result := 'list';
    ctComplex: Result := 'complex';
    else Result := 'null';
  end;
end;

function TComplex.getDataTypeFromStr(aStr: string): TComplexType;
begin
  if aStr = 'float' then Result := ctFloat
  else if aStr = 'int' then Result := ctInt
  else if aStr = 'bool' then Result := ctBool
  else if aStr = 'str' then Result := ctStr
  else if aStr = 'binary' then Result := ctBinary
  else if aStr = 'list' then Result := ctList
  else if aStr = 'complex' then Result := ctComplex
  else Result := ctNull;
end;


{****************** TComplexList ******************}

procedure TComplexList.setComplex(Index: integer; Value: TComplex);
var i: integer;
begin
  if (Index < 0) then Index := -Index;
  if (Index >= inherited Count) then begin
    for i := inherited Count to Index do Add(TComplex.Create);
  end;

  inherited Items[Index] := pComplex(Value);
end;

function TComplexList.getComplex(Index: integer): TComplex;
var i: integer;
begin
  if (Index < 0) then Index := -Index;
  if (Index >= inherited Count) then begin
    for i := inherited Count to Index do Add(TComplex.Create);
  end;

  Result := TComplex(inherited Items[Index]);
end;

procedure TComplexList.Add(Value: TComplex);
begin
  inherited Add(pComplex(Value));
end;

function TComplexList.indexOf(Value: TComplex): integer;
var i: integer;
begin
  Result := -1; for i := 0 to inherited Count-1 do begin
    if inherited Items[i] <> Value then continue;

    Result := i;
    break;
  end;
end;

function TComplexList.asStr: string;
var i: integer;
begin
  Result := '{ '; for i := 0 to inherited Count-1 do begin
    if Items[i].Hidden then continue;

    Result := Result + intToStr(i) + ': ' + Items[i].asStr;
    if i < inherited Count-1 then Result := Result + ', ';
  end;

  Result := Result + ' }';
end;

end.
