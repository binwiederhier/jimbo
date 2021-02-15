unit uSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ToolWin, ComCtrls, FileCtrl,

  // Fremdkomponenten
  PngSpeedButton,

  // Eigene Komponenten
  objJimbo, objSettings, objBackup,

  TB2Item, TBX, SpTBXItem, TB2Dock, TB2Toolbar, TBXDkPanels, SpTBXControls,
  SpTBXEditors, ImgList, PngImageList;

type
  TfrmSettings = class(TForm)
    pCommon: TPanel;
    sbImageCommon: TPngSpeedButton;
    pBottom: TPanel;
    Bevel1: TBevel;
    pUpdate: TPanel;
    sbImageUpdate: TPngSpeedButton;
    cbOpenLast: TCheckBox;
    pBackup: TPanel;
    sbImageBackup: TPngSpeedButton;
    Label1: TLabel;
    edUpdate: TEdit;
    Button1: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    tbDock: TSpTBXDock;
    SpTBXToolbar1: TSpTBXToolbar;
    sbCustomer: TSpTBXItem;
    sbShop: TSpTBXItem;
    SpTBXItem1: TSpTBXItem;
    btnBackupNow: TSpTBXButton;
    seBackupMinutes: TSpTBXSpinEdit;
    cbBackupUse: TSpTBXCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    SpTBXLabel1: TSpTBXLabel;
    cbBackupAccessExt: TSpTBXCheckBox;
    edBackupDir: TEdit;
    btnBrowseDirs: TSpTBXButton;
    PngImageList1: TPngImageList;
    btnSave: TSpTBXButton;
    btnCancel: TSpTBXButton;
    procedure FormCreate(Sender: TObject);
    procedure sbCommonClick(Sender: TObject);
    procedure sbUpdateClick(Sender: TObject);
    procedure sbBackupClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnBackupNowClick(Sender: TObject);
    procedure btnBrowseDirsClick(Sender: TObject);
  private
    FSettings: TSettings;
    FBackup: TBackup;
  public
    Panels: array[0..2] of TPanel;

    procedure Prepare(const Settings: TSettings; const Backup: TBackup);
    procedure showPanel(Panel: TPanel);
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.dfm}

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  Panels[0] := pCommon;
  Panels[1] := pUpdate;
  Panels[2] := pBackup;
end;

procedure TfrmSettings.Prepare(const Settings: TSettings; const Backup: TBackup);
begin
  // Unser Settings-Objekt
  FSettings := Settings;
  FBackup := Backup;

  showPanel(pCommon);

  // Common
  cbOpenLast.Checked := Settings.openLast;

  // Backup
  cbBackupUse.Checked := Backup.Enabled;
  edBackupDir.Text := Backup.BackupDir;
  seBackupMinutes.ValueAsInteger := Backup.Interval;
  cbBackupAccessExt.Checked := Backup.AccessExt;
  btnBackupNow.Enabled := Backup.Project is TJimbo;
end;

procedure TfrmSettings.showPanel(Panel: TPanel);
var i: integer;
begin
  for i := 0 to Length(Panels)-1 do begin
    if (Panels[i].Name <> Panel.Name) and (Panels[i].Visible) then Panels[i].Visible := false
    else if (Panels[i].Name = Panel.Name) and (not Panels[i].Visible) then Panels[i].Visible := true;
  end;
end;

procedure TfrmSettings.sbCommonClick(Sender: TObject);
begin
  showPanel(pCommon);
end;

procedure TfrmSettings.sbUpdateClick(Sender: TObject);
begin
  showPanel(pUpdate);
end;

procedure TfrmSettings.sbBackupClick(Sender: TObject);
begin
  showPanel(pBackup);
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  FSettings.openLast := cbOpenLast.Checked;

  FBackup.BackupDir := edBackupDir.Text;
  FBackup.Interval := seBackupMinutes.ValueAsInteger;
  FBackup.Enabled := cbBackupUse.Checked;
  FBackup.AccessExt := cbBackupAccessExt.Checked;
end;

procedure TfrmSettings.btnBackupNowClick(Sender: TObject);
begin
  if not FBackup.Backup then begin
    showmessage('Fehler beim Sichern');
  end;

  btnBackupNow.Enabled := false;
end;

procedure TfrmSettings.btnBrowseDirsClick(Sender: TObject);
var Dir: string;
begin
  Dir := edBackupDir.Text;
  if not SelectDirectory('Bitte wählen Sie ein Backup-Verzeichnis.','',Dir) then exit;

  edBackupDir.Text := Dir;
end;

end.
