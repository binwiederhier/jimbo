unit uJumpDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,

  // Eigene Objekte
  objMap, funcCommon;

type
  TJumpDialog = class(TForm)
    cbLocation: TComboBox;
    Label1: TLabel;
    procedure formKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbLocationKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FLocationID: integer;
    FLocations: TLocations;

    procedure disposeComboBox(const List: TComboBox);
    procedure Reset;
  public
    constructor Create;
    function Execute: boolean;

    property locationID: integer read FLocationID;
    property Locations: TLocations read FLocations write FLocations;
  end;

implementation

{$R *.dfm}

constructor TJumpDialog.Create;
begin
  inherited Create(nil);

  FLocationID := -1;
end;

procedure TJumpDialog.Reset;
var i: integer;
    pInt: pInteger;
begin
  // Sprung-Punkte laden (Locations)
  disposeComboBox(cbLocation);
  cbLocation.Clear;

  for i := 0 to FLocations.Count-1 do begin
    // ID als Objekt anfügen
    System.New(PInt); PInt^ := FLocations[i].ID;
    cbLocation.Items.AddObject(FLocations[i].Title,TObject(PInt));
  end;

  FLocationID := -1;
end;

function TJumpDialog.Execute: boolean;
begin
  Reset;

  Result := ShowModal = mrOk;
  if not Result then exit;
end;

procedure TJumpDialog.disposeComboBox(const List: TComboBox);
var i: integer;
begin
  for i := 0 to List.Items.Count-1 do begin
    if (List.Items.Objects[i] = nil) then continue;
    Dispose(PInteger(List.Items.Objects[i]));
  end;
end;

procedure TJumpDialog.formKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> VK_ESCAPE then exit;
  modalResult := mrCancel;
end;

procedure TJumpDialog.cbLocationKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i: integer;
begin
  if Key = VK_ESCAPE then begin
    formKeyDown(Sender,Key,Shift);
    exit;
  end;

  if Key <> VK_RETURN then exit;

  i := indexOf(cbLocation.Text,cbLocation.Items);
  if i = -1 then begin
    showmessage('..');
    exit;
  end;

  FLocationID := PInteger(cbLocation.Items.Objects[i])^;

  modalResult := mrOk;
end;

end.
