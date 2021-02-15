unit uProjectEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls,

  // Fremdkomponenten
  PngSpeedButton,

  // Eigene Komponenten
  objJimbo, objPricer, objMaps, objDates, objCustomerTypes, objShopTypes, objShopDates, funcVCL,
  TBXDkPanels, SpTBXControls, TB2Item, TBX, SpTBXItem, TB2Dock, TB2Toolbar,
  ImgList, PngImageList;

type
  TfrmProjectEdit = class(TForm)
    pCommon: TPanel;
    sbImage: TPngSpeedButton;
    pBottom: TPanel;
    bvBottom: TBevel;
    lbTitleCpt: TLabel;
    edTitle: TEdit;
    lbDatesCpt: TLabel;
    lvDates: TListView;
    pTypes: TPanel;
    PngSpeedButton1: TPngSpeedButton;
    Label4: TLabel;
    lvCustomerTypes: TListView;
    Label2: TLabel;
    lvShopTypes: TListView;
    pMap: TPanel;
    PngSpeedButton2: TPngSpeedButton;
    Label5: TLabel;
    cbMaps: TComboBox;
    Label3: TLabel;
    edPassword: TEdit;
    sbDates: TPngSpeedButton;
    sbTitle: TPngSpeedButton;
    sbError: TPngSpeedButton;
    lbError: TLabel;
    sbCustomerTypes: TPngSpeedButton;
    sbShopTypes: TPngSpeedButton;
    tbDock: TSpTBXDock;
    SpTBXToolbar1: TSpTBXToolbar;
    tbCommon: TSpTBXItem;
    tbMap: TSpTBXItem;
    tbTypes: TSpTBXItem;
    btnSave: TSpTBXButton;
    btnCancel: TSpTBXButton;
    lbMap: TLabel;
    cbMapChange: TSpTBXCheckBox;
    Label1: TLabel;
    memOther: TMemo;
    PngImageList1: TPngImageList;
    btnAddDate: TPngSpeedButton;
    btnEditDate: TPngSpeedButton;
    btnDelDate: TPngSpeedButton;
    btnEditCType: TPngSpeedButton;
    btnDelCType: TPngSpeedButton;
    btnAddCType: TPngSpeedButton;
    btnAddSType: TPngSpeedButton;
    btnEditSType: TPngSpeedButton;
    btnDelSType: TPngSpeedButton;

    procedure btnAddDateClick(Sender: TObject);
    procedure btnEditDateClick(Sender: TObject);
    procedure btnDelDateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbCommonClick(Sender: TObject);
    procedure tbMapClick(Sender: TObject);
    procedure sbTypesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddCTypeClick(Sender: TObject);
    procedure btnEditCTypeClick(Sender: TObject);
    procedure btnDelCTypeClick(Sender: TObject);
    procedure btnAddSTypeClick(Sender: TObject);
    procedure btnEditSTypeClick(Sender: TObject);
    procedure btnDelSTypeClick(Sender: TObject);
    procedure lvDatesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure edTitleChange(Sender: TObject);
    procedure edPriceChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvCustomerTypesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvShopTypesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure tbTypesClick(Sender: TObject);
    procedure cbMapChangeClick(Sender: TObject);
    procedure lvDatesEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure lvCustomerTypesEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure lvShopTypesEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
  private
    // Sichbares
    FPanels: array[0..2] of TPanel;

    // Jimbo (angeliefert vom Dialog Objekt)
    FProject: TJimbo;
    FMaps: TMaps;

    procedure Load; {= Reset}
    procedure Save;

    procedure updateDates;
    procedure updateMaps;
    procedure updateCustomerTypes;
    procedure updateShopTypes;

    function checkForm(testPrice: boolean): boolean;

    procedure showPanel(Panel: TPanel);
  end;

  TProjectEditDialog = class
  private
    FForm: TfrmProjectEdit;
    FPricer: TPricer;

    procedure setProject(Project: TJimbo);
    function getProject: TJimbo;

    procedure setMaps(Maps: TMaps);
    function getMaps: TMaps;
  public
    constructor Create;
    destructor Destroy; override;

    function Execute: Boolean;

    property Project: TJimbo read getProject write setProject;
    property Pricer: TPricer read FPricer write FPricer;
    property Maps: TMaps read getMaps write setMaps;
  end;

implementation

uses uDateEdit, dlgCustomerTypes, dlgShopType;

{$R *.dfm}

{****************** TProjectEditDialog ******************}

constructor TProjectEditDialog.Create;
begin
  inherited Create;
  FForm := TfrmProjectEdit.Create(nil);
end;

destructor TProjectEditDialog.Destroy;
begin
  FForm.Free;
  inherited Destroy;
end;

procedure TProjectEditDialog.setProject(Project: TJimbo);
begin
  FForm.FProject := Project;
end;

function TProjectEditDialog.getProject: TJimbo;
begin
  Result := FForm.FProject;
end;

procedure TProjectEditDialog.setMaps(Maps: TMaps);
begin
  FForm.FMaps := Maps;
end;

function TProjectEditDialog.getMaps: TMaps;
begin
  Result := FForm.FMaps;
end;

function TProjectEditDialog.Execute: Boolean;
begin
  FForm.Load;

  Result := FForm.ShowModal = mrOK;

  if Result then FForm.Save
  else FForm.Load;
end;
                              


{****************** TfrmProjectDialog ******************}

procedure TfrmProjectEdit.Load;
begin
  edTitle.Text := FProject.Title;
  memOther.Text := FProject.Other;

  FProject.Dates.Load;
  FProject.shopTypes.Load;
  FProject.customerTypes.Load;

  updateDates;
  updateMaps;
  updateCustomerTypes;
  updateShopTypes;
end;

procedure TfrmProjectEdit.Save;
begin
  with FProject do begin
    Title := edTitle.Text;
    Other := memOther.Text;

    Dates.Save;
    shopTypes.Save;
    customerTypes.Save;
  end;
end;

procedure TfrmProjectEdit.btnAddDateClick(Sender: TObject);
var dlgDate: TDateDialog;
    aDate: TADate;
begin
  dlgDate := TDateDialog.Create;
  dlgDate.Mode := dmAdd;
  dlgDate.Pricer := FProject.Pricer;

  if not dlgDate.Execute then begin
    dlgDate.Free;
    exit;
  end;

  // Projekt + GUI updaten
  aDate := FProject.Dates.New;
  aDate.Assign(dlgDate.Date,false);

  updateDates;

  dlgDate.Free;
end;

procedure TfrmProjectEdit.btnEditDateClick(Sender: TObject);
var dlgDate: TDateDialog;
    dateID: integer;
begin
  if not (lvDates.Selected is TListItem) then exit;
  if not getIntFromListItem(lvDates.Selected,dateID) then exit;

  dlgDate := TDateDialog.Create;
  dlgDate.Mode := dmEdit;
  dlgDate.Pricer := FProject.Pricer;
  dlgDate.Date := FProject.Dates.byID(dateID);

  if not dlgDate.Execute then begin
    dlgDate.Free;
    exit;
  end;

  // Kopieren
  FProject.Dates.byID(dateID).Assign(dlgDate.Date,false);

  // Projekt + GUI updaten
  updateDates;

  dlgDate.Free;
end;

procedure TfrmProjectEdit.btnDelDateClick(Sender: TObject);
var aDate: TADate;
    usedCount: integer;
begin
  if not (lvDates.Selected is TListItem) then exit;
  if FProject.Dates.Count < lvDates.Selected.Index then exit;

  aDate := FProject.Dates[lvDates.Selected.Index];

  // Wird dieses Datum benutzt?
  usedCount := FProject.ShopDates.usedCount(aDate.ID);
  if (usedCount > 0) then begin
    MessageDlg('Dieses Datum kann nicht gelöscht werden, da es noch in Benutzung ist.',mtInformation,[mbOK],0);
    exit;
  end;

  // Löschen?
  if MessageDlg('Möchten Sie den gewählten Termin wirklich löschen?',mtConfirmation,[mbYes,mbNo],0) = mrNo then exit;

  FProject.Dates.Delete(aDate.ID);
  updateDates;
end;

procedure TfrmProjectEdit.updateDates;
var i: integer;
    liItem: TListItem;
begin
  disposeFromListView(lvDates);
  lvDates.Clear;

  for i := 0 to FProject.Dates.Count-1 do begin
    liItem := lvDates.Items.Add;

    liItem.Checked := FProject.Dates[i].Active;
    liItem.Caption := FProject.Dates[i].Title;
    liItem.SubItems.Add(DateToStr(FProject.Dates[i].Date));
    liItem.SubItems.Add(FProject.Dates[i].Price);

    writeIntToListItem(liItem,FProject.Dates[i].ID);
  end;
end;

procedure TfrmProjectEdit.showPanel(Panel: TPanel);
var i: integer;
begin
  for i := 0 to Length(FPanels)-1 do begin
    if (FPanels[i].Handle <> Panel.Handle) and (FPanels[i].Visible) then FPanels[i].Visible := false
    else if (FPanels[i].Handle = Panel.Handle) and (not FPanels[i].Visible) then FPanels[i].Visible := true;
  end;
end;


procedure TfrmProjectEdit.FormCreate(Sender: TObject);
begin
  FPanels[0] := pCommon;
  FPanels[1] := pMap;
  FPanels[2] := pTypes;

  showPanel(pCommon);
end;

procedure TfrmProjectEdit.tbCommonClick(Sender: TObject);
begin
  showPanel(pCommon);
end;

procedure TfrmProjectEdit.tbMapClick(Sender: TObject);
begin
  showPanel(pMap);
end;

procedure TfrmProjectEdit.updateMaps;
begin
  cbMaps.Clear;
  cbMaps.Items.Assign(FMaps.Maps);

  cbMaps.ItemIndex := cbMaps.Items.IndexOf(FProject.MapFile);
  if (cbMaps.ItemIndex = -1) and (cbMaps.Items.Count > 0) then cbMaps.ItemIndex := 0;
end;

procedure TfrmProjectEdit.updateCustomerTypes;
var i: integer;
    liItem: TListItem;
begin
  disposeFromListView(lvCustomerTypes);
  lvCustomerTypes.Clear;

  for i := 0 to FProject.customerTypes.Count-1 do begin
    liItem := lvCustomerTypes.Items.Add;

    liItem.Caption := FProject.customerTypes[i].Title;
    liItem.SubItems.Add(Format('%2.2f',[FProject.customerTypes[i].Multiplier]));

    writeIntToListItem(liItem,FProject.customerTypes[i].ID);
  end;
end;

procedure TfrmProjectEdit.updateShopTypes;
var i: integer;
    liItem: TListItem;
begin
  disposeFromListView(lvShopTypes);
  lvShopTypes.Clear;

  for i := 0 to FProject.shopTypes.Count-1 do begin
    liItem := lvShopTypes.Items.Add;

    liItem.Caption := FProject.shopTypes[i].Title;
    liItem.SubItems.Add(Format('%2.2f',[FProject.shopTypes[i].Multiplier]));

    writeIntToListItem(liItem,FProject.shopTypes[i].ID);
  end;
end;

procedure TfrmProjectEdit.sbTypesClick(Sender: TObject);
begin
  showPanel(pTypes);
end;

procedure TfrmProjectEdit.FormDestroy(Sender: TObject);
begin
  disposeFromListView(lvDates);
  disposeFromListView(lvCustomerTypes);
  disposeFromListView(lvShopTypes);
end;

procedure TfrmProjectEdit.btnAddCTypeClick(Sender: TObject);
var dlgCust: TCustomerTypeDialog;
    aType: TCustomerType;
begin
  dlgCust := TCustomerTypeDialog.Create;
  dlgCust.Mode := cdNew;

  if not dlgCust.Execute then begin
    dlgCust.Free;
    exit;
  end;

  // Projekt + GUI updaten
  aType := FProject.customerTypes.New;
  aType.Assign(dlgCust.customerType,false);

  updateCustomerTypes;

  dlgCust.Free;
end;

procedure TfrmProjectEdit.btnEditCTypeClick(Sender: TObject);
var dlgCust: TCustomerTypeDialog;
    typeID: integer;
begin
  if not (lvCustomerTypes.Selected is TListItem) then exit;
  if not getIntFromListItem(lvCustomerTypes.Selected,typeID) then exit;

  dlgCust := TCustomerTypeDialog.Create;
  dlgCust.Mode := cdEdit;
  dlgCust.customerType := FProject.customerTypes.byID(typeID);

  if not dlgCust.Execute then begin
    dlgCust.Free;
    exit;
  end;

  // Kopieren
  FProject.customerTypes.byID(typeID).Assign(dlgCust.customerType,false);

  // Projekt + GUI updaten
  updateCustomerTypes;

  dlgCust.Free;
end;

procedure TfrmProjectEdit.btnDelCTypeClick(Sender: TObject);
var i: integer;
    isUsed: boolean;
    aType: TCustomerType;
begin
  if not (lvCustomerTypes.Selected is TListItem) then exit;
  if not getIntFromListItem(lvCustomerTypes.Selected,i) then exit;
  if FProject.CustomerTypes.indexOf(i) = -1 then exit;

  aType := FProject.CustomerTypes.byID(i);

  // Wird dieses Datum benutzt?
  isUsed := false; for i := 0 to FProject.Customers.Count-1 do begin
    if FProject.Customers[i].typeID <> aType.ID then continue;
    isUsed := true; break;
  end;

  if (isUsed) then begin
    MessageDlg('Dieser Kunden-Typ kann nicht gelöscht werden, da es noch in Benutzung ist.',mtInformation,[mbOK],0);
    exit;
  end;

  // Löschen?
  if MessageDlg('Möchten Sie den gewählten Kunden-Typ wirklich löschen?',mtConfirmation,[mbYes,mbNo],0) = mrNo then exit;

  FProject.customerTypes.Delete(aType.ID);
  updateCustomerTypes;
end;

procedure TfrmProjectEdit.btnAddSTypeClick(Sender: TObject);
var dlgShop: TShopTypeDialog;
    aType: TShopType;
begin
  dlgShop := TShopTypeDialog.Create;
  dlgShop.Mode := sdNew;

  if not dlgShop.Execute then begin
    dlgShop.Free;
    exit;
  end;

  // Projekt + GUI updaten
  aType := FProject.shopTypes.New;
  aType.Assign(dlgShop.shopType,false);

  updateShopTypes;

  dlgShop.Free;
end;

procedure TfrmProjectEdit.btnEditSTypeClick(Sender: TObject);
var dlgShop: TShopTypeDialog;
    typeID: integer;
begin
  if not (lvShopTypes.Selected is TListItem) then exit;
  if not getIntFromListItem(lvShopTypes.Selected,typeID) then exit;

  dlgShop := TShopTypeDialog.Create;
  dlgShop.Mode := sdEdit;
  dlgShop.shopType := FProject.shopTypes.byID(typeID);

  if not dlgShop.Execute then begin
    dlgShop.Free;
    exit;
  end;

  // Kopieren
  FProject.shopTypes.byID(typeID).Assign(dlgShop.shopType,false);

  // Projekt + GUI updaten
  updateShopTypes;

  dlgShop.Free;
end;

procedure TfrmProjectEdit.btnDelSTypeClick(Sender: TObject);
var i: integer;
    isUsed: boolean;
    aType: TShopType;
begin
  if not (lvShopTypes.Selected is TListItem) then exit;
  if not getIntFromListItem(lvShopTypes.Selected,i) then exit;
  if FProject.ShopTypes.indexOf(i) = -1 then exit;

  aType := FProject.ShopTypes.byID(i);

  // Wird dieser Typ benutzt?
  isUsed := false; for i := 0 to FProject.Shops.Count-1 do begin
    if FProject.Shops[i].typeID <> aType.ID then continue;
    isUsed := true; break;
  end;

  if (isUsed) then begin
    MessageDlg('Dieser Stand-Typ kann nicht gelöscht werden, da es noch in Benutzung ist.',mtInformation,[mbOK],0);
    exit;
  end;

  // Löschen?
  if MessageDlg('Möchten Sie den gewählten Stand-Typ wirklich löschen?',mtConfirmation,[mbYes,mbNo],0) = mrNo then exit;

  FProject.ShopTypes.Delete(aType.ID);
  updateShopTypes;
end;

procedure TfrmProjectEdit.lvDatesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
var dateID: integer;
    aDate: TADate;
begin
  checkForm(false);

  if not (Item is TListItem) then exit;
  if not getIntFromListItem(Item,dateID) then exit;

  aDate := FProject.Dates.byID(dateID);
  if not (aDate is TADate) then exit;

  aDate.Active := Item.Checked;
  checkForm(false);
end;

function TfrmProjectEdit.checkForm(testPrice: boolean): Boolean;
var isErr: Boolean;

    dummyInt, i: integer;
begin
  isErr := false;

  if Trim(edTitle.Text) = '' then begin sbTitle.Show; isErr := true; end else sbTitle.Hide;

  // Termine
  dummyInt := 0; for i := 0 to lvDates.Items.Count-1 do begin
    if not lvDates.Items[i].Checked then continue;
    dummyInt := 1; break;
  end;

  if (dummyInt = 0) then begin sbDates.Show; isErr := true; end else sbDates.Hide;

  // Karte
  cbMaps.Enabled := false;
  cbMapChange.Checked := false;

  // Kunden-Typen + Shop-Typen
  if (lvCustomerTypes.Items.Count = 0) then begin sbCustomerTypes.Show; isErr := true; end else sbCustomerTypes.Hide;
  if (lvShopTypes.Items.Count = 0) then begin sbShopTypes.Show; isErr := true; end else sbShopTypes.Hide;


  if isErr then begin
    lbError.Caption := 'Bitte füllen Sie alle benötigten Felder aus. '
                     + 'Nicht oder fehlerhaft ausgefüllte Felder werden '
                     + 'mit einem gelben Ausrufezeichen markiert.';

    sbError.Show;
    btnSave.Enabled := false;
    Result := false;
    exit;
  end;

  // Datum Buttons aktivieren/deaktivieren
  if lvDates.SelCount = 0 then begin
    btnEditDate.Visible := false;
    btnDelDate.Visible := false;
  end

  else begin
    btnEditDate.Visible := true;
    btnDelDate.Visible := true;
  end;

  // CTypen Buttons aktivieren/deaktivieren
  if lvCustomerTypes.SelCount = 0 then begin
    btnEditCType.Visible := false;
    btnDelCType.Visible := false;
  end

  else begin
    btnEditCType.Visible := true;
    btnDelCType.Visible := true;
  end;

  // CTypen Buttons aktivieren/deaktivieren
  if lvShopTypes.SelCount = 0 then begin
    btnEditSType.Visible := false;
    btnDelSType.Visible := false;
  end

  else begin
    btnEditSType.Visible := true;
    btnDelSType.Visible := true;
  end;

  sbError.Hide;
  lbError.Caption := '';
  
  btnSave.Enabled := true;
  Result := true;
end;


procedure TfrmProjectEdit.edTitleChange(Sender: TObject);
begin
  checkForm(false);
end;

procedure TfrmProjectEdit.edPriceChange(Sender: TObject);
begin
  checkForm(true);
end;

procedure TfrmProjectEdit.FormShow(Sender: TObject);
begin
  checkForm(true);
end;

procedure TfrmProjectEdit.lvCustomerTypesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  checkForm(false);
end;

procedure TfrmProjectEdit.lvShopTypesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  checkForm(false);
end;

procedure TfrmProjectEdit.tbTypesClick(Sender: TObject);
begin
  showPanel(pTypes);
end;

procedure TfrmProjectEdit.cbMapChangeClick(Sender: TObject);
begin
  cbMaps.Enabled := cbMapChange.Checked;
end;

procedure TfrmProjectEdit.lvDatesEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

procedure TfrmProjectEdit.lvCustomerTypesEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

procedure TfrmProjectEdit.lvShopTypesEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

end.
