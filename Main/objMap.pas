unit objMap;

interface

uses
  Windows, Messages, Classes, SysUtils, Math, Graphics, JPEG, IniFiles, Dialogs,
  ExtCtrls, ShellAPI,


  gr32, GR32_Image,

  // Packer
  ZIP,

  // Eigene
  _define, objIntegerList, funcCommon;

type
  TLocations = class;

  pThread = ^TThread;

  TPiece = class(TThread)
  private
    FFilename: string;
    FBitmap: TBitmap;
    FEmpty: TBitmap;

    FUpdating: boolean;
    FLoaded: boolean;

    FOnLoaded: TNotifyEvent;

    function getBitmap: TBitmap;
    procedure DoOnLoaded;
  public
    constructor Create(Filename: string; const Empty: TBitmap);
    destructor Destroy; override;

    procedure Execute; override;
    procedure Terminate;

    property Bitmap: TBitmap read getBitmap;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
  end;

  TMap = class
  private
    // DLLs
    FDLLPath: string;

    FFilename: string;
    FKey: string;

    FOpened: Boolean;

    // Bilder
    FBitmap: TBitmap; {dynamisch aus xxyy.jpg erzeugtes Bitmap mit variablen Ausmaßen}
    FBitmap32: TBitmap32;
    FNavigator: TBitmap; {navi.jpg, feste Breite, in Open() geladen}

    // Maße
    FWidth: integer;
    FHeight: integer;

    // Stücke
    FPieceCols: integer;
    FPieceRows: integer;
    FPieceWidth: integer;
    FPieceHeight: integer;

    // Ausschnitt
    FRect: TRect;
    FTopLeft: TPoint;
    FBottomRight: TPoint;

    FPieces: array of array of TPiece;
    FPiecesLoading: integer;
//    FPiecesTimer: TTimer;
    FPieceEmpty: TBitmap;

    FUpdated: cardinal;

    // Sprung-Punkte (Locations)
    FLocations: TLocations;

    // Temp. Verzeichnis
    FTempPath: string;

    // Ereignisse
    FOnLoadedPiece: TNotifyEvent;
    FOnLoadedComplete: TNotifyEvent;

    procedure setDLLPath(Path: string);
    procedure setRect(Value: TRect);
    procedure setPosition(Value: TPoint);

    function getRect: TRect;
    function getPosition: TPoint;

    procedure Reset;
    procedure cleanTemp;

    procedure loadPieces;

    procedure DoLoadedPiece;
    procedure DoLoadedComplete;

    procedure OnTimer(Sender: TObject);
    procedure makeMap;
    procedure haltPieces;
  public
    constructor Create;
    destructor Destroy; override;

    function Open(Filename: string; Key: string = ''; AskKey: boolean = true): Boolean;
    procedure Close;

    function Visible(X,Y: integer): boolean;

    property DLLPath: string read FDLLPath write setDLLPath;

    property Bitmap: TBitmap read FBitmap;
    property Bitmap32: TBitmap32 read FBitmap32;
    property Navigator: TBitmap read FNavigator;

    property Filename: string read FFilename;
    property Key: string read FKey;
    property Opened: Boolean read FOpened;

    // Maße
    property Width: integer read FWidth;
    property Height: integer read FHeight;
    property Position: TPoint read getPosition write setPosition; {Punkt in der Mitte der Karte}

    // Stücke
    property pieceCols: integer read FPieceCols;
    property pieceRows: integer read FPieceRows;
    property pieceWidth: integer read FPieceWidth;
    property pieceHeight: integer read FPieceHeight;

    // Ausschnitt
    property Rect: TRect read getRect write setRect;

    // Sprung-Punkte (Locations)
    property Locations: TLocations read FLocations;

    property Updated: cardinal read FUpdated;

    property OnLoadedPiece: TNotifyEvent read FOnLoadedPiece write FOnLoadedPiece;
    property OnLoadedComplete: TNotifyEvent read FOnLoadedComplete write FOnLoadedComplete;
    procedure Update;
  end;

  TLocation = record
    ID: integer;
    Title: string;
    X: integer;
    Y: integer;
    Radius: integer;
  end;


  TLocations = class(TList)
  private
    FUpdating: Boolean;

    procedure setLocation(Index: integer; Value: TLocation);
    function getLocation(Index: integer): TLocation;
  public
    constructor Create;
    procedure Clear; override;

    procedure beginUpdate;
    procedure endUpdate;

    procedure Add(Location: TLocation); overload;
    function indexOf(ID: integer): integer; overload;
    function byID(ID: integer): TLocation;
    function Nearest(X, Y: integer): TLocation;
    function At(X, Y: integer; var Location: TLocation): boolean;

    property Items[Index: Integer]: TLocation read getLocation write setLocation; default;
    property Updating: Boolean read FUpdating;
  end;

implementation

{** Callback-Funktion für die Sortierung **}

function locationSort(pLocation1, pLocation2: Pointer): integer;
var pLoc1, pLoc2: ^TLocation;
begin
  pLoc1 := pLocation1; pLoc2 := pLocation2;
  Result := AnsiCompareText(pLoc1^.Title,pLoc2^.Title);
end;

{****************** TMap ******************}

constructor TMap.Create;
begin
  inherited Create;

  FBitmap := TBitmap.Create;
  FBitmap32 := TBitmap32.Create;
  FNavigator := TBitmap.Create;

  FLocations := TLocations.Create;

  FFilename := '';
  FKey := '';

  FPieceEmpty := TBitmap.Create;
  FPiecesLoading := 0;
//  FPiecesLoading := TList.Create;
 // FPiecesTimer := TTimer.Create(nil);
  //FPiecesTimer.Interval := 20;
//  FPiecesTimer.OnTimer := OnTimer;

  FUpdated := GetTickCount;

  setLength(FPieces,0);
end;

destructor TMap.Destroy;
begin
  setLength(FPieces,0);

  FLocations.Free;

//  FPiecesLoading.Free;
  //FPiecesTimer.Free;

  FPieceEmpty.Free;

  FNavigator.Free;
  FBitmap.Free;
  FBitmap32.Free;

  inherited Destroy;
end;

procedure TMap.Reset;
var x, y: integer;
begin
  for y := 0 to High(FPieces) do begin
    for x := 0 to High(FPieces[y]) do
      if Assigned(FPieces[y][x]) then FreeAndNil(FPieces[y][x]);

    setLength(FPieces[y],0);
  end;

  setLength(FPieces,0);

  FWidth := -1;
  FHeight := -1;

  FPieceCols := -1;
  FPieceRows := -1;
  FPieceWidth := -1;
  FPieceHeight := -1;
end;


procedure TMap.haltPieces;
var x, y: integer;
begin
  for y := 0 to High(FPieces) do begin
    for x := 0 to High(FPieces[y]) do
      if Assigned(FPieces[y][x]) then begin
        try
          FPieces[y][x].OnTerminate := nil;
          FPieces[y][x].OnLoaded := nil;

          FPieces[y][x].Terminate;
//          if Assigned(FPieces[y][x]) then FPieces[y][x].WaitFor;
        except
          continue;
        end;
      end;

    setLength(FPieces[y],0);
  end;
end;

function TMap.Open(Filename: string; Key: string = ''; AskKey: boolean = true): Boolean;
var ZIP: TZip;
    Ini: TIniFile;
    Jpg: TJPEGImage;
    Loc: TLocation;

    tempPath: array[0..MAX_PATH] of Char;
    i, fileCount: integer;
begin
  Result := false;

  if not FileExists(Filename) then exit;

  Reset;

  // Pfad im Temp-Verzeichnis erstellen
  i := 0; randomize;

  repeat
    FillChar(tempPath,MAX_PATH,#0);

    Windows.GetTempPath(SizeOf(tempPath)-1,tempPath);
    Windows.GetTempFileName(tempPath,'map',1+random(10000),tempPath);

    inc(i);
  until ForceDirectories(tempPath) or (i = 3);

  if not DirectoryExists(tempPath) then exit;

  FTempPath := tempPath;
  if (copy(FTempPath,length(FTempPath)-1,1) <> '\') then FTempPath := FTempPath + '\';

  // Archiv entpacken
  ZIP := TZIP.Create(nil);
  ZIP.ShowProgressDialog := false;
  ZIP.DllPath := FDLLPath;

  ZIP.Filename := Filename;
  ZIP.PasswordRetry := 2;
  ZIP.PasswordAsk := AskKey;
  ZIP.Password := Key;

  ZIP.ExtractPath := FTempPath;
  ZIP.ExtractOptions := [eoUpdate];

  try
    fileCount := ZIP.Extract;
  except
    ZIP.Free;
    cleanTemp;

    exit;
  end;

  if fileCount = 0 then begin
    ZIP.Free;
    sleep(50);
    cleanTemp;
               
    exit;
  end;
  
  FKey := Zip.Password;
  ZIP.Free;

  // Karten-Einstellungen lesen (settings.ini)
  Ini := TIniFile.Create(FTempPath+FILE_SETTINGS);

  FWidth := Ini.ReadInteger(INI_SECTION_MAP,'width',-1);
  FHeight := Ini.ReadInteger(INI_SECTION_MAP,'height',-1);

  FPieceWidth := Ini.ReadInteger(INI_SECTION_PIECES,'width',-1);
  FPieceHeight := Ini.ReadInteger(INI_SECTION_PIECES,'height',-1);

  Ini.Free;

  if (FWidth = -1) or (FHeight = -1) or (FPieceWidth = -1) or (FPieceHeight = -1) then begin
    Reset;
    exit;
  end;

  // Stückanzahl errechnen
  FPieceCols := Ceil(FWidth/FPieceWidth);
  FPieceRows := Ceil(FHeight/FPieceHeight);

  setLength(FPieces,FPieceRows);
  for i := 0 to FPieceRows-1 do setLength(FPieces[i],FPieceCols);

  // Navigator lesen
  jpg := TJPEGImage.Create;

  try
    jpg.LoadFromFile(FTempPath+FILE_NAVIGATOR);

    // JPEG in Bitmap kopieren
    FNavigator.Assign(jpg);
  except
    jpg.Free;
    cleanTemp;

    raise;
    exit;
  end;

  jpg.Free;

  // Leeres Bild zeichnen
  FPieceEmpty.Width := FPieceWidth;
  FPieceEmpty.Height := FPieceHeight;
  
  with FPieceEmpty.Canvas do begin
    Brush.Style := bsBDiagonal;
    Brush.Color := clSilver;
    Pen.Color := clSilver;

    Rectangle(0,0,FPieceWidth,FPieceHeight);

    Pen.Color := clBlack;
    Brush.Style := bsClear;

    Font.Name := 'Verdana';

    TextOut(2,2,'Kartenteil laden ...');
  end;

   // Sprung-Punkte lesen (Locations)
  Ini := TIniFile.Create(FTempPath+FILE_LOCATIONS);

  fileCount := Ini.ReadInteger(INI_SECTION_LOCATIONS,'count',-1);
  if (fileCount = -1) then begin
    Reset;

    Ini.Free;
    cleanTemp;
    
    exit;
  end;

  FLocations.beginUpdate;

  for i := 0 to fileCount-1 do begin
    Loc.ID := i+1;

    Loc.Title := Ini.ReadString(INI_SECTION_LOCATIONS,'t'+IntToStr(i),'');
    Loc.X := Ini.ReadInteger(INI_SECTION_LOCATIONS,'x'+IntToStr(i),-1);
    Loc.Y := Ini.ReadInteger(INI_SECTION_LOCATIONS,'y'+IntToStr(i),-1);
    Loc.Radius := Ini.ReadInteger(INI_SECTION_LOCATIONS,'r'+IntToStr(i),-1);

    if (Loc.Title = '') or (Loc.X = -1) or (Loc.Y = -1) or (Loc.Radius = -1) then continue;
    FLocations.Add(Loc);
  end;

  FLocations.endUpdate;

  Ini.Free;

  // Setzen
  FFilename := Filename;
  FKey := Key;

  FOpened := true;
  Result := true;
end;

procedure TMap.Close;
begin
  haltPieces;
  FBitmap.FreeImage;

  Locations.Clear;

  try cleanTemp;
  except end;

  Reset;
  
  FOpened := false;
end;

function TMap.Visible(X,Y: integer): boolean;
begin
  Result := (FRect.Left < X) and (FRect.Right > X)
        and (FRect.Top < Y) and (FRect.Bottom > Y);
end;

procedure TMap.setDLLPath(Path: string);
begin
  if (copy(Path,length(Path)-1,1) <> '\') then Path := Path + '\';

  // FEHLERBEHANDLUNG

  if not FileExists(Path+DLL_UNZIP) then raise Exception.Create('Die UnZip DLL wurde nicht gefunden');

  FDLLPath := Path;
end;

procedure TMap.makeMap;
var x, y, rectW, rectH: integer;
    topLeft, bottomRight: TPoint;
    destRect, srcRect: TRect;
    pieceX, pieceY, pieceW, pieceH: integer;
begin
  rectW := FRect.Right - FRect.Left;
  rectH := FRect.Bottom - FRect.Top;

  if (FRect.Left < 0) then begin
    FRect.Left := 0;
    FRect.Right := rectW;
  end;

  if (FRect.Right > FWidth) then begin
    FRect.Right := FWidth;
    FRect.Left := FWidth-rectW;
  end;

  if (FRect.Top < 0) then begin
    FRect.Top := 0;
    FRect.Bottom := rectH;
  end;

  if (FRect.Bottom > FHeight) then begin
    FRect.Bottom := FHeight;
    FRect.Top := FHeight-rectH;
  end;

//  if (FRect.Right - FRect.Left < rectW) then FRect.Right :=

  // TopLeft und BottomRight errechnen
  FTopLeft.X := floor(FRect.Left/FPieceWidth);
  FTopLeft.Y := floor(FRect.Top/FPieceHeight);
  FBottomRight.X := floor(FRect.Right/FPieceWidth);
  FBottomRight.Y := floor(FRect.Bottom/FPieceHeight);

  // Ränder
  if (FTopLeft.X < 0) then FTopLeft.X := 0;
  if (FTopLeft.Y < 0) then FTopLeft.Y := 0;
  if (FBottomRight.X < 0) then FBottomRight.X := 0;
  if (FBottomRight.Y < 0) then FBottomRight.Y := 0;

  if (Length(FPieces) > 0) and (Length(FPieces[0]) > 0) then begin
    if (FTopLeft.X > High(FPieces[0])) then FTopLeft.X := High(FPieces[0]);
    if (FTopLeft.Y > High(FPieces)) then FTopLeft.Y := High(FPieces);
    if (FBottomRight.X > High(FPieces[0])) then FBottomRight.X := High(FPieces[0]);
    if (FBottomRight.Y > High(FPieces)) then FBottomRight.Y := High(FPieces);
  end;

  // Noch nicht geladene Stücke einlesen
  loadPieces;

  //  Bitmap zusammenkopieren
  FBitmap.Width := FRect.Right - FRect.Left;
  FBitmap.Height := FRect.Bottom - FRect.Top;

  FBitmap32.Width := FBitmap.Width;
  FBitmap32.Height := FBitmap.Height;

  for y := FTopLeft.Y to FBottomRight.Y do begin
    for x := FTopLeft.X to FBottomRight.X do begin
      pieceX := x*FPieceWidth;
      pieceY := y*FPieceHeight;
      pieceW := FPieces[y][x].Bitmap.Width;
      pieceH := FPieces[y][x].Bitmap.Height;

      // Ziel-Rect berechnen
      destRect.Left := pieceX - FRect.Left;
      if (destRect.Left < 0) then destRect.Left := 0;

      destRect.Top := pieceY - FRect.Top;
      if (destRect.Top < 0) then destRect.Top := 0;

      destRect.Right := pieceX - FRect.Left + pieceW;
      if (destRect.Right > FBitmap.Width) then destRect.Right := FBitmap.Width;

      destRect.Bottom := pieceY - FRect.Top + pieceH;
      if (destRect.Bottom > FBitmap.Height) then destRect.Bottom := FBitmap.Height;

      // Source-Rect berechnen
      srcRect.Left := 0;
      if (FRect.Left > pieceX) then srcRect.Left := FRect.Left - pieceX;

      srcRect.Top := 0;
      if (FRect.Top > pieceY) then srcRect.Top := FRect.Top - pieceY;

      srcRect.Right := pieceW;
      if (pieceX + srcRect.Right > FRect.Right) then srcRect.Right := FRect.Right mod FPieceWidth;

      srcRect.Bottom := pieceH;
      if (pieceY + srcRect.Bottom > FRect.Bottom) then srcRect.Bottom := FRect.Bottom mod FPieceHeight;

      // Ausgeben
      FBitmap.Canvas.CopyRect(
        destRect,
        FPieces[y][x].Bitmap.Canvas,
        srcRect
      );

      //FBitmap.Canvas.TextOut(destRect.Left,destRect.Top,inttostr(x)+'-'+inttostr(y)+'-'+intToStr(GetTickCount));
    end;
  end;

//  FBitmap32.Canvas.Draw(0,0,FBitmap);
end;

procedure TMap.Update;
begin
  makeMap;
end;

procedure TMap.cleanTemp;
begin
  if not DirectoryExists(FTempPath) then exit;

  SetCurrentDirectory(PChar(FDLLPath));
  try delTree(FTempPath); except end;
end;

procedure TMap.setRect(Value: TRect);
begin
  // Rechteck (absolut zum gesamten Bild)
  FRect := Value;

  makeMap;
end;

procedure TMap.setPosition(Value: TPoint);
var w2, h2: integer;
begin
  w2 := (Rect.Right - Rect.Left) div 2;
  h2 := (Rect.Bottom - Rect.Top) div 2;

  Rect := Classes.Rect(
    Value.X - w2, Value.Y - h2,
    Value.X + w2, Value.Y + h2
  );       
end;

function TMap.getRect: TRect;
begin
  Result := FRect;
end;

function TMap.getPosition: TPoint;
begin
  Result := Point(
    Rect.Left + (Rect.Right - Rect.Left)  div 2,
    Rect.Top + (Rect.Bottom - Rect.Top) div 2
  );
end;

procedure TMap.loadPieces;
var i, x, y: integer;
    tempFile: string;

    //jpg: TJPEGImage;
    Piece: TPiece;
begin
  for y := 0 to High(FPieces) do begin
    for x := 0 to High(FPieces[y]) do begin

      // Freigeben, da nicht zwischen TopLeft und BottomRight
      if (x < FTopLeft.X) or (y < FTopLeft.Y) or (x > FBottomRight.X) or (y > FBottomRight.Y) then begin
        if Assigned(FPieces[y][x]) and (FPieces[y][x] is TPiece) and (not (FPieces[y][x] as TPiece).Terminated) then begin
          {
            Hinweis:
              Der Thread gibt sich selbst frei und 'nil't die Variable darauf,
              sodass ohne Probleme getestet werden kann ob TPiece schon geladen ist.
          }
          Piece := FPieces[y][x];

          FPieces[y][x] := nil;
          Piece.Terminate;
 //         if FPieces[y][x] <> nil then
    //         exit;
        end;

        continue;
      end;

      // Bitmap bereits geladen?
      if Assigned(FPieces[y][x]) and (FPieces[y][x] is TPiece) then begin
        GetTickCount;
        continue;
      end;



      // JPEG laden
      tempFile := FTempPath+Format('%2.2d%2.2d',[x,y])+'.jpg';

      // Increase Loading Threads
      inc(FPiecesLoading);

      // Piece erzeugen
      FPieces[y][x] := TPiece.Create(tempFile,FPieceEmpty);
      FPieces[y][x].OnLoaded := OnTimer;
     // FPieces[y][x].OnTerminate := OnTimer;

      FPieces[y][x].Resume;
    end;
  end;

end;

procedure TMap.OnTimer(Sender: TObject);
var i: integer;
    doUpd: boolean;

    Piece: TPiece;
begin
 // if not Assigned(Sender) or (not (Sender is TPiece)) then exit;

//  (Sender as TPiece).Free;
  FUpdated := GetTickCount;
  dec(FPiecesLoading);

  if FPiecesLoading < 0 then begin
    exit;
  end;

  DoLoadedPiece;

  if FPiecesLoading = 0 then
    DoLoadedComplete;

{


exit;

  i := 0;
  doUpd := false;

  while i < FPiecesLoading.Count-1 do begin
    Piece := FPiecesLoading[i];

    if not (Piece is TPiece) then begin
      FPiecesLoading.Delete(i);
      continue;
    end;

    if not Piece.Terminated then begin
      inc(i);
      continue;
    end;

    FPiecesLoading.Delete(i);
    Piece.Free;

    FUpdated := GetTickCount;
  end;

  if FPiecesLoading.Count = 0 then FPiecesTimer.Enabled := false;}
end;

procedure TMap.DoLoadedPiece;
begin
  makeMap;

  if Assigned(FOnLoadedPiece) then
    FOnLoadedPiece(Self);
end;

procedure TMap.DoLoadedComplete;
begin
  makeMap;

  if Assigned(FOnLoadedComplete) then
    FOnLoadedComplete(Self);
end;


{****************** TPiece ******************}

constructor TPiece.Create(Filename: string; const Empty: TBitmap);
begin
  FBitmap := nil;
  FEmpty := Empty;

  FFilename := Filename;
  FLoaded := false;

  // Selbstmord
  FreeOnTerminate := true;
  inherited Create(true);
end;

destructor TPiece.Destroy;
begin
  FLoaded := false;
  inherited Destroy;
end;

function TPiece.getBitmap: TBitmap;
begin
  try
    if (FUpdating or (not FLoaded) or Terminated or (not (FBitmap is TBitmap))) and (FEmpty is TBitmap) then Result := FEmpty
    else Result := FBitmap;
  except
    FUpdating := not FUpdating;
    FLoaded := not FLoaded;
    FBitmap := nil;
    FEmpty := nil;
  end;
end;

procedure TPiece.DoOnLoaded;
begin
  if Assigned(FOnLoaded) then
    FOnLoaded(Self);
end;

procedure TPiece.Execute;
var jpg: TJPEGImage;
begin
  FBitmap := TBitmap.Create;
  jpg := TJPEGImage.Create;

  try
    jpg.LoadFromFile(FFilename);
    if Terminated or (not (jpg is TJPEGImage)) then begin
      freeAndNil(FBitmap);
      jpg.Free;

      exit;
    end;
  except
    freeAndNil(FBitmap);
    jpg.Free;

    exit;
  end;

  try
    // JPEG in Bitmap kopieren
    FUpdating := true;

    FBitmap.Width := FEmpty.Width;
    FBitmap.Height := FEmpty.Height;
    if Terminated or (not (jpg is TJPEGImage)) then begin
      freeAndNil(FBitmap);
      jpg.Free;

      exit;
    end;

    FBitmap.Assign(jpg);
  finally
    jpg.Free;

    FUpdating := false;
    FLoaded := true;
  end;

  Synchronize(DoOnLoaded);

  while not Terminated do sleep(1000);

  freeAndNil(FBitmap);
end;

procedure TPiece.Terminate;
begin
{  if Assigned(FVarAddr) and Assigned(FVarAddr^) then
    FVarAddr^ := nil;}

  inherited;
end;

{****************** TLocations ******************}

constructor TLocations.Create;
begin
  FUpdating := false;
end;

procedure TLocations.Clear;
begin
  while inherited Count > 0 do begin
    if Assigned(inherited Items[0]) then freeMem(inherited Items[0]);
    inherited Delete(0);
  end;
end;

procedure TLocations.Add(Location: TLocation);
var pLocation: ^TLocation;
begin
  System.New(pLocation);
  pLocation^ := Location;

  inherited Add(pLocation);

  if not FUpdating then Sort(@locationSort);
end;

procedure TLocations.setLocation(Index: integer; Value: TLocation);
var pLocation: ^TLocation;
begin
  pLocation := inherited Items[Index];
  pLocation^ := Value;
end;

function TLocations.getLocation(Index: integer): TLocation;
var pLocation: ^TLocation;
begin
  pLocation := inherited Items[Index];
  Result := pLocation^;
end;

function TLocations.indexOf(ID: integer): integer;
var i: integer;
    pLocation: ^TLocation;
begin
  Result := -1;

  for i := 0 to Count-1 do begin
    pLocation := inherited Items[i];
    if (pLocation^.ID <> ID) then continue;

    Result := i;
    exit;
  end;
end;

function TLocations.byID(ID: integer): TLocation;
var i: integer;
    pLocation: ^TLocation;
begin
  i := indexOf(ID);
  if i = -1 then exit;

  pLocation := inherited Items[i];
  Result := pLocation^;
end;

function TLocations.Nearest(X, Y: integer): TLocation;
var i, Dist, aDist: integer;
begin
  Result.ID := -1;
  if inherited Count = 0 then exit;

  for i := 0 to Count-1 do begin
    if not (Assigned(inherited Items[i])) then continue;

    if Result.ID = -1 then begin
      Result := Items[i];
      Dist := Round(Sqrt( Sqr(Items[i].X-X) + Sqr(Items[i].Y-Y) ));

      continue;
    end;

    aDist := Round(Sqrt( Sqr(Items[i].X-X) + Sqr(Items[i].Y-Y) ));
    if Dist <= aDist then continue;

    Result := Items[i];
    Dist := aDist;
  end;
end;

function TLocations.At(X, Y: integer; var Location: TLocation): boolean;
var tmpLoc: TLocation;
begin
  Result := false;
  if inherited Count = 0 then exit;

  tmpLoc := Nearest(X,Y);
  Result := (Abs(X-tmpLoc.X) <= tmpLoc.Radius) and (Abs(tmpLoc.Y-Y) <= tmpLoc.Radius);

  if Result then Location := tmpLoc;
end;

procedure TLocations.beginUpdate;
begin
  FUpdating := true;
end;

procedure TLocations.endUpdate;
begin
  FUpdating := false;
  Sort(@locationSort);
end;



end.
