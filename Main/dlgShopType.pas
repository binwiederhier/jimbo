unit dlgShopType;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Gauges, StdCtrls, Buttons, PngSpeedButton,

  // Eigene
  objJimbo, objShopTypes, ExtCtrls, TBXDkPanels, SpTBXControls;

type
  TShopTypeDialogMode = (sdNew, sdEdit); 

  TfrmShopTypeDialog = class(TForm)
    lbTitleCpt: TLabel;
    edTitle: TEdit;
    sbTitle: TPngSpeedButton;
    Label1: TLabel;
    edMultiplier: TEdit;
    sbMultiplier: TPngSpeedButton;
    cbVisible: TCheckBox;
    Label2: TLabel;
    ggColor: TGauge;
    colDialog: TColorDialog;
    puColor: TPopupMenu;
    Fllfarbewhlen1: TMenuItem;
    Randfarbewhlen1: TMenuItem;
    lbError: TLabel;
    sbError: TPngSpeedButton;
    pTop: TPanel;
    bvTop: TBevel;
    lbTitle: TLabel;
    lbSubtitle: TLabel;
    PngSpeedButton1: TPngSpeedButton;
    sbTop: TPngSpeedButton;
    SpTBXButton1: TSpTBXButton;
    btnSave: TSpTBXButton;
    btnCancel: TSpTBXButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Fllfarbewhlen1Click(Sender: TObject);
    procedure Randfarbewhlen1Click(Sender: TObject);
    procedure edMultiplierChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpTBXButton1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FType: TShopType;
    FMode: TShopTypeDialogMode;

    procedure Load;
    procedure Save;

    function checkForm: boolean;
  end;

  TShopTypeDialog = class
  private                         
    FForm: TfrmShopTypeDialog;

    function getType: TShopType;
    function getMode: TShopTypeDialogMode;

    procedure setType(Value: TShopType);
    procedure setMode(Value: TShopTypeDialogMode);
  public
    constructor Create;
    destructor Destroy; override;

    function Execute: Boolean;

    property shopType: TShopType read getType write setType;
    property Mode: TShopTypeDialogMode read getMode write setMode;
  end;

implementation

{$R *.dfm}

{****************** TShopTypeDialog ******************}

constructor TShopTypeDialog.Create;
begin
  inherited Create;
  FForm := TfrmShopTypeDialog.Create(nil);
end;

destructor TShopTypeDialog.Destroy;
begin
  FForm.Free;
  inherited Destroy;
end;

function TShopTypeDialog.Execute: Boolean;
begin
  FForm.Load;

  Result := FForm.ShowModal = mrOK;

  if not Result then exit;

  FForm.Save;
end;

procedure TShopTypeDialog.setMode(Value: TShopTypeDialogMode);
begin
  FForm.FMode := Value;

  if (FForm.FMode = sdNew) then begin
    FForm.Caption := 'Stand-Typ hinzufügen';
    FForm.lbTitle.Caption := 'Stand-Typ hinzufüen';
    FForm.lbSubtitle.Caption := 'Erstellen Sie einen neuen Typ, um die Stände auf der Karte auseinander halten zu können.';
  end else begin
    FForm.Caption := 'Stand-Typ bearbeiten';
    FForm.lbTitle.Caption := 'Stand-Typ bearbeiten';
    FForm.lbSubtitle.Caption := 'Verändern Sie Farbe, Beschreibung und Preis-Wert des gewählten Stand-Typs.';
  end;
end;

procedure TShopTypeDialog.setType(Value: TShopType);
begin
  FForm.FType.Assign(Value);
end;

function TShopTypeDialog.getType: TShopType;
begin
  Result := FForm.FType;
end;

function TShopTypeDialog.getMode: TShopTypeDialogMode;
begin
  Result := FForm.FMode;
end;


{****************** TfrmShopTypeDialog ******************}

procedure TfrmShopTypeDialog.Load;
begin
  cbVisible.Checked := FType.Visible;
  edTitle.Text := FType.Title;
  ggColor.BackColor := FType.Color;
  ggColor.ForeColor := FType.borderColor;
  edMultiplier.Text := floatToStr(FType.Multiplier);
end;

procedure TfrmShopTypeDialog.Save;
begin
  FType.Visible := cbVisible.Checked;
  FType.Title := edTitle.Text;
  FType.Color := ggColor.BackColor;
  FType.borderColor := ggColor.ForeColor;

  try FType.Multiplier := strToFloat(edMultiplier.Text);
  except FType.Multiplier := 0; end;
end;

procedure TfrmShopTypeDialog.FormCreate(Sender: TObject);
begin
  FType := TShopType.Create;
end;

procedure TfrmShopTypeDialog.FormDestroy(Sender: TObject);
begin
  FType.Free;
end;

procedure TfrmShopTypeDialog.Fllfarbewhlen1Click(Sender: TObject);
begin
  colDialog.Color := ggColor.BackColor;
  if not colDialog.Execute then exit;
  ggColor.BackColor := colDialog.Color;
end;

procedure TfrmShopTypeDialog.Randfarbewhlen1Click(Sender: TObject);
begin
  colDialog.Color := ggColor.ForeColor;
  if not colDialog.Execute then exit;
  ggColor.ForeColor := colDialog.Color;
end;

procedure TfrmShopTypeDialog.edMultiplierChange(Sender: TObject);
begin
  checkForm;
end;

function TfrmShopTypeDialog.checkForm: Boolean;
var isErr: Boolean;
    dummyFloat: Single;
begin
  isErr := false;

  if Trim(edTitle.Text) = '' then begin sbTitle.Show; isErr := true; end else sbTitle.Hide;
  if not TryStrToFloat(edMultiplier.Text,dummyFloat) then begin sbMultiplier.Show; isErr := true; end else sbMultiplier.Hide;

  if isErr then begin
    lbError.Caption := 'Bitte füllen Sie alle benötigten Felder aus.';

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


procedure TfrmShopTypeDialog.FormShow(Sender: TObject);
begin
  checkForm;
end;

procedure TfrmShopTypeDialog.SpTBXButton1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  puColor.Popup(X,Y);
end;

end.
