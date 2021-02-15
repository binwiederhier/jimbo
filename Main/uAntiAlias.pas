//****************************************
// gefunden im Internet, Quelle unbekannt
//****************************************

unit uAntiAlias;

interface

uses
  Windows, SysUtils, Graphics;

const
    MaxPixelCount   =  32768;

type
    pRGBArray  =  ^TRGBArray;
    TRGBArray  =  ARRAY[0..MaxPixelCount-1] OF TRGBTriple;

procedure AntiAliasPicture(org_bmp, big_bmp, out_bmp: TBitmap);

implementation

procedure AntiAliasPicture(org_bmp, big_bmp, out_bmp: TBitmap);
var
  x, y, cx, cy : integer;
  totr, totg, totb : integer;
  Row1, Row2, Row3, DestRow: pRGBArray;
  i: integer;
begin
  // For each row
  for y := 0 to org_bmp.Height - 1 do
  begin
    // We compute samples of 3 x 3 pixels
    cy := y*3;
    // Get pointers to actual, previous and next rows in supersampled bitmap
    Row1 := big_bmp.ScanLine[cy];
    Row2 := big_bmp.ScanLine[cy+1];
    Row3 := big_bmp.ScanLine[cy+2];

    // Get a pointer to destination row in output bitmap
    DestRow := out_bmp.ScanLine[y];

    // For each column...
    for x := 0 to org_bmp.Width - 1 do
    begin
      // We compute samples of 3 x 3 pixels
      cx := 3*x;

      // Initialize result color
      totr := 0;
      totg := 0;
      totb := 0;

      // For each pixel in sample
      for i := 0 to 2 do
      begin
        // New red value
        totr := totr + Row1[cx + i].rgbtRed
             + Row2[cx + i].rgbtRed
             + Row3[cx + i].rgbtRed;
        // New green value
        totg := totg + Row1[cx + i].rgbtGreen
             + Row2[cx + i].rgbtGreen
             + Row3[cx + i].rgbtGreen;
        // New blue value
        totb := totb + Row1[cx + i].rgbtBlue
             + Row2[cx + i].rgbtBlue
             + Row3[cx + i].rgbtBlue;
      end;

      // Set output pixel colors
      DestRow[x].rgbtRed := totr div 9;
      DestRow[x].rgbtGreen := totg div 9;
      DestRow[x].rgbtBlue := totb div 9;
    end;
  end;
end;

end.

