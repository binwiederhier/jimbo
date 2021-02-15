unit funcVCL;

interface

uses
  Windows, Messages, Classes, SysUtils, StdCtrls, ComCtrls;

//procedure writeIntToComboBoxObject(Index: integer; const ComboBox: TComboBox);

function writeIntToStringListItem(StringList: TStrings; Index, aInt: integer): boolean;
function getIntFromStringListItem(StringList: TStrings; Index: integer; var aInt: integer): boolean;

procedure writeIntToListItem(ListItem: TListItem; aInt: integer);
function getIntFromListItem(ListItem: TListItem; var aInt: integer): boolean;

procedure disposeFromComboBox(const List: TComboBox);
procedure disposeFromListView(const List: TListView);

implementation

procedure disposeFromComboBox(const List: TComboBox);
var i: integer;
begin
  for i := 0 to List.Items.Count-1 do begin
    if (List.Items.Objects[i] = nil) then continue;

    Dispose(Pointer(List.Items.Objects[i]));
    List.Items.Objects[i] := nil;
  end;
end;

procedure disposeFromListView(const List: TListView);
var i: integer;
begin
  for i := 0 to List.Items.Count-1 do begin
    if (List.Items[i].Data = nil) then continue;

    Dispose(List.Items[i].Data);
    List.Items[i].Data := nil;
  end;
end;

procedure writeIntToListItem(ListItem: TListItem; aInt: integer);
var pInt: pInteger;
begin
  if not (ListItem is TListItem) then exit;

  New(pInt); pInt^ := aInt;
  ListItem.Data := pInt;
end;

function getIntFromListItem(ListItem: TListItem; var aInt: integer): boolean;
begin
  Result := false;
  if not (ListItem is TListItem) then exit;
  if not Assigned(ListItem.Data) then exit;

  try
    aInt := pInteger(ListItem.Data)^;
  except
    aInt := -1;
    exit;
  end;

  Result := true;
end;

function writeIntToStringListItem(StringList: TStrings; Index, aInt: integer): boolean;
var pInt: pInteger;
begin
  Result := false;
  if (Index < 0) or (Index >= StringList.Count) then exit;

  System.New(pInt);
  pInt^ := aInt;

  StringList.Objects[Index] := TObject(pInt);
end;

function getIntFromStringListItem(StringList: TStrings; Index: integer; var aInt: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= StringList.Count) then exit;

  try
    aInt := pInteger(StringList.Objects[Index])^;
  except
    exit;
  end;

  Result := true;
end;

end.
