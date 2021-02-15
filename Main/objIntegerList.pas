unit objIntegerList;

interface

uses
  Windows, Messages, Classes, SysUtils,

  // Eigene
  funcCommon;              

type
  TIntegerList = class(TList)
  private
    procedure setInteger(Index: integer; Value: LongInt);
    function getInteger(Index: integer): LongInt;
  public
    procedure fromSepString(Str: string; Sep: Char);
    function toSepString(Sep: Char): string;

    procedure Add(Value: LongInt);
    function indexOf(Value: integer): integer;
    property Items[Index: Integer]: LongInt read getInteger write setInteger; default;
  end;

implementation
                                              
{****************** TIntegerList ******************}

procedure TIntegerList.fromSepString(Str: string; Sep: Char);
var tempList: TStrings;
    tempInt, i: integer;
begin
  Clear; tempList := TStringList.Create;
  if not Split(Str,Sep,tempList) then exit;

  for i := 0 to tempList.Count-1 do try
    tempInt := StrToInt(tempList[i]);
    Add(tempInt);
  except
    Add(0);
    continue;
  end;

  tempList.Free;
end;

function TIntegerList.toSepString(Sep: Char): string;
var i: integer;
begin
  Result := '';
  
  for i := 0 to Count-1 do begin
    Result := Result + IntToStr(Items[i]);
    if i < Count-1 then Result := Result + ',';
  end;
end;

procedure TIntegerList.setInteger(Index: integer; Value: LongInt);
begin
  inherited Items[Index] := Pointer(Value);
end;

function TIntegerList.getInteger(Index: integer): LongInt;
begin
  Result := LongInt(inherited Items[Index]);
end;

procedure TIntegerList.Add(Value: LongInt);
begin
  inherited Add(Pointer(Value));
end;

function TIntegerList.indexOf(Value: integer): integer;
var i: integer;
begin
  Result := -1; for i := 0 to Count-1 do begin
    if Items[i] <> Value then continue;

    Result := i;
    break;
  end;
end;


{[procedure TIntegerList.Reset;
begin
  while FCount > 0 do begin
    if
end;}

end.
