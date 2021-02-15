unit uInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, PngSpeedButton, StdCtrls, JvExControls, JvComponent,
  JvScrollText;

type
  TInfoDialog = class(TForm)
    sbImageInfo: TPngSpeedButton;
    btnOk: TButton;
    JvScrollText1: TJvScrollText;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  InfoDialog: TInfoDialog;

implementation

{$R *.dfm}

end.
