program jimbupd;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uDownloadFile in 'uDownloadFile.pas',
  funcVersion in '../Main/funcVersion.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
