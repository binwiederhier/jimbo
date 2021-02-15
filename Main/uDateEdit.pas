unit uDateEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, PngSpeedButton,

  // Eigene
  objJimbo, objPricer, objDates, ExtCtrls, TBXDkPanels, SpTBXControls;

type
  TDateDialogMode = (dmAdd, dmEdit);
  
  TfrmDateDialog = class(TForm)
    lbTitleCpt: TLabel;
    lbDateCpt: TLabel;
    dtDate: TDateTimePicker;
    edTitle: TEdit;
    lbShortCpt: TLabel;
    edShort: TEdit;
    cbActive: TCheckBox;
    edPrice: TEdit;
    Label1: TLabel;
    sbTitle: TPngSpeedButton;
    sbShort: TPngSpeedButton;
    sbPrice: TPngSpeedButton;
    pTop: TPanel;
    bvTop: TBevel;
    sbTop: TPngSpeedButton;
    lbTitle: TLabel;
    lbSubtitle: TLabel;
    lbError: TLabel;
    sbError: TPngSpeedButton;
    Label7: TLabel;
    Label8: TLabel;
    Label11: TLabel;
    Label10: TLabel;
    Label9: TLabel;
    btnSave: TSpTBXButton;
    btnCancel: TSpTBXButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edTitleChange(Sender: TObject);
  private
    FDate: TADate;
    FMode: TDateDialogMode;
    FPricer: TPricer;

    procedure Load;
    procedure Save;
    function checkForm: boolean;
  end;

  TDateDialog = class
  private
    FForm: TfrmDateDialog;

    function getDate: TADate;
    function getMode: TDateDialogMode;
    function getPricer: TPricer;

    procedure setDate(Value: TADate);
    procedure setMode(Value: TDateDialogMode);
    procedure setPricer(Value: TPricer);
  public
    constructor Create;
    destructor Destroy; override;

    function Execute: Boolean;

    property Date: TADate read getDate write setDate;
    property Mode: TDateDialogMode read getMode write setMode;
    property Pricer: TPricer read getPricer write setPricer;
  end;

implementation

{$R *.dfm}

{****************** TDateDialog ******************}

constructor TDateDialog.Create;
begin
  inherited Create;

  FForm := TfrmDateDialog.Create(nil);
end;

destructor TDateDialog.Destroy;
begin
  FForm.Free;
  inherited Destroy;
end;

function TDateDialog.Execute: Boolean;
begin
  FForm.Load;

  Result := FForm.ShowModal = mrOK;

  if not Result then exit;

  FForm.Save;
end;

procedure TDateDialog.setMode(Value: TDateDialogMode);
begin
  FForm.FMode := Value;

  if (FForm.FMode = dmAdd) then begin
    FForm.Caption := 'Termin hinzufügen';
    FForm.lbTitle.Caption := 'Termin hinzufüen';
    FForm.lbSubtitle.Caption := 'In der Karte können Sie für jeden Termin gesondert Stände vergeben.';
  end else begin
    FForm.Caption := 'Termin bearbeiten';
    FForm.lbTitle.Caption := 'Termin bearbeiten';
    FForm.lbSubtitle.Caption := 'Verändern Sie die Details des ausgewählten Termins.';
  end;
end;

procedure TDateDialog.setDate(Value: TADate);
begin
  FForm.FDate.Assign(Value);
end;

function TDateDialog.getDate: TADate;
begin
  Result := FForm.FDate;
end;

procedure TDateDialog.setPricer(Value: TPricer);
begin
  FForm.FPricer := Value;
end;

function TDateDialog.getPricer: TPricer;
begin
  Result := FForm.FPricer;
end;


function TDateDialog.getMode: TDateDialogMode;
begin
  Result := FForm.FMode;
end;


{****************** TfrmDateDialog ******************}

procedure TfrmDateDialog.Load;
begin
  cbActive.Checked := FDate.Active;
  edTitle.Text := FDate.Title;
  edShort.Text := FDate.Short;
  dtDate.DateTime := FDate.Date;
  edPrice.Text := FDate.Price;
end;

procedure TfrmDateDialog.Save;
begin
  FDate.Active := cbActive.Checked;
  FDate.Title := edTitle.Text;
  FDate.Short := edShort.Text;
  FDate.Date := dtDate.DateTime;
  FDate.Price := edPrice.Text;
end;


procedure TfrmDateDialog.FormCreate(Sender: TObject);
begin
  FDate := TADate.Create;
  FDate.Active := true;
end;

procedure TfrmDateDialog.FormDestroy(Sender: TObject);
begin
 FDate.Free;
end;

function TfrmDateDialog.checkForm: Boolean;
var isErr: Boolean;
    dummyFloat: Single;
begin
  isErr := false;

  if Trim(edTitle.Text) = '' then begin sbTitle.Show; isErr := true; end else sbTitle.Hide;
  if Trim(edShort.Text) = '' then begin sbShort.Show; isErr := true; end else sbShort.Hide;
  if (Trim(edPrice.Text) = '') or (not FPricer.Test(edPrice.Text)) then begin sbPrice.Show; isErr := true; end else sbPrice.Hide;

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

procedure TfrmDateDialog.FormShow(Sender: TObject);
begin
  checkForm;
end;

procedure TfrmDateDialog.edTitleChange(Sender: TObject);
begin
  checkForm;
end;

end.
