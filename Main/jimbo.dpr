{

  - Änderungen:
     TShops, TCustomers: Objekte sind in der TList als Pointer auf Pointer gespeichert,
     also List.Add(@Shop-Objekt), dabei geht auch List.Add(Shop-Objekt).

     Zur Erinnerung: Objekte sind Pointer!

  - TJimbo.Open aufteilen
    - Customers.Load
    - Shops.Load

  - dateshop erweitern um load + usedb

  - locations.ini

}
program jimbo;   

uses
  Forms,
  _define in '_define.pas',
  objMap in 'objMap.pas',
  objMaps in 'objMaps.pas',
  objPainter in 'objPainter.pas',
  objJimbo in 'objJimbo.pas',
  objShops in 'objShops.pas',
  objShopDates in 'objShopDates.pas',
  objShopTypes in 'objShopTypes.pas',
  objCustomers in 'objCustomers.pas',
  objCustomerTypes in 'objCustomerTypes.pas',
  objSettings in 'objSettings.pas',
  objIntegerList in 'objIntegerList.pas',
  objBackup in 'objBackup.pas',
  objDates in 'objDates.pas',
  objComplex in 'objComplex.pas',
  objPricer in 'objPricer.pas',
  uMain in 'uMain.pas' {frmMain},
  uEditDialog in 'uEditDialog.pas' {EditDialog},
  uSettings in 'uSettings.pas' {frmSettings},
  uInfo in 'uInfo.pas' {InfoDialog},
  uProjectEdit in 'uProjectEdit.pas' {frmProjectEdit},
  uLoading in 'uLoading.pas' {frmLoadingDialog},
  uDateEdit in 'uDateEdit.pas' {frmDateDialog},
  dlgCustomerTypes in 'dlgCustomerTypes.pas' {TfrmCustomerTypeDialog},
  dlgShopType in 'dlgShopType.pas' {frmShopTypeDialog},
  dlgProjectNew in 'dlgProjectNew.pas' {frmProjectNew},
  uMutex in 'uMutex.pas',
  funcCommon in 'funcCommon.pas',
  funcVCL in 'funcVCL.pas',
  funcVersion in 'funcVersion.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Jimbo';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmSettings, frmSettings);
  Application.Run;
end.                            
