unit objCustomListView;

interface

uses
  Windows, Classes, SysUtils, ComCtrls; 

type
  TCustomListItem = class(TListItem)
  private
    FID: integer;
  public
    constructor Create(AOwner: TListItems);

    property ID: integer read FID write FID;
  end;

implementation

constructor TCustomListItem.Create(AOwner: TListItems);
begin
  inherited Create(AOwner);

  FID := -1;
end;

end.
 