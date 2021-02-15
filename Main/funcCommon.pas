unit funcCommon;

interface

uses
  Windows, Messages, Classes, SysUtils, Math, Graphics;

function Like(const AString, APattern: String): Boolean;
function Split(aString: string; Delimiter: Char; out outStrings: TStrings): Boolean;
procedure DelTree(const Directory: TFileName);

function escapeStr(aString: string; escChars: string; escChar: Char): string;
function sqlEsc(aString: string): string;

function indexOf(Str: string; Strings: TStrings): integer;
procedure listReverse(const List: TList);
procedure grayBitmap(Bitmap: TBitmap);

function ifThenElse(compareBool: boolean; trueValue, falseValue: string): string; overload;
function ifThenElse(compareBool: boolean; trueValue, falseValue: integer): integer; overload;

function MaxP(XorY: boolean; aP: array of TPoint): integer;
function MinP(XorY: boolean; aP: array of TPoint): integer;

implementation

{ Like prüft die Übereinstimmung eines Strings mit einem Muster.
  So liefert Like('Delphi', 'D*p?i') true.
  Der Vergleich berücksichtigt Klein- und Großschreibung.
  Ist das nicht gewünscht, muss statt dessen
  Like(AnsiUpperCase(AString), AnsiUpperCase(APattern)) benutzt werden: }

function Like(const AString, APattern: String): Boolean;
var
  StringPtr, PatternPtr: PChar;
  StringRes, PatternRes: PChar;
begin
  Result:=false;
  StringPtr:=PChar(AString);
  PatternPtr:=PChar(APattern);
  StringRes:=nil;
  PatternRes:=nil;
  repeat
    repeat // ohne vorangegangenes "*"
      case PatternPtr^ of
        #0: begin
          Result:=StringPtr^=#0;
          if Result or (StringRes=nil) or (PatternRes=nil) then
            Exit;
          StringPtr:=StringRes;
          PatternPtr:=PatternRes;
          Break;
        end;
        '*': begin
          inc(PatternPtr);
          PatternRes:=PatternPtr;
          Break;
        end;
        '?': begin
          if StringPtr^=#0 then
            Exit;
          inc(StringPtr);
          inc(PatternPtr);
        end;
        else begin
          if StringPtr^=#0 then
            Exit;
          if StringPtr^<>PatternPtr^ then begin
            if (StringRes=nil) or (PatternRes=nil) then
              Exit;
            StringPtr:=StringRes;
            PatternPtr:=PatternRes;
            Break;
          end
          else begin
            inc(StringPtr);
            inc(PatternPtr);
          end;
        end;
      end;
    until false;
    repeat // mit vorangegangenem "*"
      case PatternPtr^ of
        #0: begin
          Result:=true;
          Exit;
        end;
        '*': begin
          inc(PatternPtr);
          PatternRes:=PatternPtr;
        end;
        '?': begin
          if StringPtr^=#0 then
            Exit;
          inc(StringPtr);
          inc(PatternPtr);
        end;
        else begin
          repeat
            if StringPtr^=#0 then
              Exit;
            if StringPtr^=PatternPtr^ then
              Break;
            inc(StringPtr);
          until false;
          inc(StringPtr);
          StringRes:=StringPtr;
          inc(PatternPtr);
          Break;
        end;
      end;
    until false;
  until false;
end; {Michael Winter}

function Split(aString: string; Delimiter: Char; out outStrings: TStrings): Boolean;
begin
  if not (outStrings is TStringList) then outStrings := TStringList.Create;

  outStrings.Clear;
  outStrings.Delimiter := Delimiter;
  outStrings.DelimitedText := aString;

  Result := true;
end;

{
  von
  http://groups.google.de/group/de.comp.lang.delphi.misc/msg/8ef5cbed2f865ae6?hl=de&
}

procedure DelTree(const Directory: TFileName);
var
  DrivesPathsBuff: array[0..1024] of char;
  DrivesPaths: string;
  len: longword;
  ShortPath: array[0..MAX_PATH] of char;
  dir: TFileName;
procedure rDelTree(const Directory: TFileName);
// Recursively deletes all files and directories
// inside the directory passed as parameter.
var
  SearchRec: TSearchRec;
  Attributes: LongWord;
  ShortName, FullName: TFileName;
  pname: pchar;
begin
  if FindFirst(Directory + '*', faAnyFile and not faVolumeID,
     SearchRec) = 0 then begin
    try
      repeat // Processes all files and directories
        if SearchRec.FindData.cAlternateFileName[0] = #0 then
          ShortName := SearchRec.Name
        else
          ShortName := SearchRec.FindData.cAlternateFileName;
        FullName := Directory + ShortName;
        if (SearchRec.Attr and faDirectory) <> 0 then begin
          // It's a directory
          if (ShortName <> '.') and (ShortName <> '..') then
            rDelTree(FullName + '\');
        end else begin
          // It's a file
          pname := PChar(FullName);
          Attributes := GetFileAttributes(pname);
          if Attributes = $FFFFFFFF then
            raise EInOutError.Create(SysErrorMessage(GetLastError));
          if (Attributes and FILE_ATTRIBUTE_READONLY) <> 0 then
            SetFileAttributes(pname, Attributes and not
              FILE_ATTRIBUTE_READONLY);
          if Windows.DeleteFile(pname) = False then
            raise EInOutError.Create(SysErrorMessage(GetLastError));
        end;
      until FindNext(SearchRec) <> 0;
    except
      FindClose(SearchRec);
      raise;
    end;
    FindClose(SearchRec);
  end;
  if Pos(#0 + Directory + #0, DrivesPaths) = 0 then begin
    // if not a root directory, remove it
    pname := PChar(Directory);
    Attributes := GetFileAttributes(pname);
    if Attributes = $FFFFFFFF then
      raise EInOutError.Create(SysErrorMessage(GetLastError));
    if (Attributes and FILE_ATTRIBUTE_READONLY) <> 0 then
      SetFileAttributes(pname, Attributes and not
        FILE_ATTRIBUTE_READONLY);
    if Windows.RemoveDirectory(pname) = False then begin
      raise EInOutError.Create(SysErrorMessage(GetLastError));
    end;
  end;             
end;                    
// ----------------
begin
  DrivesPathsBuff[0] := #0;
  len := GetLogicalDriveStrings(1022, @DrivesPathsBuff[1]);
  if len = 0 then
    raise EInOutError.Create(SysErrorMessage(GetLastError));
  SetString(DrivesPaths, DrivesPathsBuff, len + 1);
  DrivesPaths := Uppercase(DrivesPaths);
  len := GetShortPathName(PChar(Directory), ShortPath, MAX_PATH);
  if len = 0 then
    raise EInOutError.Create(SysErrorMessage(GetLastError));
  SetString(dir, ShortPath, len);
  dir := Uppercase(dir);
  rDelTree(IncludeTrailingBackslash(dir));
end;

function escapeStr(aString: string; escChars: string; escChar: Char): string;
var i: integer;
begin
  Result := aString;
  for i := 1 to Length(escChars) do
    Result := StringReplace(Result,escChars[i],escChar+escChars[i],[rfReplaceAll]);
end;

function sqlEsc(aString: string): string;
begin
  Result := escapeStr(aString,'''','''');
//  Result := escapeStr(Result,'[]\','\');
end;

function indexOf(Str: string; Strings: TStrings): integer;
var i: integer;
begin
  Result := -1;
  for i := 0 to Strings.Count-1 do begin
    if AnsiLowerCase(Strings[i]) <> AnsiLowerCase(Str) then continue;

    Result := i;
    break;
  end;
end;

procedure listReverse(const List: TList);
var i: integer;
begin
  for i := 0 to floor(List.Count/2)-1 do
    List.Exchange(i,List.Count -i -1);
end;

procedure grayBitmap(Bitmap: TBitmap);
var
  Pixel: PLongWord;
  I, J: Integer;

begin
  Bitmap.PixelFormat := pf32Bit;

  for J := 0 to (Bitmap.Height - 1) do
    begin
    Pixel := Bitmap.Scanline[J];

    for I := 0 to (Bitmap.Width - 1) do
      begin
      Pixel^ := Pixel^ and $00FEFEFE shr 1 + $00808080;
      Inc(Pixel);
      end;
    end;
end;

function ifThenElse(compareBool: boolean; trueValue, falseValue: string): string;
begin
  if compareBool then Result := trueValue
  else Result := falseValue;
end;

function ifThenElse(compareBool: boolean; trueValue, falseValue: integer): integer;
begin
  if compareBool then Result := trueValue
  else Result := falseValue;
end;

{Note: Negative values are not supported}
function MaxP(XorY: boolean; aP: array of TPoint): integer;
var i: integer;
begin
  Result := -1;
  if Length(aP) = 0 then exit;

  for i := 0 to Length(aP)-1 do begin
    if (Result <> -1) and ( ( (XorY) and (Result >= aP[i].X) ) or ( (not XorY) and (Result >= aP[i].Y) ) ) then
      continue;

    if XorY then Result := aP[i].X
    else Result := aP[i].Y;
  end;
end;

{Note: Negative values are not supported}
function MinP(XorY: boolean; aP: array of TPoint): integer;
var i: integer;
begin
  Result := -1;
  if Length(aP) = 0 then exit;

  for i := 0 to Length(aP)-1 do begin
    if (Result <> -1) and ( ( (XorY) and (Result <= aP[i].X) ) or ( (not XorY) and (Result <= aP[i].Y) ) ) then
      continue;

    if XorY then Result := aP[i].X
    else Result := aP[i].Y;
  end;
end;

end.
