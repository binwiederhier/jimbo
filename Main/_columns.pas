unit _columns;

interface

{type
  TMaxColumn = record
    ID: integer;
    Name: string;
    ColumnType: (ctShop, ctCustomer);
    FieldID: integer;
  end;

var
  MaxColumns: array[0..12] of TMaxColumn;   }

implementation

{uses
  objShops, objCustomers;

initialization
  with MaxColumns[0] do begin
    ID := 0;
    Name := 'Kd-Nr.';
    ColumnType := ctCustomer;
    FieldID := cfFieldToId(cfCID);
  end;

  with MaxColumns[1] do begin
    ID := 1;
    Name := 'Kd-Typ';
    ColumnType := ctCustomer;
    FieldID := cfFieldToId(cfType);
  end;

  with MaxColumns[2] do begin
    ID := 2;
    Name := 'Name';
    ColumnType := ctCustomer;
    FieldID := cfFieldToId(cfLastname);
  end;

  with MaxColumns[3] do begin
    ID := 3;
    Name := 'Vorname';
    ColumnType := ctCustomer;
    FieldID := cfFieldToId(cfFirstname);
  end;

  with MaxColumns[4] do begin
    ID := 4;
    Name := 'Straﬂe';
    ColumnType := ctCustomer;
    FieldID := cfFieldToId(cfAddress);
  end;

  with MaxColumns[5] do begin
    ID := 5;
    Name := 'PLZ';
    ColumnType := ctCustomer;
    FieldID := cfFieldToId(cfZIP);
  end;

  with MaxColumns[6] do begin
    ID := 6;
    Name := 'Ort';
    ColumnType := ctCustomer;
    FieldID := cfFieldToId(cfCity);
  end;

  // Stand
  with MaxColumns[7] do begin
    ID := 7;
    Name := 'St-Nr.';
    ColumnType := ctShop;
    FieldID := sfFieldToId(sfID);
  end;

  with MaxColumns[8] do begin
    ID := 8;
    Name := 'St-Typ';
    ColumnType := ctShop;
    FieldID := sfFieldToId(sfType);
  end;

  with MaxColumns[9] do begin
    ID := 9;
    Name := 'Maﬂe';
    ColumnType := ctShop;
    FieldID := sfFieldToId(sfSize);
  end;

  with MaxColumns[10] do begin
    ID := 10;
    Name := 'Termin';
    ColumnType := ctShop;
    FieldID := sfFieldToId(sfDate);
  end;

  with MaxColumns[11] do begin
    ID := 11;
    Name := 'Standort';
    ColumnType := ctShop;
    FieldID := sfFieldToId(sfAddress);
  end;

  with MaxColumns[12] do begin
    ID := 12;
    Name := 'Preis';
    ColumnType := ctShop;
    FieldID := sfFieldToId(sfPrice);
  end;     }
end.
 