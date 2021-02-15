unit dlgProjectNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TBXDkPanels, SpTBXControls, ExtCtrls, StdCtrls, Buttons,
  PngSpeedButton, SpTBXEditors, ComCtrls,

  // EIgene
  _define, objJimbo, objMap, objMaps, objDates,

  funcVCL;

type
  TfrmProjectNew = class(TForm)
    pMap: TPanel;
    Label5: TLabel;
    Label3: TLabel;
    cbMaps: TComboBox;
    edPassword: TEdit;
    pBottom: TPanel;
    bvBottom: TBevel;
    btnNext: TSpTBXButton;
    btnCancel: TSpTBXButton;
    btnPrev: TSpTBXButton;
    pWelcome: TPanel;
    pLeft: TPanel;
    PngSpeedButton3: TPngSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    memOther: TMemo;
    Label4: TLabel;
    pDates: TPanel;
    lbDatesCpt: TLabel;
    lvDates: TListView;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edTitle: TEdit;
    sbTitle: TPngSpeedButton;
    sbMap: TPngSpeedButton;
    sbDates: TPngSpeedButton;
    sbFile: TPngSpeedButton;
    Label11: TLabel;
    edFile: TEdit;
    btnBrowse: TSpTBXButton;
    btnAddDate: TPngSpeedButton;
    btnEditDate: TPngSpeedButton;
    btnDelDate: TPngSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure lvDatesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure changeValue(Sender: TObject);
    procedure btnAddClickDate(Sender: TObject);
    procedure btnEditClickDate(Sender: TObject);
    procedure btnDelClickDate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure lvDatesEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
  private
    // Sichbares
    FPanels: array[0..2] of TPanel;

    // Jimbo (angeliefert vom Dialog Objekt)
    FProject: TJimbo;
    FMaps: TMaps;

    procedure Reset;
    procedure Save;

    function checkForm: boolean;
    procedure showPanel(Panel: TPanel);
    procedure updateDates;
    function checkMapKey(MapFile, Key: string): boolean;
  end;

  TProjectNewDialog = class
  private
    FForm: TfrmProjectNew;

    procedure setProject(Project: TJimbo);
    function getProject: TJimbo;

    procedure setMaps(Maps: TMaps);
    function getMaps: TMaps;
  public
    constructor Create;
    destructor Destroy; override;

    function Execute: Boolean;

    property Project: TJimbo read getProject write setProject;
    property Maps: TMaps read getMaps write setMaps;
  end;

implementation

uses uDateEdit, uLoading;

{$R *.dfm}

{****************** TProjectNewDialog ******************}

constructor TProjectNewDialog.Create;
begin
  inherited Create;
  FForm := TfrmProjectNew.Create(nil);
end;

destructor TProjectNewDialog.Destroy;
begin
  FForm.Free;
  inherited Destroy;
end;

procedure TProjectNewDialog.setProject(Project: TJimbo);
begin
  FForm.FProject := Project;
end;

function TProjectNewDialog.getProject: TJimbo;
begin
  Result := FForm.FProject;
end;

procedure TProjectNewDialog.setMaps(Maps: TMaps);
begin
  FForm.FMaps := Maps;
end;

function TProjectNewDialog.getMaps: TMaps;
begin
  Result := FForm.FMaps;
end;

function TProjectNewDialog.Execute: Boolean;
begin
  FForm.Reset;

  Result := FForm.ShowModal = mrOK;

  if Result then FForm.Save
  else FForm.Reset;
end;



{****************** TfrmProjectNew ******************}

procedure TfrmProjectNew.Reset;
begin
  cbMaps.Clear;
  cbMaps.Items.Assign(FMaps.Maps);

  checkForm;
end;

procedure TfrmProjectNew.Save;
begin
  FProject.Title := edTitle.Text;
  FProject.MapFile := cbMaps.Items[cbMaps.ItemIndex];
  FProject.Filename := edFile.Text;
  FProject.Other := memOther.Text;

  FProject.Dates.Save;
end;

procedure TfrmProjectNew.showPanel(Panel: TPanel);
var i: integer;
begin
  for i := 0 to Length(FPanels)-1 do begin
    if (FPanels[i].Handle <> Panel.Handle) and (FPanels[i].Visible) then FPanels[i].Visible := false
    else if (FPanels[i].Handle = Panel.Handle) and (not FPanels[i].Visible) then FPanels[i].Visible := true;
  end;
end;

procedure TfrmProjectNew.FormCreate(Sender: TObject);
begin
  FPanels[0] := pWelcome;
  FPanels[1] := pMap;
  FPanels[2] := pDates;

  showPanel(pWelcome);
end;

procedure TfrmProjectNew.btnNextClick(Sender: TObject);
var dlgLoad: TLoadingDialog;
begin
  if pWelcome.Visible then begin
    // pMap anzeigen
    showPanel(pMap);

    btnNext.Caption := '&Weiter >';
    btnPrev.Visible := true;
  end

  else if pMap.Visible then begin
    // Kennwort prüfen
    dlgLoad := TLoadingDialog.Create(Self);
    dlgLoad.Open('Kennwort prüfen','Bitte warten Sie, während Jimbo das Kennwort der Kartendatei überprüft.');

    if not checkMapKey(cbMaps.Items[cbMaps.ItemIndex],edPassword.Text) then begin
      dlgLoad.Free;

      MessageDlg('Das eingegebene Kennwort ist nicht korrekt.',mtInformation,[mbOk],0);
      exit;
    end;

    dlgLoad.Free;

    // pDates anzeigen
    showPanel(pDates);

    btnNext.Caption := '&Erstellen';
  end

  else if pDates.Visible then begin
    if not checkForm then begin
      MessageDlg('Bitte füllen Sie alle benötigten Felder aus.'#13#10#13#10'Nicht oder fehlerhaft ausgefüllte Felder werden mit einem'#13#10'gelben Ausrufezeichen markiert.',mtInformation,[mbOK],0);
      exit;
    end;

    ModalResult := mrOk;
    exit;
  end;

  checkForm;
end;

procedure TfrmProjectNew.btnPrevClick(Sender: TObject);
begin
  if pMap.Visible then begin
    // pWelcome anzeigen
    showPanel(pWelcome);

    btnNext.Caption := '&Weiter >';
    btnPrev.Visible := false;
  end

  else if pDates.Visible then begin
    // pMap anzeigen
    showPanel(pMap);

    btnNext.Caption := '&Weiter >';
  end;

  checkForm;
end;

function TfrmProjectNew.checkForm: boolean;
var isErr, f: boolean;
    i: integer;
begin
  isErr := false;

  if pWelcome.Visible then begin
    if Trim(edTitle.Text) = '' then begin sbTitle.Show; isErr := true; end else sbTitle.Hide;
    if (Trim(edFile.Text) = '') then begin sbFile.Show; isErr := true; end else sbFile.Hide;
  end

  else if pMap.Visible then begin
    if cbMaps.ItemIndex = -1 then begin sbMap.Show; isErr := true; end else sbMap.Hide;
  end

  else if pDates.Visible then begin
    if lvDates.Items.Count > 0 then sbDates.Hide
    else begin
      sbDates.Hint := 'Es muss wenigstens ein Termin vorhanden sein.';
      sbDates.Show; isErr := true;
    end;

    f := false; for i := 0 to FProject.Dates.Count-1 do
      if FProject.Dates[i].Active then begin
        f := true;
        break;
      end;

    if f then sbDates.Hide
    else begin
      sbDates.Hint := 'Mindestens ein Termin muss aktiviert sein.';
      sbDates.Show; isErr := true;
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
  end;

  btnNext.Enabled := not isErr;
  Result := not isErr;
end;

procedure TfrmProjectNew.lvDatesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
var dateID: integer;
    aDate: TADate;
begin
  checkForm;

  if not (Item is TListItem) then exit;
  if not getIntFromListItem(Item,dateID) then exit;

  aDate := FProject.Dates.byID(dateID);
  if not (aDate is TADate) then exit;

  aDate.Active := Item.Checked;
  checkForm;
end;

procedure TfrmProjectNew.changeValue(Sender: TObject);
begin
  checkForm;
end;

procedure TfrmProjectNew.btnAddClickDate(Sender: TObject);
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

procedure TfrmProjectNew.btnEditClickDate(Sender: TObject);
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

procedure TfrmProjectNew.btnDelClickDate(Sender: TObject);
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

procedure TfrmProjectNew.updateDates;
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

procedure TfrmProjectNew.btnBrowseClick(Sender: TObject);
var dlgSave: TSaveDialog;
begin
  dlgSave := TSaveDialog.Create(Self);
  dlgSave.DefaultExt := COMMON_EXT_PROJECT;
  dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
  dlgSave.Filter := 'Jimbo-Dateien (*'+COMMON_EXT_PROJECT+')|*'+COMMON_EXT_PROJECT+'|Alle Dateien (*.*)|*.*';

  if not dlgSave.Execute then begin
    dlgSave.Free;
    exit;
  end;

  edFile.Text := dlgSave.FileName;
  dlgSave.Free;
end;

function TfrmProjectNew.checkMapKey(MapFile, Key: string): boolean;
var Map: TMap;
begin
  Result := false;
  Map := TMap.Create;
  Map.DLLPath := ExtractFilePath(Application.ExeName);

  if not Map.Open(FMaps.Folder+MapFile,Key,false) then begin
    sleep(3000);

    Map.Free;
    exit;
  end;

  Map.Close;
  Map.Free;

  Result := true;
end;

procedure TfrmProjectNew.lvDatesEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

end.
