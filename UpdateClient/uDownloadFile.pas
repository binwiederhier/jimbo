unit uDownloadFile;

interface

uses
  Windows, Classes, IdTCPClient, IdHTTP, IdIOHandler, IdIOHandlerSocket,
  IdBaseComponent, IdComponent, IdTCPConnection;

type
  TDownloadFile = class(TThread)
  private
    FURL: string;
    FRunning: Boolean;

    FSuccess: Boolean;
    FResult: string;
    FBytesLoaded: integer;
    FBytesMax: integer;

    function getRunning: Boolean;
    procedure setRunning(Value: Boolean);

    procedure htWorkBegin(Sender: TObject; AWorkMode: TWorkMode; const AWorkCountMax: Integer);
    procedure htWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
  protected
    procedure Execute; override;
  public
    constructor Create;
    procedure Reset;

    property Running: Boolean read getRunning write setRunning;
    property URL: string read FURL write FURL;
    property Success: Boolean read FSuccess;
    property Result: string read FResult;
    property bytesLoaded: integer read FBytesLoaded;
    property bytesMax: integer read FBytesMax;
  end;

implementation

constructor TDownloadFile.Create;
begin
  inherited Create(true);
  Reset;
end;

procedure TDownloadFile.Reset;
begin
  FURL := '';
  FRunning := false;

  FSuccess := false;
  FResult := '';
  FBytesLoaded := 0;
  FBytesMax := 0;
end;

procedure TDownloadFile.Execute;
var Http: TIdHTTP;
    tempStr: string;
begin
  FRunning := true;
  FSuccess := false;

  Http := TIdHTTP.Create(nil);
  Http.AllowCookies := false;
  Http.ProtocolVersion := pv1_0;
  Http.OnWorkBegin := htWorkBegin;
  Http.OnWork := htWork;

  try
    tempStr := Http.Get(FURL);
  except
    Http.Free;
    FRunning := false;
    
    exit;
  end;

  if (Terminated) or (Http.Response.ContentLength = 0) then begin
    FRunning := false;
    exit;
  end;

  Http.Free;

  FResult := tempStr;
  FSuccess := true;
  FRunning := false;
end;

procedure TDownloadFile.htWorkBegin(Sender: TObject; AWorkMode: TWorkMode; const AWorkCountMax: Integer);
begin
  FBytesMax := AWorkCountMax;
end;

procedure TDownloadFile.htWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
begin
  FBytesLoaded := AWorkCount;
end;

function TDownloadFile.getRunning: Boolean;
begin
  Result := FRunning;
end;

procedure TDownloadFile.setRunning(Value: Boolean);
begin
  FRunning := Value;
end;


end.
 