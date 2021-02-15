unit uEditDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons, ToolWin, Math,

  // Fremdkomponenten
  PngImageList, PngSpeedButton,

  // Eigene Komponenten
  _define, objJimbo, objShops, objCustomers, objMap, objIntegerList, funcCommon, funcVCL,
  TB2Item, TBXDkPanels, SpTBXControls, TB2Dock, TB2Toolbar, TBX, SpTBXItem,
  ImgList;

type
  TShopDialogMode = (sdNew, sdNewCustomer, sdEdit, sdEditCustomer);
  TShopDialogPanel = (edpFindout, edpShop, edpCustomer);

  TEditDialog = class(TForm)
    pCustomer: TPanel;
    sbCustomerInfo: TPngSpeedButton;
    pBottom: TPanel;
    bvBottom: TBevel;
    pShop: TPanel;
    sbShopCpt: TPngSpeedButton;
    lbSizeCpt: TLabel;
    lbLocationCpt: TLabel;
    lbSizeXCpt: TLabel;
    lbSizeMeterCpt: TLabel;
    edWidth: TEdit;
    edHeight: TEdit;
    lbDatesCpt: TLabel;
    lvDates: TListView;
    cbLocation: TComboBox;
    Label5: TLabel;
    edeMail: TEdit;
    edPhone: TEdit;
    lbPhoneCpt: TLabel;
    lbCityCpt: TLabel;
    edZIP: TEdit;
    edCity: TEdit;
    edAddress: TEdit;
    lbAddressCpt: TLabel;
    lbLastnameCpt: TLabel;
    edLastname: TEdit;
    edFirstname: TEdit;
    lbFirstnameCpt: TLabel;
    lbCompanyCpt: TLabel;
    edCompany: TEdit;
    Label2: TLabel;
    cbExistingCustomerList: TComboBox;
    memOtherCust: TMemo;
    rbSexM: TRadioButton;
    rbSexF: TRadioButton;
    Label1: TLabel;
    cbShopTypes: TComboBox;
    memOtherShop: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    cbNewCustomer: TCheckBox;
    sbLastname: TPngSpeedButton;
    sbAddress: TPngSpeedButton;
    sbCity: TPngSpeedButton;
    sbSize: TPngSpeedButton;
    sbLocation: TPngSpeedButton;
    sbDates: TPngSpeedButton;
    lbError: TLabel;
    sbError: TPngSpeedButton;
    lbLocationInfo: TLabel;
    rbSexNone: TRadioButton;
    cbCustomerTypes: TComboBox;
    lbCustomerTypeCpt: TLabel;
    edCID: TEdit;
    sbCID: TPngSpeedButton;
    tbDock: TSpTBXDock;
    SpTBXToolbar1: TSpTBXToolbar;
    sbCustomer: TSpTBXItem;
    sbShop: TSpTBXItem;
    btnSave: TSpTBXButton;
    btnCancel: TSpTBXButton;
    Label6: TLabel;
    lbShopFor: TLabel;
    cbLocationJump: TCheckBox;
    PngImageList1: TPngImageList;
    procedure cbExistingCustomerListChange(Sender: TObject);
    procedure editMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

    // Button-Aktionen
    procedure btnSaveClick(Sender: TObject);
    procedure cbNewCustomerClick(Sender: TObject);
    procedure checkKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure checkClick(Sender: TObject);
    procedure cbExistingCustomerListKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbCustomerClick(Sender: TObject);
    procedure sbShopClick(Sender: TObject);
    procedure lvDatesEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure cbLocationJumpClick(Sender: TObject);
  private
    // Sichbares
    FPanels: array[0..1] of TPanel;
    FButtons: array[0..1] of TSpeedButton;

    // Objekte (Ref.)
    FProject: TJimbo;
    FLocations: TLocations;
    FLocationID: integer;
    FDateIDs: TIntegerList;




    // WORKAROUND

    FDoJump: boolean;

    // Modus und IDs der zu bearbeitenden Objekte
    FMode: TShopDialogMode;
    FPanel: TShopDialogPanel;
    FCustomerID: integer;
    FShopID: integer;

    procedure Load;
    procedure Save;

    function checkForm: Boolean;

    procedure disposeComboBox(const List: TComboBox);
    procedure disposeListView(const List: TListView);

    procedure setProject(const Project: TJimbo);
    procedure setLocations(const Locations: TLocations);

    // Sichtbares
    procedure showPanel(Panel: TPanel);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Execute: Boolean;

    property Project: TJimbo read FProject write setProject;
    property Locations: TLocations read FLocations write setLocations;
    property LocationID: integer read FLocationID write FLocationID;
    property DateIDs: TIntegerList read FDateIDs;

    property Mode: TShopDialogMode read FMode write FMode;
    property Panel: TShopDialogPanel read FPanel write FPanel;

    property shopID: integer read FShopID write FShopID;
    property customerID: integer read FCustomerID write FCustomerID;
  end;

implementation

{$R *.dfm}

constructor TEditDialog.Create(AOwner: TComponent);
begin                               
  inherited Create(nil);
                    
  // Sichtbares
  FPanels[0] := pCustomer;
  FPanels[1] := pShop;

  FDateIDs := TIntegerList.Create;

  FMode := sdNew;
  FPanel := edpFindout;
  FCustomerID := -1;
  FShopID := -1;

  FLocationID := -1;
end;

destructor TEditDialog.Destroy;
begin
  disposeComboBox(cbExistingCustomerList);
  disposeComboBox(cbLocation);
  disposeListView(lvDates);

  FDateIDs.Free;
  inherited Destroy;
end;

procedure TEditDialog.showPanel(Panel: TPanel);
var i: integer;
begin
  for i := 0 to Length(FPanels)-1 do begin
    if (FPanels[i].Handle <> Panel.Handle) and (FPanels[i].Visible) then FPanels[i].Visible := false
    else if (FPanels[i].Handle = Panel.Handle) and (not FPanels[i].Visible) then FPanels[i].Visible := true;
  end;
end;

procedure TEditDialog.Load;
var i, tmpInt: integer;

    Shop: TShop;
    Customers: TCustomers;
    Customer: TCustomer;
    tmpLoc: TLocation;
    
    PInt: PInteger;
    liItem: TListItem;
begin
  // Edit-Felder zurücksetzen
  rbSexNone.Checked := true;
  edCID.Clear;
  edCompany.Clear;
  edFirstname.Clear;
  edLastname.Clear;
  edAddress.Clear;
  edZIP.Clear;
  edCity.Clear;
  edPhone.Clear;
  edeMail.Clear;
  memOtherCust.Clear;
  memOtherShop.Clear;

  // "Neuer Kunde" einblenden
  cbNewCustomer.Visible := true;

  cbExistingCustomerList.ItemIndex := -1;
  cbExistingCustomerList.Text := '';

  // Buttons und Paneele zurücksetzen
  if (FMode = sdNew) or (FMode = sdEdit) then begin
    if (FPanel = edpShop) or ((FPanel = edpFindout) and (FMode = sdEdit)) then showPanel(pShop)
    else showPanel(pCustomer);
  end

  else begin
    showPanel(pCustomer);
    pShop.Visible := false;
    sbShop.Visible := false;
  end;

  // Kundenliste laden
  disposeComboBox(cbExistingCustomerList);
  cbExistingCustomerList.Clear;

  // Sortieren
  FProject.Customers.sortBy(cfLastname,true);

  for i := 0 to FProject.Customers.Count-1 do begin
    // ID als Objekt anfügen
    Customer := FProject.Customers[i];
    System.New(PInt); PInt^ := Customer.ID;

    cbExistingCustomerList.Items.AddObject(
      Format(
        '%s, %s',
        [Customer.Lastname,Customer.Firstname]
      ),
      TObject(PInt)
    );
  end;

  // Termine laden
  disposeListView(lvDates);
  lvDates.Clear;

  for i := 0 to FProject.Dates.Count-1 do begin
    //if not FProject.Dates[i].Active then continue;

    liItem := lvDates.Items.Add;
    liItem.Caption := FProject.Dates[i].Title;
    liItem.SubItems.Add(DateToStr(FProject.Dates[i].Date));

    // Date-ID anfügen
    System.New(PInt); PInt^ := FProject.Dates[i].ID;
    liItem.Data := PInt;
  end;

  // Shop-Typen laden
  cbShopTypes.Clear;
  for i := 0 to FProject.shopTypes.Count-1 do begin
    // Typ-ID anfügen
    System.New(PInt); PInt^ := FProject.shopTypes[i].ID;
    cbShopTypes.Items.AddObject(FProject.shopTypes[i].Title,TObject(PInt));
  end;

  // Kunden-Typen laden
  cbCustomerTypes.Clear;
  for i := 0 to FProject.customerTypes.Count-1 do begin
    // Typ-ID anfügen
    System.New(PInt); PInt^ := FProject.customerTypes[i].ID;
    cbCustomerTypes.Items.AddObject(FProject.customerTypes[i].Title,TObject(PInt));
  end;

  // Sprung-Punkte laden (Locations)
  disposeComboBox(cbLocation);
  cbLocation.Clear;

  for i := 0 to FLocations.Count-1 do begin
    // ID als Objekt anfügen
    System.New(PInt); PInt^ := FLocations[i].ID;
    cbLocation.Items.AddObject(FLocations[i].Title,TObject(PInt));
  end;

  // Spez. Dialogänderungen vornehmen
                                                           
  if (FMode = sdEditCustomer) or (FMode = sdEdit) then begin
    // Kundenliste zum aktuellen Kunden scrollen
    Customer := FProject.Customers.byID(customerID);
    if not (Customer is TCustomer) then raise Exception.Create('falsche kunden-id');

    for i := 0 to FProject.Customers.Count-1 do begin
      if (Customer.ID <> FProject.Customers[i].ID) then continue;
      cbExistingCustomerList.ItemIndex := i;
    end;

    // "Neuer Kunde" ausblenden
    cbNewCustomer.Visible := false;

    // Andere Informationen laden
    cbExistingCustomerListChange(nil);

    // Kunden-Typ auswählen
    for i := 0 to cbCustomerTypes.Items.Count-1 do begin
      PInt := PInteger(cbCustomerTypes.Items.Objects[i]);
      if (PInt^ <> Customer.typeID) then continue;

      cbCustomerTypes.ItemIndex := i; break;
    end;


    // "Nur-Kunde" bearbeiten
    if FMode = sdEditCustomer then begin
      Caption := 'Kundeninformation bearbeiten';

      sbShop.Visible := false;
      showPanel(pCustomer);
    end

    // Kunde + Shop bearbeiten
    else if FMode = sdEdit then begin
      Caption := 'Stand und Kunde bearbeiten';

      Shop := FProject.Shops.byID(FShopID);

      // Shop-Typ auswählen
      for i := 0 to cbShopTypes.Items.Count-1 do begin
        PInt := PInteger(cbShopTypes.Items.Objects[i]);
        if (PInt^ <> Shop.typeID) then continue;

        cbShopTypes.ItemIndex := i; break;
      end;

      // Typ: Standard setzen wenn keiner in DB
      if cbShopTypes.ItemIndex = -1 then begin
        for i := 0 to cbShopTypes.Items.Count-1 do begin
          PInt := PInteger(cbShopTypes.Items.Objects[i]);
          if (PInt^ <> FProject.shopTypeID) then continue;

          cbShopTypes.ItemIndex := i; break;
        end;
      end;

      // Location auswählen
      if Shop.locationID = -1 then cbLocation.Text := Shop.Address
      else begin
        for i := 0 to cbLocation.Items.Count-1 do begin
          PInt := PInteger(cbLocation.Items.Objects[i]);
          if (PInt^ <> Shop.locationID) then continue;

          cbLocation.ItemIndex := i;
          break;
        end;

        // Adresse testen (Sprungpunkt)
     {   if cbLocation.ItemIndex <> -1 then begin
          // Achtung: Benutzung von pInt^ nur, wenn vor dem IF
          // nichts daran geändert wird.

          if FLocations.At(Shop.X,Shop.Y,tmpLoc) then begin
          end

          else b
        end;    }

      end;

      // Termine ankreuzen
      for i := 0 to lvDates.Items.Count-1 do begin
        PInt := lvDates.Items[i].Data;
        if FProject.ShopDates.indexOf(PInteger(PInt)^,Shop.ID) >= 0 then lvDates.Items[i].Checked := true;
      end;

      // Shop-Infos laden
      edWidth.Text := Format('%2.2f',[Shop.Width]);
      edHeight.Text := Format('%2.2f',[Shop.Height]);
      cbLocation.Text := Shop.Address;
      memOtherShop.Text := Shop.Other;
    end;
  end

  // Neuer Kunde
  else if (FMode = sdNew) or (FMode = sdNewCustomer) then begin

    // Kunden-Typ (Standard) auswählen
    for i := 0 to cbCustomerTypes.Items.Count-1 do begin
      pInt := pInteger(cbCustomerTypes.Items.Objects[i]);
      if (pInt^ <> FProject.customerTypeID) then continue;

      cbCustomerTypes.ItemIndex := i; break;
    end;

    // Neuer Kunde
    if (FMode = sdNewCustomer) then begin
      Caption := 'Neuen Kunden erstellen';

      // "Neuer Kunde" anklicken
      cbNewCustomer.Visible := true;
      cbNewCustomer.Checked := true;
      cbNewCustomer.Enabled := false;
    end

    // Neuer Kunde/Shop
    else if FMode = sdNew then begin

      // Kundenliste zum aktuellen Kunden scrollen
      if CustomerID <> -1 then begin
        Customer := FProject.Customers.byID(customerID);
        if (Customer is TCustomer) then begin
          for i := 0 to FProject.Customers.Count-1 do begin
            if (Customer.ID <> FProject.Customers[i].ID) then continue;
            cbExistingCustomerList.ItemIndex := i;
          end;
        end;

        // Andere Informationen laden
        cbExistingCustomerListChange(nil);

        showPanel(pShop);
      end

      else begin
        // "Neuer Kunde" anklicken
        cbNewCustomer.Visible := true;
        cbNewCustomer.Checked := true;

        Caption := 'Neuen Stand erstellen';
      end;

      // Ausgewählten Termin ankreuzen
      for i := 0 to lvDates.Items.Count-1 do begin
        PInt := lvDates.Items[i].Data;
        if FProject.dateID = PInteger(PInt)^ then lvDates.Items[i].Checked := true;
      end;

      // Standard-Typ ankreuzen
      for i := 0 to cbShopTypes.Items.Count-1 do begin
        PInt := PInteger(cbShopTypes.Items.Objects[i]);
        if (PInt^ <> FProject.shopTypeID) then continue;

        cbShopTypes.ItemIndex := i;
        break;
      end;

      // Zur nächsten Location scrollen
      if FLocationID <> -1 then begin
        for i := 0 to cbLocation.Items.Count-1 do begin
          if not getIntFromStringListItem(cbLocation.Items,i,tmpInt) then continue;
          if tmpInt <> FLocationID then continue;

          cbLocation.ItemIndex := i;
          break;
        end;
      end;
    end;

    // Neue cID lesen
    edCID.Text := intToStr(FProject.Customers.NextCID);

    if (cbExistingCustomerList.Items.Count = 0) then begin
      cbNewCustomer.Visible := true;
      cbNewCustomer.Checked := true;
      cbNewCustomer.Enabled := false;
    end;
  end;
end;

procedure TEditDialog.Save;
var i, ID: integer;

    Customer: TCustomer;
    Shop: TShop;
    Location: TLocation;
begin
  // CUSTOMER

  // Kunde speichern (Kunde anlegen oder Referenz lesen)
  case cbNewCustomer.Checked of
    true: Customer := FProject.Customers.New;

    else begin                
      if FCustomerID = -1 then Customer := FProject.Customers.New
      else Customer := FProject.Customers.byID(customerID);
    end;
  end;

  // FEHLERBEHANDLUNG
  if not (Customer is TCustomer) then raise Exception.Create('Fehler beim Lesen des Kunden');

  with Customer do begin
    if rbSexM.Checked then Sex := 'm'
    else if rbSexF.Checked then Sex := 'f'
    else Sex := '-';

    if not TryStrToInt(edCID.Text,i) then i := 0;
    if i < 0 then i := 0;
    cID := i;

    Company := edCompany.Text;
    Firstname := edFirstname.Text;
    Lastname := edLastname.Text;
    Address := edAddress.Text;

    if not TryStrToInt(edZIP.Text,i) then i := 0;
    if i < 0 then i := 0;
    ZIP := i;

    City := edCity.Text;
    Phone := edPhone.Text;
    eMail := edeMail.Text;
    Other := memOtherCust.Text;

    // Kunden-Typ lesen
    // FEHLERBEHANDLUNG
    if cbCustomerTypes.ItemIndex = -1 then typeID := FProject.customerTypeID
    else typeID := PInteger(cbCustomerTypes.Items.Objects[cbCustomerTypes.ItemIndex])^;

    // Vorspeichern, um eine ID zu erhalten
    Save;
  end;

  // SHOP

  // Shop speichern
  if (FMode = sdNew) or (FMode = sdEdit) then begin

    // Shop speichern (Anlegen oder Referenz lesen)
    case FMode of
      sdNew: begin
        Shop := FProject.Shops.New;

        // "Vorspeichern" um eine ID zu erhalten
        Shop.Save;
      end;

      sdEdit: Shop := FProject.Shops.byID(shopID);
    end;

    // Shop wählen
    if not (Shop is TShop) then raise Exception.Create('Fehler beim Lesen des Shops');

    // FEHLERBEHANDLUNG
    try Shop.setDimension(StrToFloat(edWidth.Text),StrToFloat(edHeight.Text));
    except raise Exception.Create('Falsche angaben der Dimension'); end;

    Shop.Other := memOtherShop.Text;

    // Gegenseitige Referenzierung (Reihenfolge ist wichtig!)
    //Customer.Shops.addRef(Shop);
    //Shop.Owner := Customer;
    Shop.customerID := Customer.ID;

    // Typ-ID
    // FEHLERBEHANDLUNG
    ID := PInteger(cbShopTypes.Items.Objects[cbShopTypes.ItemIndex])^;
    Shop.typeID := ID;

    // Location-ID bzw. Location-String
    i := indexOf(cbLocation.Text,cbLocation.Items);
    if i = -1 then begin
      Shop.Address := cbLocation.Text;
      Shop.locationID := -1;
    end

    else begin
      // FEHLERBEHANDLUNG
      ID := PInteger(cbLocation.Items.Objects[i])^;
      Shop.locationID := ID;
      Shop.Address := cbLocation.Items[i];

      Location := FLocations.byID(ID);
      if (Location.ID <> -1) and FDoJump then
        Shop.setPosition(Location.X,Location.Y);
    end;

    // Shop/Datum Verknüpfungen setzen
    FProject.ShopDates.deleteShop(Shop.ID);
    
    for i := 0 to lvDates.Items.Count-1 do begin
      if not lvDates.Items[i].Checked then continue;

      // FEHLERBEHANDLUNG
      ID := PInteger(lvDates.Items[i].Data)^;
      FProject.ShopDates.Add(ID,Shop.ID);
    end;
  end;

  case FMode of
    sdNew, sdEdit: begin
      Shop.Save;
      Customer.Save;

      FShopID := Shop.ID;
      FCustomerID := Customer.ID;
    end;

    sdNewCustomer, sdEditCustomer: begin
      Customer.Save;

      FShopID := -1;
      FCustomerID := Customer.ID;
    end;
  end;
end;

procedure TEditDialog.setProject(const Project: TJimbo);
begin
  FProject := Project;
end;

procedure TEditDialog.setLocations(const Locations: TLocations);
begin
  FLocations := Locations;
end;

function TEditDialog.Execute: Boolean;
begin
  Load;

  Result := ShowModal = mrOK;
  if not Result then exit;

  Save;
end;

procedure TEditDialog.disposeComboBox(const List: TComboBox);
var i: integer;
begin
  for i := 0 to List.Items.Count-1 do begin
    if (List.Items.Objects[i] = nil) then continue;
    Dispose(PInteger(List.Items.Objects[i]));
  end;
end;

procedure TEditDialog.disposeListView(const List: TListView);
var i: integer;
begin
  for i := 0 to List.Items.Count-1 do begin
    if (List.Items[i].Data = nil) then continue;
    Dispose(PInteger(List.Items[i].Data));
  end;
end;

procedure TEditDialog.btnSaveClick(Sender: TObject);
begin
  if checkForm then begin
    ModalResult := mrOk;
    exit;
  end;

  MessageDlg('Bitte füllen Sie alle benötigten Felder aus.'#13#10#13#10'Nicht oder fehlerhaft ausgefüllte Felder werden mit einem'#13#10'gelben Ausrufezeichen markiert.',mtInformation,[mbOK],0);
  ModalResult := mrNone;
end;

procedure TEditDialog.cbExistingCustomerListChange(Sender: TObject);
var i, ID: integer;
    pInt: pInteger;

    Customer: TCustomer;
begin
  // Alle Kunden auf die Eingabe im Feld prüfen
  i := indexOf(cbExistingCustomerList.Text,cbExistingCustomerList.Items);
  if i <> -1 then begin
    cbExistingCustomerList.ItemIndex := i;
//    if (cbExistingCustomerList.Text <> Format('%s, %s',[Customer.Lastname,Customer.Firstname])) then cbExistingCustomerList.Text := Format('%s, %s',[Customer.Lastname,Customer.Firstname]);

    ID := PInteger(cbExistingCustomerList.Items.Objects[i])^;
    Customer := FProject.Customers.byID(ID);

    if not (Customer is TCustomer) then exit;

    FCustomerID := ID;

    // Kunden-Typ auswählen
    for i := 0 to cbCustomerTypes.Items.Count-1 do begin
      pInt := pInteger(cbCustomerTypes.Items.Objects[i]);
      if (pInt^ <> Customer.typeID) then continue;

      cbCustomerTypes.ItemIndex := i; break;
    end;

    // Details setzen
    if Customer.Sex = 'f' then rbSexF.Checked := true
    else if Customer.Sex = 'm' then rbSexM.Checked := true
    else rbSexNone.Checked := true;

    if Customer.cID <= 0 then edCID.Clear
    else edCID.Text := intToStr(Customer.cID);
    
    edCompany.Text := Customer.Company;
    edFirstname.Text := Customer.Firstname;
    edLastname.Text := Customer.Lastname;
    edAddress.Text := Customer.Address;
    edZIP.Text := intToStr(Customer.ZIP);
    edCity.Text := Customer.City;
    edPhone.Text := Customer.Phone;
    edeMail.Text := Customer.eMail;
    memOtherCust.Text := Customer.Other;

    lbShopFor.Caption := 'für '+Customer.Firstname+' '+Customer.Lastname;
  end

  else begin
    FCustomerID := -1;

    // Kunden-Typ (Standard) auswählen
    for i := 0 to cbCustomerTypes.Items.Count-1 do begin
      pInt := pInteger(cbCustomerTypes.Items.Objects[i]);
      if (pInt^ <> FProject.customerTypeID) then continue;

      cbCustomerTypes.ItemIndex := i; break;
    end;

    rbSexM.Checked := true;

    edCID.Clear;
    edCompany.Clear;
    edFirstname.Clear;
    edLastname.Clear;
    edAddress.Clear;
    edZIP.Clear;
    edCity.Clear;
    edPhone.Clear;
    edeMail.Clear;
    memOtherCust.Clear;

    lbShopFor.Caption := 'für (Neuer Kunde)';

    exit;
  end;
end;

procedure TEditDialog.editMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var i: integer;
    Edit: TEdit;
    Group: TWinControl;
begin
  if not (Sender is TEdit) then exit;
  Edit := Sender as TEdit;

  if not (Edit.Parent is TWinControl) then exit;
  Group := Edit.Parent as TWinControl;

  for i := 0 to Group.ControlCount-1 do begin
    if not (Group.Controls[i] is TEdit) then continue;

    // Das aktuelle Editfeld
    if ((Group.Controls[i] as TEdit) = Edit) and (Edit.Color = clWindow) then begin
      Edit.Color := $00F2F2F2;
      continue;
    end;

    if ((Group.Controls[i] as TEdit) <> Edit) and ((Group.Controls[i] as TEdit).Color = $00F2F2F2) then (Group.Controls[i] as TEdit).Color := clWindow;
  end;
end;

procedure TEditDialog.cbNewCustomerClick(Sender: TObject);
begin
  case cbNewCustomer.Checked of
    true: begin
      cbExistingCustomerList.ItemIndex := -1;
      cbExistingCustomerList.Enabled := false;
      cbExistingCustomerList.Text := 'Neuer Kunde';

      cbExistingCustomerListChange(nil);
      if Visible then edFirstname.SetFocus;
    end;

    false: begin
      cbExistingCustomerList.ItemIndex := -1;
      cbExistingCustomerList.Enabled := true;
      cbExistingCustomerList.Text := '';
      
      cbExistingCustomerListChange(nil);
      if Visible then cbExistingCustomerList.SetFocus;
    end;
  end;

  checkForm;
end;

procedure TEditDialog.checkKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  checkForm;
end;

function TEditDialog.checkForm: Boolean;
var i, customerID: integer;
    isErr: Boolean;

    dummyInt: integer;
    dummyFloat, dummyFloat2: double;
    dummyBool: boolean;

    Location: TLocation;
    Shop: TShop;
begin
  isErr := false;

  // Seite "Kunde"
  if (Trim(edCID.Text) = '') then sbCID.Hide
  else if TryStrToInt(edCID.Text,dummyInt) then begin
    if (dummyInt <= 0) or (not getIntFromStringListItem(cbExistingCustomerList.Items,cbExistingCustomerList.ItemIndex,customerID)) then begin
      sbCID.Hide;
    end
    else for i := 0 to FProject.Customers.Count-1 do begin
      if (FProject.Customers[i].ID = customerID) then continue;
      if (FProject.Customers[i].cID <> dummyInt) then continue;

      sbCID.Hint := 'Die gewählte Kundennummer ist schon vergeben an '''+FProject.Customers[i].Lastname+'''';
      sbCID.Show;
      //isErr := true;
    end;

   //if not isErr then sbCID.Hide;
  end
  else begin
    sbCID.Hint := 'In der Kundennummer sind keine Buchstaben erlaubt.';
    sbCID.Show;

    isErr := true;
  end;

  if Trim(edLastname.Text) = '' then begin sbLastname.Show; isErr := true; end else sbLastname.Hide;
  if Trim(edAddress.Text) = '' then begin sbAddress.Show; isErr := true; end else sbAddress.Hide;
  if (Trim(edZIP.Text) = '') or (Trim(edCity.Text) = '') or (not TryStrToInt(edZIP.Text,dummyInt)) then begin sbCity.Show; isErr := true; end else sbCity.Hide;

  if (FMode = sdNew) or (FMode = sdEdit) then begin
    // Größe
    if (not TryStrToFloat(edWidth.Text,dummyFloat)) or (not TryStrToFloat(edHeight.Text,dummyFloat2)) then begin
      sbSize.Hint := 'Die Eingaben sind keine gültigen Zahlen';
      sbSize.Show;
      isErr := true;
    end
    else begin
      if not InRange(dummyFloat,1,SHOP_SIZE_MAXWIDTH) then begin
        sbSize.Hint := Format('Die Breite des Standes muss zwischen 1 und %2.2f m liegen.',[SHOP_SIZE_MAXWIDTH]);
        sbSize.Show;
        isErr := true;
      end

      else if not InRange(dummyFloat2,1,SHOP_SIZE_MAXHeight) then begin
        sbSize.Hint := Format('Die Länge des Standes muss zwischen 1 und %2.2f m liegen.',[SHOP_SIZE_MAXHEIGHT]);
        sbSize.Show;
        isErr := true;
      end

      // Alles Ok.
      else sbSize.Hide;
    end;

    if (cbLocation.ItemIndex = -1) and (Trim(cbLocation.Text) = '') then begin sbLocation.Show; isErr := true; end else sbLocation.Hide;

    if cbLocation.ItemIndex = -1 then begin
      sbLocation.Hide;
      lbLocationInfo.Show;
      cbLocationJump.Hide;

      lbLocationInfo.Caption := 'Kein Spungpunkt erkannt.'#13#10#13#10'Hinweis: Sollte der Stand verschoben werden, kann ohne Sprungpunkt-Prüfung vorgenommen werden.';
    end
    else begin
      // FEHLERBEHANDLUNG
      getIntFromStringListItem(cbLocation.Items,cbLocation.ItemIndex,dummyInt);

      // FEHLERBEHANDLUNG
      Location := FLocations.byID(dummyInt);
      if Location.ID = -1 then close;

      // FEHLERBEHANDLUNG
      Shop := FProject.Shops.byID(FShopID);

      // Location wurde noch nicht geändert
      if Assigned(Shop) and (Location.ID = Shop.LocationID) then begin

        if FLocations.At(Shop.X,Shop.Y,Location) then begin
          cbLocationJump.Hide;
          cbLocationJump.Checked := false;

          sbLocation.Hide;
          lbLocationInfo.Caption := 'Sprungpunkt erkannt!';
        end else begin
          lbLocationInfo.Caption := #13#10#13#10'Der Stand befindet sich möglicherweise nicht mehr in der Nähe des Sprungpunktes '''+Location.Title+'''.';
          lbLocationInfo.Show;

          cbLocationJump.Caption := 'Standort des Standes ändern';
          cbLocationJump.Checked := false;
          cbLocationJump.Show;

          sbLocation.Hint := 'Der Stand könnte verschoben worden sein';
          sbLocation.Show;
        end;
      end

      // Location wurde geänedrt
      else begin
        cbLocationJump.Caption := ifThenElse(FMode = sdNew,'Den Stand an diese Stelle platzieren.','Standort des Standes ändern');
        cbLocationJump.Show;
        cbLocationJump.Checked := true;

        lbLocationInfo.Hide;
      end;

      // FEHLERBEHANDLUNG
     // Location.

    end;

//    if (not TryStrToInt(edAngle.Text,dummyInt)) or (dummyInt < 0) or (dummyInt > 360) then begin sbAngle.Show; isErr := true; end else sbAngle.Hide;

    dummyInt := 0; for i := 0 to lvDates.Items.Count-1 do begin
      if not lvDates.Items[i].Checked then continue;
      dummyInt := 1; break;
   end;

   if (dummyInt = 0) then begin sbDates.Show; isErr := true; end else sbDates.Hide;
  end;

  if isErr then begin
    lbError.Caption := 'Bitte füllen Sie alle benötigten Felder aus. '
                     + 'Nicht oder fehlerhaft ausgefüllte Felder werden '
                     + 'mit einem gelben Ausrufezeichen markiert.';

    sbError.Show;
    btnSave.Enabled := false;
    Result := false;
    exit;
  end;

  sbError.Hide;
  lbError.Caption := '';
  
  btnSave.Enabled := true;
  Result := true;
end;

procedure TEditDialog.checkClick(Sender: TObject);
begin
  checkForm;
end;

procedure TEditDialog.cbExistingCustomerListKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  cbExistingCustomerListChange(Sender);
  checkForm;
end;

procedure TEditDialog.sbCustomerClick(Sender: TObject);
begin
  showPanel(pCustomer);
end;

procedure TEditDialog.sbShopClick(Sender: TObject);
begin
  showPanel(pShop);
end;

procedure TEditDialog.lvDatesEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

procedure TEditDialog.cbLocationJumpClick(Sender: TObject);
begin
  FDoJump := cbLocationJump.Checked;
end;

end.
