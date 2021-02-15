unit objPainter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Math, ExtCtrls,

  // Fremde
//  uAntiAlias,

  // Eigene Komponenten
  _define, objJimbo, objMap, objShops, objCustomers, objShopTypes,

  funcCommon;

const
  SCALE_WIDTH  = 180;
  SCALE_HEIGHT = 45;
  SCALE_OFFSET = 30;

  NAVI_WIDTH   = 250;
  NAVI_HEIGHT  = 230;
  NAVI_OFFSET  = 30;

type
  TNavigator = class
  private
    FSource: TBitmap;
    FDestination: TCanvas;

    FWidth: integer;
    FHeight: integer;

    FRectWidth: integer;
    FRectHeight: integer;

    FFactor: double;

    FEnabled: boolean;
    FPosition: TPoint;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Paint;

    property Source: TBitmap read FSource write FSource;
    property Destination: TCanvas read FDestination write FDestination;

    property Width: integer read FWidth write FWidth;
    property Height: integer read FHeight write FHeight;

    property RectWidth: integer read FRectWidth write FRectWidth;
    property RectHeight: integer read FRectHeight write FRectHeight;

    property Factor: double read FFactor write FFactor;

    property Enabled: boolean read FEnabled write FEnabled;
    property Position: TPoint read FPosition write FPosition;
  end;


  TPainter = class
  private
    FProject: TJimbo; { Referenz auf TForm.Jimbo }
    FCanvas: TCanvas; { Referenz auf TForm.pbMap.Canvas }
    FMap: TMap; { Referenz auf TForm.Map }
    FBitmap: TBitmap; { Referenz auf Map.Bitmap, *nur* Hintergrund, wird geladen aus JPEGs }
    FBitmapShops: TBitmap; { Map mit Shops, auﬂer aktivem Shop }

    FNavigator: TNavigator;

    FTimer: TTimer;
    FPainted: cardinal;

    // Kartengroesse + Position auf der Karte
    FWidth: integer;
    FHeight: integer;
    FPosition: TPoint;

    // Navigator/Maﬂstab
    FScaleEnabled: Boolean;

    // angezeigter Ausschnitt
    FRectCanvas: TRect; { Ausschnitt auf dem Formular ohne Sidebar, [218,0,800,600] }

    // Verschieben oder Drehen
    FShopMoveID: integer;
    FShopMoveOffsetX, FShopMoveOffsetY: integer;

    FShopHighlightID: integer;
    FShopSelectedID: integer;

    procedure setProject(const Project: TJimbo);
    procedure setMap(const Map: TMap);
    procedure setPosition(Value: TPoint);
    procedure setRectCanvas(Value: TRect);

    procedure updateMapShops;
    procedure paintShop(Relative: Boolean; offsetPoint: TPoint; const ACanvas: TCanvas; Shop: TShop);
    procedure paintScale(const ABitmap: TBitmap);
    function getMidColor(Color1, Color2: TColor; perCent: integer): TColor;

    function getListen: boolean;
    procedure setListen(Value: boolean);

    procedure OnTimer(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure Update;

    procedure beginMove(ShopID: integer; OffsetX, OffsetY: integer);
    procedure beginHighlight(ShopID: integer);

    procedure setSelection(shopID: integer);

    procedure endMove;
    procedure endHighlight;

    procedure Paint; overload;
    procedure Paint(shopID: integer); overload;
    procedure paintNavigator;

    procedure Clear;

    // Eigenschaften
    property Project: TJimbo read FProject write setProject;
    property Canvas: TCanvas read FCanvas write FCanvas;

    property Map: TMap read FMap write setMap;
    //property Listen: boolean read getListen write setListen;
    property Navigator: TNavigator read FNavigator write FNavigator;

    property Width: integer read FWidth write FWidth;
    property Height: integer read FHeight write FHeight;

    property scaleEnabled: Boolean read FScaleEnabled write FScaleEnabled;

    property Position: TPoint read FPosition write setPosition; {link oben}
    property RectCanvas: TRect read FRectCanvas write setRectCanvas;

    property shopMoveID: integer read FShopMoveID;
    property shopHighlightID: integer read FShopHighlightID;
  end;

implementation

{****************** TNavigator ******************}

constructor TNavigator.Create;
begin
  inherited Create;

  FWidth := 0;
  FHeight := 0;

  FRectWidth := 0;
  FRectHeight := 0;

  FEnabled := true;
  FPosition := Point(0,0);
end;

destructor TNavigator.Destroy;
begin
  inherited Destroy;
end;

procedure TNavigator.Paint;
var ARect, ABox: TRect;
    hFac, wFac: double;
    tmpBitmap, boxBmp: TBitmap;
begin
  if not FEnabled then exit;

  ABox := Rect(
    Round(FPosition.X),
    Round(FPosition.Y),
    Floor(FPosition.X+FRectWidth),
    Floor(FPosition.Y+FRectHeight)
  );

  tmpBitmap := TBitmap.Create;
  tmpBitmap.Width := FWidth;
  tmpBitmap.Height := FHeight;

  with tmpBitmap.Canvas do begin
    StretchDraw(Rect(0,0,FWidth,FHeight),FSource);

    boxBmp := TBitmap.Create;
    boxBmp.Width := FRectWidth;
    boxBmp.Height := FRectHeight;

    boxBmp.Canvas.CopyRect(
      Rect(0,0,FRectWidth,FRectHeight),
      tmpBitmap.Canvas,
      Rect(FPosition.X,FPosition.Y,FPosition.X+FRectWidth,FPosition.Y+FRectHeight)
    );

    grayBitmap(tmpBitmap);

    Brush.Style := bsClear;
    Pen.Color := clBlack;
    Pen.Width := 1;

    Draw(FPosition.X,FPosition.Y,boxBmp);
    Rectangle(ABox);
  end;

//  FDestination.Draw(0,0,tmpBitmap);

  FDestination.CopyRect(
    Rect(0,0,tmpBitmap.Width,tmpBitmap.Height),
    tmpBitmap.Canvas,
    Rect(0,0,tmpBitmap.Width,tmpBitmap.Height)
  );

  boxBmp.Free;
  tmpBitmap.Free;
end;

{****************** TPainter ******************}

constructor TPainter.Create;
begin
  inherited Create;

  FBitmapShops := TBitmap.Create;
  FNavigator := TNavigator.Create;
  FTimer := TTimer.Create(nil);

  FTimer.Interval := 300;
  FTimer.OnTimer := OnTimer;
  FTimer.Enabled := false;

  FPainted := GetTickCount;

  Reset;
end;

destructor TPainter.Destroy;
begin
  FTimer.Free;
  FNavigator.Free;
  FBitmapShops.Free;

  inherited Destroy;
end;

procedure TPainter.Reset;
begin
  FNavigator.Enabled := false;
  FScaleEnabled := true;

  FShopMoveID := -1;
  FShopHighlightID := -1;
  FShopSelectedID := -1;
  
  FCanvas := nil;
  FRectCanvas := Rect(0,0,0,0);
end;

procedure TPainter.updateMapShops;
var i: integer;
    aShop: TShop;
begin
  //FCanvas.CopyRect(FRectCanvas,FBitmap.Canvas,FRectMap);
  FBitmapShops.Width := FBitmap.Width;
  FBitmapShops.Height := FBitmap.Height;

  FBitmapShops.Assign(FBitmap);

  for i := 0 to FProject.Shops.Count-1 do begin
    aShop := FProject.Shops[i];

    if not FProject.checkDate(FProject.dateID, AShop.ID) then continue;
    if (FShopMoveID = aShop.ID) or (FShopHighlightID = aShop.ID) or (FShopSelectedID = aShop.ID) then continue;

    paintShop(false,FPosition,FBitmapShops.Canvas,FProject.Shops[i]);
  end;

  // Ausgew‰hten Shop zeichnen
  if (FShopMoveID <> FShopSelectedID) and (FShopSelectedID <> -1) then begin
    aShop := FProject.Shops.byID(FShopSelectedID);
    
    if (aShop is TShop) and FProject.checkDate(FProject.dateID,aShop.ID) then
      paintShop(false,FPosition,FBitmapShops.Canvas,aShop);
  end;

  // Hover Shop zeichnen
 { if FShopHighlightID <> -1 then begin
    aShop := FProject.Shops.byID(FShopHighlightID);
    if aShop is TShop then paintShop(false,FPosition,FBitmapShops.Canvas,aShop);
  end;    }

  //if FScaleEnabled then paintScale(FBitmapShops);
  if FNavigator.Enabled then paintNavigator;;
end;

procedure TPainter.beginMove(ShopID, OffsetX, OffsetY: integer);
begin
  FShopMoveID := ShopID;
  FShopMoveOffsetX := OffsetX;
  FShopMoveOffsetY := OffsetY;

  updateMapShops;
end;

procedure TPainter.endMove;
var Shop: TShop;
begin
  if FShopMoveID = -1 then exit;

  Shop := FProject.Shops.byID(FShopMoveID);
  if (Shop is TShop) then Shop.setPosition(Shop.X+FShopMoveOffsetX,Shop.Y+FShopMoveOffsetY);

  FShopMoveID := -1;
  FShopMoveOffsetX := 0;
  FShopMoveOffsetY := 0;

  updateMapShops;
end;

procedure TPainter.beginHighlight(ShopID: integer);
begin
  FShopHighlightID := ShopID;
  updateMapShops;
end;

procedure TPainter.setSelection(shopID: integer);
begin
  if (shopID < 0) then FShopSelectedID := -1
  else FShopSelectedID := shopID;
end;                              

procedure TPainter.endHighlight;
begin
  FShopHighlightID := -1;
  updateMapShops;
end;

procedure TPainter.Update;
begin
  updateMapShops;
end;

procedure TPainter.setProject(const Project: TJimbo);
begin
  if not (Project is TJimbo) then raise Exception.Create('Kein Jimbo Objekt!');
  FProject := Project;
end;

procedure TPainter.setMap(const Map: TMap);
begin
  FMap := Map;
  FBitmap := Map.Bitmap;
end;

procedure TPainter.setPosition(Value: TPoint);
begin
  FPosition := Value;

  // Navigator
  FNavigator.Factor := FNavigator.Width / FWidth;

  FNavigator.RectWidth := Round((FRectCanvas.Right - FRectCanvas.Left) * FNavigator.Factor);
  FNavigator.RectHeight := Round((FRectCanvas.Bottom - FRectCanvas.Top) * FNavigator.Factor);

  FNavigator.Position := Point(
    Round(FPosition.X / FWidth * FNavigator.Width),
    Round(FPosition.Y / FHeight * FNavigator.Height)
  );

  FPainted := GetTickCount;
end;

procedure TPainter.setRectCanvas(Value: TRect);
begin
  FRectCanvas := Value;

end;

function TPainter.getMidColor(Color1, Color2: TColor; perCent: integer): TColor;
begin
  Result := TColor( RGB(
    ( GetRValue(ColorToRGB(Color1))*perCent + GetRValue(ColorToRGB(Color2))*(100-perCent) ) div 100,
    ( GetGValue(ColorToRGB(Color1))*perCent + GetGValue(ColorToRGB(Color2))*(100-perCent) ) div 100,
    ( GetBValue(ColorToRGB(Color1))*perCent + GetBValue(ColorToRGB(Color2))*(100-perCent) ) div 100
  ));
end;

procedure TPainter.Paint;
var ARect: TRect;
begin
  ARect := Rect(0,0,FBitmap.Width,FBitmap.Height);
  FCanvas.CopyRect(FRectCanvas,FBitmapShops.Canvas,ARect);

  if FNavigator.Enabled then paintNavigator;

  FPainted := GetTickCount;
end;

procedure TPainter.Paint(shopID: integer);
var ARect, ARectRelative: TRect;
    tmpBitmap: TBitmap;
    AShop: TShop;
begin
    // FEHLERBEHANDLUNG
  {if (FShopMoveID >= 0) then AShop := FProject.Shops.byID(FShopMoveID)
  else AShop := FProject.Shops.byID(FShopHighlightID);}
  AShop := FProject.Shops.byID(shopID);

  ARectRelative := AShop.getRect(true,SHOP_PAINTER_OFFSET);
  ARect := AShop.getRect(false,SHOP_PAINTER_OFFSET);

  ARect := Rect(
    ARect.Left - FPosition.X,
    ARect.Top - FPosition.Y,
    ARect.Right - FPosition.X,
    ARect.Bottom - FPosition.Y
  );

  // Temp. Bild erzeugen (Ausschnitt des Shops + Offset), Shop zeichnen
  // und auf Haup-Canvas zeichnen
  tmpBitmap := TBitmap.Create;
  tmpBitmap.Width := ARect.Right - ARect.Left;
  tmpBitmap.Height := ARect.Bottom - ARect.Top;
  tmpBitmap.Canvas.CopyRect(ARectRelative,FBitmapShops.Canvas,ARect);

  if FShopMoveID = AShop.ID then begin
   paintShop(true,Point(-FShopMoveOffsetX,-FShopMoveOffsetY),tmpBitmap.Canvas,AShop)
   end
  else paintShop(true,Point(0,0),tmpBitmap.Canvas,AShop);

  ARect := Rect(
    ARect.Left + FRectCanvas.Left,
    ARect.Top + FRectCanvas.Top,
    ARect.Right + FRectCanvas.Left,
    ARect.Bottom + FRectCanvas.Top
  );

  FCanvas.CopyRect(ARect,tmpBitmap.Canvas,ARectRelative);

  tmpBitmap.Free;
  //FPainted := GetTickCount;
end;

procedure TPainter.paintNavigator;
begin
  FNavigator.Paint;
end;

procedure TPainter.Clear;
begin
  FCanvas.Brush.Color := clBtnFace;
  FCanvas.Pen.Color := clBtnFace;
  FCanvas.Rectangle(FRectCanvas);
end;

procedure TPainter.paintShop(Relative: Boolean; offsetPoint: TPoint; const ACanvas: TCanvas; Shop: TShop);
var i, iX, iY: integer;
    Caption: string;
    RectPoints: TFourPoints;
    shopType: TShopType;
    Customer: TCustomer;

    // ANTI
    aRect: TRect;
    aPoints: TFourPoints;
    org_bmp, big_bmp, out_bmp: TBitmap;
begin
//  if ACanvas.Brush.Style <> bsSolid then ACanvas.Brush.Style := bsDiagCross;

  ACanvas.Pen.Width := 1;

  Customer := FProject.Customers.byID(Shop.customerID);

  // Farben/Text festlegen
  if (FShopHighlightID = Shop.ID) or (FShopMoveID = Shop.ID) or (FShopSelectedID = Shop.ID) then begin
    if not (Customer is TCustomer) then Caption := '(kein Kunde)'
    else Caption := Customer.Lastname;

    ACanvas.Pen.Color := COLOR_SHOP_SELECTION_BORDER;
    ACanvas.Brush.Color := getMidColor(COLOR_SHOP_SELECTION,clWhite,20);
  end

  // Kein Besitzer (Rot!)
  else if not (Customer is TCustomer) then begin
    Caption := '?';
    ACanvas.Pen.Color := COLOR_SHOP_NOCUSTOMER;
    ACanvas.Brush.Color := getMidColor(COLOR_SHOP_NOCUSTOMER,clWhite,20);
  end

  // Normal zeichnen
  else begin
    Caption := Customer.Lastname;
    shopType := FProject.shopTypes.byID(Shop.typeID);
    if not shopType.Visible then exit;

    if not (shopType is TShopType) then begin
      ACanvas.Pen.Color := COLOR_SHOP_NOCUSTOMER;
      ACanvas.Brush.Color := getMidColor(COLOR_SHOP_NOCUSTOMER,clWhite,20);
    end else begin
      ACanvas.Pen.Color := shopType.borderColor;
      ACanvas.Brush.Color := shopType.Color;
    end;
  end;

  // Rechteck zeichnen
  RectPoints := Shop.getPoints(Relative,SHOP_PAINTER_OFFSET);
  if (not Relative) or (FShopMoveID = Shop.ID) then for i := 0 to High(RectPoints) do RectPoints[i] := Point(RectPoints[i].X-offsetPoint.X, RectPoints[i].Y-offsetPoint.Y);

  ACanvas.Polygon(RectPoints);

  // Anfasser zeichnen
  if (FShopHighlightID = Shop.ID) or (FShopMoveID = Shop.ID {Shop.isHighlighted or Shop.isSelected}) then begin
    for i := 0 to Length(RectPoints)-1 do begin
      //ACanvas.Brush.Style := bsClear;
      ACanvas.Brush.Color := COLOR_SHOP_SELECTION_BORDER;
      ACanvas.Pen.Color := COLOR_SHOP_SELECTION_BORDER;
      ACanvas.Ellipse(
        RectPoints[i].X-ROTATE_POINT_RADIUS, RectPoints[i].Y-ROTATE_POINT_RADIUS,
        RectPoints[i].X+ROTATE_POINT_RADIUS, RectPoints[i].Y+ROTATE_POINT_RADIUS
      );
    end;
  end;

  // Titeltext zeichnen
  Caption := IntToStr(Shop.ID);
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Name := 'Verdana';
  ACanvas.Font.Size := 7;


  if Relative then begin
    iX := SHOP_PAINTER_OFFSET + (MaxP(true,RectPoints) - MinP(true,RectPoints)) div 2 - Canvas.TextWidth(Caption) div 2 - offsetPoint.X;
    iY := SHOP_PAINTER_OFFSET + (MaxP(false,RectPoints) - MinP(false,RectPoints)) div 2 - Canvas.TextHeight(Caption) div 2 - offsetPoint.Y;
  end

  else begin
    iX := Shop.X - Canvas.TextWidth(Caption) div 2 - offsetPoint.X;
    iY := Shop.Y - Canvas.TextHeight(Caption) div 2 - offsetPoint.Y;
  end;

  ACanvas.TextOut(iX,iY,Caption);
end;

procedure TPainter.paintScale(const ABitmap: TBitmap);
var ARect: TRect;
begin
  if not FScaleEnabled then exit;

  ARect := Rect(
    SCALE_OFFSET,
    ABitmap.Height - SCALE_OFFSET - SCALE_HEIGHT,
    SCALE_OFFSET + SCALE_WIDTH,
    ABitmap.Height - SCALE_OFFSET
  );

  with ABitmap.Canvas do begin
    Brush.Color := clCream;
    Pen.Color := clBlack;
    Rectangle(ARect);

    TextOut(ARect.Left+4,ARect.Top+4,'Maﬂstab');
  end;
end;

procedure TPainter.OnTimer(Sender: TObject);
begin
  if FPainted < Map.Updated then exit;

  updateMapShops;
  Paint;
end;

function TPainter.getListen: boolean;
begin
  Result := FTimer.Enabled;
end;

procedure TPainter.setListen(Value: boolean);
begin
  FTimer.Enabled := Value;
end;

end.
