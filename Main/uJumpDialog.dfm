object JumpDialog: TJumpDialog
  Left = 535
  Top = 408
  AlphaBlend = True
  AlphaBlendValue = 210
  BorderStyle = bsNone
  Caption = 'JumpDialog'
  ClientHeight = 112
  ClientWidth = 327
  Color = clSkyBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = formKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 68
    Top = 24
    Width = 50
    Height = 13
    Caption = 'Springe zu'
  end
  object cbLocation: TComboBox
    Left = 68
    Top = 43
    Width = 229
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    OnKeyDown = cbLocationKeyDown
  end
end
