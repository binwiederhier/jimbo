unit objPricer;

interface

uses
  Windows, Messages, SysUtils,

  // Fremdkomponenten
  MathParser,

  objComplex;

type
  TPricer = class
  private
    FUseCache: boolean;
    FCache: TComplex;
    FFields: TComplex;
  public
    constructor Create;
    destructor Destroy; override;

    function Test(Formula: string): boolean;
    function Calculate(Formula: string; var Price: double; noCache: boolean = false): boolean;

    property Fields: TComplex read FFields write FFields;
    property useCache: boolean read FUseCache write FUseCache;
  end;

implementation

constructor TPricer.Create;
begin
  inherited Create;

  FCache := TComplex.Create;
  FFields := TComplex.Create;
  FUseCache := false;
end;

destructor TPricer.Destroy;
begin
  FCache.Free;
  FFields.Free;
  inherited Destroy;
end;

function TPricer.Test(Formula: string): boolean;
var i: integer;
    dummyFloat: double;
    priceStr: string;

    Field: TComplex;
begin
  {
    Alle vorhandenen Felder werden durch Zufallszahlen <> 0 ersetzt.
    Da dies zu Fehlern (Division durch Null) führen kann, wird die Prüfung zwei mal
    durchgeführt, wenn der Test scheitert.
  }
  randomize;

  for i := 0 to 1 do begin
    priceStr := Formula;

    // Zufallszahlen einsetzen
    FFields.Reset;
    while not FFields.Last do begin
      Field := FFields.Next;
      Field.asInt := 10+random(200);
    end;

    // Rechnen!          
    Result := Calculate(Formula,dummyFloat,true);
    if Result then break;
  end;
end;

function TPricer.Calculate(Formula: string; var Price: double; noCache: boolean = false): boolean;
var calcResult: double;

    Field: TComplex;

    Parser: TMathParser;
    pTree: pTTermTreeNode;
begin
  Result := false;

  // Felder einsetzen
  FFields.Reset;
  while not FFields.Last do begin
    Field := FFields.Next;
    Formula := stringReplace(Formula,Field.Name,Field.asStr,[rfReplaceAll]);
  end;

  // Cache!
  if (not noCache) and (FUseCache and FCache.Exists(Formula)) then begin
    Price := FCache[Formula].asFloat;

    Result := true;
    exit;
  end;

  // Parse!
  Parser := TMathParser.Create;

  try
    pTree := Parser.ParseTerm(Formula);
    calcResult := Parser.CalcTree(pTree);

//    showmessage(Formula + ' = '+floattostr(calcResult));
  except
    Parser.FreeLastTermTree;
    Parser.Free;

    exit;
  end;

  if Parser.ParseError = mpeNone then begin
    Price := calcResult;
    if FUseCache then FCache[Formula].asFloat := Price;

    Result := true;
  end;

  Parser.FreeLastTermTree;
  Parser.Free;
end;

end.
