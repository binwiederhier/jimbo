unit objMaps;

interface

uses
  Windows, Messages, Classes, SysUtils,

  _define;

type
  TMaps = class
  private
    FMaps: TStrings;
    FMapFile: string;
    FMapKey: string;
    FMapDir: string;

    function getMaps: TStrings;

    procedure setMapDir(Directory: string);
  public
    constructor Create;
    destructor Destroy; override;

    property Maps: TStrings read getMaps;
    property Folder: string read FMapDir write setMapDir;
  end;

implementation

constructor TMaps.Create;
begin
  inherited Create;

  FMaps := TStringList.Create;
  FMapDir := '';
end;

destructor TMaps.Destroy;
begin
  FMaps.Free;

  inherited Destroy;
end;

function TMaps.getMaps: TStrings;
var sr: TSearchRec;
begin
  Result := FMaps;
  FMaps.Clear;

  if findFirst(FMapDir+'*'+COMMON_EXT_MAP,faAnyFile,sr) <> 0 then begin
    findClose(sr);
    exit;
  end;

  repeat FMaps.Add(sr.Name);
  until findNext(sr) <> 0;

  findClose(sr);
end;

procedure TMaps.setMapDir(Directory: string);
begin
  // FEHLERBEHANDLUNG
  if not DirectoryExists(Directory) then raise Exception.Create('Der Maps-Ordner wurde nicht gefunden');

  if copy(Directory,Length(Directory)-1,1) <> '\' then Directory := Directory + '\';
  FMapDir := Directory;
end;



end.
