unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, Menus, ImgList, ComCtrls, Buttons, PngSpeedButton,
  Grids, CommCtrl, XPMan, Math,

  // Fremdkomponenten
  PngImageList,

  // TB2k + TBX
  TBX, TB2Item, TB2Dock, TB2Toolbar,
  TBXDkPanels, TBXSwitcher, TBXExtItems, TB2ExtItems,
  TBXStatusBars, TB2MRU, TBXThemes,

  // SpTBX
  SpTBXControls, SpTBXDkPanels, SpTBXItem, SpTBXEditors, SpTBXCustomizer,

  // Themen
  {TBXOfficeXPTheme, TBXXitoTheme, TBXTristanTheme, TBXTristan2Theme, TBXWhidbeyTheme,
  TBXSentimoXTheme, TBXOffice11AdaptiveTheme, TBXNexos5Theme,}

  // Eigene Komponenten
  _define, _columns, objJimbo, objMaps, objShops, objShopTypes, objCustomerTypes, objCustomers,
  objSettings, objBackup, objPainter, objMap, objIntegerList, objComplex, objCustomListView,

  funcCommon, funcVCL, funcVersion,

  JvComponentBase, GR32_Image;


const
  FILENAME_MAPDIR          = 'Maps';
  FILENAME_BACKUPDIR       = 'Backups';

  FILENAME_XML             = 'jimbo.xml';
  FILENAME_RESX            = 'resX.dll';

  ACTION_VIEW_PROJECT      = 1;
  ACTION_VIEW_PLAN         = 2;
  ACTION_VIEW_CUSTOMERS    = 3;
  ACTION_VIEW_SHOPS        = 4;

  ACTION_CUSTOMER_NEW      = 5;
  ACTION_CUSTOMER_EDIT     = 6;
  ACTION_CUSTOMER_DELETE   = 7;

  ACTION_SHOP_NEW          = 8;
  ACTION_SHOP_EDIT         = 9;
  ACTION_SHOP_DELETE       = 10;

  ACTION_PROJECT_NEW       = 11;
  ACTION_PROJECT_OPEN      = 12;

  ACTION_OFFSET_COUNT      = 50;
  ACTION_DATES_OFFSET      = 300;
  ACTION_MRU_OFFSET        = 350;

  SHOP_NO_CUSTOMER_TITLE   = '(kein Kunde)';
  SHOP_CUSTOMER_TITLE      = '%s, %s';

type
  TMouseStatus = (msDown, msUp, msMove, msNone);

  TMouseInfo = record
    Status: TMouseStatus;
    Button: TMouseButton;
    X: integer;
    Y: integer;
  end;

  TSidebarAction = (sbaNew, sbaEdit, sbaDelete, sbaNewCustomer, sbaEditCustomer, sbaDeleteCustomer);
  TSidebarActions = set of TSidebarAction;

  TMapAction = (
   {keine Aktion}        maNone,
   {Karten-Aktionen}     maHover, maBeginMove, maMove,
   {Navigator-Aktionen}  maNavHover, maNavMove,
   {Stand-Aktionen}      maShopHover, maShopMove, maShopRotate
  );

  TfrmMain = class(TForm)
    ilSidebar16: TPngImageList;
    ilMapEdit: TPngImageList;
    ilMenu: TPngImageList;
    ilSidebar32: TPngImageList;
    tiProjectOpen: TTimer;
    pCustomers: TPanel;
    pShops: TPanel;
    pCustomersFilter: TPanel;
    cbCustomersFilter: TComboBox;
    edCustomerFind: TEdit;
    pCustomersMain: TPanel;
    lvCustomers: TListView;
    lvCustomerShops: TListView;
    splCustomers: TSplitter;
    tbDockTop: TSpTBXDock;
    tbMenu: TSpTBXToolbar;
    tbMenuFile: TSpTBXSubmenuItem;
    tbMenuFileNew: TSpTBXItem;
    tbMenuFileOpen: TSpTBXItem;
    tbMenuFileClose: TSpTBXItem;
    TBXSubmenuItem2: TSpTBXSubmenuItem;
    TBXItem4: TSpTBXItem;
    tbPanProject: TSpTBXDockablePanel;
    TBXRadioButton2: TSpTBXRadioButton;
    TBXCheckBox1: TSpTBXCheckBox;
    tbToolJump: TSpTBXToolbar;
    TBXLabelItem1: TTBXLabelItem;
    tbToolJumpList: TSpTBXComboBoxItem;
    lvMax: TListView;
    tbMenuFileSettings: TSpTBXItem;
    tbMenuFileLine1: TSpTBXSeparatorItem;
    tbMenuFileShutdown: TSpTBXItem;
    tbMenuFileLine3: TSpTBXSeparatorItem;
    TBXSeparatorItem3: TSpTBXSeparatorItem;
    TBXSeparatorItem4: TSpTBXSeparatorItem;
    TBXItem7: TSpTBXItem;
    TBXItem8: TSpTBXItem;
    TBXItem9: TSpTBXItem;
    tbMenuView: TSpTBXSubmenuItem;
    TBXItem10: TSpTBXItem;
    TBXItem11: TSpTBXItem;
    TBXItem12: TSpTBXItem;
    TBXItem13: TSpTBXItem;
    TBXSeparatorItem5: TSpTBXSeparatorItem;
    tbMenuViewJump: TSpTBXItem;
    tbToolFastnav: TSpTBXToolbar;
    tbFastNavProject: TTBXVisibilityToggleItem;
    tbMenuFileLine2: TSpTBXSeparatorItem;
    tbMenuFileMRU: TTBXMRUListItem;
    tbFastNavMap: TTBXVisibilityToggleItem;
    tbFastNavCustomers: TTBXVisibilityToggleItem;
    tbFastNavShops: TTBXVisibilityToggleItem;
    tbMRUList: TTBXMRUList;
    tbDockLeft: TspTBXMultiDock;
    tbPanNavigation: TSpTBXDockablePanel;
    tbScrollMain: TTBXPageScroller;
    pSbDetails: TTBXAlignmentPanel;
    tbSbDetailsCpt: TTBXLabel;
    tbDetails: TTBXLabel;
    pSbDates: TTBXAlignmentPanel;
    tbSbDatesCpt: TTBXLabel;
    pSbNoProject: TTBXAlignmentPanel;
    tbSbNoProjectCpt: TTBXLabel;
    tbSbNoProjectOpen: TTBXLink;
    tbSbNoProjectNew: TTBXLink;
    pSbLastFiles: TTBXAlignmentPanel;
    tbSbLastFilesCpt: TTBXLabel;
    pSbActions: TTBXAlignmentPanel;
    tbSbActionsCpt: TTBXLabel;
    tbSbDates: TTBXAlignmentPanel;
    tbSbLastFiles: TTBXAlignmentPanel;
    tbDockRight: TspTBXMultiDock;
    tbDockBottom: TspTBXMultiDock;
    tbSbActions: TTBXAlignmentPanel;
    tbSbActionNew: TTBXLink;
    tbSbActionEdit: TTBXLink;
    tbSbActionDelete: TTBXLink;
    tbSbActionNewCustomer: TTBXLink;
    tbSbActionEditCustomer: TTBXLink;
    tbSbActionDeleteCustomer: TTBXLink;
    pMap: TPanel;
    pbMap: TPaintBox;
    Panel1: TPanel;
    edShopFind: TEdit;
    tbMenuViewFastnav: TSpTBXItem;
    pSbNavigator: TTBXAlignmentPanel;
    pbNavigator: TPaintBox;
    cbShopFilter: TComboBox;
    tbMenuViewNavigator: TSpTBXItem;
    spCustomizer: TSpTBXCustomizer;
    puCustomerShopsNew: TSpTBXPopupMenu;
    puCustomerShopsNewNew: TSpTBXItem;
    puCustomersEdit: TSpTBXPopupMenu;
    puCustomersEditNew: TSpTBXItem;
    puCustomersEditDelete: TSpTBXItem;
    puCustomersEditLine1: TSpTBXSeparatorItem;
    puCustomersEditEdit: TSpTBXItem;
    puCustomersNew: TSpTBXPopupMenu;
    puCustomersNewNew: TSpTBXItem;
    puCustomerShopsEdit: TSpTBXPopupMenu;
    puCustomerShopsEditNew: TSpTBXItem;
    puCustomerShopsEditDelete: TSpTBXItem;
    puCustomerShopsEditJump: TSpTBXItem;
    puCustomerShopsEditEdit: TSpTBXItem;
    puCustomerShopsEditLine1: TSpTBXSeparatorItem;
    puMapEdit: TSpTBXPopupMenu;
    puMapEditNew: TSpTBXItem;
    puMapEditDeleteBoth: TSpTBXItem;
    puMapEditDelete: TSpTBXItem;
    puMapEditEditShop: TSpTBXItem;
    puMapEditLine1: TSpTBXSeparatorItem;
    puMapNew: TSpTBXPopupMenu;
    puMapNewNew: TSpTBXItem;
    puMapEditEditCust: TSpTBXItem;
    btnCustomersFind: TSpTBXButton;
    btnShopFind: TSpTBXButton;

    // Hauptübersichten
    procedure showPanel(Panel: TWinControl);

    // Formularaktionen
    procedure formCreate(Sender: TObject);
    procedure formDestroy(Sender: TObject);

    // Aktionen bei geschlossenem Projekt
    procedure logoEventPaint(Sender: TObject);

    // Aktionen auf der Map-Fläche
    procedure mapEventPaint(Sender: TObject);
    procedure pbMapDblClick(Sender: TObject);

    // Menü-Aktionen
    procedure menuItemClick(Sender: TObject);

    procedure menuFileOpenClick(Sender: TObject);
    procedure menuFileCloseClick(Sender: TObject);
    procedure menuFileSettingsClick(Sender: TObject);
    procedure menuFileShutdownClick(Sender: TObject);

    procedure menuHelpInfoClick(Sender: TObject);

    // Popup-Aktionen (Stadtplan)
    procedure puMapEditEditClick(Sender: TObject);
    procedure puMapEditDeleteClick(Sender: TObject);
    procedure tiProjectOpenTimer(Sender: TObject);
    procedure btnCustomersFindClick(Sender: TObject);
    procedure lvCustomersEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure formClose(Sender: TObject; var Action: TCloseAction);
    procedure lvCustomersColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvCustomersDblClick(Sender: TObject);
    procedure lvCustomersMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvCustomersContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lvCustomersKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure puCustomersEditEditClick(Sender: TObject);
    procedure lvCustomerShopsDblClick(Sender: TObject);
    procedure puCustomersEditDeleteClick(Sender: TObject);
    procedure StandundKundelschen1Click(Sender: TObject);
    procedure puMapEditNewClick(Sender: TObject);
    procedure puCustomersNewNewClick(Sender: TObject);
    procedure puCustomersEditNewClick(Sender: TObject);
    procedure lvCustomerShopsContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    procedure puCustomerShopsNewNewClick(Sender: TObject);
    procedure puCustomerShopsEditEditClick(Sender: TObject);
    procedure puCustomerShopsEditJumpClick(Sender: TObject);
    procedure tbSbMapClick(Sender: TObject);
    procedure tbSbCustomersClick(Sender: TObject);
    procedure pbMapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMapMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pbMapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tbSbNoProjectOpenClick(Sender: TObject);
    procedure tbSbNoProjectNewClick(Sender: TObject);
    procedure tbSbProjectClick(Sender: TObject);
    procedure tbSbShopsClick(Sender: TObject);
    procedure sidebarClickLastFile(Sender: TObject);
    procedure sidebarClickShopNew(Sender: TObject);
    procedure sidebarClickShopEdit(Sender: TObject);
    procedure sidebarClickShopDelete(Sender: TObject);
    procedure sidebarClickNewCustomer(Sender: TObject);
    procedure sidebarClickEditCustomer(Sender: TObject);
    procedure sidebarClickDeleteCustomer(Sender: TObject);
    procedure sidebarClickDateSet(Sender: TObject);
    procedure lvCustomerShopsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tbPanNavigationResize(Sender: TObject);
    procedure pbNavigatorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tbPanNavigationVisibleChanged(Sender: TObject);
    procedure pbNavigatorMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pbNavigatorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnShopFindClick(Sender: TObject);
    procedure lvCustomerShopsEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure lvMaxEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure tbMRUListClick(Sender: TObject; const Filename: String);
    procedure tbPanProjectCloseQuery(Sender: TObject;
      var CanClose: Boolean);
    procedure pbNavigatorPaint(Sender: TObject);
    procedure lvMaxColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvCustomerShopsColumnClick(Sender: TObject;
      Column: TListColumn);
    procedure lvMaxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvMaxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvMaxDblClick(Sender: TObject);
    procedure lvMaxContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lvCustomerShopsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure puMapEditDeleteBothClick(Sender: TObject);
    procedure spCustomizerLayoutLoad(Sender: TObject; LayoutName: String;
      ExtraOptions: TStringList);
    procedure spCustomizerLayoutSave(Sender: TObject; LayoutName: String;
      ExtraOptions: TStringList);
    procedure mapLoadedPiece(Sender: TObject);
    procedure tbToolJumpListSelect(Sender: TTBCustomItem;
      Viewer: TTBItemViewer; Selecting: Boolean);
    procedure tbToolJumpListChange(Sender: TObject; const Text: WideString);
    procedure tbToolJumpListItemClick(Sender: TObject);
  private
    // Hauptübersichten
    Panels: array[0..2] of TWinControl;

    // Sidebar
    FSidebarActions: TSidebarActions;

    // Hauptobjekte
    Jimbo: TJimbo;
    Maps: TMaps;
    Map: TMap;
    Settings: TSettings;
    Backup: TBackup;
    Painter: TPainter;

    // Navigator
    FNavigatorMove: boolean;

    // Karte: Spezielle Rotationsvariablen
    rotateStartPoint: TPoint;
    rotateStartAngle: integer;
    rotateStartPos: integer;

    // Karte: Aktive Shops
    FShopSelectedID: integer;
    FShopHoverID: integer;
    FShopMoveID: integer;
    FShopRotateID: integer;

    // Karte: Maus-Status
    FMapMoveStartPoint: TPoint;
    FMapMoveStartRect: TRect;

    FMapAction: TMapAction;
    FMouse: TMouseInfo;

    // Listen
    hListArrowUp, hListArrowDown: hBitmap;
    FListArrow: TBitmap;

    // Silversun-Logo
    FLogoBitmap: TBitmap;

    // Sonstige
    FOpened: Boolean;

    function getShopHover: TShop;
    function getShopSelected: TShop;
    function getShopMove: TShop;
    function getShopRotate: TShop;
    function getOpenStatus: Boolean;

    procedure setShopHover(Shop: TShop);
    procedure setShopSelected(Shop: TShop);
    procedure setShopMove(Shop: TShop);
    procedure setShopRotate(Shop: TShop);
    procedure setOpenStatus(Value: Boolean);

    // Sonstige
    procedure saveReleaseAndHalt;
    procedure callbackResize(var Message: TWMSize); message WM_SIZE;

  public
    // Projekt-Aktionen
    procedure projectNew;
    procedure projectOpen(Filename: string);
    procedure projectOpenDlg;
    procedure projectOpenLast(Index: integer);
    procedure projectEdit;
    procedure projectClose;
    procedure projectSetDate(DateID: integer);

    // Karten-Aktionen
    procedure mapActionFindOut(X, Y: integer);
    procedure mapActionMove;
    procedure mapActionShopMoveBegin(X, Y: integer);
    procedure mapActionShopMove(X, Y: integer);
    procedure mapActionShopRotateBegin(X, Y: integer);
    procedure mapActionShopRotate(X, Y: integer);

    // Shop-Aktionen
    procedure shopNew(Position: TPoint; CustomerID: integer = -1);
    procedure shopEdit(shopID: integer; ShowShop: boolean = true);
    procedure shopDelete(shopID: integer; delOwner: boolean);

    // Kunden-Aktionen
    procedure customerNew;
    procedure customerEdit(customerID: integer);
    procedure customerDelete(customerID: integer);

    // Prozeduren bei geschlossenem Projekt
    procedure logoOpen;
    procedure logoClose;

    // Listen (Pfeile)
    procedure arrowsCreate;
    procedure arrowAdd(List: TListView; Column: integer; Asc: boolean);
    procedure arrowsFree;


    // Kundenübersicht
    procedure customerListCreate;
    procedure customerListFind(cfField: TCustomerField; Query: string);
    procedure customerListSave;

    procedure customerShopListCreate;
    procedure customerShopListUpdate;
    procedure customerShopListSave;
    procedure customerShopListDestroy;

    // Gesamtübersicht
    procedure shopListCreate;
    procedure shopListFind(maxField: integer; Query: string);
    procedure shopListSave;


    // Toolbar "Jump"
    procedure toolbarJumpUpdate;

    // Sidebar-Aktionen
    procedure sidebarUpdateLastFiles;

    procedure sidebarUpdateDetails(Str: string); overload;
    procedure sidebarUpdateDetails(Customer: TCustomer; Shop: TShop); overload;

    procedure sidebarUpdateActions(Actions: TSidebarActions);
    procedure sidebarUpdateDates;

    procedure sidebarViewCustomers;
    procedure sidebarViewMap;

    // Customizer
    procedure customizerCreate;
    procedure customizerLoad(isOpen: boolean);
    procedure customizerSave(isOpen: boolean);
    
    // Menü-Aktionen
    procedure toolbarOpened;
    procedure toolbarClosed;

    // Ansicht wechseln
    procedure viewMapShow;
    procedure viewCustomersShow;
    procedure viewShopsShow;

    // Eigenschaften
    property shopHover: TShop read getShopHover write setShopHover;
    property shopSelected: TShop read getShopSelected write setShopSelected;
    property shopMove: TShop read getShopMove write setShopMove;
    property shopRotate: TShop read getShopRotate write setShopRotate;

    property Opened: Boolean read getOpenStatus write setOpenStatus;
    procedure sidebarViewMax;
    procedure toolbarJumpDo;
  end;

var
  frmMain: TfrmMain;

implementation

uses uEditDialog, uJumpDialog, uSettings, uInfo, uProjectEdit, uLoading, dlgProjectNew;

{$R *.dfm}

procedure TfrmMain.formCreate(Sender: TObject);
begin
  // *** JIMBO.INI SCHREIBEN UND STOPPEN ***
  if (ParamStr(1) = '/saverelease') then saveReleaseAndHalt;

  // *** RESOURCEN PRÜFEN ***

  // resX.dll
  if not FileExists(ExtractFilePath(Application.ExeName) + FILENAME_RESX) then begin
    MessageDlg('Die Datei ''' + FILENAME_RESX + ''' wurde nicht gefunden oder ist nicht lesbar.'#13#10#13#10'Die Anwendung wird geschlossen.',mtError,[mbOK],0);
    Halt;
  end;

  // *** ERZEUGEN ***
  Painter := TPainter.Create;
  Maps := TMaps.Create;
  Map := TMap.Create;
  Settings := TSettings.Create;
  Backup := TBackup.Create;

  Maps.Folder := ExtractFilePath(Application.ExeName) + FILENAME_MAPDIR + '\';



  // *** ANSICHTEN ***

  // Übersicht-Paneelen
  Panels[0] := pCustomers;
  Panels[1] := pShops;
  Panels[2] := pMap;

  // Layout laden usw
  arrowsCreate;

 // pbMap.Align := alClient;
  pCustomers.Align := alClient;
  pShops.Align := alClient;
  pMap.Align := alClient;

  // *** OBJEKTE ***

  // Einstellungen
  Settings.Filename := ExtractFilePath(Application.ExeName) + FILENAME_XML;

  Settings.Load;
  Settings.Version := versionInfo.FileVersion;

  // Karte erstellen
  Map.DLLPath := ExtractFilePath(Application.ExeName);
  Map.OnLoadedPiece := mapLoadedPiece;

  // Painter erzeugen
  Painter.Canvas := pbMap.Canvas;
  Painter.Navigator.Destination := pbNavigator.Canvas;
  Painter.RectCanvas := Rect(0,0,frmMain.ClientWidth,frmMain.ClientHeight);

  DoubleBuffered := true;

  // Backup-Funktion
  Backup.Project := nil;
  Backup.ImportSettings(Settings.Cpx['Backup']);
  if not DirectoryExists(Backup.BackupDir) then
    Backup.BackupDir := ExtractFilePath(Application.ExeName) + FILENAME_BACKUPDIR + '\';

  // Spezielle Shops
  shopHover := nil;
  shopSelected := nil;
  shopMove := nil;
  shopRotate := nil;

  // Projekt schließen
  sidebarUpdateLastFiles;
  toolbarClosed;


  //TBXSetTheme('OfficeXP');
  //TBXSetTheme('Xito');

  showPanel(nil);

  FNavigatorMove := false;

  Opened := false;
  tiProjectOpen.Enabled := true;

  // Customizer laden (geschlossen)
  customizerLoad(false);
end;

procedure TfrmMain.formDestroy(Sender: TObject);
begin
  arrowsFree;

  Maps.Free;
  Map.Free;
  Painter.Free;
  Backup.Free;
  Settings.Free;
end;

procedure TfrmMain.saveReleaseAndHalt;
begin
  // Einstellungen laden
  Settings := TSettings.Create;
  Settings.Filename := ExtractFilePath(Application.ExeName) + FILENAME_XML;

  Settings.Load;
  Settings.Version := versionInfo.FileVersion;

  Settings.Save;
  Halt;
end;

procedure TfrmMain.mapEventPaint(Sender: TObject);
begin
  inherited;

  if not Opened then exit;
//  if not pbMap.Visible then exit;

  Painter.Paint;
end;

procedure TfrmMain.menuFileShutdownClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.pbMapDblClick(Sender: TObject);
var X, Y: integer;
begin
  if not Opened then exit;

  X := FMouse.X - Painter.RectCanvas.Left + Map.Rect.Left;
  Y := FMouse.Y - Painter.RectCanvas.Top + Map.Rect.Top;

  if shopMove is TShop then shopMove.setPosition(X,Y);
  Painter.endMove;

  // Ausgewählten Stand bearbeiten
  if (shopSelected is TShop) then begin
    shopEdit(shopSelected.ID);

    shopMove := nil;
    exit;
  end;

  // Neuen Stand anlegen
  shopNew(Point(X,Y));
  shopMove := nil;
end;

procedure TfrmMain.sidebarViewMap;
var Customer: TCustomer;
begin
  pSbNoProject.Visible := false;
  pSbLastFiles.Visible := false;

  pSbDates.Visible := true;
  pSbActions.Visible := true;

  if (shopSelected is TShop) then begin
    Customer := Jimbo.Customers.byID(shopSelected.customerID);

    sidebarUpdateDates;
    sidebarUpdateActions([sbaNew,sbaEdit,sbaDelete]);
    sidebarUpdateDetails(Customer,shopSelected);
  end

  else begin
    sidebarUpdateDates;
    sidebarUpdateActions([sbaNew]);
    sidebarUpdateDetails(nil,nil);
  end;

  Painter.Paint;
end;


procedure TfrmMain.sidebarViewCustomers;
var i, ID, cIDs: integer;
    Customer: TCustomer;
    isCust: boolean;
    str: string;
begin
  pSbNoProject.Visible := false;
  pSbLastFiles.Visible := false;

  pSbDates.Visible := false;
  pSbActions.Visible := true;

  // Kunde ausgewählt?
  isCust := (lvCustomers.SelCount > 0);
  if isCust then begin
    isCust := getIntFromListItem(lvCustomers.Selected,ID);
    if isCust then Customer := Jimbo.Customers.byID(ID);

    isCust := Customer is TCustomer;
  end;

  // Kein Kunde
  if (not isCust) then begin
    // Daten sammeln
    cIDs := 0; for i := 0 to Jimbo.Customers.Count-1 do begin
      if Jimbo.Customers[i].cID <= 0 then continue;
      inc(cIDs);
    end;

    str := intToStr(Jimbo.Customers.Count) + ' Kunde(n)'#13#10
         + intToStr(cIDs) + ' davon mit Kd-Nr.'#13#10#13#10

         + intToStr(Jimbo.Shops.Count) + 'Stände';

    sidebarUpdateDetails(str);
    sidebarUpdateActions([sbaNewCustomer]);

    customerShopListUpdate;
  end

  // Ausgewählten Kunden im Detail zeigen
  else begin
    // Alles updaten oder nur die Details
    sidebarUpdateDetails(Customer,nil);
    sidebarUpdateActions([sbaNewCustomer,sbaEditCustomer,sbaDeleteCustomer,sbaNew]);

    // Shop-Liste updaten
    customerShopListUpdate;
  end;
end;

procedure TfrmMain.shopNew(Position: TPoint; CustomerID: integer = -1);
var i: integer;

    Shop: TShop;
    Customer: TCustomer;

    Location: TLocation;
    dlgNew: TEditDialog;
begin

  // Dialog öffnen
  dlgNew := TEditDialog.Create(Self);
  dlgNew.Mode := sdNew;

  dlgNew.Project := Jimbo;
  dlgNew.Locations := Map.Locations;

  // Kunde ?
  if CustomerID <> -1 then begin
    Customer := Jimbo.Customers.byID(CustomerID);
    if Customer is TCustomer then dlgNew.customerID := CustomerID;
  end;

  // Nächste Location erkennen
  if (Position.X <> -1) and (Map.Locations.At(Position.X,Position.Y,Location)) then
    dlgNew.LocationID := Location.ID;

  if not dlgNew.Execute then begin
    dlgNew.Free;
    exit;
  end;

  Shop := Jimbo.Shops.byID(dlgNew.shopID);
  dlgNew.Free;

  // Wenn Location vorhanden, dann genau dort platzieren
  if (Shop.locationID = -1) then Shop.setPosition(Position.X,Position.Y)
  else begin
    Location := Map.Locations.byID(Shop.locationID);
//    if not (Location is TLocation) then Shop.setPosition(Position.X,Position.Y);

    Shop.setPosition(Location.X,Location.Y);
  end;

  // Wenn der Tag nicht gewählt ist, dann diesen Tag auswählen
  if Jimbo.ShopDates.indexOf(Shop.ID,Jimbo.DateID) = -1 then begin
    for i := 0 to Jimbo.Dates.Count-1 do begin
      if (not Jimbo.Dates[i].Active) or (Jimbo.ShopDates.indexOf(Shop.ID,Jimbo.Dates[i].ID) = -1) then continue;

      projectSetDate(Jimbo.Dates[i].ID);
      break;
    end;
  end;

  // Preis updaten
  Shop.Price := Jimbo.PriceCalc(Shop.ID);
  Shop.Save;

  // Zeichnen
  Map.Position := Point(Shop.X,Shop.Y);

  Painter.setSelection(Shop.ID);
  Painter.Position := Point(Map.Rect.Left,Map.Rect.Top);

  viewMapShow;

  //Painter.Update;
  //Painter.Paint;

  Painter.Paint(Shop.ID);
end;

procedure TfrmMain.shopEdit(shopID: integer; ShowShop: boolean = true);
var i, customerID: integer;
    oldPos: TPoint;
    oldW, oldH: double;
    mustRepaint: boolean;

    Shop: TShop;
    dlgEdit: TEditDialog;
begin
  Shop := Jimbo.Shops.byID(shopID);
  if not (Shop is TShop) then raise Exception.Create('falsche shop-id');

  if not Shop.hasOwner then customerID := -1
  else customerID := Shop.customerID;

  dlgEdit := TEditDialog.Create(Self);
  dlgEdit.Mode := sdEdit;

  if ShowShop then dlgEdit.Panel := edpShop
  else dlgEdit.Panel := edpCustomer;

  dlgEdit.shopID := shopID;
  dlgEdit.customerID := customerID;

  dlgEdit.Project := Jimbo;
  dlgEdit.Locations := Map.Locations;

  oldPos := Point(Shop.X,Shop.Y);
  oldW := Shop.Width; oldH := Shop.Height;

  if not dlgEdit.Execute then begin
    dlgEdit.Free;
    exit;
  end;

  dlgEdit.Free;

  // Wenn der Tag nicht gewählt ist, dann diesen Tag auswählen
  if Jimbo.ShopDates.indexOf(Shop.ID,Jimbo.DateID) = -1 then begin
    for i := 0 to Jimbo.Dates.Count-1 do begin
      if (not Jimbo.Dates[i].Active) or (Jimbo.ShopDates.indexOf(Shop.ID,Jimbo.Dates[i].ID) = -1) then continue;

      projectSetDate(Jimbo.Dates[i].ID);
      break;
    end;
  end;

  // Preis updaten
  Shop.Price := Jimbo.PriceCalc(Shop.ID);
  Shop.Save;

  // Map anzeigen?
  mustRepaint := (not SameValue(oldW,Shop.Width,0.05)) or (not SameValue(oldH,Shop.Height,0.05))
              or (Shop.X <> oldPos.X) or (Shop.Y <> oldPos.Y);

  // Zeichnen
  if mustRepaint or pMap.Visible then begin
    Painter.setSelection(shopID);

    if not Map.Visible(Shop.X,Shop.Y) then begin
      Map.Position := Point(Shop.X,Shop.Y);
      Painter.Position := Point(Map.Rect.Left,Map.Rect.Top);
    end;

    viewMapShow;

    //Painter.Update;
    //Painter.Paint;

    Painter.Paint(shopID);
  end

  // Listeneintrag ändern (Kunden)
  else if pCustomers.Visible then begin
    // ..
  end;
end;

procedure TfrmMain.shopDelete(shopID: integer; delOwner: boolean);
var askStr: string;
    Shop: TShop;
begin
  shopMove := nil;

  Shop := Jimbo.Shops.byID(shopID);
  if not (Shop is TShop) then raise Exception.Create('Fehler beim Löschen des Shops');

  delOwner := delOwner and Shop.hasOwner and Jimbo.Customers.Exists(Shop.customerID);

  // Mehrere Shops mit dieser Kunden-ID vorhanden?
  if delOwner and (Jimbo.Shops.Count(Shop.customerID) > 1) then begin
    {then exit} if (MessageDlg('Dieser Besitzer des Standes kann nicht gelöscht werden, da noch andere Stände auf ihn zugewiesen sind.'#13#10'Soll der Stand trotzdem gelöscht werden?',mtConfirmation,[mbYes,mbNo],0) = mrNo) then exit;
    delOwner := false;
  end;

  if delOwner then askStr := 'Möchten Sie den gewählten Stand und seiner Besitzer endgültig aus der Datenbank löschen?'
  else askStr := 'Möchten Sie diesen Stand aus der Datenbank entfernen?';

  if MessageDlg(askStr,mtConfirmation,[mbYes,mbNo],0) = mrNo then exit;

  // Aus der Liste löschen & der Datenbank
  Jimbo.Shops.Delete(shopID,true);

  // Kunde löschen
  if delOwner then Jimbo.Customers.Delete(Shop.customerID,true);
end;    

function TfrmMain.getShopHover: TShop;
var i: integer;
begin
  Result := nil;

  for i := 0 to Jimbo.Shops.Count-1 do begin
    if Jimbo.Shops[i].ID <> FShopHoverID then continue;
    Result := Jimbo.Shops[i]; exit;
  end;
end;

function TfrmMain.getShopMove: TShop;
var i: integer;
begin
  Result := nil;

  for i := 0 to Jimbo.Shops.Count-1 do begin
    if Jimbo.Shops[i].ID <> FShopMoveID then continue;
    Result := Jimbo.Shops[i]; exit;
  end;
end;

function TfrmMain.getShopRotate: TShop;
var i: integer;
begin
  Result := nil;

  for i := 0 to Jimbo.Shops.Count-1 do begin
    if Jimbo.Shops[i].ID <> FShopRotateID then continue;
    Result := Jimbo.Shops[i]; exit;
  end;
end;

function TfrmMain.getShopSelected: TShop;
var i: integer;
begin
  Result := nil;

  for i := 0 to Jimbo.Shops.Count-1 do begin
    if Jimbo.Shops[i].ID <> FShopSelectedID then continue;
    Result := Jimbo.Shops[i]; exit;
  end;
end;

procedure TfrmMain.setShopMove(Shop: TShop);
begin
  if not (Shop is TShop) then FShopMoveID := -1
  else FShopMoveID := Shop.ID;
end;

procedure TfrmMain.setShopHover(Shop: TShop);
begin
  if not (Shop is TShop) then FShopHoverID := -1
  else FShopHoverID := Shop.ID;
end;

procedure TfrmMain.setShopRotate(Shop: TShop);
begin
  if not (Shop is TShop) then FShopRotateID := -1
  else FShopRotateID := Shop.ID;
end;

procedure TfrmMain.setShopSelected(Shop: TShop);
begin
  if not (Shop is TShop) then FShopSelectedID := -1
  else FShopSelectedID := Shop.ID;
end;


procedure TfrmMain.menuFileSettingsClick(Sender: TObject);
begin
  frmSettings.Prepare(Settings,Backup);
  if frmSettings.ShowModal <> mrOK then exit;

  Settings.Save;
end;

procedure TfrmMain.tiProjectOpenTimer(Sender: TObject);
var R: ^TRect;
begin
  tiProjectOpen.Enabled := false;

  //customerListCreate;
  { customerShopList wird erst bei projectOpen erzeugt }

  // Letzte Veranstaltung laden
  if (Settings.Cpx['Common']['OpenLast'].asBool) and (Settings.lastFiles.Count > 0) then begin
    projectOpen(Settings.lastFiles[0]);
    sidebarViewMap;

    exit;
  end;

  sidebarUpdateLastFiles;

  // Fenster-Größe
  if Settings.Cpx['Layout'].Exists('WindowRect') then begin
    New(R);
    try
      Settings.Cpx['Layout']['WindowRect'].getAsBinary(R);

      if R^.Right <= 0 then R^.Right := Width;
      if R^.Bottom <= 0 then R^.Bottom := Height;

      Left := R^.Left;
      Top := R^.Top;
      Width := R^.Right;
      Height := R^.Bottom;
    finally
      freeMem(R);
    end;
  end;
end;

procedure TfrmMain.menuFileOpenClick(Sender: TObject);
begin
  projectOpenDlg;
end;

procedure TfrmMain.menuHelpInfoClick(Sender: TObject);
begin
  with TInfoDialog.Create(Self) do begin
    ShowModal;
    Free;
  end;
end;

procedure TfrmMain.menuItemClick(Sender: TObject);
var Index: integer;
    Filename: string;
begin
  if not (Sender is TMenuItem) then exit;
  Index := (Sender as TMenuItem).Tag - 1;

  projectOpenLast(Index);
end;

procedure TfrmMain.projectOpen(Filename: string);
var i: integer;
    loadDlg: TLoadingDialog;
begin
  if not FileExists(Filename) then begin
    MessageDlg('Die angegebene Datei konnte nicht gefunden werden.',mtInformation,[mbOK],0);
    exit;
  end;

  // Wenn noch geöffnet, schließen
  if Opened then projectClose;

  // Jimbo Objekt erzeugen
  // FEHLERBEHANDLUNG
  Jimbo := TJimbo.Create;

  // Ladebildschirm
  loadDlg := TLoadingDialog.Create(Self);
  loadDlg.Open('Veranstaltung laden ...','Bitte warten Sie während Jimbo die gewählte Datei öffnet.');

  // Datenbank laden
  try
    Jimbo.Open(Filename);
  except
    loadDlg.Close;
    loadDlg.Free;

    MessageDlg('Fehler beim Laden der Projektdatei',mtInformation,[mbOK],0);

    Jimbo.Close;
    Jimbo.Free;

    exit;
  end;

  // Karte laden
  loadDlg.Title := 'Karte laden ...';

  try
    if not Map.Open(Maps.Folder+Jimbo.MapFile,Jimbo.MapKey) then
      raise Exception.Create('');
  except
    loadDlg.Close;
    loadDlg.Free;

    MessageDlg('Fehler beim Laden der Karte '+Jimbo.MapFile,mtInformation,[mbOK],0);

    Jimbo.Close;
    Jimbo.Free;

    exit;
  end;

  // Wichtig: Erst hier werden die notwendigen Teile geladen.
  loadDlg.Title := 'Kartenteile laden ...';

  Map.Rect := Rect(
    Jimbo.Position.X,
    Jimbo.Position.Y,
    Jimbo.Position.X + ClientWidth - Painter.RectCanvas.Left,
    Jimbo.Position.Y + ClientHeight - Painter.RectCanvas.Top
  );

  // Letzte Ansicht (geschlossen) speichern
  customizerSave(false);

  // Painter initialisieren (Referenzen setzen)
  Painter.Width := Map.Width;
  Painter.Height := Map.Height;

  Painter.Project := Jimbo;
  Painter.Map := Map;
  Painter.Navigator.Source := Map.Navigator;

  tbPanNavigationResize(nil);

  Painter.Position := Point(Map.Rect.Left,Map.Rect.Top);

  // Malen :)
  Painter.Update;
  Painter.Paint;

  // Backupper
  Backup.Project := Jimbo;

  // Datei hinzufügen
  Settings.lastFiles.Add(Filename);
  Settings.Save;

  // Titelleiste schreiben
  tbPanProject.Caption := Jimbo.Title;
  Caption := 'Jimbo Planer - ' + ExtractFileName(Filename);

  // Sidebar+Menü aktualisieren
  toolbarOpened;
  toolbarJumpUpdate;

  sidebarUpdateLastFiles;
  sidebarViewMap;

  viewMapShow;

  // Customizer laden (offen)
  customizerLoad(true);
  Opened := true;

  loadDlg.Close;
end;

procedure TfrmMain.projectOpenLast(Index: integer);
var Filename: string;
begin
  // Item löschen
  if (Index < 0) or (Index >= Settings.lastFiles.Count) then begin
    sidebarUpdateLastFiles;
    exit;
  end;

  Filename := Settings.lastFiles[Index];

  if Opened then Jimbo.Close;
  projectOpen(Filename);

  // Menü-Liste aktualisieren
  Settings.lastFiles.Add(Filename);
  sidebarUpdateLastFiles;
end;


procedure TfrmMain.menuFileCloseClick(Sender: TObject);
begin
  projectClose;
end;

procedure TfrmMain.puMapEditEditClick(Sender: TObject);
begin
  if not (shopSelected is TShop) then exit;

  shopEdit(shopSelected.ID, (Sender is TSpTBXItem) and ((Sender as TSpTBXItem).Name = 'puMapEditEditShop') );
end;

procedure TfrmMain.puMapEditDeleteClick(Sender: TObject);
begin
  if not (shopSelected is TShop) then exit;
  shopDelete(shopSelected.ID,false);
end;

procedure TfrmMain.showPanel(Panel: TWinControl);
var i: integer;
begin
  for i := 0 to Length(Panels)-1 do begin
    if (Panels[i] <> Panel) and (Panels[i].Visible) then Panels[i].Visible := false
    else if (Panels[i] = Panel) and (not Panels[i].Visible) then Panels[i].Visible := true;
  end;
end;

procedure TfrmMain.viewMapShow;
begin
  sidebarViewMap;

  pSbDates.Visible := true;
  tbFastNavMap.Checked := true;

  showPanel(pMap);

  Map.Rect := Rect(
    Map.Rect.Left,
    Map.Rect.Top,
    Map.Rect.Left + pbMap.ClientWidth,
    Map.Rect.Top + pbMap.ClientHeight
  );

  Painter.RectCanvas := Rect(0,0,pbMap.Width,pbMap.Height);

  Painter.Update;
  Painter.Paint;
end;

procedure TfrmMain.viewCustomersShow;
begin
  sidebarViewCustomers;

  showPanel(pCustomers);

  tbFastNavCustomers.Checked := true;

  if lvCustomers.Columns.Count = 0 then customerListCreate;
  if lvCustomerShops.Columns.Count = 0 then customerShopListCreate;

  lvCustomers.SetFocus;
  if lvCustomers.SelCount > 0 then lvCustomerShops.SetFocus;
end;

procedure TfrmMain.projectEdit;
var i: integer;

    dlgEdit: TProjectEditDialog;
    dlgLoad: TLoadingDialog;
begin
  dlgEdit := TProjectEditDialog.Create;
  dlgEdit.Project := Jimbo;
  dlgEdit.Maps := Maps;

  if not dlgEdit.Execute then begin
    dlgEdit.Free;
    exit;
  end;

  // Stand-Preise berechnen
  dlgLoad := TLoadingDialog.Create(Self);
  dlgLoad.Open('Preise berechnen...','Bitte haben Sie einen Moment Geduld.');

  for i := 0 to Jimbo.Shops.Count-1 do begin
    Jimbo.Shops[i].Price := Jimbo.priceCalc(Jimbo.Shops[i].ID);
    Jimbo.Shops[i].Save;
  end;

  dlgLoad.Close;
  dlgLoad.Free;

  tbPanProject.Caption := Jimbo.Title;
  sidebarUpdateDates;

  dlgEdit.Free;
end;

procedure TfrmMain.projectClose;
begin
  if Opened then begin
    customizerSave(true);
    if Backup.Enabled then Backup.Backup;
  end

  else begin
    customizerSave(false);
  end;

  showPanel(nil);
  Jimbo.Position := Painter.Position;

  // Speichern und Ende
  Jimbo.MapKey := Map.Key;
  
  Jimbo.Close;
  Map.Close;

  // Backupper
  Backup.Project := nil;

  // Alles wieder auf Anfang
  customerShopListDestroy;

  sidebarUpdateLastFiles;
  toolbarClosed;

  tbPanProject.Caption := 'Veranstaltung';
  Caption := 'Jimbo Planer';

  // Jimbo zerstören
  freeAndNil(Jimbo);

  customizerLoad(false);
  Opened := false;
end;

procedure TfrmMain.sidebarUpdateLastFiles;
var i, lH: integer;
    menuItem: TSpTBXItem;
begin
  // MENÜ + SIDEBAR

  // Löschen
  tbMenuFileLine3.Visible := Settings.lastFiles.Count > 0;

  while tbSbLastFiles.ControlCount > 0 do
    tbSbLastFiles.RemoveControl(tbSbLastFiles.Controls[0]);

  while tbMRUList.Items.Count > 0 do
    tbMRUList.Remove(tbMRUList.Items[0]);

  // Adden
  for i := 0 to Settings.lastFiles.Count-1 do begin
    // Menü
    tbMRUList.Add(Settings.lastFiles[i]);

    // Sidebar
    with TTBXLink.Create(tbSbLastFiles) do begin
      Parent := tbSbLastFiles;

      Top := 0;

      Margins.Left := 5;
      Margins.Right := 5;
      Margins.Top := 3;

      Align := alTop;
      Cursor := crArrow;

      Caption := ExtractFileName(Settings.lastFiles[i]);
      Hint := Settings.lastFiles[i];

      Tag := i;
      OnClick := sidebarClickLastFile;
    end;
  end;
end;

procedure TfrmMain.btnCustomersFindClick(Sender: TObject);
var cfField: TCustomerField;
begin
  //customerListCreate;
  cfField := cfIdToField(cbCustomersFilter.ItemIndex);
  customerListFind(cfField,edCustomerFind.Text);

  with Settings.Cpx['Lists']['Customers'] do begin
    Items['FindField'].asInt := cfFieldToId(cfField);
    Items['FindQuery'].asStr := edCustomerFind.Text;
  end;
end;

procedure TfrmMain.lvCustomersEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

procedure TfrmMain.formClose(Sender: TObject; var Action: TCloseAction);
begin
  // Listenbreiten speichern
  customerListSave;
  customerShopListSave;
  shopListSave;

  Backup.ExportSettings(Settings.Cpx['Backup']);

//  customizerSave(Opened);
  if Opened then projectClose
  else customizerSave(false);

  // Einstellungen speichern
  Settings.Save;
end;

procedure TfrmMain.projectSetDate(dateID: integer);
var i: integer;
    AChecked: Boolean;
begin
  // FEHLERBEHANDLUNG
  if Jimbo.Dates.indexOf(dateID) = -1 then exit;

  // In Jimbo aktualisieren
  Jimbo.dateID := dateID;

  if Assigned(ShopSelected) and (not Jimbo.checkDate(Jimbo.DateID,ShopSelected.ID)) then begin
    Painter.setSelection(-1);
    ShopSelected := nil;
    viewMapShow;
  end;


  // Sidebar
  SidebarUpdateDates;
  
  Painter.Update;
  Painter.Paint;
end;

procedure TfrmMain.callbackResize(var Message: TWMSize);
var R: ^TRect;
begin
  if not frmMain.Visible then exit;

  case Opened of
    // Nicht geöffnet: Silversun Logo zeigen
    false: begin
      Paint;
    end;

    true: if (Message.SizeType = Integer(wsMaximized)) or (Message.SizeType = Integer(wsNormal)) then begin
        frmMain.Realign;

        Map.Rect := Rect(
          Map.Rect.Left,
          Map.Rect.Top,
          Map.Rect.Left + pbMap.ClientWidth,
          Map.Rect.Top + pbMap.ClientHeight
        );

        Painter.RectCanvas := Rect(0,0,pbMap.Width,pbMap.Height);

        Painter.Update;
        Painter.Paint;
    end;
  end;

  //  Fenster-Größe und Positionen
  Settings.Cpx['Layout']['WindowState'].asInt := Integer(WindowState);

  New(R); R^ := Rect(Left,Top,Width,Height);
  Settings.Cpx['Layout']['WindowRect'].setAsBinary(R,sizeOf(R^));
  freeMem(R);


  inherited;
end;

procedure TfrmMain.setOpenStatus(Value: Boolean);
begin
  if Value then begin
    pbMap.OnDblClick := pbMapDblClick;
    pbMap.OnMouseDown := pbMapMouseDown;
    pbMap.OnMouseMove := pbMapMouseMove;
    pbMap.OnMouseUp := pbMapMouseUp;
    pbMap.OnPaint := mapEventPaint;
    OnPaint := nil;

    logoClose;
  end else begin
    logoOpen;

    pbMap.OnDblClick := nil;
    pbMap.OnMouseDown := nil;
    pbMap.OnMouseMove := nil;
    pbMap.OnMouseUp := nil;
    pbMap.OnPaint := nil;
    OnPaint := logoEventPaint;

    Paint;
  end;

  FOpened := Value;
end;

function TfrmMain.getOpenStatus: Boolean;
begin
  Result := Assigned(Jimbo) and (Jimbo is TJimbo) and FOpened and Jimbo.Opened and Map.Opened;
end;

procedure TfrmMain.logoOpen;
var ResX: THandle;
    Jpg: TJPEGImage;
    Res: TResourceStream;
begin
  // Sidebar-Resourcen laden
  FLogoBitmap := TBitmap.Create;
  ResX := LoadLibrary(PChar(ExtractFilePath(Application.ExeName) + FILENAME_RESX));

  if ResX = 0 then raise Exception.Create('Resource datei nicht gefunden');

  Jpg := TJPEGImage.Create;

  try
    Res := TResourceStream.Create(ResX,'SILVERSUN',RT_RCDATA);

    try
      Jpg.LoadFromStream(Res);
      FLogoBitmap.Assign(Jpg);
    finally
      Res.Free;
    end;

  finally
    Jpg.Free;
  end;

  FreeLibrary(ResX);
end;

procedure TfrmMain.logoClose;
begin
  if FLogoBitmap is TBitmap then FLogoBitmap.Free;
end;

procedure TfrmMain.logoEventPaint(Sender: TObject);
var availRect, bmpRect: TRect;
    availW, availH, bmpL, bmpT: integer;
begin
  availRect := Rect(0,0,ClientWidth,ClientHeight);

  availW := availRect.Right - availRect.Left;
  availH := availRect.Bottom - availRect.Top;
  bmpL := (FLogoBitmap.Width - availW) div 2;
  bmpT := (FLogoBitmap.Height - availH) div 2;

  bmpRect := Rect(bmpL,bmpT,bmpL+availW,bmpT+availH);

  Canvas.CopyRect(availRect,FLogoBitmap.Canvas,bmpRect);
end;

procedure TfrmMain.toolbarClosed;
begin
  tbMenuFileClose.Enabled := false;
  tbMenuView.Visible := false;

  pSbActions.Visible := false;
  pSbDates.Visible := false;
  pSbDetails.Visible := false;

  tbPanNavigation.Visible := false;

  tbToolJump.Visible := false;
  tbToolFastnav.Visible := false;

  pSbNoProject.Visible := true;
  pSbLastFiles.Visible := true;

  pSbNoProject.Top := 0;
  pSbLastFiles.Top := pSbNoProject.Height;
end;

procedure TfrmMain.toolbarOpened;
begin
  tbMenuFileClose.Enabled := true;
  tbMenuView.Visible := true;

  pSbNoProject.Visible := false;
  pSbLastFiles.Visible := false;

  pSbDates.Visible := true;
  pSbActions.Visible := true;
end;

procedure TfrmMain.customerNew;
var dlgNew: TEditDialog;
begin
  dlgNew := TEditDialog.Create(Self);
  dlgNew.Mode := sdNewCustomer;

  dlgNew.Project := Jimbo;
  dlgNew.Locations := Map.Locations;

  dlgNew.Execute;

  dlgNew.Free;
end;

procedure TfrmMain.customerEdit(customerID: integer);
var dlgEdit: TEditDialog;
begin
  dlgEdit := TEditDialog.Create(Self);
  dlgEdit.Mode := sdEditCustomer;
  dlgEdit.customerID := customerID;

  dlgEdit.Project := Jimbo;
  dlgEdit.Locations := Map.Locations;

  dlgEdit.Execute;

  dlgEdit.Free;
end;

procedure TfrmMain.customerDelete(customerID: integer);
var i: integer;

    Customer: TCustomer;
    Shops: TShops;
begin
  shopMove := nil;

  Customer := Jimbo.Customers.byID(customerID);
  if not (Customer is TCustomer) then raise Exception.Create('Fehler beim Löschen des Kunden');

  // Ja oder Nein?
  if MessageDlg('Möchten Sie den ausgewählten Kunden mit allen eingetragenen Ständen endgültig aus der Datenbank löschen?',mtConfirmation,[mbYes,mbNo],0) = mrNo then exit;

  // Stände löschen
  Shops := Jimbo.Shops.byCustomer(Customer.ID);
  for i := 0 to Shops.Count-1 do Jimbo.Shops.Delete(Shops[i].ID,true);

  // Kunde löschen
  Jimbo.Customers.Delete(customerID,true);
end;

procedure TfrmMain.lvCustomersColumnClick(Sender: TObject;
  Column: TListColumn);
var Field: TCustomerField;
begin
  Field := cfIdToField(Column.ID);

  with Settings.Cpx['Lists']['Customers'] do begin
    if (cfIdToField(Items['SortField'].asInt) = Field) then Items['SortAsc'].asBool := not Items['SortAsc'].asBool
    else Items['SortAsc'].asBool := true;

    Items['SortField'].asInt := cfFieldToId(Field);
    customerListFind(cfIdToField(Items['FindField'].asInt),Items['FindQuery'].asStr);
  end;
end;

procedure TfrmMain.customerListCreate;
var i, j: integer;
    a: array of integer;
begin
  with Settings.Cpx['Lists']['Customers'] do begin
    // Suchfeld updaten
    edCustomerFind.Text := Items['FindQuery'].asStr;

    disposeFromComboBox(cbCustomersFilter);
    cbCustomersFilter.Clear;

    for i := 0 to Items['Captions'].asList.Count-1 do begin
      j := cbCustomersFilter.Items.Add(Items['Captions'].asList[i].asStr);
      writeIntToStringListItem(cbCustomersFilter.Items,j,i);

      if Items['FindField'].asInt = j then cbCustomersFilter.ItemIndex := j;
    end;

    // Kundenübersicht-ListView laden
    lvCustomers.Columns.BeginUpdate;
    setLength(a,Items['Captions'].asList.Count);

    for i := 0 to Items['Captions'].asList.Count-1 do begin
      with lvCustomers.Columns.Add do begin
        Caption := Items['Captions'].asList[i].asStr;

        Width := Items['Widths'].asList[i].asInt;
        a[i] := Items['Order'].asList[i].asInt;
      end;
    end;

    lvCustomers.Columns.EndUpdate;
    lvCustomers.Repaint;

    Application.ProcessMessages;

    // Spalten sortieren
    ListView_SetColumnOrderArray(lvCustomers.Handle,lvCustomers.Columns.Count,pInteger(a));
    lvCustomers.Refresh;

    // Letzte suche starten
    customerListFind(cfIdToField(Items['FindField'].asInt),Items['FindQuery'].asStr);
  end;
end;

procedure TfrmMain.customerListFind(cfField: TCustomerField; Query: string);
var i: integer;
    listItem: TListItem;

    Customer: TCustomer;
    Customers: TCustomers;
begin
  Customers := Jimbo.Customers.Find(cfField,edCustomerFind.Text);

  with Settings.Cpx['Lists']['Customers'] do
    Customers.sortBy(cfIdToField(Items['SortField'].asInt),Items['SortAsc'].asBool);

  lvCustomers.Clear;

  for i := 0 to Customers.Count-1 do begin
    Customer := Customers[i];

    listItem := lvCustomers.Items.Add;
    listItem.Caption := Customer.Lastname;
    listItem.SubItems.Add(Customer.Firstname);
    listItem.SubItems.Add(Customer.Company);
    listItem.SubItems.Add(Customer.Address);
    listItem.SubItems.Add(intToStr(Customer.ZIP));
    listItem.SubItems.Add(Customer.City);
    listItem.SubItems.Add(Customer.Phone);
    listItem.SubItems.Add(Customer.eMail);
    listItem.SubItems.Add(Customer.Other);
    listItem.SubItems.Add(intToStr(Customer.cID));
    listItem.SubItems.Add('');

    // Customer-ID anfügen
    writeIntToListItem(listItem,Customer.ID);
  end;

  Customers.Free;

 { with Settings.Cpx['Lists']['Customers'] do
    arrowAdd(lvCustomers,Items['SortField'].asInt,Items['SortAsc'].asBool);}
end;

procedure TfrmMain.lvCustomersDblClick(Sender: TObject);
var ID: integer;
begin
  if not (lvCustomers.Selected is TListItem) then exit;

  getIntFromListItem(lvCustomers.Selected,ID);
  customerEdit(ID);
end;

procedure TfrmMain.lvCustomersMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  sidebarViewCustomers;
end;


procedure TfrmMain.customerShopListUpdate;
var i, j, ID: integer;
    pInt: pInteger;
    listItem: TListItem;

    DateStr: string;
    Price, tmpFloat: double;

    Customer: TCustomer;
    Shops: TShops;
    Shop: TShop;
    sType: TShopType;
begin
  disposeFromListView(lvCustomerShops);
  lvCustomerShops.Clear;

  if not (lvCustomers.Selected is TListItem) then exit;

  // FEHLERBEHANDLUNG
  ID := pInteger(lvCustomers.Selected.Data)^;
  Customer := Jimbo.Customers.byID(ID);

  if not (Customer is TCustomer) then exit;

  Shops := Jimbo.Shops.byCustomer(ID);
  if not (Shops is TShops) then exit;

  Shops.sortBy(
    sfIdToField(Settings.Cpx['Lists']['Shops']['SortField'].asInt),
    Settings.Cpx['Lists']['Shops']['SortAsc'].asBool
  );

  for i := 0 to Shops.Count-1 do begin
    Shop := Shops[i];
    sType := Jimbo.shopTypes.byID(Shop.typeID);

    DateStr := '';
    Price := 0;

    for j := 0 to Jimbo.Dates.Count-1 do begin
      if Jimbo.shopDates.indexOf(Jimbo.Dates[j].ID,Shop.ID) = -1 then continue;

      if DateStr <> '' then DateStr := DateStr + ', ';
      DateStr := DateStr + Jimbo.Dates[j].Short;
    end;

    if DateStr <> '' then begin
      //Price := Price + Jimbo.Dates[j].Calculate);

      // 'St-Nr.', 'Typ', 'Standort', 'Maße', 'Termin', 'Zusatz', Preis
      listItem := lvCustomerShops.Items.Add;
      listItem.Caption := intToStr(Shop.ID);

      if (sType is TShopType) then listItem.SubItems.Add(sType.Title)
      else listItem.SubItems.Add('?');

      listItem.SubItems.Add(Shop.Address);
      listItem.SubItems.Add(Format('%2.2f x %2.2f',[Shop.Width,Shop.Height]));
      listItem.SubItems.Add(DateStr);
      listItem.SubItems.Add(Shop.Other);
      listItem.SubItems.Add(floatToStr(Jimbo.PriceCalc(Shop.ID)) + ' EUR');
      listItem.SubItems.Add('');

      // Shop-ID anfügen
      writeIntToListItem(listItem,Shop.ID);
    end;
  end;
end;

procedure TfrmMain.lvCustomersContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  if lvCustomers.SelCount = 0 then lvCustomers.PopupMenu := puCustomersNew
  else lvCustomers.PopupMenu := puCustomersEdit;
end;

procedure TfrmMain.lvCustomersKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  sidebarViewCustomers;
end;

procedure TfrmMain.puCustomersEditEditClick(Sender: TObject);
var customerID: integer;
begin
  if lvCustomers.SelCount = 0 then exit;
  if not getIntFromListItem(lvCustomers.Selected,customerID) then exit;

  customerEdit(customerID);
end;

procedure TfrmMain.lvCustomerShopsDblClick(Sender: TObject);
var i, countIDs, shopID: integer;
   // Shop: TShop;
begin
  if lvCustomerShops.SelCount = 0 then exit;
  if not getIntFromListItem(lvCustomerShops.Selected,shopID) then exit;

{  Shop := Jimbo.Shops.byID(shopID);
  if not (Shop is TShop) then exit;

  countIDs := 0; for i := Jimbo.Dates.Count-1 do begin
    if Jimbo.ShopDates.indexOf(Jimbo.Dates[i].ID,shopID) = -1 then continue;
    inc(countIDs);
  end;

  if countIDs = 0 then begin
    MessageDlg('Dieser Stand
 }
  shopEdit(shopID);
end;

procedure TfrmMain.sidebarUpdateDetails(Str: string);
begin
  if Trim(Str) = '' then begin
    pSbDetails.Hide;
    exit;
  end;

  tbDetails.Caption := Trim(Str);
end;

procedure TfrmMain.sidebarUpdateDetails(Customer: TCustomer; Shop: TShop);
var i: integer;
    Shops: TShops;
    s: string;
begin
  if (not (Customer is TCustomer)) and (Shop is TShop) and (Shop.hasOwner) then
    Customer := Jimbo.Customers.byID(Shop.customerID);

  if (not (Customer is TCustomer)) and (not (Shop is TShop)) then begin
    pSbDetails.Hide;
    exit;
  end;

  pSbDetails.Show;

  s := '';

  if Customer is TCustomer then begin
    if Customer.cID > 0 then s := s + #13#10 + 'Kd-Nr. ' + IntToStr(Customer.cID);

    if Customer.Firstname <> '' then s := s + #13#10 + Format('%s, %s',[Customer.Lastname,Customer.Firstname])
    else s := s + #13#10 + Customer.Lastname;

    s := s + #13#10 + Customer.Address;
    s := s + #13#10 + Format('%d %s',[Customer.ZIP,Customer.City]);

    if Customer.Phone <> '' then s := s + #13#10 + 'Fon: '+Customer.Phone;
    if Customer.eMail <> '' then s := s + #13#10 + 'eMail: '+Customer.eMail;

    if (Customer.Other <> '') then s := s + #13#10 + Customer.Other;
  end;

  if Shop is TShop then begin
    s := s + #13#10#13#10
           + 'Standnummer: ' + IntToStr(Shop.ID) + #13#10
           + 'Größe: ' + Format('%2.2f x %2.2f',[Shop.Width,Shop.Height]) + ' cm' + #13#10
           + 'Standort: ' + Shop.Address;

    if Shop.Other <> '' then s := s + #13#10 + Shop.Other;
  end;

  if tbDetails.Caption <> Trim(s) then tbDetails.Caption := Trim(s);
end;


procedure TfrmMain.puCustomersEditDeleteClick(Sender: TObject);
var customerID: integer;
begin
  if lvCustomers.SelCount = 0 then exit;
  if not getIntFromListItem(lvCustomers.Selected,customerID) then exit;

  customerDelete(customerID);
end;

procedure TfrmMain.StandundKundelschen1Click(Sender: TObject);
begin
  if not (shopSelected is TShop) then exit;
  shopDelete(shopSelected.ID,true);
end;

procedure TfrmMain.puMapEditNewClick(Sender: TObject);
var X, Y: integer;
begin
  X := FMouse.X - Painter.RectCanvas.Left + Map.Rect.Left;
  Y := FMouse.Y - Painter.RectCanvas.Top + Map.Rect.Top;

  shopNew(Point(X,Y), ifThenElse(Assigned(ShopHover),ShopHover.CustomerID,-1) );
end;

procedure TfrmMain.puCustomersNewNewClick(Sender: TObject);
begin
  customerNew;
end;

procedure TfrmMain.puCustomersEditNewClick(Sender: TObject);
begin
  customerNew;
end;


procedure TfrmMain.viewShopsShow;
begin
  showPanel(pShops);

  pSbNoProject.Visible := false;
  pSbLastFiles.Visible := false;

  pSbDates.Visible := false;
  pSbActions.Visible := true;

  tbFastNavShops.Checked := true;

  if lvMax.Columns.Count = 0 then shopListCreate;

  lvMax.SetFocus;
end;

procedure TfrmMain.lvCustomerShopsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var ShopID: integer;
    ShopType: TShopType;
    Shop: TShop;
begin
  if lvCustomerShops.SelCount = 0 then begin
    lvCustomerShops.PopupMenu := puCustomerShopsNew;
    exit;
  end;

  lvCustomerShops.PopupMenu := puCustomerShopsEdit;

  if not getIntFromListItem(lvCustomerShops.Selected,ShopID) then exit;

  Shop := Jimbo.Shops.byID(ShopID);
  if not (Shop is TShop) then exit;

  ShopType := Jimbo.ShopTypes.byID(Shop.TypeID);
  if not (ShopType is TShopType) then exit;

  puCustomerShopsEditJump.Enabled := ShopType.Visible;
end;

procedure TfrmMain.puCustomerShopsNewNewClick(Sender: TObject);
var X, Y, CustomerID: integer;
begin
  CustomerID := -1;
  if (lvCustomers.SelCount <> 0) then
    getIntFromListItem(lvCustomers.Selected,CustomerID);

  X := FMouse.X - Painter.RectCanvas.Left + Map.Rect.Left;
  Y := FMouse.Y - Painter.RectCanvas.Top + Map.Rect.Top;

  shopNew(Point(X,Y),CustomerID);
end;

procedure TfrmMain.puCustomerShopsEditEditClick(Sender: TObject);
var shopID: integer;
begin
  if lvCustomerShops.SelCount = 0 then exit;
  if not getIntFromListItem(lvCustomerShops.Selected,shopID) then exit;

  shopEdit(shopID);
end;

procedure TfrmMain.puCustomerShopsEditJumpClick(Sender: TObject);
var i, shopID: integer;
    Shop: TShop;
begin
  if lvCustomerShops.SelCount = 0 then exit;
  if not getIntFromListItem(lvCustomerShops.Selected,shopID) then exit;

  Shop := Jimbo.Shops.byID(shopID);
  if not (Shop is TShop) then exit;

  // Datum updaten, wenn nicht ausgewählt
  if Jimbo.ShopDates.indexOf(Jimbo.DateID,Shop.ID) = -1 then begin
    for i := 0 to Jimbo.Dates.Count-1 do begin
      if Jimbo.ShopDates.indexOf(Jimbo.Dates[i].ID,Shop.ID) = -1 then continue;

      Jimbo.DateID := Jimbo.Dates[i].ID;
      break;
    end;

    sidebarUpdateDates;
  end;

  // GUI-Update
  viewMapShow;
  shopSelected := Shop;

  // Objekt-Update
  Map.Position := Point(Shop.X,Shop.Y);

  Painter.setSelection(shopID);
  Painter.Position := Point(Map.Rect.Left,Map.Rect.Top);

  Painter.Update;
  Painter.Paint(shopID);
  Painter.Paint;
end;

procedure TfrmMain.customerShopListCreate;
var i: integer;
    a: array of integer;
begin
  // Kundenübersicht-ListView laden
  lvCustomerShops.Columns.BeginUpdate;
  setLength(a,Settings.DefaultCpx['Lists']['Shops']['Captions'].asList.Count);

  for i := 0 to Settings.DefaultCpx['Lists']['Shops']['Captions'].asList.Count-1 do begin
    with lvCustomerShops.Columns.Add do begin
      Caption := Settings.DefaultCpx['Lists']['Shops']['Captions'].asList[i].asStr;

      Width := Settings.Cpx['Lists']['Shops']['Widths'].asList[i].asInt;
      a[i] := Settings.Cpx['Lists']['Shops']['Order'].asList[i].asInt;
    end;
  end;

  lvCustomerShops.Columns.EndUpdate;
  lvCustomerShops.Repaint;

  Application.ProcessMessages;

  // Spalten sortieren
  ListView_SetColumnOrderArray(lvCustomerShops.Handle,lvCustomerShops.Columns.Count,pInteger(a));
  lvCustomerShops.Refresh;
end;

procedure TfrmMain.customerShopListDestroy;
begin
  disposeFromListView(lvCustomerShops);

  lvCustomerShops.Columns.BeginUpdate;
  while lvCustomerShops.Columns.Count > 0 do lvCustomerShops.Columns[0].Free;
  lvCustomerShops.Columns.EndUpdate;
end;

procedure TfrmMain.projectNew;
var dlgNew: TProjectNewDialog;
    dlgLoad: TLoadingDialog;

    ResX: THandle;
    Res: TResourceStream;

    NewProject: TJimbo;

    i: integer;
    tempPath: array[0..MAX_PATH] of char;
    newFilename: string;
begin
{temp export
temp open
dlg open
 nein: temp close
       temp delete
       exit

dlg close
  -> dlg saves temp

temp close
temp move to dlg.file

normal open projectOpen}

  // Temp-Dateiname erstellen
  repeat
    FillChar(tempPath,MAX_PATH,#0);

    Windows.GetTempPath(SizeOf(tempPath)-1,tempPath);
    Windows.GetTempFileName(tempPath,'jidb',1+random(10000),tempPath);

    inc(i);
  until (not FileExists(tempPath)) or (i = 3);

  if FileExists(tempPath) then exit;

  // Default-Datei aus resX extrahieren und speichern
  ResX := LoadLibrary(pChar(ExtractFilePath(Application.ExeName) + FILENAME_RESX));
  if ResX = 0 then raise Exception.Create('Resource Datei nicht gefunden');

  try
    Res := TResourceStream.Create(ResX,'EMPTYDB',RT_RCDATA);
  except
    Res.Free;
    //NewProject.Free;
    FreeLibrary(ResX);

    raise Exception.Create('Resource Datei nicht gefunden');
    exit;
  end;

  try
    Res.SaveToFile(tempPath);
  except
    Res.Free;
    FreeLibrary(ResX);
    //NewProject.Free;

    raise Exception.Create('Fehler beim Speichern der Datei');
  end;

  Res.Free;
  FreeLibrary(ResX);

  // Temp-Projekt öffnen
  NewProject := TJimbo.Create;
  try
    NewProject.Open(tempPath);
  except
    NewProject.Free;
    DeleteFile(tempPath);

    exit;
  end;

  // Dialog öffnen (Projekt wird gespeichert)
  dlgNew := TProjectNewDialog.Create;
  dlgNew.Project := NewProject;
  dlgNew.Maps := Maps;

  if not dlgNew.Execute then begin
    NewProject.Free;
    dlgNew.Free;

    DeleteFile(tempPath);

    exit;
  end;

  newFilename := NewProject.Filename;

  dlgNew.Free;

  NewProject.Close;
  NewProject.Free;

  // Datei an die wirkliche Stelle kopieren
  if not CopyFile(tempPath,pChar(newFilename),false) then begin
//    NewProject.Free;
    DeleteFile(tempPath);

    exit;
  end;


{  tbPanProject.Caption := Jimbo.Title;
  sidebarUpdateDates;}

  // Projekt laden
  projectOpen(newFilename);

  if not Opened then begin
    exit;
  end;
end;

procedure TfrmMain.mapActionMove;
var i, diffX, diffY: integer;
begin
  FMapAction := maMove;

  diffX := FMapMoveStartPoint.X - FMouse.X;
  diffY := FMapMoveStartPoint.Y - FMouse.Y;

    Map.Rect := Rect(
      FMapMoveStartRect.Left + diffX,
      FMapMoveStartRect.Top + diffY,
      FMapMoveStartRect.Right + diffX,
      FMapMoveStartRect.Bottom + diffY
    );

    Painter.Position := Point(Map.Rect.Left, Map.Rect.Top);

    Painter.Update;
    Painter.Paint;
end;

procedure TfrmMain.mapActionShopMoveBegin(X, Y: integer);
begin
  FMapAction := maShopMove;

  shopMove := shopHover;
  Painter.beginMove(shopMove.ID,shopMove.X-X,shopMove.Y-Y);
end;

procedure TfrmMain.mapActionShopRotate(X, Y: integer);
var b: string;
    Customer: TCustomer;
begin
  // Drehen eines Shops
  if not (shopRotate is TShop) then exit;

  shopRotate.Angle := rotateStartAngle-round((X-rotateStartPos));
  Painter.Paint(shopRotate.ID);
end;

procedure TfrmMain.mapActionShopRotateBegin(X, Y: integer);
begin
  // Drehen des Shops beginnen
  FMapAction := maShopRotate;

  shopRotate := shopHover;
  Painter.beginMove(shopRotate.ID,0,0);
end;

procedure TfrmMain.mapActionShopMove(X, Y: integer);
begin
  // Bewegen eines Shops
  if not (shopMove is TShop) then exit;

  shopMove.setPosition(X,Y);
  Painter.Paint(shopMove.ID);
end;

procedure TfrmMain.mapActionFindOut(X, Y: integer);
var i: integer;

    Customer: TCustomer;
    sType: TShopType;
begin
 // Nichts von alledem ...
  if Jimbo.Shops.Count = 0 then begin
    FMapAction := maHover;
    shopHover := nil;

    exit;
  end;


  for i := 0 to Jimbo.Shops.Count-1 do begin
    // Datum korrekt?
    if Jimbo.shopDates.indexOf(Jimbo.dateID,Jimbo.Shops[i].ID) = -1 then continue;

    // Sichtbar??
    sType := Jimbo.shopTypes.byID(Jimbo.Shops[i].typeID);
    if (sType is TShopType) and (not sType.Visible) then continue;

    // Anfasser-Punkt
    if Jimbo.Shops[i].isRotatePoint(X,Y) then begin
      FMapAction := maShopHover;
      shopHover := Jimbo.Shops[i];

      if Jimbo.Shops[i].ID <> Painter.shopHighlightID then begin
        Painter.beginHighlight(Jimbo.Shops[i].ID);
        Painter.Paint(Jimbo.Shops[i].ID);
      end;

      // Startpunkt (f. Änderung der Rotation)
      rotateStartPoint := Point(X,Y);
      rotateStartPos := X;
      rotateStartAngle := shopHover.Angle;

      pbMap.Cursor := crSizeAll;
      exit;
    end

    // Punkt in der Mitte des Rechtecks
    else if Jimbo.Shops[i].isMovePoint(X,Y) then begin
      shopHover := Jimbo.Shops[i];
      FMapAction := maShopHover;

      if not (Jimbo.Shops[i].ID = Painter.shopHighlightID) then begin
        Painter.beginHighlight(Jimbo.Shops[i].ID);
        Painter.Paint(Jimbo.Shops[i].ID);
      end;

      pbMap.Cursor := crDefault;
      exit;
    end

    else if Jimbo.Shops[i].ID = Painter.shopHighlightID then begin
      Painter.endHighlight;
      Painter.Paint(Jimbo.Shops[i].ID);
    end;
  end;

  // Nichts von alledem ...
  FMapAction := maHover;
  shopHover := nil;
  pbMap.Cursor := crDefault;

  // Ausgewählten Shop anzeigen
  sidebarUpdateDetails(nil,shopSelected);
end;


procedure TfrmMain.projectOpenDlg;
var dlgOpen: TOpenDialog;
    Filename: string;
begin
  dlgOpen := TOpenDialog.Create(Self);
  dlgOpen.DefaultExt := COMMON_EXT_PROJECT;
  dlgOpen.Filter := 'Jimbo-Dateien (MS-Access) (*'+COMMON_EXT_PROJECT+')|*'+COMMON_EXT_PROJECT+'|Alle Dateien (*.*)|*.*';

  if not dlgOpen.Execute then begin
    dlgOpen.Free;
    exit;
  end;

  Filename := dlgOpen.FileName;
  dlgOpen.Free;

  projectOpen(Filename);
end;

procedure TfrmMain.tbSbMapClick(Sender: TObject);
begin
  viewMapShow;
end;

procedure TfrmMain.tbSbCustomersClick(Sender: TObject);
begin
  viewCustomersShow;
end;

procedure TfrmMain.pbMapMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Opened then exit;

  FMouse.X := X;
  FMouse.Y := Y;

  X := X - Painter.RectCanvas.Left + Map.Rect.Left;
  Y := Y - Painter.RectCanvas.Top + Map.Rect.Top;

  FMouse.Status := msDown;
  FMouse.Button := Button;

  FMapMoveStartPoint := Point(FMouse.X,FMouse.Y);
  FMapMoveStartRect := Map.Rect;//Painter.RectMap;

  case FMapAction of
    // Karte verschieben beginnen
    maHover: begin
      FMapAction := maBeginMove;
      //Painter.Listen := true;
    end;

    // Drehen/Bewegen beginnen
    maShopHover: begin
      if not (shopHover is TShop) then exit;

      // Drehen beginnen
      if shopHover.isRotatePoint(X,Y) then mapActionShopRotateBegin(X,Y)

      // Bewegen beginnen
      else if shopHover.isMovePoint(X,Y) then mapActionShopMoveBegin(X,Y);
    end;

    // Im Zweifelsfall nichts tun
    else FMapAction := maNone;
  end;
end;

procedure TfrmMain.pbMapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
{

  Erläuterungen:

  1. msNone als MapAction.

  2. Bewegen der Maus über die Karte
   -> mapMouseMove setzt den neuen Hover-(!)-Status z.B. msHover,
      msShopHover oder msNavHover

  3. Nach Drücken der Maustaste wird eine Aktion gestartet
   -> mapMouseDown setzt den Move/Rotate-Status z.B. msMove,
      msShopMove, msShopRotate oder msNavMove
   -> mapMouseDown beginnt die jew. Aktion mit der mapAction*Begin()-Fkt.

  4. mapMouseMove erkennt den Status während dem Bewegen und leitet
     and die jew. Fkt. weiter, z.B. mapActionShopRotate(), mapActionMove()

  5. mapMouseUp setzt alle Aktionen (FMapAction -> msNone) auf Null und
     beendet das Prozedere

 }

  if not Opened then exit;

  FMouse.X := X;
  FMouse.Y := Y;

  X := X - Painter.RectCanvas.Left + Map.Rect.Left;//Painter.RectMap.Left;
  Y := Y - Painter.RectCanvas.Top + Map.Rect.Top;// + Painter.RectMap.Top;

  case FMapAction of
    maMove, maBeginMove: begin mapActionMove; exit; end;
    maShopMove: begin mapActionShopMove(X,Y); exit; end;
    maShopRotate: begin mapActionShopRotate(X,Y); exit; end;
    else mapActionFindOut(X,Y);
  end;

end;

procedure TfrmMain.pbMapMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i: integer;
    sType: TShopType;
begin
  if not Opened then exit;

  FMouse.X := X;
  FMouse.Y := Y;

  X := X - Painter.RectCanvas.Left + Map.Rect.Left;// + Painter.RectMap.Left;
  Y := Y - Painter.RectCanvas.Top + Map.Rect.Top;// + Painter.RectMap.Top;

  if FMapAction <> maMove then begin
    ShopSelected := nil;
    Painter.setSelection(-1);
  end;

  FMouse.Status := msUp;
  FMouse.Button := Button;
  FMapAction := maNone;

 // Painter.Listen := false;

  // Drehwinkel speichern
  if (shopRotate is TShop) then begin
    Painter.endMove;
    shopRotate.Save;
  end;

  // Position speichern
  if (shopMove is TShop) then begin
    shopMove.setPosition(X,Y);
    Painter.endMove;

    shopMove.Save;
  end;

  shopMove := nil;
  shopRotate := nil;

  for i := 0 to Jimbo.Shops.Count-1 do begin
    // Datum korrekt?
    if Jimbo.ShopDates.indexOf(Jimbo.dateID,Jimbo.Shops[i].ID) = -1 then continue;

    // Sichtbar?
    sType := Jimbo.shopTypes.byID(Jimbo.Shops[i].typeID);
    if (sType is TShopType) and (not sType.Visible) then continue;

    // Auswählen / Popup
    if Jimbo.Shops[i].isMovePoint(X,Y) then begin
      shopSelected := Jimbo.Shops[i];
      Painter.setSelection(shopSelected.ID);
      Painter.Paint(shopSelected.ID);

      // Rechte Maustaste: Popup
      if Button = mbRight then begin
        puMapEdit.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
      end;

      continue;
    end;

    // Nicht auswählen
    //Jimbo.Shops[i].setSelection(false);
    //Jimbo.Shops[i].setHighlight(false);
    //Painter.endHighlight;
  end;

  if not Assigned(shopSelected) then begin
    Painter.setSelection(-1);
    Painter.endHighlight;
  end;

  Painter.Update;
  Painter.Paint;

  sidebarViewMap;
end;

procedure TfrmMain.tbSbNoProjectOpenClick(Sender: TObject);
begin
  projectOpenDlg;
end;

procedure TfrmMain.tbSbNoProjectNewClick(Sender: TObject);
begin
  projectNew;
end;

procedure TfrmMain.tbSbProjectClick(Sender: TObject);
begin
  projectEdit;
end;

procedure TfrmMain.tbSbShopsClick(Sender: TObject);
begin
  viewShopsShow;
end;

procedure TfrmMain.sidebarClickLastFile(Sender: TObject);
begin
  if not (Sender is TTBXLink) then exit;
  if Settings.lastFiles.Count <= (Sender as TTBXLink).Tag then exit;

  projectOpenLast((Sender as TTBXLink).Tag);
end;

procedure TfrmMain.customerListSave;
var i, j, idx: integer;
    a: array of integer;
begin
  if lvCustomers.Columns.Count = 0 then exit;

  setLength(a,lvCustomers.Columns.Count);
  ListView_GetColumnOrderArray(lvCustomers.Handle,lvCustomers.Columns.Count,pInteger(a));

  for i := 0 to Length(a)-1 do begin
    idx := lvCustomers.Columns.FindItemID(i).Index;

    with Settings.Cpx['Lists']['Customers'] do begin
      Items['Order'].asList[i].asInt := a[i];
      Items['Widths'].asList[i].asInt := lvCustomers.Columns[idx].Width;
    end;
  end;
end;

procedure TfrmMain.customerShopListSave;
var i, idx: integer;
    a: array of integer;
begin
  if lvCustomerShops.Columns.Count = 0 then exit;

  setLength(a,lvCustomerShops.Columns.Count);
  ListView_GetColumnOrderArray(lvCustomerShops.Handle,lvCustomerShops.Columns.Count,pInteger(a));

  for i := 0 to Length(a)-1 do begin
    idx := lvCustomerShops.Columns.FindItemID(i).Index;

    with Settings.Cpx['Lists']['Shops'] do begin
      Items['Order'].asList[i].asInt := a[i];
      Items['Widths'].asList[i].asInt := lvCustomerShops.Columns[idx].Width;
    end;
  end;
end;

procedure TfrmMain.sidebarUpdateActions(Actions: TSidebarActions);
begin
  if FSidebarActions = Actions then exit;

  tbSbActionNew.Visible := (sbaNew in Actions);
  tbSbActionEdit.Visible := (sbaEdit in Actions);
  tbSbActionDelete.Visible := (sbaDelete in Actions);

  tbSbActionNewCustomer.Visible := (sbaNewCustomer in Actions);
  tbSbActionEditCustomer.Visible := (sbaEditCustomer in Actions);
  tbSbActionDeleteCustomer.Visible := (sbaDeleteCustomer in Actions);

  tbSbActionNew.Top := 10;
  tbSbActionEdit.Top := 20;
  tbSbActionDelete.Top := 30;

  tbSbActionNewCustomer.Top := 40;
  tbSbActionEditCustomer.Top := 50;
  tbSbActionDeleteCustomer.Top := 60;

  FSidebarActions := Actions;
end;

procedure TfrmMain.sidebarClickShopNew(Sender: TObject);
var X, Y: integer;
begin
  X := Map.Rect.Left + Painter.RectCanvas.Left + (Painter.RectCanvas.Right - Painter.RectCanvas.Left) div 2;
  Y := Map.Rect.Top + Painter.RectCanvas.Top + (Painter.RectCanvas.Bottom - Painter.RectCanvas.Top) div 2;

  shopNew(Point(X,Y));
end;

procedure TfrmMain.sidebarClickShopEdit(Sender: TObject);
begin
  if not (shopSelected is TShop) then exit;
  shopEdit(shopSelected.ID);
end;

procedure TfrmMain.sidebarClickShopDelete(Sender: TObject);
begin
  if not (shopSelected is TShop) then exit;
  shopDelete(shopSelected.ID,false);
end;

procedure TfrmMain.sidebarClickNewCustomer(Sender: TObject);
begin
  customerNew;
end;

procedure TfrmMain.sidebarClickEditCustomer(Sender: TObject);
begin
  puCustomersEditEditClick(Sender);
end;

procedure TfrmMain.sidebarClickDeleteCustomer(Sender: TObject);
begin
  puCustomersEditDeleteClick(Sender);
end;

procedure TfrmMain.sidebarUpdateDates;
var i, j, allHeight, mOk, iOk: integer;
    curTop: integer;
    curDate: TDateTime;

    isOk: boolean;
begin
  { Hinweis: tbDates muss Visible sein }

  // Daten prüfen: Müssen Sie Daten aktualisiert werden?
  iOk := 0; mOk := 0;

  for i := 0 to Jimbo.Dates.Count-1 do begin
    if not Jimbo.Dates[i].Active then continue;

    for j := 0 to tbSbDates.ControlCount-1 do begin
      if (tbSbDates.Controls[j].Tag <> Jimbo.Dates[i].ID)
        or ((tbSbDates.Controls[j] as TSpTBXRadioButton).Caption <> Jimbo.Dates[i].Title)
        or (
          ((tbSbDates.Controls[j] as TSpTBXRadioButton).Tag = Jimbo.DateID)
          and (not (tbSbDates.Controls[j] as TSpTBXRadioButton).Checked)
        )

        then continue;

      inc(iOk);
    end;

    inc(mOk);
  end;

  // Reihenfolge prüfen
  if mOk = iOk then begin
    curTop := 0;
    curDate := 0;
//    isOk := true;

   for i := 0 to Jimbo.Dates.Count-1 do begin
     if not Jimbo.Dates[i].Active then continue;
     isOk := true;

     for j := 0 to tbSbDates.ControlCount-1 do begin
       if Jimbo.Dates[i].ID <> tbSbDates.Controls[j].Tag then continue;

       if (tbSbDates.Controls[j].Top < curTop) and (Jimbo.Dates[i].Date < curDate) then begin
         isOk := false;
       end;

       if isOk then begin
         curDate := Jimbo.Dates[i].Date;
         curTop := tbSbDates.Controls[j].Top;
       end;

       break;
     end;

     if not isOk then break;
   end;

   if not isOk then begin
     showmessage('fsddf');
   end;

   exit;
  end;

  // Alles OK!
  if mOk = iOk then exit;

  // Irgendwas stimmt nicht: Neu erstellen
  while tbSbDates.ControlCount > 0 do tbSbDates.RemoveControl(tbSbDates.Controls[0]);

  for i := 0 to Jimbo.Dates.Count-1 do begin
    if not Jimbo.Dates[i].Active then continue;

    with TSpTBXRadioButton.Create(tbSbDates) do begin
      Parent := tbSbDates;

      Margins.Top := 3;
      Align := alTop;

      Tag := Jimbo.Dates[i].ID;
      Caption := Jimbo.Dates[i].Title;
      Checked := Jimbo.Dates[i].ID = Jimbo.dateID;

      Visible := true;
      OnClick := sidebarClickDateSet;
    end;
  end;

  for i := 0 to tbSbDates.ControlCount-1 do
    tbSbDates.Controls[i].Top := tbSbDates.Controls[i].Height*i;

  pSbDates.Update;
  pSbDates.Refresh;
end;

procedure TfrmMain.sidebarClickDateSet(Sender: TObject);
begin
  if not (Sender is TSpTBXRadioButton) then exit;

  projectSetDate((Sender as TSpTBXRadioButton).Tag);
end;

procedure TfrmMain.shopListCreate;
var i, j: integer;
    a: array of integer;
begin
  with Settings.Cpx['Lists']['Max'] do begin
    // Suchfeld updaten
    edShopFind.Text := Items['FindQuery'].asStr;

    disposeFromComboBox(cbShopFilter);
    cbShopFilter.Clear;

    for i := 0 to Items['Captions'].asList.Count-1 do begin
      j := cbShopFilter.Items.Add(Items['Captions'].asList[i].asStr);
      writeIntToStringListItem(cbShopFilter.Items,j,i);

      if Items['FindField'].asInt = j then cbShopFilter.ItemIndex := j;
    end;

    // Kundenübersicht-ListView laden
    lvMax.Columns.BeginUpdate;
    setLength(a,Items['Captions'].asList.Count);

    for i := 0 to Items['Captions'].asList.Count-1 do begin
      with lvMax.Columns.Add do begin
        Caption := Items['Captions'].asList[i].asStr;

        Width := Items['Widths'].asList[i].asInt;
        a[i] := Items['Order'].asList[i].asInt;
      end;
    end;

    lvMax.Columns.EndUpdate;
    lvMax.Repaint;

    Application.ProcessMessages;

    // Spalten sortieren
    ListView_SetColumnOrderArray(lvMax.Handle,lvMax.Columns.Count,pInteger(a));
    lvMax.Refresh;
  end;

  shopListFind(Settings.Cpx['Lists']['Max']['FindField'].asInt,Settings.Cpx['Lists']['Max']['FindQuery'].asStr);
end;

procedure TfrmMain.lvCustomerShopsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // Kein Stand
  if lvCustomerShops.SelCount = 0 then begin
    lvCustomersMouseDown(Sender,Button,Shift,X,Y);
    exit;
  end;

//  sidebarViewCustomers;
end;

procedure TfrmMain.shopListSave;
var i, j, idx: integer;
    a: array of integer;
begin
  if lvMax.Columns.Count = 0 then exit;

  setLength(a,lvMax.Columns.Count);
  ListView_GetColumnOrderArray(lvMax.Handle,lvMax.Columns.Count,pInteger(a));

  for i := 0 to Length(a)-1 do begin
    idx := lvMax.Columns.FindItemID(i).Index;

    with Settings.Cpx['Lists']['Max'] do begin
      Items['Order'].asList[i].asInt := a[i];
      Items['Widths'].asList[i].asInt := lvMax.Columns[idx].Width;
    end;
  end;
end;

procedure TfrmMain.tbPanNavigationResize(Sender: TObject);
begin
  if (Map.Navigator.Width = 0) or (Map.Navigator.Height = 0) then exit;

  if pSbNavigator.ClientWidth < pSbNavigator.ClientHeight then begin
    Painter.Navigator.Width := pSbNavigator.ClientWidth;
    Painter.Navigator.Height := Floor(Map.Navigator.Height/Map.Navigator.Width*Painter.Navigator.Width);

    //tbPanNavigation.ClientHeight := Painter.Navigator.Height;
  end

  else begin
    Painter.Navigator.Height := pSbNavigator.ClientHeight;
    Painter.Navigator.Width := Floor(Map.Navigator.Width/Map.Navigator.Height*Painter.Navigator.Height);

    //tbPanNavigation.ClientWidth := Painter.Navigator.Width;
  end;

  pbNavigator.Left := 0;
  pbNavigator.Top := 0;
  pbNavigator.Width := Painter.Navigator.Width;
  pbNavigator.Height := Painter.Navigator.Height;
end;

procedure TfrmMain.pbNavigatorMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var w2, h2: integer;
begin
  FNavigatorMove := false;

  // Größe!
  tbPanNavigationResize(Sender);

  X := Round(X/Painter.Navigator.Width*Map.Width);
  Y := Round(Y/Painter.Navigator.Height*Map.Height);

  w2 := (Map.Rect.Right - Map.Rect.Left) div 2;
  h2 := (Map.Rect.Bottom - Map.Rect.Top) div 2;

  Map.Rect := Rect(
    X - w2, Y - h2,
    X + w2, Y + h2
  );

  Painter.Position := Point(Map.Rect.Left, Map.Rect.Top);

  Painter.Update;
  Painter.Paint;

  viewMapShow;
end;

procedure TfrmMain.tbPanNavigationVisibleChanged(Sender: TObject);
begin
  Painter.Navigator.Enabled := tbPanNavigation.Visible;
  Settings.Cpx['Layout']['ShowNavigator'].asBool := tbPanNavigation.Visible;
end;

procedure TfrmMain.pbNavigatorMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if not FNavigatorMove then exit;

  // Größe!
  tbPanNavigationResize(Sender);

  with Painter.Navigator do begin
    Position := Point(X - RectWidth div 2,Y - RectHeight div 2);
    Paint;
  end;
end;

procedure TfrmMain.pbNavigatorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // Größe!
  tbPanNavigationResize(Sender);

  FNavigatorMove := true;
end;

procedure TfrmMain.toolbarJumpUpdate;
var i, j: integer;
    pInt: pInteger;
begin
  //disposeComboBox(cbLocation);
  tbToolJumpList.Clear;

  for i := 0 to Map.Locations.Count-1 do begin
    // ID als Objekt anfügen
//    System.New(pInt); PInt^ := Map.Locations[i].ID;
//    tbToolJumpList.Strings.AddObject(FLocations[i].Title,TObject(pInt));
    tbToolJumpList.Strings.Add(Map.Locations[i].Title);
  end;
end;

procedure TfrmMain.btnShopFindClick(Sender: TObject);
var i: integer;
begin
  if not getIntFromStringListItem(cbShopFilter.Items,cbShopFilter.ItemIndex,i) then exit;
  shopListFind(i,edShopFind.Text);

  with Settings.Cpx['Lists']['Max'] do begin
    Items['FindField'].asInt := i;
    Items['FindQuery'].asStr := edShopFind.Text;
  end;
end;

procedure TfrmMain.shopListFind(maxField: integer; Query: string);

  procedure add2List(Customer: TCustomer; Shop: TShop);
  var j: integer;
      listItem: TListItem;

      cType: TCustomerType;
      sType: TShopType;
  begin
      sType := Jimbo.shopTypes.byID(Shop.typeID);
      cType := Jimbo.customerTypes.byID(Customer.typeID);

      for j := 0 to Jimbo.Dates.Count-1 do begin
        if not Jimbo.Dates[j].Active then continue;
        if Jimbo.shopDates.indexOf(Jimbo.Dates[j].ID,Shop.ID) = -1 then continue;

        // Kd-Nr., Kd-Typ, Name, Vorname, Straße, PLZ, Ort,
        // St-Nr., St-Typ, Maße, Termin, Standort, Preis

        listItem := lvMax.Items.Add;
        listItem.Caption := intToStr(Customer.cID);

        with listItem.SubItems do begin
          if (cType is TCustomerType) then Add(cType.Title) else Add('?');
          Add(Customer.Lastname);
          Add(Customer.Firstname);
          Add(Customer.Address);
          Add(intToStr(Customer.ZIP));
          Add(Customer.City);

          Add(intToStr(Shop.ID));
          if (sType is TShopType) then Add(sType.Title) else Add('?');
          Add(Format('%2.2f x %2.2f',[Shop.Width,Shop.Height]) + ' m');
          Add(Jimbo.Dates[j].Short);
          Add(Shop.Address);
          Add(floatToStr(Jimbo.priceCalc(Shop.ID)));
          Add('');
        end;

        // Shop-ID anfügen
        writeIntToListItem(listItem,Shop.ID);
      end;

  end;

var i, j, k: integer;

    listItem: TListItem;

    Shop: TShop;
    Shops, CustomerShops: TShops;
    ShopField: TShopField;

    Customer: TCustomer;
    Customers: TCustomers;
    CustomerField: TCustomerField;
begin
  disposeFromListView(lvMax);
  lvMax.Clear;

  with Settings.Cpx['Lists']['Max'] do begin

    // SUCHEN

    // Such-Feld ist vom Typ "Shop"
    if Items['Types'].asList[maxField].asInt = 2{Shop-Feld} then begin

      // Suchen
      Shops := Jimbo.Shops.Find(sfIdToField(Items['ID'].asList[maxField].asInt),Query);

//      if Items['Types'].asList[Items['Sort']['Field'].asInt].asInt <> 2{Shops} then begin
//        Items['Sort']['Field'].asInt := 7; {St-Nr.}
//        Items['Sort']['Asc'].asBool := true;
//      end;


      // Kundenliste der Stände suchen
      Customers := TCustomers.Create;

      for i := 0 to Shops.Count-1 do begin
        if Customers.Exists(Shops[i].customerID) then continue;

        Customer := Jimbo.Customers.byID(Shops[i].customerID);
        if not (Customer is TCustomer) then continue;

        Customers.addCopy(Customer);
      end;
    end

    // Such-Feld ist vom Typ "Kunde"
    else if Items['Types'].asList[maxField].asInt = 1{Customer-Feld} then begin

      // Suchen
      Customers := Jimbo.Customers.Find(cfIdToField(Items['ID'].asList[maxField].asInt),Query);
      Shops := TShops.Create;

      // Stände der Kundenliste (Customers) suchen
      for i := 0 to Customers.Count-1 do begin
        Customer := Customers[i];
        if not (Customer is TCustomer) then continue;

        CustomerShops := Jimbo.Shops.byCustomer(Customer.ID);
        if not (CustomerShops is TShops) then continue;

        for j := 0 to CustomerShops.Count-1 do
          Shops.Add(CustomerShops[j]);

        freeAndNil(CustomerShops);
      end;
    end;


    // SORTIEREN

    // Sortier-Feld ist vom Typ "Kunde"
    if Items['Types'].asList[Items['SortField'].asInt].asInt = 1{Customers} then begin

      // Kundenliste sortieren
      CustomerField := cfIdToField(Items['ID'].asList[ Items['SortField'].asInt ].asInt);
      Customers.sortBy(CustomerField,Items['SortAsc'].asBool);

      for i := 0 to Customers.Count-1 do begin
        Customer := Customers[i];
        if not (Customer is TCustomer) then continue;

        CustomerShops := Shops.byCustomer(Customer.ID);
        if not (CustomerShops is TShops) then continue;

        CustomerShops.sortBy(sfDate,true);

        // Zum ListView
        for j := 0 to CustomerShops.Count-1 do add2List(Customer,CustomerShops[j]);

        freeAndNil(CustomerShops);
      end;

    end

    // Sortier-Feld ist vom Typ "Stand"
    else begin
      ShopField := sfIdToField(Items['ID'].asList[ Items['SortField'].asInt ].asInt);
      Shops.sortBy(ShopField,Items['SortAsc'].asBool);

      for i := 0 to Shops.Count-1 do begin
        Shop := Shops[i];
        if not (Shop is TShop) then continue;

        Customer := Customers.byID(Shop.customerID);
        if not (Customer is TCustomer) then continue;

        // Zum ListView
        add2List(Customer,Shop);
      end;
    end;


    // Und Fertig!
    Customers.Free;
    Shops.Free;
  end;
end;

procedure TfrmMain.lvCustomerShopsEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

procedure TfrmMain.lvMaxEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

procedure TfrmMain.tbMRUListClick(Sender: TObject; const Filename: String);
begin
  projectOpen(Filename);
end;

procedure TfrmMain.tbPanProjectCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := false;
end;

procedure TfrmMain.pbNavigatorPaint(Sender: TObject);
begin
  Painter.Navigator.Paint;
end;

procedure TfrmMain.customizerLoad(isOpen: boolean);
var sl: TStringList;
    pLay: pChar;
    s, layoutName: string;
begin
  // Navigator
  with Settings.Cpx['Layout'] do begin

    // Einzelne Toolbars
    if isOpen then begin
      layoutName := 'Opened';

      tbPanNavigation.Visible := Items['ShowNavigator'].asBool;
      tbToolFastNav.Visible := Items['ShowFastNav'].asBool;
      tbToolJump.Visible := Items['ShowJump'].asBool;
    end

    else begin
      layoutName := 'Closed';
    end;

    // Layout
    sl := TStringList.Create;
    getMem(pLay,Items['Toolbars'].DataLength);

    Items['Toolbars'].getAsBinary(pLay);
    sl.Text := String(pLay);

    spCustomizer.LoadLayout(sl,layoutName);

    freeAndNil(sl);
    freeMem(pLay,Length(pLay));
  end;
end;

procedure TfrmMain.customizerSave(isOpen: boolean);
var sl: TStringList;
    pLay, pStr: pChar;
    s, layoutName: string;
begin
  // Navigator
  with Settings.Cpx['Layout'] do begin

    sl := TStringList.Create;
    getMem(pLay,Items['Toolbars'].DataLength);

    // Opened / Closed laden
    Items['Toolbars'].getAsBinary(pLay);
    sl.Text := String(pLay);

    // Einzelne Toolbars
    if isOpen then begin
      layoutName := 'Opened';

      Items['ShowNavigator'].asBool := tbPanNavigation.Visible;
      Items['ShowFastNav'].asBool := tbToolFastNav.Visible;
      Items['ShowJump'].asBool := tbToolJump.Visible;
    end

    else begin
      layoutName := 'Closed';
    end;

    // Layout
    spCustomizer.SaveLayout(sl,layoutName);

    pStr := pChar(sl.Text);
    Items['Toolbars'].setAsBinary(pStr,Length(sl.Text));

    freeAndNil(sl);
    freeMem(pLay,Length(pLay));
  end;
end;


procedure TfrmMain.lvMaxColumnClick(Sender: TObject; Column: TListColumn);
var Cpx: TComplex;
begin
  Cpx := Settings.Cpx['Lists']['Max'];

  if (Cpx['SortField'].asInt = Column.ID) then Cpx['SortAsc'].asBool := not Cpx['SortAsc'].asBool
  else Cpx['SortAsc'].asBool := true;

  Cpx['SortField'].asInt := Column.ID;

  shopListFind(Cpx['FindField'].asInt,Cpx['FindQuery'].asStr);
end;

procedure TfrmMain.lvCustomerShopsColumnClick(Sender: TObject; Column: TListColumn);
var Field: TShopField;
    Cpx: TComplex;
begin
  Cpx := Settings.Cpx['Lists']['Shops'];

  Field := sfIdToField(Column.ID);

  if (sfIdToField(Cpx['SortField'].asInt) = Field) then Cpx['SortAsc'].asBool := not Cpx['SortAsc'].asBool
  else Cpx['SortAsc'].asBool := true;

  Cpx['SortField'].asInt := sfFieldToId(Field);

  customerShopListUpdate;
end;

procedure TfrmMain.lvMaxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  sidebarViewMax;
end;

procedure TfrmMain.lvMaxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  sidebarViewMax;
end;

procedure TfrmMain.lvMaxDblClick(Sender: TObject);
var shopID: integer;
begin
  if lvMax.SelCount = 0 then exit;
  if not getIntFromListItem(lvMax.Selected,shopID) then exit;

  shopEdit(shopID);
end;

procedure TfrmMain.lvMaxContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  //
end;

procedure TfrmMain.lvCustomerShopsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  sidebarViewCustomers;
end;

procedure TfrmMain.puMapEditDeleteBothClick(Sender: TObject);
begin
  if not (shopSelected is TShop) then exit;
  shopDelete(shopSelected.ID,true);
end;

procedure TfrmMain.arrowsCreate;
var ResX: THandle;
begin
  ResX := LoadLibrary(PChar(ExtractFilePath(Application.ExeName) + FILENAME_RESX));
  if ResX = 0 then raise Exception.Create('Resource datei nicht gefunden');

  try
    hListArrowUp := LoadBitmap(ResX, 'ARROWUP');
    hListArrowDown := LoadBitmap(ResX, 'ARROWDOWN');
  finally
    FreeLibrary(ResX);
  end;

  FListArrow := TBitmap.Create;
end;

procedure TfrmMain.arrowsFree;
begin
  FListArrow.ReleaseHandle;
  FListArrow.Free;

  DeleteObject(hListArrowUp);
  DeleteObject(hListArrowDown);
end;

procedure TfrmMain.arrowAdd(List: TListView; Column: integer; Asc: boolean);
var i: integer;
    Hdr: HWND;
    HdItem: THdItem;
begin
{ var
  hdr: HWND;
  hdritem: THDItem;
Begin}
    FListArrow.ReleaseHandle;

      case Asc of
        true: FListArrow.Handle := hListArrowUp;
        false: FListArrow.Handle := hListArrowDown;
      end;
    FListArrow.Transparent := true;
    FListArrow.TransparentMode := tmFixed;
    FListArrow.TransparentColor := clWhite;


  hdr := Listview_GetHeader( List.handle );

  FillChar( hditem, sizeof(hditem), 0 );
  hditem.Mask := HDI_FORMAT;
  Header_GetItem( hdr, column, hditem );
  hditem.Mask := HDI_FORMAT or HDI_BITMAP;
  If Asc Then
    hditem.hbm  := FListArrow.Handle
  Else
    hditem.hbm := FListArrow.Handle;
  hditem.fmt   := hditem.fmt OR HDF_BITMAP_ON_RIGHT OR HDF_BITMAP;
  Header_SetItem( hdr, column, hditem );




{  for i := 0 to List.Columns.Count-1 do begin
    FListArrow.ReleaseHandle;
    FListArrow.TransparentColor := clWhite;

    if i = Column then begin
      case Asc of
        true: FListArrow.Handle := hListArrowUp;
        false: FListArrow.Handle := hListArrowDown;
      end;

      HdItem.Mask := HDI_FORMAT;
      Header_GetItem(GetDlgItem(List.Handle,0),Column,HdItem);

      HdItem.Mask := HDI_BITMAP or HDI_FORMAT;
      HdItem.fmt := HDF_STRING or HDF_BITMAP;
      HdItem.hbm := FListArrow.Handle;
//      HdItem.iOrder := 1;
    end

    else begin
      HdItem.Mask := HDI_FORMAT;
      HdItem.fmt := HDF_STRING;
      HdItem.hbm := 0;
    end;

    Header_SetItem(GetDlgItem(List.Handle,0),Column,HdItem);
  end;              }
end;

procedure TfrmMain.customizerCreate;
begin
{  tbToolThemes
  tbToolThemesList.
  GetAvailableTBXThemes(
  TBXCUrrentTheme}
end;

procedure TfrmMain.spCustomizerLayoutLoad(Sender: TObject; LayoutName: String; ExtraOptions: TStringList);
begin
  TBXSetTheme(Settings.Cpx['Layout']['Theme'].asStr);
end;

procedure TfrmMain.spCustomizerLayoutSave(Sender: TObject; LayoutName: String; ExtraOptions: TStringList);
begin
  Settings.Cpx['Layout']['Theme'].asStr := TBXCurrentTheme;
end;

procedure TfrmMain.sidebarViewMax;
var i, j, shopIDs, shopID: integer;
    Customer: TCustomer;
    Shop: TShop;
    isShop: boolean;
    str: string;
begin
  pSbNoProject.Visible := false;
  pSbLastFiles.Visible := false;

  pSbDates.Visible := false;
  pSbActions.Visible := true;

  // Stand ausgewählt?
  isShop := (lvMax.SelCount > 0);
  if isShop then begin
    isShop := getIntFromListItem(lvMax.Selected,shopID);
    if isShop then Shop := Jimbo.Shops.byID(shopID);

    isShop := Shop is TShop;
  end;

  // Kein Stand
  if (not isShop) then begin
    // Daten sammeln
    shopIDs := 0; for i := 0 to Jimbo.Shops.Count-1 do begin
      for j := 0 to Jimbo.Dates.Count-1 do begin
        if Jimbo.ShopDates.indexOf(Jimbo.Dates[j].ID,Jimbo.Shops[i].ID) = -1 then continue;

        inc(shopIDs);
      end;
    end;

    str := intToStr(Jimbo.Shops.Count) + ' Stände'#13#10
         + intToStr(shopIDs) + ' davon mit aktuell';

    sidebarUpdateDetails(str);
    sidebarUpdateActions([sbaNew]);

    customerShopListUpdate;
  end

  // Ausgewählten Stand im Detail zeigen
  else begin
    // Alles updaten oder nur die Details
    sidebarUpdateDetails(nil,Shop);
    sidebarUpdateActions([sbaNew,sbaEdit,sbaDelete]);

    // Shop-Liste updaten
    // customerShopListUpdate;
  end;
end;

procedure TfrmMain.mapLoadedPiece(Sender: TObject);
begin
  if not Opened then exit;
  
  Painter.Update;
  Map.Update;
  Painter.Paint;
end;

procedure TfrmMain.toolbarJumpDo;
var Index, halfW, halfH: integer;
    Location: TLocation;
begin
 // if not I
//  Index := indexOf(tbToolJumpList.Strings,tbToolJumpList .IndexOf(NewText);
  Index := tbToolJumpList.ItemIndex;


  if Index = -1 then exit;
  if Map.Locations.Count <= Index then exit;

  Location := Map.Locations[Index];

  halfW := pbMap.ClientWidth div 2;
  halfH := pbMap.ClientHeight div 2;

  Map.Rect := Rect(
    Location.X - halfW,
    Location.Y - halfH,
    Location.X + halfW,
    Location.Y + halfH
  );

  Painter.Position := Point(Map.Rect.Left, Map.Rect.Top);

  Painter.Update;
  Painter.Paint;
end;

procedure TfrmMain.tbToolJumpListSelect(Sender: TTBCustomItem;
  Viewer: TTBItemViewer; Selecting: Boolean);
begin
  if not Selecting then toolbarJumpDo;
end;

procedure TfrmMain.tbToolJumpListChange(Sender: TObject; const Text: WideString);
var Index: integer;
begin
  Index := indexOf(Text,tbToolJumpList.Strings.AnsiStrings);
  if Index <> -1 then tbToolJumpList.ItemIndex := Index;
end;

procedure TfrmMain.tbToolJumpListItemClick(Sender: TObject);
begin
  toolbarJumpDo;
end;

end.
