{
  partly from
    http://groups.google.com/group/borland.public.delphi.objectpascal/msg/c7ad65d695513443?hl=de&

  mainly changed by P.Heckel
}
unit funcVersion;

interface

uses
  Windows, Classes, SysUtils;

type
 TVersionInfoRec = record
    CompanyName, FileDescription, FileVersion,
    InternalName, LegalCopyright, LegalTradeMarks,
    OriginalFilename, ProductName, ProductVersion,
    Comments: string;
  end;

  TVersionRec = record
    Major: integer;
    Minor: integer;
    Release: integer;
    Build: integer;
  end;

function versionFromStr(versionStr: string): TVersionRec;
function versionCompare(versionA, versionB: string): integer;
function versionInfo(exeName: string = ''): TVersionInfoRec;

implementation

function versionFromStr(versionStr: string): TVersionRec;
var tmpL: TStrings;
begin
  tmpL := TStringList.Create;

  tmpL.Delimiter := '.';
  tmpL.DelimitedText := versionStr;

  with Result do begin
    Major := 0;
    Minor := 0;
    Release := 0;
    Build := 0;
  end;

  if tmpL.Count = 0 then begin tmpL.Free; exit; end;
  if tmpL.Count > 0 then Result.Major := strToIntDef(tmpL[0],0);
  if tmpL.Count > 1 then Result.Minor := strToIntDef(tmpL[1],0);
  if tmpL.Count > 2 then Result.Release := strToIntDef(tmpL[2],0);
  if tmpL.Count > 3 then Result.Build := strToIntDef(tmpL[3],0);

  tmpL.Free;
end;

{
  versionA > versionB => positive
  versionA < versionB => negative
  versionA = versionB => 0
}
function versionCompare(versionA, versionB: string): integer;
var vA, vB: TVersionRec;
begin
  Result := 0;
  if versionA = versionB then exit;

  vA := versionFromStr(versionA);
  vB := versionFromStr(versionB);

  if (vA.Major = vB.Major) and (vA.Minor = vB.Minor)
     and (vA.Release = vB.Release) and (vA.Build = vb.Build) then exit;

  Result := vA.Major-vB.Major;
  if Result <> 0 then exit;

  Result := vA.Minor-vB.Minor;
  if Result <> 0 then exit;

  Result := vA.Release-vB.Release;
  if Result <> 0 then exit;

  Result := vA.Build-vB.Build;
end;

function versionInfo(exeName: string = ''): TVersionInfoRec;
var i: integer;
    Len, n: cardinal;
    Buf, Val: pChar;
const
  InfoStr : array [1..10] of string =
    ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName',
     'LegalCopyright', 'LegalTradeMarks', 'OriginalFilename',
     'ProductName', 'ProductVersion', 'Comments');
begin
  if exeName = '' then exeName := paramStr(0);

  n := GetFileVersionInfoSize(PChar(exeName),n);
  if n <= 0 then exit;

  Buf := AllocMem(n);
  try
    GetFileVersionInfo(PChar(ExeName),0,n,Buf);
    for i := 1 to Length(InfoStr) do begin
      // http://www.microsoft.com/msj/0498/c0498.aspx
      // 0407 = deutsch; 0409 = englisch
      if not VerQueryValue(Buf,pChar('StringFileInfo\040704E4\' + InfoStr[i]),Pointer(Val),Len) then continue;

      case i of
        1: Result.CompanyName := Val;
        2: Result.FileDescription := Val;
        3: Result.FileVersion := Val;
        4: Result.InternalName := Val;
        5: Result.LegalCopyright := Val;
        6: Result.LegalTradeMarks := Val;
        7: Result.OriginalFilename := Val;
        8: Result.ProductName := Val;
        9: Result.ProductVersion := Val;
        10: Result.Comments := Val;
      end;
    end;
  finally
    FreeMem(Buf,n);
  end;
end;

end.
 