unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, objComplex;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    save: TSaveDialog;
    Button3: TButton;
    Button4: TButton;
    load: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;
  Cpx: TComplex;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Cpx := TComplex.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Cpx.Free;
end;
                   
procedure TForm1.Button1Click(Sender: TObject);
var i: integer;
    p: pchar;
    s: string;
    cpx2: TComplex;
    r: ^trect;
begin
{  Cpx.asStr := 'test';
  Memo1.Lines.Add(Cpx.asStr);

  Cpx.asInt := 77;
  Memo1.Lines.Add(intToStr(Cpx.asInt) + ' / ' + Cpx.asStr);

  Cpx.asStr := '9008';
  Memo1.Lines.Add(Cpx.asStr);
  Cpx.asFloat := Cpx.asInt+4.1;
  Memo1.Lines.Add(Cpx.asStr);   }

 {
  for i := 0 to 2 do begin
    Cpx['Name'+inttostr(i)].asStr := inttostr(i)+'a';
  end;


  Cpx.byId[9].asInt := 9001;

  for i := 0 to 5 do begin
    Cpx.byId[i].byId[0].asStr := 'James BOnd ' + inttostr(i);
    Cpx.byId[i].byId[1].asInt := 2006+i;

    Memo1.Lines.Add(Cpx.byId[i].byId[1].asStr);
  end;
  }
{  with Cpx['Settings'] do begin
    Items['File'].asStr := 'C:\pagefile.sys';
    Items['Log'].asStr := 'C:\log.log';
    Items['Interval'].asFloat := 8.998;
  end;                }
            {
  for i := 0 to 5 do begin
    with Cpx['Liste'].asList do begin
     Items[i].asInt := i;
    end;
  end;

  Cpx['Liste'].asList[8].asStr := 'blubl';
  Cpx['Liste'].asList[9].asStr := 'blub5';}

{  Cpx.asList[0].asInt := 1;
  Cpx.asList[1].asStr := 'blubl';
  Cpx.asList[2].asStr := 'blub5';   }
                 {

  Cpx['Name9'].asStr := 'test an name[9]';
  Memo1.Lines.Add(Cpx['Name9'].Name + '/// ' +Cpx['Name9'].asStr);

  Cpx['Name9'].asStr := 'tname9 überschrieben';
  Memo1.Lines.Add(Cpx['Name9'].asStr);
     }
 { p := 'Mumumu macht die Kuh ;)';
  Cpx['BINARY DATA'].setAsBinary(p,Length(p));

  Cpx['Hidden'].Hidden := true;
  Cpx['Hidden'].asStr := 'HiddenValue';


  New(r);
  r^ := Rect(10,20,30,40);
  cpx['window'].setAsBinary(r,sizeof(r^));
  freemem(r);      }

  //

  Cpx.PathAccess := true;
  Cpx.PathSeparator := ',';
  with Cpx['Path,111,222'] do begin
    Items['333'].asStr := 'bla0';
    Items['444'].asStr := 'bla1';
    Items['555'].asStr := 'bla2';
    Items['666'].asStr := 'bla3';
  end;

  Memo1.Lines.Add(Cpx['Path,111,222,333'].AsStr);

  //

  //Memo1.Lines.Add('HIDDEN: ' + cpx['Hidden'].asStr);
  Memo1.Lines.Add(Cpx.asStr);

             {


  cpx2 := TComplex.Create;
  cpx2.Assign(Cpx,true);
  Memo1.Lines.Add(Cpx2.asStr);
  Memo1.Lines.Add('HIDDEN: ' + cpx2['Hidden'].asStr);


 // Cpx['Name9'].Free;    }
end;

procedure TForm1.Button2Click(Sender: TObject);
var cpx2: tcomplex;
begin
  if not save.Execute then exit;
  cpx2 := tcomplex.Create;
  cpx2.Assign(cpx,true);
  Memo1.Lines.Add('HIDDEN: ' + cpx2['Hidden'].asStr);

  Cpx2.saveToFile(save.FileName,true);
cpx2.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
var r: ^TRect;
begin
  New(r);
  cpx['window'].getAsBinary(r);
  Memo1.Lines.Add('Rect window geladen: ' + inttostr(r^.left) );
  Memo1.Lines.Add(Cpx.asStr);
  freemem(r);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if not load.Execute then exit;

  Cpx['Hidden'].Hidden := true;
  Cpx['Hidden'].asList[0].asStr := 'HiddenValue vor dem laden';

  Cpx.loadfromfile(load.FileName,false);
  Memo1.Lines.Add('HIDDEN: ' + cpx['Hidden'].asStr);
end;

end.

