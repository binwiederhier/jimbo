{
This component mimics the WinXP explorer left-side bar (when not showing folders)
it supports skins but it doesn't load skin used by win XP. You have to specify a
bitmap that respect a given format (see examples).
The 3 basic skins of winXp are included in the demo prog.
This component needs run-time creation (That's why it's still a beta version).
See attached demo for an example.

This component doesn't require an installation because design-time creation/
edition isn't possible. You just have to put Exbar.pas and ExBar.res in a folder
that is included in the Library path of the environment options.

 *********************************************************************
 **                                                                 **
 ** http://maxxdelphisite.free.fr (in english)                      **
 **                                                                 **
 **   if you use this component, please put a link on my website    **
 ** in the about box or something like this.                        **
 **   if you have a good idea of improvement, please                **
 ** let me know (http://maxxdelphisite.free.fr/mail/mail.htm).      **
 **   if you improve this component, please send me a copy          **
 ** so everybody can use it                                         **
 **                                                                 **
 *********************************************************************

 History :
 ---------
 31-05-2005 : version 0.5 ra
               - a "visible" property has been added for each item
 16-02-2005 : version 0.4 ra
               - a new TExCheckBox written by Dmitry Chaplinsky (chaplinsky@gtlab.net)
 10-08-2004 : new branch - version 0.3 ra
               - right-to-left text alignment support made by amos szust (http://www.emailaya.2ya.com - amos_sz@zahav.net.il)
 05-08-2004 : version 0.3 beta
               - wrote a TExProgressBar
 11-02-2003 : version 0.2 beta
               - i wrote my own alphablending functions and i'm now using
                 TBitmap and GDI functions.
               - using TFlickerFreePaintBox.
 20-01-2003 : version 0.1 beta - first published version
               - using Graphics32 (for alpha blending function)
 *******************************************************************}

unit objExbar2;

interface

uses
  Windows,
  Classes,
  Contnrs,
  Controls,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  Math,
  Messages,
  SysUtils,
  Types,
  JPEG;

type
  {flickerfree paint box OnPaint event type}
  TFFPaintEvent = procedure(Sender: TObject; Buffer: TBitmap) of object;
  TCheckBoxState = (cbUnchecked, cbChecked, cbGrayed);

  {a flickerfree paint box}
  TFlickerFreePaintBox = class(TCustomControl)
  private
    FOnFFPaint: TFFPaintEvent;
    FBuffer: TBitmap; //buffered bitmap (filled when Repaint method is called)
    FDrawing: Boolean;
    FNeedRepaint: Boolean;
    FDeformHorz: Extended;
    FDeformVert: Extended;
    FDeformAlpha: Extended;
    FApplyDeform: Boolean;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Repaint; override;
    procedure ApplyDeform(Horz, Vert, Alpha: Extended);
    procedure NoDeform;
    property OnPaint: TFFPaintEvent read FOnFFPaint write FOnFFPaint;
  end;

  TExGroup = class;

  {an item - generic class for all items}
  TExCustomItem = class(TObject)
  private
    FVisible: boolean;
    FOwner: TExGroup;
    procedure Draw(Bitmap: TBitmap; var X, Y, Width: Integer); virtual;
    procedure Measure(Bitmap: TBitmap; var X, Y, Width: Integer); virtual;
  public
    constructor Create(AOwner: TExGroup); overload; virtual;
    property Owner: TExGroup read FOwner write FOwner;
    property Visible: boolean read FVisible write FVisible;
  end;

  THotStyle = set of (hsUnderline, hsBold, hsItalic, hsStrikeOut);
  TIconSource = (isImageList, isBitmap, isNone);

  {a menu item - clickable}
  TExMenuItem = class(TExCustomItem)
  private
    // v2
    FCaption: string;
    FFontStyle: TFontStyles;
    FHint: string;
    FIcon: TBitmap;
    FIconIndex: Integer;
    FId: Integer; //Id used in clickevent
    FClipRect: TRect; //rect in which fit the icon + the caption
    procedure Draw(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure Measure(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure SetCaption(Value: string);
    procedure SetFontStyle(Value: TFontStyles);
    procedure SetIcon(Value: TBitmap);
  public
    constructor Create(AOwner: TExGroup); override;
    constructor Create(AOwner: TExGroup; ACaption, AHint: string; AId: Integer; AIconIndex: Integer); overload;
    constructor Create(AOwner: TExGroup; ACaption, AHint: string; AId: Integer; AIconIndex: Integer; AFontStyle: TFontStyles); overload;
    constructor Create(AOwner: TExGroup; ACaption, AHint: string; AId: Integer; AIcon: TBitmap); overload;
    destructor Destroy; override;
    property Caption: string read FCaption write SetCaption;
    property FontStyle: TFontStyles read FFontStyle write SetFontStyle;
    property Hint: string read FHint write FHint;
    property Icon: TBitmap read FIcon write SetIcon;
  end;

  TExCheckBox = class(TExMenuItem)
  private
    FChecked: Boolean;
    FEnabled: boolean;
    FFlat: boolean;
    FExCheckHeight, FExCheckWidth: Integer;
    procedure Draw(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure Measure(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure SetEnabled(Value: boolean);
    procedure SetChecked(Value: boolean);
    procedure SetFlat(Value: boolean);
    procedure DrawCheck(Canvas: TCanvas; R: TRect; AState: TCheckBoxState; AEnabled: Boolean);
  public
    constructor Create(AOwner: TExGroup); override;
    constructor Create(AOwner: TExGroup; ACaption: string; AID: Integer; AHint: string; AChecked, AEnabled, AFlat: boolean); overload;
    property Checked: boolean read FChecked write SetChecked;
    property Enabled: boolean read FEnabled write SetEnabled;
    property Flat: boolean read FFlat write SetFlat;
  end;

  {a picture resized to fit in Bar}
  TExBmp = class(TExCustomItem)
  private
    FImage: TBitmap;
    procedure Draw(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure Measure(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure SetImage(Value: TBitmap);
  public
    constructor Create(AOwner: TExGroup); override;
    constructor Create(AOwner: TExGroup; AImage: TBitmap); overload;
    constructor Create(AOwner: TExGroup; AImageFile: TFileName); overload;
    destructor Destroy; override;
    property Image: TBitmap read FImage write SetImage;
  end;

  {a line of text}
  TExLine = class(TExCustomItem)
  private
    FCaption: string;
    FFontColor: TColor;
    FFontStyle: TFontStyles;
    FWordWrap: Boolean;
    procedure Draw(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure Measure(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure SetCaption(Value: string);
    procedure SetFontColor(Value: TColor);
    procedure SetFontStyle(Value: TFontStyles);
    procedure SetWordWrap(Value: Boolean);
  public
    constructor Create(AOwner: TExGroup); override;
    constructor Create(AOwner: TExGroup; ACaption: string; AFontColor: TColor;
      AFontStyle: TFontStyles; AWordWrap: Boolean); overload;
    property Caption: string read FCaption write SetCaption;
    property FontColor: TColor read FFontColor write SetFontColor;
    property FontStyle: TFontStyles read FFontStyle write SetFontStyle;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
  end;

  {a progress bar}
  TExProgressBar = class(TExCustomItem)
  private
    FMin, FMax, FPosition: Integer;
    FHeight: Integer;
    FBorderColor: TColor;
    FFillColor: TColor;

    procedure Draw(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure Measure(Bitmap: TBitmap; var X, Y, Width: Integer); override;
    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure SetPosition(Value: Integer);
  public
    constructor Create(AOwner: TExGroup); override;
    constructor Create(AOwner: TExGroup; AMin, AMax, APosition, AHeight: Integer; ABorderColor, AFillCOlor: TColor); overload;
    property Min: Integer read FMin write SetMin;
    property Max: Integer read FMax write SetMax;
    property Position: Integer read FPosition write SetPosition;
  end;

  TExBar = class;

  TGroupState = (gsOpen, gsClosed, gsOpening, gsClosing);

  {a group of items - clickable}
  TExGroup = class(TObject)
  private
    FAnimStep: Integer;
    FNbSteps: Integer;
    FDestHeight: Integer;
    FShownHeight: Integer;

    FBgImage: TBitmap;
    FExBar: TExBar;
    FGroupIconIndex: Integer;
    FItems: TObjectList;
    FSpecialGroup: Boolean;
    FState: TGroupState;
    FTimer: TTimer;
    FTitle: string;
    FTitleRect: TRect;
    FBodyRect: TRect;

    FHeight: Integer;
    FWidth: Integer;

    procedure Draw(Bitmap: TBitmap; var X, Y: Integer);
    procedure Measure(Bitmap: TBitmap; var X, Y: Integer); overload;
    procedure Measure; overload;
    procedure SetBgImage(Value: TBitmap);
    procedure SetGroupIconIndex(Value: Integer);
    procedure SetSpecialGroup(Value: Boolean);
    procedure SetTitle(Value: string);
    procedure Timer(Sender: TObject);
  public
    constructor Create(AOwner: TExBar);
    destructor Destroy; override;
    procedure AddMenuItem(ACaption: string; AHint: string = ''; AId: Integer = -1; AIconIndex: Integer = -1; AFontStyle: TFontStyles = []); overload;
    procedure AddMenuItem(ACaption: string; AHint: string = ''; AId: Integer = -1; AIconBmp: TBitmap = nil); overload;
    procedure AddMenuItem(ACaption: string; AHint: string; AId: Integer; ABmpFile: TFileName; AWidth, AHeight: Integer); overload;
    procedure AddCheckBox(ACaption: string; AHint: string = ''; AId: Integer = -1; AChecked: boolean = false; AEnabled: Boolean = true; AFlat: boolean = false); overload;
    procedure AddBmp(AImage: TBitmap); overload;
    procedure AddBmp(AImageFile: TFileName); overload;
    procedure AddLine(ACaption: string; AFontColor: TColor = clBtnText; AFontStyle: TFontStyles = []; AWordWrap: Boolean = False);
    procedure AddProgressBar(AMin, AMax, APosition, AHeight: Integer; ABorderColor, AFillCOlor: TColor);
    procedure OpenClose;
    property BgImage: TBitmap read FBgImage write SetBgImage;
    property GroupIconIndex: Integer read FGroupIconIndex write SetGroupIconIndex;
    property Items: TObjectList read FItems;
    property SpecialGroup: Boolean read FSpecialGroup write SetSpecialGroup;
    property State: TGroupState read FState write FState;
    property Title: string read FTitle write SetTitle;
  end;

  {a list of groups}
  TExGroups = class(TObjectList)
  private
    FOwner: TExBar;
    function GetItem(Index: Integer): TExGroup;
    procedure SetItem(Index: Integer; Value: TExGroup);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    function Add(ATitle: string; ASpecialGroup: Boolean = False): TExGroup;
    property Items[Index: Integer]: TExGroup read GetItem write SetItem; default;
  end;

  TMenuItemClickEvent = procedure(Sender: TObject; Id: Integer) of object;

  {a complete bar}
  TExBar = class(TScrollingWinControl)
  private
    FAnimStep: Integer;

    FUpdating: Boolean;

    FBgColor: TColor;
    FBorderColor: TColor;
    FGroupBgColor: TColor;
    FSpecialTextColor: TColor;
    FSpecialTextHotColor: TColor;
    FTextColor: TColor;
    FTextHotColor: TColor;

    FAnimate: Boolean;
    FExGroups: TExGroups;
    FGroupIcons: TImageList;
    FHotArea: TObject;
    FItemIcons: TImageList;
    FNeedResize: Boolean;
    FOnClick: TMenuItemClickEvent;
    FPaintBox: TFlickerFreePaintBox;
    FSkin: TBitmap;
    FTimer: TTimer;

    FOldWidth: Integer;
    FGroupsHeight: Integer;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    function GetHotArea(X, Y: Integer): TObject;
    procedure PaintBuffer(Sender: TObject; Buffer: TBitmap);
    procedure PbMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PbMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetGroupIcons(Value: TImageList);
    procedure Measure;
    procedure SetItemIcons(Value: TImageList);
    procedure Timer(Sender: TObject);
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Repaint; override;
    procedure SetSkin(ASkin: TBitmap);
    procedure ShowAnimate;
    property ExGroups: TExGroups read FExGroups;
  published
    property Animate: Boolean read FAnimate write FAnimate;
    property GroupIcons: TImageList read FGroupIcons write SetGroupIcons;
    property ItemIcons: TImageList read FItemIcons write SetItemIcons;
    property OnMenuItemClick: TMenuItemClickEvent read FOnClick write FOnClick;

    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
  end;

const
  crHand = 1;

implementation
var
  FCheckWidth, FCheckHeight: Integer;

procedure GetCheckSize;
begin
  with TBitmap.Create do
  try
    Handle := LoadBitmap(0, PChar(32759));
    FCheckWidth := Width div 4;
    FCheckHeight := Height div 3;
  finally
    Free;
  end;
end;

{$R ExBar.res}

var
  ArUp: TBitmap;
  ArDn: TBitmap;

const
  DEFAULT_WIDTH = 218;
  DEFAULT_HEIGHT = 300;
  Y_OFFSET = 8;
  ICON_SIDE = 32;
  //  SMALL_ICON_SIDE = 16;
  X_OFFSET = 12;
  ICON_OFFSET = 4;
  UNKNOWN_VALUE = -1;
  UNKNOWN_RECT: TRect = (Left: - 1; Top: - 1; Right: - 1; Bottom: - 1);
  ANIM_SPEED = 30; //timer.interval
  ANIM_COUNT = 10;
  SCROLLBAR_WIDTH = 17;

  SKIN_HEIGHT = 23;
  SKIN_LEFT_PART_WIDTH = 5;
  SKIN_RIGHT_PART_WIDTH = 25;
  //  BG_IMG_SIDE = 60;
  //  BG_IMG_TOP = 55;
  SKIN_TITLE_LEFT_RECT: TRect = (Left: 7; Top: 1; Right: 12; Bottom: 24);
  SKIN_TITLE_CENTER_RECT: TRect = (Left: 13; Top: 1; Right: 163; Bottom: 24);
  SKIN_TITLE_RIGHT_UP_OFF_RECT: TRect = (Left: 164; Top: 1; Right: 189; Bottom: 24);
  SKIN_TITLE_RIGHT_UP_ON_RECT: TRect = (Left: 190; Top: 1; Right: 215; Bottom: 24);
  SKIN_TITLE_RIGHT_DN_OFF_RECT: TRect = (Left: 216; Top: 1; Right: 241; Bottom: 24);
  SKIN_TITLE_RIGHT_DN_ON_RECT: TRect = (Left: 242; Top: 1; Right: 267; Bottom: 24);
  SKIN_SPEC_TITLE_LEFT_RECT: TRect = (Left: 7; Top: 25; Right: 12; Bottom: 48);
  SKIN_SPEC_TITLE_CENTER_RECT: TRect = (Left: 13; Top: 25; Right: 163; Bottom: 48);
  SKIN_SPEC_TITLE_RIGHT_UP_OFF_RECT: TRect = (Left: 164; Top: 25; Right: 189; Bottom: 48);
  SKIN_SPEC_TITLE_RIGHT_UP_ON_RECT: TRect = (Left: 190; Top: 25; Right: 215; Bottom: 48);
  SKIN_SPEC_TITLE_RIGHT_DN_OFF_RECT: TRect = (Left: 216; Top: 25; Right: 241; Bottom: 48);
  SKIN_SPEC_TITLE_RIGHT_DN_ON_RECT: TRect = (Left: 242; Top: 25; Right: 267; Bottom: 48);

  {------------------------------------------------
  -------------------------------------------------
  procedure and functions
  -------------------------------------------------
  ------------------------------------------------}

{-----------------------------------------------
Select a color}

function IfThenColor(ATest: Boolean; const ATrue, AFalse: TColor): TColor;
begin
  if ATest then
    Result := ATrue
  else
    Result := AFalse;
end;

{-----------------------------------------------
Select a bitmap}

function IfThenBitmap(ATest: Boolean; const ATrue, AFalse: TBitmap): TBitmap;
begin
  if ATest then
    Result := ATrue
  else
    Result := AFalse;
end;

{-----------------------------------------------
Select a FontStyle}

function IfThenFs(ATest: Boolean; const ATrue, AFalse: TFontStyles): TFontStyles;
begin
  if ATest then
    Result := ATrue
  else
    Result := AFalse;
end;

{-----------------------------------------------
draw a masked bitmap Src on a bitmap Dest}

procedure DrawMask(Dest: TBitmap; X, Y: Integer; Src: TBitmap);
var
  I, J: Integer;
  X2, Y2: Integer;
  PSrc {, PDest}: PByteArray;
  //  R, G, B: Byte;
begin
  if (Y >= Dest.Height) or (X >= Dest.Width) then
    Exit;
  Y2 := Min(Src.Height, Dest.Height - Y) - 1;
  X2 := Min(Src.Width, Dest.Width - X) - 1;
  {R := GetRValue(Dest.Canvas.Font.Color);
  G := GetGValue(Dest.Canvas.Font.Color);
  B := GetBValue(Dest.Canvas.Font.Color);}
  for J := 0 to Y2 do
  begin
    PSrc := Src.ScanLine[J];
    //PDest := Dest.ScanLine[J + Y];
    for I := 0 to X2 do
      if PSrc[I] = 0 then
      begin
        Dest.Canvas.Pixels[X + I, Y + J] := Dest.Canvas.Brush.Color;
        //PDest[3 * (I + X)] := B;
        //PDest[3 * (I + X) + 1] := G;
        //PDest[3 * (I + X) + 2] := R;
      end;
  end;
end;

{-----------------------------------------------
draw part of a bitmap Src on a bitmap Dest with Alphablending}

procedure DrawAlpha(Dest: TBitmap; BgColor: TColor; X, Y: Integer; SrcRect: TRect; Src: TBitmap; Alpha: Extended = 1);
var
  I, J: Integer;
  RTmp, OutRect: TRect;
  PSrc, PDest: PByteArray;
  R, G, B: Byte;
begin
  if Alpha >= 1 then //if no alpha blending
    Dest.Canvas.CopyRect(Rect(X, Y, X + SrcRect.Right - SrcRect.Left, Y + SrcRect.Bottom - SrcRect.Top), Src.Canvas, SrcRect)
  else
  begin
    if Src.PixelFormat <> pf24bit then
      Src.PixelFormat := pf24bit;
    if Dest.PixelFormat <> pf24bit then
      Dest.PixelFormat := pf24bit;
    RTmp := Rect(Max(0, X), Max(0, Y), Min(Dest.Width - 1, X + SrcRect.Right - SrcRect.Left - 1), Min(Dest.Height - 1, Y + SrcRect.Bottom - SrcRect.Top - 1));
    if IntersectRect(OutRect, RTmp, Dest.Canvas.ClipRect) then
    begin
      R := GetRValue(BgColor);
      G := GetGValue(BgColor);
      B := GetBValue(BgColor);
      for J := OutRect.Top to OutRect.Bottom do
      begin
        PSrc := Src.ScanLine[J - Y + SrcRect.Top];
        PDest := Dest.ScanLine[J];
        for I := OutRect.Left to OutRect.Right do
        begin //blending
          PDest[I * 3] := Round(((1 - Alpha) * B + Alpha * PSrc[(I - X + SrcRect.Left) * 3]));
          PDest[I * 3 + 1] := Round(((1 - Alpha) * G + Alpha * PSrc[(I - X + SrcRect.Left) * 3 + 1]));
          PDest[I * 3 + 2] := Round(((1 - Alpha) * R + Alpha * PSrc[(I - X + SrcRect.Left) * 3 + 2]));
        end;
      end;
    end;
  end;
end;

{-----------------------------------------------
Draw a blended Rect using the brush color}

procedure BlendFillRect(Dest: TBitmap; ARect: TRect; Alpha: Extended = 1);
var
  I, J: Integer;
  OutRect: TRect;
  PDest: PByteArray;
  R, G, B: Byte;
begin
  if Alpha >= 1 then //if no alpha blending
    Dest.Canvas.FillRect(ARect)
  else if Alpha > 0 then
  begin
    if Dest.PixelFormat <> pf24bit then
      Dest.PixelFormat := pf24bit;
    if IntersectRect(OutRect, ARect, Dest.Canvas.ClipRect) then
    begin
      R := GetRValue(Dest.Canvas.Brush.Color);
      G := GetGValue(Dest.Canvas.Brush.Color);
      B := GetBValue(Dest.Canvas.Brush.Color);
      for J := OutRect.Top to OutRect.Bottom - 1 do
      begin
        PDest := Dest.ScanLine[J];
        for I := OutRect.Left to OutRect.Right - 1 do
        begin //blending
          PDest[I * 3] := Round(((1 - Alpha) * PDest[I * 3] + Alpha * B));
          PDest[I * 3 + 1] := Round(((1 - Alpha) * PDest[I * 3 + 1] + Alpha * G));
          PDest[I * 3 + 2] := Round(((1 - Alpha) * PDest[I * 3 + 2] + Alpha * R));
        end;
      end;
    end;
  end;
end;

{-----------------------------------------------
draw group head (skin support)}

procedure DrawSkinedHead(Bitmap, Skin: TBitmap; X, Y, Width: Integer; SpecialGroup, Closed, MouseOver: Boolean);
begin
  SetStretchBltMode(Bitmap.Canvas.Handle, COLORONCOLOR);
  if SpecialGroup then
  begin
    BitBlt(Bitmap.Canvas.Handle, X, Y + ICON_SIDE - SKIN_HEIGHT, SKIN_LEFT_PART_WIDTH, SKIN_HEIGHT, Skin.Canvas.Handle, SKIN_SPEC_TITLE_LEFT_RECT.Left, SKIN_SPEC_TITLE_LEFT_RECT.Top, SRCCOPY);
    StretchBlt(Bitmap.Canvas.Handle, X + SKIN_LEFT_PART_WIDTH, Y + ICON_SIDE - SKIN_HEIGHT, Width - SKIN_LEFT_PART_WIDTH - SKIN_RIGHT_PART_WIDTH,
      SKIN_HEIGHT, Skin.Canvas.Handle, SKIN_SPEC_TITLE_CENTER_RECT.Left, SKIN_SPEC_TITLE_CENTER_RECT.Top,
      SKIN_SPEC_TITLE_CENTER_RECT.Right - SKIN_SPEC_TITLE_CENTER_RECT.Left, SKIN_SPEC_TITLE_CENTER_RECT.Bottom - SKIN_SPEC_TITLE_CENTER_RECT.Top, SRCCOPY);
    BitBlt(Bitmap.Canvas.Handle, X + Width - SKIN_RIGHT_PART_WIDTH, Y + ICON_SIDE - SKIN_HEIGHT, SKIN_RIGHT_PART_WIDTH, SKIN_HEIGHT, Skin.Canvas.Handle,
      IfThen(Closed, IfThen(MouseOver, SKIN_SPEC_TITLE_RIGHT_DN_ON_RECT.Left, SKIN_SPEC_TITLE_RIGHT_DN_OFF_RECT.Left), IfThen(MouseOver, SKIN_SPEC_TITLE_RIGHT_UP_ON_RECT.Left, SKIN_SPEC_TITLE_RIGHT_UP_OFF_RECT.Left)),
      IfThen(Closed, IfThen(MouseOver, SKIN_SPEC_TITLE_RIGHT_DN_ON_RECT.Top, SKIN_SPEC_TITLE_RIGHT_DN_OFF_RECT.Top), IfThen(MouseOver, SKIN_SPEC_TITLE_RIGHT_UP_ON_RECT.Top, SKIN_SPEC_TITLE_RIGHT_UP_OFF_RECT.Top)), SRCCOPY);
  end
  else
  begin
    BitBlt(Bitmap.Canvas.Handle, X, Y + ICON_SIDE - SKIN_HEIGHT, SKIN_LEFT_PART_WIDTH, SKIN_HEIGHT, Skin.Canvas.Handle, SKIN_TITLE_LEFT_RECT.Left, SKIN_TITLE_LEFT_RECT.Top, SRCCOPY);
    StretchBlt(Bitmap.Canvas.Handle, X + SKIN_LEFT_PART_WIDTH, Y + ICON_SIDE - SKIN_HEIGHT, Width - SKIN_LEFT_PART_WIDTH - SKIN_RIGHT_PART_WIDTH,
      SKIN_HEIGHT, Skin.Canvas.Handle, SKIN_TITLE_CENTER_RECT.Left, SKIN_TITLE_CENTER_RECT.Top,
      SKIN_TITLE_CENTER_RECT.Right - SKIN_TITLE_CENTER_RECT.Left, SKIN_TITLE_CENTER_RECT.Bottom - SKIN_TITLE_CENTER_RECT.Top, SRCCOPY);
    BitBlt(Bitmap.Canvas.Handle, X + Width - SKIN_RIGHT_PART_WIDTH, Y + ICON_SIDE - SKIN_HEIGHT, SKIN_RIGHT_PART_WIDTH, SKIN_HEIGHT, Skin.Canvas.Handle,
      IfThen(Closed, IfThen(MouseOver, SKIN_TITLE_RIGHT_DN_ON_RECT.Left, SKIN_TITLE_RIGHT_DN_OFF_RECT.Left), IfThen(MouseOver, SKIN_TITLE_RIGHT_UP_ON_RECT.Left, SKIN_TITLE_RIGHT_UP_OFF_RECT.Left)),
      IfThen(Closed, IfThen(MouseOver, SKIN_TITLE_RIGHT_DN_ON_RECT.Top, SKIN_TITLE_RIGHT_DN_OFF_RECT.Top), IfThen(MouseOver, SKIN_TITLE_RIGHT_UP_ON_RECT.Top, SKIN_TITLE_RIGHT_UP_OFF_RECT.Top)), SRCCOPY);
  end;
end;

{-----------------------------------------------
Draw group head (no skin)}

procedure DrawHead(Bitmap: TBitmap; X, Y, Width: Integer; SpecialGroup, Closed: Boolean; TextColor: TColor);
begin
  with Bitmap.Canvas do
  begin
    Brush.Color := IfThen(SpecialGroup, clActiveCaption, clBtnFace);
    FillRect(Rect(X, Y + ICON_SIDE - SKIN_HEIGHT, X + Width, Y + ICON_SIDE));
    Brush.Color := TextColor;
    DrawMask(Bitmap, Width - X_OFFSET, Y + 2 * Y_OFFSET, IfThenBitmap(Closed, ArDn, ArUp))
  end;
end;

{-----------------------------------------------
resize a bitmap}

procedure ResizeBmp(var Src, Dst: TBitmap);
begin
  SetStretchBltMode(Dst.Canvas.Handle, HALFTONE);
  Dst.Canvas.CopyRect(Dst.Canvas.ClipRect, Src.Canvas, Src.Canvas.ClipRect);
end;

{-----------------------------------------------
nb of steps to change height from H1 to H2}

function CalcNbSteps(H1, H2, Incr: Integer): Integer;
var
  NbSteps: Integer;
  Buf: Integer;
begin
  NbSteps := 1;
  if H1 > H2 then
  begin
    Buf := H1;
    H1 := H2;
    H2 := Buf;
  end;
  while H1 < H2 do
  begin
    Inc(H1, NbSteps);
    Inc(NbSteps, Incr);
  end;
  Result := NbSteps;
end;

{-----------------------------------------------
parse a line to fit in a specified width}

function Parse(Canvas: TCanvas; var Line: string; MaxWidth: Integer): string;
var
  I: Integer;
  Word: string;
  Stop: Boolean;
begin
  Result := '';
  Stop := False;
  while not Stop and (Line <> '') do
  begin
    I := 1;
    while (I <= Length(Line)) and (Line[I] <> ' ') do
      Inc(I);
    Word := Copy(Line, 1, I);
    if (Canvas.TextWidth(Result + Word) < MaxWidth) then
    begin
      Line := Copy(Line, I + 1, Length(Line));
      Result := Result + Word;
    end
    else
    begin
      if Result = '' then
      begin
        Line := Copy(Line, I + 1, Length(Line));
        repeat
          Delete(Word, Length(Word), 1);
        until (Canvas.TextWidth(Word + '...') < MaxWidth) or (Length(Word) < 2);
        Result := Word + '...';
      end;
      Stop := True;
    end;
  end;
end;

{-----------------------------------------------
Cut a line and add '...'}

function ClipLine(Canvas: TCanvas; Line: string; MaxWidth: Integer): string;
begin
  Result := Line;
  if Canvas.TextWidth(Line) > MaxWidth then
  begin
    repeat
      System.Delete(Result, Length(Result), 1);
    until (Canvas.TextWidth(Result + '...') <= MaxWidth) or (Length(Result) < 2);
    Result := Result + '...';
  end;
end;

{------------------------------------------------
 TFlickerFreePaintBox
------------------------------------------------}

procedure TFlickerFreePaintBox.Paint;
var
  Bmp: TBitmap;
begin
  if csDesigning in ComponentState then
    with Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsSolid;
      Canvas.Brush.Color := Color;
      Rectangle(0, 0, Width, Height);
      Exit;
    end;

  if FNeedRepaint then
    Repaint
  else if FApplyDeform then
  begin
    FDrawing := True;
    Bmp := TBitmap.Create;
    try
      Bmp.PixelFormat := pf24bit;
      Bmp.Width := FBuffer.Width;
      Bmp.Height := FBuffer.Height;
      DrawAlpha(Bmp, Color, 0, 0, FBuffer.Canvas.ClipRect, FBuffer, FDeformAlpha);
      Canvas.CopyRect(Rect(0, 0, Round(FBuffer.Width * FDeformHorz), Round(FBuffer.Height * FDeformVert)), Bmp.Canvas, Bmp.Canvas.ClipRect);
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect(Round(FBuffer.Width * FDeformHorz), 0, Width - 1, Height - 1));
      Canvas.FillRect(Rect(0, Round(FBuffer.Height * FDeformVert), Width - 1, Height - 1));
    finally
      Bmp.Free;
      FDrawing := False;
    end;
  end
  else
  begin
    FDrawing := True;
    Canvas.Draw(0, 0, FBuffer);
    FDrawing := False;
  end;
end;

{-----------------------------------------------}

procedure TFlickerFreePaintBox.Resize;
begin
  if FDrawing then
    Exit;
  FBuffer.Free;
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf24bit;
  FBuffer.Width := Width;
  FBuffer.Height := Height;
  FBuffer.Canvas.Brush.Color := Color;
  FNeedRepaint := True;
end;

{-----------------------------------------------}

procedure TFlickerFreePaintBox.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

{-----------------------------------------------}

constructor TFlickerFreePaintBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabStop := False;
  FBuffer := TBitmap.Create;
  FBuffer.Width := Width;
  FBuffer.Height := Height;
  FBuffer.PixelFormat := pf24bit;
  FBuffer.Canvas.Brush.Color := Color;
  FNeedRepaint := True;
  FDrawing := False;
end;

{-----------------------------------------------}

procedure TFlickerFreePaintBox.Repaint;
begin
  if csDesigning in ComponentState then
    Exit;

  FBuffer.Canvas.FillRect(FBuffer.Canvas.ClipRect);
  if Assigned(FOnFFPaint) then
    FOnFFPaint(Self, FBuffer);
  FNeedRepaint := False;
  Paint;
end;

{-----------------------------------------------}

procedure TFlickerFreePaintBox.ApplyDeform(Horz, Vert, Alpha: Extended);
begin
  FApplyDeform := True;
  FDeformHorz := Horz;
  FDeformVert := Vert;
  FDeformAlpha := Alpha;
  Paint;
end;

{-----------------------------------------------}

procedure TFlickerFreePaintBox.NoDeform;
begin
  FApplyDeform := False;
  Paint;
end;

{------------------------------------------------
 TExCustomItem
------------------------------------------------}

procedure TExCustomItem.Draw(Bitmap: TBitmap; var X, Y, Width: Integer);
begin
    with Bitmap.Canvas do
    begin
      Pen.Color := clBtnText;
      Pen.Style := psDot;
      Brush.Style := bsClear;
      Rectangle(Rect(X + X_OFFSET, Y + 2, X + Width - X_OFFSET, Y + 18));
    end;
    Inc(Y, 20);
end;

{-----------------------------------------------}

procedure TExCustomItem.Measure(Bitmap: TBitmap; var X, Y, Width: Integer);
begin
    Inc(Y, 20);
end;

{-----------------------------------------------}

constructor TExCustomItem.Create(AOwner: TExGroup);
begin
  FOwner := AOwner;
  FVisible := True;
end;

{------------------------------------------------
 TExMenuItem
------------------------------------------------}

procedure TExMenuItem.Draw(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  IconWidth, IconHeight, IconTop: Integer;
  ALine, EndStr: string;
begin
    with Bitmap.Canvas do
    begin
      Font.Style := IfThenFs(Self = FOwner.FExBar.FHotArea, [fsUnderline]+FFontStyle, []+FFontStyle);
      Font.Color := IfThenColor(Self = FOwner.FExBar.FHotArea, FOwner.FExBar.FTextHotColor, FOwner.FExBar.FTextColor);
      IconTop := Y;
      if FIcon <> nil then
      begin
        Draw(X + X_OFFSET, Y, FIcon);
        IconWidth := FIcon.Width + X_OFFSET + X_OFFSET div 2;
        IconHeight := FIcon.Height;
      end
      else if (FIconIndex <> UNKNOWN_VALUE) and Assigned(FOwner.FexBar.FItemIcons) then
      begin
        FOwner.FExBar.FItemIcons.Draw(Bitmap.Canvas, X + X_OFFSET, Y, FIconIndex);
        IconWidth := FOwner.FExBar.FItemIcons.Width + X_OFFSET + X_OFFSET div 2;
        IconHeight := FOwner.FExBar.FItemIcons.Height;
      end
      else
      begin
        IconWidth := X_OFFSET;
        IconHeight := 0;
      end;

      FClipRect.TopLeft := Point(X + X_OFFSET, Y);
      FClipRect.Right := X + IconWidth;
      if IconHeight > TextHeight('A') then
        Inc(Y, (IconHeight - TextHeight('A')) div 2);
      EndStr := FCaption;
      Brush.Style := bsClear;
      repeat
        Aline := Parse(Bitmap.Canvas, EndStr, FOwner.FWidth - IconWidth + X - 2 * X_OFFSET);
        if X + IconWidth + TextWidth(Aline) > FClipRect.Right then
          FClipRect.Right := X + IconWidth + TextWidth(Aline);
        TextOut(X + IconWidth, Y, ALine);
        Inc(Y, TextHeight('A') + 1);
      until EndStr = '';
      if Y < IconTop + IconHeight then
        Y := IconTop + IconHeight;
      FClipRect.Bottom := Y;
    end;
    Inc(Y, Y_OFFSET div 2);
end;

{-----------------------------------------------}

procedure TExMenuItem.Measure(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  IconWidth, IconHeight, IconTop: Integer;
  ALine, EndStr: string;
begin
    with Bitmap.Canvas do
    begin
      Font.Style := [];
      IconTop := Y;
      if FIcon <> nil then
      begin
        IconWidth := FIcon.Width + X_OFFSET + X_OFFSET div 2;
        IconHeight := FIcon.Height;
      end
      else if (FIconIndex <> UNKNOWN_VALUE) and Assigned(FOwner.FexBar.FItemIcons) then
      begin
        IconWidth := FOwner.FExBar.FItemIcons.Width + X_OFFSET + X_OFFSET div 2;
        IconHeight := FOwner.FExBar.FItemIcons.Height;
      end
      else
      begin
        IconWidth := X_OFFSET;
        IconHeight := 0;
      end;
      if IconHeight > TextHeight('A') then
        Inc(Y, (IconHeight - TextHeight('A')) div 2);
      EndStr := FCaption;
      repeat
        Aline := Parse(Bitmap.Canvas, EndStr, FOwner.FWidth - IconWidth + X - 2 * X_OFFSET);
        Inc(Y, TextHeight('A') + 1);
      until EndStr = '';
      if Y < IconTop + IconHeight then
        Y := IconTop + IconHeight;
    end;
    Inc(Y, Y_OFFSET div 2);
end;

{-----------------------------------------------}

procedure TExMenuItem.SetCaption(Value: string);
begin
  FCaption := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExMenuItem.SetFontStyle(Value: TFontStyles);
begin
  FFontStyle := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExMenuItem.SetIcon(Value: TBitmap);
begin
  if Value = nil then
  begin
    if FIcon <> nil then
    begin
      FIcon.Free;
      FIcon := nil;
    end;
  end
  else
  begin
    if FIcon = nil then
      FIcon := TBitmap.Create;
    FIcon.Assign(Value);
  end;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

constructor TExMenuItem.Create(AOwner: TExGroup);
begin
  inherited Create(AOwner);
  FCaption := 'MenuItem';
  FHint := 'MenuItem';
  FIcon := nil;
  FIconIndex := UNKNOWN_VALUE;
  FId := UNKNOWN_VALUE;
  FClipRect := UNKNOWN_RECT;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

constructor TExMenuItem.Create(AOwner: TExGroup; ACaption, AHint: string; AId: Integer; AIconIndex: Integer);
begin
  inherited Create(AOwner);
  FCaption := ACaption;
  FHint := AHint;
  FIcon := nil;
  FIconIndex := AIconIndex;
  FId := AId;
  FClipRect := UNKNOWN_RECT;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

constructor TExMenuItem.Create(AOwner: TExGroup; ACaption, AHint: string; AId: Integer; AIconIndex: Integer; AFontStyle: TFontStyles);
begin
  inherited Create(AOwner);
  FCaption := ACaption;
  FFontStyle := AFontStyle;
  FHint := AHint;
  FIcon := nil;
  FIconIndex := AIconIndex;
  FId := AId;
  FClipRect := UNKNOWN_RECT;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

constructor TExMenuItem.Create(AOwner: TExGroup; ACaption, AHint: string; AId: Integer; AIcon: TBitmap);
begin
  inherited Create(AOwner);
  FCaption := ACaption;
  FHint := AHint;
  FIconIndex := UNKNOWN_VALUE;
  if AIcon = nil then
    FIcon := nil
  else
  begin
    FIcon := TBitmap.Create;
    FIcon.Assign(AIcon);
  end;
  FId := AId;
  FClipRect := UNKNOWN_RECT;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

destructor TExMenuItem.Destroy;
begin
  if FOwner.FExBar.FHotArea = Self then
    FOwner.FExBar.FHotArea := nil;
  if FIcon <> nil then
    FIcon.Free;
end;

{------------------------------------------------
 TExBmp
------------------------------------------------}

constructor TExBmp.Create(AOwner: TExGroup);
begin
  inherited Create(AOwner);
  FImage := nil;
end;

{-----------------------------------------------}

constructor TExBmp.Create(AOwner: TExGroup; AImage: TBitmap);
begin
  if AImage <> nil then
  begin
    inherited Create(AOwner);
    SetImage(AImage);
  end
  else
    Create(AOwner);
end;

{-----------------------------------------------}

constructor TExBmp.Create(AOwner: TExGroup; AImageFile: TFileName);
var
  Bmp: TBitmap;
  Jpg: TJPEGImage;
begin
  if FileExists(AImageFile) then
  begin
    if (UpperCase(ExtractFileExt(AImageFile)) = '.BMP') then
    begin
      Bmp := TBitmap.Create;
      try
        Bmp.LoadFromFile(AImageFile);
        Create(AOwner, Bmp);
      finally
        Bmp.Free;
      end;
    end
    else if (UpperCase(ExtractFileExt(AImageFile)) = '.JPG') then
    begin
      Bmp := TBitmap.Create;
      Jpg := TJPEGImage.Create;
      try
        Jpg.LoadFromFile(AImageFile);
        Bmp.Assign(Jpg);
        Create(AOwner, Bmp);
      finally
        Bmp.Free;
        Jpg.Free;
      end;
    end
  end
  else
    Create(AOwner);
end;

{-----------------------------------------------}

destructor TExBmp.Destroy;
begin
  if Fimage <> nil then
    FImage.Free;
  inherited Destroy;
end;

{-----------------------------------------------}

procedure TExBmp.Draw(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  W: Integer;
begin
    if FImage <> nil then
      if FOwner.FExBar.Width < DEFAULT_WIDTH then
      begin
        W := FOwner.FExBar.Width - SCROLLBAR_WIDTH - 4 * X_OFFSET;
        Bitmap.Canvas.StretchDraw(Rect(X + (Width - W) div 2, Y, X + Width - (Width - W) div 2, Y + FImage.Height * W div FImage.Width), FImage);
        Inc(Y, FImage.Height * W div FImage.Width + Y_OFFSET);
      end
      else
      begin
        Bitmap.Canvas.Draw(X + (Width - FImage.Width) div 2, Y, FImage);
        Inc(Y, FImage.Height + Y_OFFSET);
      end;
end;

{-----------------------------------------------}

procedure TExBmp.Measure(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  W: Integer;
begin
    if FImage <> nil then
      if FOwner.FExBar.Width < DEFAULT_WIDTH then
      begin
        W := FOwner.FExBar.Width - SCROLLBAR_WIDTH - 4 * X_OFFSET;
        Inc(Y, FImage.Height * W div FImage.Width + Y_OFFSET);
      end
      else
        Inc(Y, FImage.Height + Y_OFFSET);
end;

{-----------------------------------------------}

procedure TExBmp.SetImage(Value: TBitmap);
begin
  if Value <> nil then
  begin
    if FImage <> nil then
      FImage.Free;
    FImage := TBitmap.Create;
    FImage.Width := DEFAULT_WIDTH - SCROLLBAR_WIDTH - 4 * X_OFFSET;
    FImage.Height := Value.Height * (DEFAULT_WIDTH - SCROLLBAR_WIDTH - 4 * X_OFFSET) div Value.Width;
    FImage.Canvas.StretchDraw(FImage.Canvas.ClipRect, Value);
  end
  else if FImage <> nil then
  begin
    FImage.Free;
    FImage := nil;
  end;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{------------------------------------------------
 TExProgressBar
------------------------------------------------}

procedure TExProgressBar.Draw(Bitmap: TBitmap; var X, Y, Width: Integer);
begin
  with Bitmap.Canvas do
  begin
    Pen.Color := FBorderColor;
    Rectangle(X + X_OFFSET, Y, X + Width - X_OFFSET, Y + FHeight);
    Brush.Color := FFillColor;
    FillRect(Rect(X + X_OFFSET + 2, Y + 2, X + X_OFFSET + 2 + Round((Width - 2 * X_OFFSET - 4) * (FPosition - FMin) / (FMax - FMin)), Y + FHeight - 2));
    Inc(Y, FHeight + Y_OFFSET);
  end;
end;

{-----------------------------------------------}

procedure TExProgressBar.Measure(Bitmap: TBitmap; var X, Y, Width: Integer);
begin
  Inc(Y, FHeight + Y_OFFSET);
end;

{-----------------------------------------------}

procedure TExProgressBar.SetMin(Value: Integer);
begin
  FMin := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExProgressBar.SetMax(Value: Integer);
begin
  FMax := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExProgressBar.SetPosition(Value: Integer);
begin
  FPosition := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

constructor TExProgressBar.Create(AOwner: TExGroup);
begin
  inherited Create(AOwner);
  FMin := 0;
  FMax := 0;
  FPosition := 0;
  FHeight := 20;
  FBorderCOlor := cl3DDkShadow;
  FFillColor := clBtnShadow;
end;

{-----------------------------------------------}

constructor TExProgressBar.Create(AOwner: TExGroup; AMin, AMax, APosition, AHeight: Integer; ABorderColor, AFillCOlor: TColor);
begin
  inherited Create(AOwner);
  FMin := AMin;
  FMax := AMax;
  FPosition := APosition;
  FHeight := AHeight;
  FBorderCOlor := ABorderColor;
  FFillColor := AFillColor;
end;

{------------------------------------------------
 TExLine
------------------------------------------------}

procedure TExLine.Draw(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  ALine, EndStr: string;
begin
  with Bitmap.Canvas do
  begin
    Font.Style := FFontStyle;
    Font.Color := FFontColor;
    if WordWrap then
    begin
      EndStr := FCaption;
      repeat
        Aline := Parse(Bitmap.Canvas, EndStr, FOwner.FWidth - 2 * X_OFFSET);
        TextOut(X + X_OFFSET, Y, ALine);
        Inc(Y, TextHeight('A') + 1);
      until EndStr = '';
      Inc(Y, Y_OFFSET - 1);
    end
    else
    begin
      TextOut(X + X_OFFSET, Y, ClipLine(Bitmap.Canvas, FCaption, FOwner.FWidth - 2 * X_OFFSET));
      Inc(Y, TextHeight('A') + 1);
      with FOwner do
        if (Items.IndexOf(Self) + 1 < Items.Count) and not (Items[Items.IndexOf(Self) + 1] is TExLine) then
          Inc(Y, Y_OFFSET - 1);
    end;
  end;
end;

{-----------------------------------------------}

procedure TExLine.Measure(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  ALine, EndStr: string;
begin
  with Bitmap.Canvas do
  begin
    Font.Style := FFontStyle;
    if WordWrap then
    begin
      EndStr := FCaption;
      repeat
        Aline := Parse(Bitmap.Canvas, EndStr, FOwner.FWidth - 2 * X_OFFSET);
        Inc(Y, TextHeight('A') + 1);
      until EndStr = '';
      Inc(Y, Y_OFFSET - 1);
    end
    else
    begin
      Inc(Y, TextHeight('A') + 1);
      with FOwner do
        if (Items.IndexOf(Self) + 1 < Items.Count) and not (Items[Items.IndexOf(Self) + 1] is TExLine) then
          Inc(Y, Y_OFFSET - 1);
    end;
  end;
end;

{-----------------------------------------------}

procedure TExLine.SetCaption(Value: string);
begin
  FCaption := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExLine.SetFontColor(Value: TColor);
begin
  FFontColor := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExLine.SetFontStyle(Value: TFontStyles);
begin
  FFontStyle := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExLine.SetWordWrap(Value: Boolean);
begin
  FWordWrap := Value;
  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

{-----------------------------------------------}

constructor TExLine.Create(AOwner: TExGroup);
begin
  inherited Create(AOwner);
  FCaption := 'a line';
  FFontColor := clBtnText;
end;

{-----------------------------------------------}

constructor TExLine.Create(AOwner: TExGroup; ACaption: string; AFontColor: TColor;
  AFontStyle: TFontStyles; AWordWrap: Boolean);
begin
  inherited Create(AOwner);
  FCaption := ACaption;
  FFontColor := AFontColor;
  FFontStyle := AFontStyle;
  FWordWrap := AWordWrap;
end;

{------------------------------------------------
 TExGroup
------------------------------------------------}

procedure TExGroup.Draw(Bitmap: TBitmap; var X, Y: Integer);
var
  I: Integer;
  BodyRgn: HRGN;
begin
  if FExBar.FUpdating then Exit;
  BodyRgn := CreateRectRgn(X, Y, X + FWidth, Y + ICON_SIDE);
  SelectClipRgn(Bitmap.Canvas.Handle, BodyRgn);
  if Assigned(FExBar.FSkin) then
    DrawSkinedHead(Bitmap, FExBar.FSkin, X, Y, FWidth, FSpecialGroup, FState in [gsClosed, gsClosing], Self = FExBar.FHotArea)
  else
    DrawHead(Bitmap, X, Y, FWidth, FSpecialGroup, FState in [gsClosed, gsClosing], IfThen(FSpecialGroup, IfThen(Self <> FExBar.FHotArea, FExBar.FSpecialTextColor, FExBar.FSpecialTextHotColor), IfThen(Self <> FExBar.FHotArea, FExBar.FTextColor, FExBar.FTextHotColor)));
  //draw icon and write title
  with Bitmap.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Style := [fsBold];
    Font.Color := IfThen(FSpecialGroup,
      IfThen(Self <> FExBar.FHotArea, FExBar.FSpecialTextColor, FExBar.FSpecialTextHotColor),
      IfThen(Self <> FExBar.FHotArea, FExBar.FTextColor, FExBar.FTextHotColor));
    if (FGroupIconIndex <> UNKNOWN_VALUE) and (FExBar.FGroupIcons <> nil) then
    begin
      FExBar.FGroupIcons.Draw(Bitmap.Canvas, X, Y, FGroupIconIndex);
      TextRect(Rect(X, Y, X + FWidth - SKIN_RIGHT_PART_WIDTH, Y + ICON_SIDE), X + 2 * ICON_OFFSET + ICON_SIDE, Y + Y_OFFSET + (ICON_SIDE - Y_OFFSET - TextHeight('A')) div 2, FTitle);
    end
    else
      TextRect(Rect(X, Y, X + FWidth - SKIN_RIGHT_PART_WIDTH, Y + ICON_SIDE), X + 2 * ICON_OFFSET, Y + Y_OFFSET + (ICON_SIDE - Y_OFFSET - TextHeight('A')) div 2, FTitle);
  end;
  DeleteObject(BodyRgn);
  FTitleRect := Rect(X, Y + ICON_SIDE - SKIN_HEIGHT, X + FWidth, Y + ICON_SIDE);
  Inc(Y, ICON_SIDE);
  FBodyRect.TopLeft := Point(X, Y);
  FBodyRect.Right := X + FWidth;
  if FState <> gsClosed then
  begin
    BodyRgn := CreateRectRgn(X, Y, X + FWidth, Y + FShownHeight);
    SelectClipRgn(Bitmap.Canvas.Handle, BodyRgn);
    //draw body background
    with Bitmap.Canvas do
    begin
      Brush.Color := FExBar.FGroupBgColor;
      Brush.Style := bsSolid;
      FillRect(Bitmap.Canvas.ClipRect);
      //draw BgImage
      if FBgImage <> nil then
        Draw(X + FWidth - FBgImage.Width, Y + FShownHeight - FBgImage.Height, FBgImage);
      Pen.Color := FExBar.FBorderColor;
      Pen.Style := psSolid;
      MoveTo(X, Y);
      LineTo(X, Y + FShownHeight - 1);
      LineTo(X + FWidth - 1, Y + FShownHeight - 1);
      LineTo(X + FWidth - 1, Y);
    end;
    //draw items
    if FState in [gsOpening, gsCLosing] then
      Y := Y - FHeight + FShownHeight;
    Inc(Y, Y_OFFSET);
    for I := 0 to FItems.Count - 1 do
      if (FItems[I] as TExCustomItem).Visible then
        (FItems[I] as TExCustomItem).Draw(Bitmap, X, Y, FWidth);
    Inc(Y, Y_OFFSET);
    if FState in [gsOpening, gsCLosing] then
    begin
      Bitmap.Canvas.Brush.Color := FExBar.FBgColor;
      BlendFillRect(Bitmap, Bitmap.Canvas.ClipRect, 1 - FShownHeight / FHeight);
    end;
    DeleteObject(BodyRgn);
  end;
  FBodyRect.Bottom := Y;
  Inc(Y, Y_OFFSET);
end;

{-----------------------------------------------}

procedure TExGroup.Measure(Bitmap: TBitmap; var X, Y: Integer);
var
  I, Bottom: Integer;
begin
  if FExBar.FUpdating then Exit;
  Inc(Y, ICON_SIDE);
  Bottom := Y;
  Inc(Bottom, Y_OFFSET);
  for I := 0 to FItems.Count - 1 do
    if (FItems[I] as TExCustomItem).Visible then
      (FItems[I] as TExCustomItem).Measure(Bitmap, X, Bottom, FWidth);
  Inc(Bottom, Y_OFFSET);
  FHeight := Bottom - Y;
  if (FShownHeight > FHeight) or (FState = gsOpen) then
    FShownHeight := FHeight;
  if FState in [gsOpen, gsOpening] then
    Y := Bottom;
  Inc(Y, Y_OFFSET);
end;

{-----------------------------------------------}

procedure TExGroup.Measure;
var
  X, Y: Integer;
begin
  X := 0;
  Y := 0;
  Measure(FExBar.FPaintBox.FBuffer, X, Y);
end;

{-----------------------------------------------}

procedure TExGroup.SetBgImage(Value: TBitmap);
begin
  if Value <> nil then
  begin
    if FBgImage = nil then
      FBgImage := TBitmap.Create;
    FBgImage.Assign(Value);
  end
  else if FBgImage <> nil then
  begin
    FBgImage.Free;
    FBgImage := nil;
  end;
end;

{-----------------------------------------------}

procedure TExGroup.SetGroupIconIndex(Value: Integer);
begin
  FGroupIconIndex := Value;
  if not FExBar.FUpdating then
    FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExGroup.SetSpecialGroup(Value: Boolean);
begin
  FSpecialGroup := Value;
  if not FExBar.FUpdating then
    FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExGroup.SetTitle(Value: string);
begin
  FTitle := Value;
  if not FExBar.FUpdating then
    FExBar.Repaint;
end;

{-----------------------------------------------}

procedure TExGroup.Timer(Sender: TObject);
begin
  case FState of
    gsOpening:
      begin
        FShownHeight := FShownHeight + FAnimStep;
        if FShownHeight > FHeight then
          FShownHeight := FHeight;
        Dec(FAnimStep, 1 + FHeight div 150);
      end;
    gsClosing:
      begin
        FShownHeight := FShownHeight - FAnimStep;
        if FShownHeight < 0 then
          FShownHeight := 0;
        Inc(FAnimStep, 1 + FHeight div 150);
      end;
  end;
  if (FAnimStep >= FNbSteps) or (FAnimStep < 0) then
  begin
    FShownHeight := FDestHeight;
    FTimer.Enabled := False;
    if FShownHeight = 0 then
      FState := gsClosed
    else
      FState := gsOpen;
  end;
  FExBar.Measure;
  FExBar.Repaint;
end;

{-----------------------------------------------}

constructor TExGroup.Create(AOwner: TExBar);
begin
  inherited Create;
  FExBar := AOwner;
  FItems := TObjectList.Create;
  FState := gsOpen;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := ANIM_SPEED;
  FTimer.OnTimer := Timer;
  FHeight := 25;
  FDestHeight := FHeight;
  FShownHeight := FHeight;
  FWidth := FExBar.ClientWidth - 2 * X_OFFSET;
  FGroupIconIndex := UNKNOWN_VALUE;
  FBgImage := nil;
end;

{-----------------------------------------------}

destructor TExGroup.Destroy;
begin {override}
  if FExBar.FHotArea = Self then
    FExBar.FHotArea := nil;
  FItems.Free;
  FTimer.Free;
end;

{-----------------------------------------------}

procedure TExGroup.AddMenuItem(ACaption, AHint: string; AId: Integer; AIconIndex: Integer; AFontStyle: TFontStyles);
begin
  if Assigned(FExBar.FItemIcons) then
    FItems.Add(TExMenuItem.Create(Self, ACaption, AHint, AId, AIconIndex, AFontStyle));
end;

{-----------------------------------------------}

procedure TExGroup.AddMenuItem(ACaption, AHint: string; AId: Integer; AIconBmp: TBitmap);
begin
  FItems.Add(TExMenuItem.Create(Self, ACaption, AHint, AId, AIconBmp));
end;

{-----------------------------------------------}

procedure TExGroup.AddMenuItem(ACaption: string; AHint: string; AId: Integer; ABmpFile: TFileName; AWidth, AHeight: Integer);
var
  Bmp, Buffer: TBitmap;
  Jpg: TJPEGImage;
begin
  if FileExists(ABmpFile) then
  begin
    if UpperCase(ExtractFileExt(ABmpFile)) = '.BMP' then
    begin
      Bmp := TBitmap.Create;
      Bmp.Width := AWidth;
      Bmp.Height := AHeight;
      Buffer := TBitmap.Create;
      try
        Buffer.LoadFromFile(ABmpFile);
        ResizeBmp(Buffer, Bmp);
        FItems.Add(TExMenuItem.Create(Self, ACaption, AHint, AId, Bmp));
      finally
        Buffer.Free;
        Bmp.Free;
      end;
    end
    else if UpperCase(ExtractFileExt(ABmpFile)) = '.JPG' then
    begin
      Bmp := TBitmap.Create;
      Bmp.Width := AWidth;
      Bmp.Height := AHeight;
      Buffer := TBitmap.Create;
      Jpg := TJPEGImage.Create;
      try
        Jpg.LoadFromFile(ABmpFile);
        Buffer.Assign(Jpg);
        ResizeBmp(Buffer, Bmp);
        FItems.Add(TExMenuItem.Create(Self, ACaption, AHint, AId, Bmp));
      finally
        Buffer.Free;
        Bmp.Free;
        Jpg.Free;
      end;
    end
  end
  else
    FItems.Add(TExMenuItem.Create(Self, ACaption, AHint, AId, nil));
end;

{-----------------------------------------------}

procedure TExGroup.AddBmp(AImage: TBitmap);
begin
  FItems.Add(TExBmp.Create(Self, AImage));
end;

{-----------------------------------------------}

procedure TExGroup.AddBmp(AImageFile: TFileName);
begin
  FItems.Add(TExBmp.Create(Self, AImageFile));
end;

{-----------------------------------------------}

procedure TExGroup.AddLine(ACaption: string; AFontColor: TColor; AFontStyle: TFontStyles;
  AWordWrap: Boolean);
begin
  FItems.Add(TExLine.Create(Self, ACaption, AFontColor, AFontStyle, AWordWrap));
end;

{-----------------------------------------------}

procedure TExGroup.AddProgressBar(AMin, AMax, APosition, AHeight: Integer; ABorderColor, AFillCOlor: TColor);
begin
  FItems.Add(TExProgressBar.Create(Self, AMin, AMax, APosition, AHeight, ABorderColor, AFillColor));
end;

{-----------------------------------------------}

procedure TExGroup.OpenClose;
var
  DoCalc: Boolean;
begin
  if not FExBar.FAnimate then
  begin
    case FState of
      gsOpen:
        FState := gsClosed;
      gsClosed:
        FState := gsOpen;
    end;
  end
  else
  begin
    DoCalc := False;
    case FState of
      gsOpen:
        begin
          DoCalc := True;
          FDestHeight := 0;
          FShownHeight := FHeight;
          FState := gsClosing;
          FTimer.Enabled := True;
        end;
      gsClosed:
        begin
          DoCalc := True;
          FDestHeight := FHeight;
          FShownHeight := 0;
          FState := gsOpening;
          FTimer.Enabled := True;
        end;
      gsOpening:
        begin
          FDestHeight := 0;
          FState := gsClosing;
        end;
      gsClosing:
        begin
          FDestHeight := FHeight;
          FState := gsOpening;
        end;
    end;
    if FShownHeight > FHeight then
      FShownHeight := FHeight;
    if DoCalc then
    begin
      FNbSteps := CalcNbSteps(0, FHeight, 1 + FHeight div 150);
      if FState = gsOpening then
        FAnimStep := FNbSteps - 1
      else
        FAnimStep := 0;
    end;
  end;
  FExBar.Measure;
  FExBar.Repaint;
end;

{------------------------------------------------
 TExGroupList
------------------------------------------------}

function TExGroups.Add(ATitle: string; ASpecialGroup: Boolean = False): TExGroup;
var
  ExGroup: TExGroup;
begin
  ExGroup := TExGroup.Create(FOwner);
  ExGroup.Title := ATitle;
  ExGroup.SpecialGroup := ASpecialGroup;
  inherited Add(ExGroup);
  FOwner.FNeedResize := True;
  Result := ExGroup;
end;

{-----------------------------------------------}

constructor TExGroups.Create(AOwner: TComponent);
begin
  inherited Create;
  FOwner := TExBar(AOwner);
end;

{-----------------------------------------------}

destructor TExGroups.Destroy;
begin
  inherited;
end;

{-----------------------------------------------}

function TExGroups.GetItem(Index: Integer): TExGroup;
begin
  Result := TExGroup(inherited GetItem(Index));
end;

{-----------------------------------------------}

procedure TExGroups.SetItem(Index: Integer; Value: TExGroup);
begin
  inherited SetItem(Index, Value);
end;

{------------------------------------------------
 TExBar
------------------------------------------------}

procedure TExBar.CMMouseLeave(var Message: TMessage);
var
  OldHotArea: TObject;
  DrawX, DrawY: Integer;
begin
  if (FHotArea <> nil) then
  begin
    OldHotArea := FHotArea;
    FHotArea := nil;
    if (OldHotArea <> nil) and (OldHotArea is TExMenuItem) then
      OldHotArea := (OldHotArea as TExMenuItem).FOwner;
    if OldHotArea <> nil then
      with OldHotArea as TExGroup do
      begin
        DrawX := FTitleRect.Left;
        DrawY := FTitleRect.Top - ICON_SIDE + SKIN_HEIGHT;
        Draw(FPaintBox.FBuffer, DrawX, DrawY);
      end;
    FPaintBox.Paint;
  end;
end;

{-----------------------------------------------}

function TExBar.GetHotArea(X, Y: Integer): TObject;
var
  I, J: Integer;
  Found: Boolean;
begin
  Result := nil;
  Found := False;
  I := 0;
  while not Found and (I < FExGroups.Count) do
    with FExGroups[I] do
    begin
      if PtInRect(FTitleRect, Point(X, Y)) then
      begin
        Result := FExGroups[I];
        Found := True;
      end
      else if PtInRect(FBodyRect, Point(X, Y)) then
      begin
        J := 0;
        while not Found and (J < Items.Count) do
        begin
          if (Items[J] is TExMenuItem) then
            if (Items[J] as TExMenuItem).Visible and PtInRect((Items[J] as TExMenuItem).FClipRect, Point(X, Y)) then
            begin
              Result := Items[J];
              Found := True;
            end;
          Inc(J);
        end;
      end;
      Inc(I);
    end;
end;

{-----------------------------------------------}

procedure TExBar.PaintBuffer(Sender: TObject; Buffer: TBitmap);
var
  I: Integer;
  X, Y: Integer;
begin
  if FUpdating then Exit;
  Buffer.Canvas.Brush.Color := FBgColor;
  Buffer.Canvas.FillRect(Buffer.Canvas.ClipRect);
  X := X_OFFSET;
  Y := Y_OFFSET;
  for I := 0 to FExGroups.Count - 1 do
    FExGroups[I].Draw(Buffer, X, Y);
end;

{-----------------------------------------------}

procedure TExBar.PbMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  NewHotArea: TObject;
  OldHotArea: TObject;
  DrawX, DrawY: Integer;
begin
  if Shift <> [] then
    Exit;
  if not ((FHotArea <> nil) and
    ((FHotArea is TExMenuItem) and PtInRect((FHotArea as TExMenuItem).FClipRect, Point(X, Y))) or
    ((FHotArea is TExGroup) and PtInRect((FHotArea as TExGroup).FTitleRect, Point(X, Y)))) then
  begin
    NewHotArea := GetHotArea(X, Y);
    if NewHotArea <> FHotArea then
    begin
      OldHotArea := FHotArea;
      FHotArea := NewHotArea;
      if (FHotArea is TExMenuItem) and ((FHotArea as TExMenuItem).Hint <> '') then
      begin
        ShowHint := True;
        Hint := (FHotArea as TExMenuItem).Hint;
      end
      else
        ShowHint := False;
      if (OldHotArea <> nil) and (OldHotArea is TExMenuItem) then
        OldHotArea := (OldHotArea as TExMenuItem).FOwner;
      if (NewHotArea <> nil) and (NewHotArea is TExMenuItem) then
        NewHotArea := (NewHotArea as TExMenuItem).FOwner;
      if OldHotArea <> nil then
        with OldHotArea as TExGroup do
        begin
          DrawX := FTitleRect.Left;
          DrawY := FTitleRect.Top - ICON_SIDE + SKIN_HEIGHT;
          Draw(FPaintBox.FBuffer, DrawX, DrawY);
        end;
      if NewHotArea <> nil then
        with NewHotArea as TExGroup do
        begin
          DrawX := FTitleRect.Left;
          DrawY := FTitleRect.Top - ICON_SIDE + SKIN_HEIGHT;
          Draw(FPaintBox.FBuffer, DrawX, DrawY);
        end;
      if FHotArea = nil then
        (Sender as TFlickerFreePaintBox).Cursor := crDefault
      else
      begin
        if not (FHotArea is TExCheckBox) or ((FHotArea is TExCheckBox) and (FHotArea as TExCheckBox).Enabled) then
          (Sender as TFlickerFreePaintBox).Cursor := crHand;
      end;
      FPaintBox.Paint;
      //Repaint;
    end;
  end;
end;

{-----------------------------------------------}

procedure TExBar.PbMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  NewHotArea: TObject;
begin
  NewHotArea := GetHotArea(X, Y);
  if (NewHotArea = FHotArea) and (NewHotArea <> nil) then
    if (NewHotArea is TExMenuItem) then
    begin
      if (NewHotArea is TExCheckBox) then
      begin
        if (NewHotArea as TExCheckBox).Enabled then
        begin
          (NewHotArea as TExCheckBox).Checked := not (NewHotArea as TExCheckBox).Checked;
          if Assigned(FOnClick) then
            FOnClick(Self, (NewHotArea as TExMenuItem).FId);
        end
      end
      else
        if Assigned(FOnClick) then
          FOnClick(Self, (NewHotArea as TExMenuItem).FId);
    end
    else if NewHotArea is TExGroup then
      with (NewHotArea as TExGroup) do
      begin
        OpenClose;
        //        RepaintTitle;
      end;
  if FHotArea = nil then
    (Sender as TFlickerFreePaintBox).Cursor := crDefault
  else
  begin
    if not (FHotArea is TExCheckBox) or ((FHotArea is TExCheckBox) and (FHotArea as TExCheckBox).Enabled) then
      (Sender as TFlickerFreePaintBox).Cursor := crHand;
  end;
  Repaint;
end;

{-----------------------------------------------}

procedure TExBar.SetGroupIcons(Value: TImageList);
begin
  FGroupIcons := Value;
end;

{-----------------------------------------------}

procedure TExBar.Measure;
var
  I: Integer;
  X, Y: Integer;
  Closing: Boolean;
  NewPbHeight: Integer;
begin
  //resize FpaintBox & FpaintBox.Buffer
  Y := Y_OFFSET;
  X := X_OFFSET;
  Closing := False;
  for I := 0 to FExGroups.Count - 1 do
    with FExGroups[I] do
    begin
      Measure(FPaintBox.FBuffer, X, Y);
      if State = gsClosing then
        Closing := True;
    end;
  if Closing and (Y < ClientHeight - 1) then
    NewPbHeight := ClientHeight - 1
  else
    NewPbHeight := Y;
  if NewPbHeight <> FPaintBox.Height then
  begin
    FPaintBox.Height := NewPbHeight;
    FPaintBox.Resize;
  end;
  FGroupsHeight := Y;
  Resize;
end;

{-----------------------------------------------}

procedure TExBar.SetItemIcons(Value: TImageList);
begin
  FItemIcons := Value;
end;

{-----------------------------------------------}

procedure TExBar.Timer(Sender: TObject);
begin
  Inc(FAnimStep);
  if FAnimStep >= ANIM_COUNT then
  begin
    FTimer.Enabled := False;
    FPaintBox.NoDeform;
  end
  else
    FPaintBox.ApplyDeform(1, FAnimStep / ANIM_COUNT, (FAnimStep / ANIM_COUNT) * (FAnimStep / ANIM_COUNT));
  FPaintBox.Paint;
end;

{-----------------------------------------------}

constructor TExBar.Create(AOwner: TComponent);
begin //override
  inherited Create(AOwner);
  FUpdating := False;
  FAnimate := True;
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents, csSetCaption,
    csDoubleClicks];
  Width := DEFAULT_WIDTH;
  FOldWidth := DEFAULT_WIDTH;
  Height := DEFAULT_HEIGHT;
  ParentColor := False;
  VertScrollBar.Smooth := True;
  VertScrollBar.Tracking := True;
  VertScrollBar.ButtonSize := SCROLLBAR_WIDTH;
  VertScrollBar.Visible := False;
  HorzScrollBar.Visible := False;
  FPaintBox := TFlickerFreePaintBox.Create(Self);
  FExGroups := TExGroups.Create(Self);
  with FPaintBox do
  begin
    Parent := Self;
    SetBounds(0, 0, Self.Width, 1);
    Resize;
    OnMouseMove := PbMouseMove;
    OnMouseUp := PbMouseUp;
    OnPaint := PaintBuffer;
  end;
  FGroupIcons := nil;
  FItemIcons := nil;
  FNeedResize := True;
  FHotArea := nil;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.OnTimer := Timer;
  FTimer.Interval := ANIM_SPEED;
  SetSkin(nil);
end;

{-----------------------------------------------}

procedure TExBar.Resize;
var
  I: Integer;
  NeedRefresh: Boolean;
begin //override
  inherited;
  NeedRefresh := False;
  if (ClientHeight >= FGroupsHeight) and VertScrollBar.Visible then
  begin
    VertScrollBar.Visible := False;
    NeedRefresh := True;
  end
  else if (ClientHeight < FGroupsHeight) and not VertScrollBar.Visible then
  begin
    VertScrollBar.Visible := True;
    NeedRefresh := True;
  end;
  if Width <> FOldWidth then
  begin
    FOldWidth := Width;
    FPaintBox.Width := Width;
    FPaintBox.Resize;
    NeedRefresh := True;
  end;
  if NeedRefresh then
  begin
    for I := 0 to FExGroups.Count - 1 do
    begin
      FExGroups[I].FWidth := ClientWidth - 2 * X_OFFSET;
      FExGroups[I].Measure;
    end;
    Measure;
    Repaint;
  end;
end;

{-----------------------------------------------}

destructor TExBar.Destroy;
begin //override
  FPaintBox.Free;
  FExGroups.Free;
  FTimer.Free;
  inherited Destroy;
end;

{-----------------------------------------------}

procedure TExBar.BeginUpdate;
begin
  FUpdating := True;
end;

{-----------------------------------------------}

procedure TExBar.EndUpdate;
begin
  FUpdating := False;
  Measure;
end;

{-----------------------------------------------}

procedure TExBar.Repaint;
begin //override
  if FUpdating then Exit;
  inherited Repaint;
  if FNeedResize then
  begin
    Measure;
    FNeedResize := False;
  end;
  FPaintBox.Repaint;
end;

{-----------------------------------------------}

procedure TExBar.SetSkin(ASkin: TBitmap);
begin
  if ASkin <> nil then
  begin
    if FSkin = nil then
      FSkin := TBitmap.Create;
    FSkin.Assign(ASkin);
    FBgColor := FSkin.Canvas.Pixels[1, 1];
    FGroupBgColor := FSkin.Canvas.Pixels[1, 7];
    FBorderColor := FSkin.Canvas.Pixels[1, 13];
    FTextColor := FSkin.Canvas.Pixels[1, 19];
    FTextHotColor := FSkin.Canvas.Pixels[1, 25];
    FSpecialTextColor := FSkin.Canvas.Pixels[1, 31];
    FSpecialTextHotColor := FSkin.Canvas.Pixels[1, 37];
    Color := FBgColor;
  end
  else
  begin
    if FSkin <> nil then
    begin
      FSkin.Free;
      FSkin := nil;
    end;
    FBgColor := clWhite; //clWindow;
    FGroupBgColor := clWindow;
    FBorderColor := clBtnFace;
    FTextColor := clBtnText;
    FTextHotColor := clBtnText;
    FSpecialTextColor := clCaptionText;
    FSpecialTextHotColor := clCaptionText;
    Color := clWhite; //clWindow;
  end;
end;

{-----------------------------------------------}

procedure TExBar.ShowAnimate;
begin
  if FUpdating or not FAnimate then Exit;
  FAnimStep := 0;
  if FNeedResize then
  begin
    Measure;
    FNeedResize := False;
  end;
  FTimer.Enabled := True;
  Timer(FTimer);
end;

{-----------------------------------------------}


procedure TExGroup.AddCheckBox(ACaption: string; AHint: string = ''; AId: Integer = -1; AChecked: boolean = false; AEnabled: Boolean = true; AFlat: boolean = false);
begin
  FItems.Add(TExCheckBox.Create(Self, ACaption, AId, AHint, AChecked, AEnabled, AFlat));
end;

{ TExCheckBox }

constructor TExCheckBox.Create(AOwner: TExGroup);
begin
  inherited Create(AOwner);
  FFlat := true;
  FChecked := false;
  FEnabled := true;
end;

constructor TExCheckBox.Create(AOwner: TExGroup; ACaption: string; AID: Integer; AHint: string; AChecked, AEnabled, AFlat: boolean);
begin
  inherited Create(AOwner);
  FOwner := AOwner;
  FHint := AHint;
  FCaption := ACaption;
  FFlat := AFlat;
  FId := AId;
  FChecked := AChecked;
  FEnabled := AEnabled;
end;

procedure TExCheckBox.SetEnabled(Value: boolean);
begin
  FEnabled := Value;

  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

procedure TExCheckBox.SetChecked(Value: boolean);
begin
  FChecked := Value;

  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;

procedure TExCheckBox.SetFlat(Value: boolean);
begin
  FFlat := Value;

  if not FOwner.FExBar.FUpdating then
    FOwner.FExBar.Repaint;
end;


procedure TExCheckBox.Draw(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  CheckTop: Integer;
  ALine, EndStr: string;
  ARect: TRect;
begin
    with Bitmap.Canvas do
    begin
      Font.Style := IfThenFs(Self = FOwner.FExBar.FHotArea, [fsUnderline], []);

      Font.Color := IfThenColor(Self = FOwner.FExBar.FHotArea, FOwner.FExBar.FTextHotColor, FOwner.FExBar.FTextColor);

      if not FEnabled then
      begin
        Font.Style := Font.Style - [fsUnderLine];
        Font.Color := FOwner.FExBar.FTextColor;
      end;

      CheckTop := Y;

      if FChecked and FEnabled then
        Font.Style := Font.Style + [fsBold]
      else
        Font.Style := Font.Style - [fsBold];

      ARect := rect(X + X_OFFSET, Y, X + X_OFFSET + 16, Y + 16);
      if FChecked then
        DrawCheck(Bitmap.Canvas, ARect, cbChecked, FEnabled)
      else
        DrawCheck(Bitmap.Canvas, ARect, cbUnchecked, FEnabled);

      FExCheckWidth := 16 + X_OFFSET + X_OFFSET div 2;
      FExCheckHeight := 16;

      FClipRect.TopLeft := Point(X + X_OFFSET, Y);
      FClipRect.Right := X + FExCheckWidth;
      if FExCheckHeight > TextHeight('A') then
        Inc(Y, (FExCheckHeight - TextHeight('A')) div 2);
      EndStr := FCaption;
      Brush.Style := bsClear;
      repeat
        Aline := Parse(Bitmap.Canvas, EndStr, FOwner.FWidth - FExCheckWidth + X - 2 * X_OFFSET);
        if X + FExCheckWidth + TextWidth(Aline) > FClipRect.Right then
          FClipRect.Right := X + FExCheckWidth + TextWidth(Aline);
        TextOut(X + FExCheckWidth, Y, ALine);
        Inc(Y, TextHeight('A') + 1);
      until EndStr = '';
      if Y < CheckTop + FExCheckHeight then
        Y := CheckTop + FExCheckHeight;
      FClipRect.Bottom := Y;
    end;
    Inc(Y, Y_OFFSET div 2);
end;

procedure TExCheckBox.Measure(Bitmap: TBitmap; var X, Y, Width: Integer);
var
  CheckTop: Integer;
  ALine, EndStr: string;
begin
  with Bitmap.Canvas do
  begin
    Font.Style := [];
    CheckTop := Y;

    if FCheckHeight > TextHeight('A') then
      Inc(Y, (FCheckHeight - TextHeight('A')) div 2);
    EndStr := FCaption;
    repeat
      Aline := Parse(Bitmap.Canvas, EndStr, FOwner.FWidth - FCheckWidth + X - 2 * X_OFFSET);
      Inc(Y, TextHeight('A') + 1);
    until EndStr = '';
    if Y < CheckTop + FCheckHeight then
      Y := CheckTop + FCheckHeight;
  end;
  Inc(Y, Y_OFFSET div 2);
end;

procedure TExCheckBox.DrawCheck(Canvas: TCanvas; R: TRect; AState: TCheckBoxState; AEnabled: Boolean);
var
  DrawState: Integer;
  DrawRect: TRect;
  OldBrushColor: TColor;
  OldBrushStyle: TBrushStyle;
  OldPenColor: TColor;
//  Rgn, SaveRgn: HRgn;
begin
//  SaveRgn := 0;
  DrawRect.Left := R.Left + (R.Right - R.Left - FCheckWidth) div 2;
  DrawRect.Top := R.Top + (R.Bottom - R.Top - FCheckWidth) div 2;
  DrawRect.Right := DrawRect.Left + FCheckWidth;
  DrawRect.Bottom := DrawRect.Top + FCheckHeight;
  case AState of
    cbChecked:
      DrawState := DFCS_BUTTONCHECK or DFCS_CHECKED;
    cbUnchecked:
      DrawState := DFCS_BUTTONCHECK;
  else // cbGrayed
    DrawState := DFCS_BUTTON3STATE or DFCS_CHECKED;
  end;
  if not AEnabled then
    DrawState := DrawState or DFCS_INACTIVE;
  with Canvas do
  begin
{    if FFlat then
    begin
      // Remember current clipping region
      SaveRgn := CreateRectRgn(0,0,0,0);
      GetClipRgn(Handle, SaveRgn);
      // Clip 3d-style checkbox to prevent flicker
      with DrawRect do
        Rgn := CreateRectRgn(Left + 2, Top + 2, Right - 2, Bottom - 2);
      SelectClipRgn(Handle, Rgn);
      DeleteObject(Rgn);
    end;}
    DrawFrameControl(Handle, DrawRect, DFC_BUTTON, DrawState);
    if FFlat then
    begin
{      SelectClipRgn(Handle, SaveRgn);
      DeleteObject(SaveRgn);}
      // Draw flat rectangle in-place of clipped 3d checkbox above
      OldBrushStyle := Brush.Style;
      OldBrushColor := Brush.Color;
      OldPenColor := Pen.Color;
      Brush.Style := bsClear;
      Pen.Color := clBtnShadow;
      with DrawRect do
        Rectangle(Left + 1, Top + 1, Right - 1, Bottom - 1);
      Brush.Style := OldBrushStyle;
      Brush.Color := OldBrushColor;
      Pen.Color := OldPenColor;
    end;
  end;
end;

begin
  Screen.Cursors[crHand] := LoadCursor(0, IDC_HAND);
  ArUp := TBitmap.Create;
  ArUp.LoadFromResourceName(hInstance, 'AR_UP');
  ArUp.PixelFormat := pf8bit;
  ArDn := TBitmap.Create;
  ArDn.LoadFromResourceName(hInstance, 'AR_DN');
  ArDn.PixelFormat := pf8bit;
  GetCheckSize;
end.
d.

