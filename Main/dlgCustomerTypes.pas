unit dlgCustomerTypes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, PngSpeedButton,

  // Eigene
  objJimbo, objCustomerTypes, ExtCtrls, TBXDkPanels, SpTBXControls;

type
  TCustomerTypeDialogMode = (cdNew, cdEdit);

  TTfrmCustomerTypeDialog = class(TForm)
    lbTitleCpt: TLabel;
    edTitle: TEdit;
    sbTitle: TPngSpeedButton;
    Label1: TLabel;
    edMultiplier: TEdit;
    sbMultiplier: TPngSpeedButton;
    pTop: TPanel;
    bvTop: TBevel;
    sbTop: TPngSpeedButton;
    lbTitle: TLabel;
    lbSubtitle: TLabel;
    lbError: TLabel;
    sbError: TPngSpeedButton;
    btnSave: TSpTBXButton;
    btnCancel: TSpTBXButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edTitleChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FType: TCustomerType;
    FMode: TCustomerTypeDialogMode;

    procedure Load;
    procedure Save;
    function checkForm: boolean;
  end;

  TCustomerTypeDialog = class
  private                         
    FForm: TTfrmCustomerTypeDialog;

    function getType: TCustomerType;
    function getMode: TCustomerTypeDialogMode;

    procedure setType(Value: TCustomerType);
    procedure setMode(Value: TCustomerTypeDialogMode);
  public
    constructor Create;
    destructor Destroy; override;

    function Execute: Boolean;

    property customerType: TCustomerType read getType write setType;
    property Mode: TCustomerTypeDialogMode read getMode write setMode;
  end;

implementation

{$R *.dfm}

{****************** TCustomerTypeDialog ******************}

constructor TCustomerTypeDialog.Create;
begin
  inherited Create;
  FForm := TTfrmCustomerTypeDialog.Create(nil);
end;

destructor TCustomerTypeDialog.Destroy;
begin
  FForm.Free;
  inherited Destroy;
end;

function TCustomerTypeDialog.Execute: Boolean;
begin
  FForm.Load;

  Result := FForm.ShowModal = mrOK;

  if not Result then exit;

  FForm.Save;
end;

procedure TCustomerTypeDialog.setMode(Value: TCustomerTypeDialogMode);
begin
  FForm.FMode := Value;

  if (FForm.FMode = cdNew) then begin
    FForm.Caption := 'Kunden-Typ hinzufügen';
    FForm.lbTitle.Caption := 'Kunden-Typ hinzufüen';
    FForm.lbSubtitle.Caption := 'Erstellen Sie einen neuen Typ, um z.B. Privatpersonen und Firmen bei der Preisberechnung anders zu werten.';
  end else begin
    FForm.Caption := 'Kunden-Typ bearbeiten';
    FForm.lbTitle.Caption := 'Kunden-Typ bearbeiten';
    FForm.lbSubtitle.Caption := 'Verändern Sie Beschreibung und Preis-Wert des gewählten Kunden-Typs.';
  end;
end;

procedure TCustomerTypeDialog.setType(Value: TCustomerType);
begin
  FForm.FType.Assign(Value);
end;

function TCustomerTypeDialog.getType: TCustomerType;
begin
  Result := FForm.FType;
end;

function TCustomerTypeDialog.getMode: TCustomerTypeDialogMode;
begin
  Result := FForm.FMode;
end;


{****************** TTfrmCustomerTypeDialog ******************}

procedure TTfrmCustomerTypeDialog.Load;
begin
  edTitle.Text := FType.Title;
  edMultiplier.Text := floatToStr(FType.Multiplier);
end;

procedure TTfrmCustomerTypeDialog.Save;
begin
  FType.Title := edTitle.Text;

  try FType.Multiplier := strToFloat(edMultiplier.Text);
  except FType.Multiplier := 0; end;
end;


procedure TTfrmCustomerTypeDialog.FormCreate(Sender: TObject);
begin
  FType := TCustomerType.Create;
end;

procedure TTfrmCustomerTypeDialog.FormDestroy(Sender: TObject);
begin
  FType.Free;
end;

function TTfrmCustomerTypeDialog.checkForm: Boolean;
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

procedure TTfrmCustomerTypeDialog.edTitleChange(Sender: TObject);
begin
  checkForm;
end;

procedure TTfrmCustomerTypeDialog.FormShow(Sender: TObject);
begin
  checkForm;
end;

end.
