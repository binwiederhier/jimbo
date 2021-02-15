unit uLoading;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, PngSpeedButton;

type
  TfrmLoadingDialog = class(TForm)
    sbImage: TPngSpeedButton;
    lbTitle: TLabel;
    lbText: TLabel;
  end;

  TLoadingDialog = class
  private
    FForm: TfrmLoadingDialog;
    FOwner: TForm;

    procedure setText(Text: string);
    procedure setTitle(Title: string);
    function getText: string;
    function getTitle: string;
  public
    constructor Create(AOwner: TForm);
    destructor Destroy; override;

    procedure Open(Title, Text: string);
    procedure Close;

    property Title: string read getTitle write setTitle;
    property Text: string read getText write setText;
  end;

implementation

{$R *.dfm}

constructor TLoadingDialog.Create(AOwner: TForm);
begin
  inherited Create;
  FForm := TfrmLoadingDialog.Create(AOwner);
  FOwner := AOwner;
end;

destructor TLoadingDialog.Destroy;
begin
  FOwner.Enabled := true;

  FForm.Free;
  inherited Destroy;
end;

procedure TLoadingDialog.Open(Title, Text: string);
begin
  FForm.lbTitle.Caption := Title;
  FForm.lbText.Caption := Text;

  FOwner.Enabled := false;

  FForm.Show;
  Application.ProcessMessages;
end;

procedure TLoadingDialog.Close;
begin
  FOwner.Enabled := true;
  FForm.Hide;
end;

procedure TLoadingDialog.setText(Text: string);
begin
  FForm.lbText.Caption := Text;
  Application.ProcessMessages;
end;

procedure TLoadingDialog.setTitle(Title: string);
begin
  FForm.lbTitle.Caption := Title;
  Application.ProcessMessages;
end;

function TLoadingDialog.getText: string;
begin
  Result := FForm.lbText.Caption;
end;

function TLoadingDialog.getTitle: string;
begin
  Result := FForm.lbTitle.Caption;
end;

end.
