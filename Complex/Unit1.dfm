object Form1: TForm1
  Left = 389
  Top = 199
  Width = 870
  Height = 640
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 44
    Top = 86
    Width = 745
    Height = 467
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 82
    Top = 32
    Width = 165
    Height = 25
    Caption = 'f'#252'llen'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 258
    Top = 32
    Width = 163
    Height = 25
    Caption = 'speichern'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 610
    Top = 34
    Width = 183
    Height = 25
    Caption = 'laden'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 448
    Top = 32
    Width = 155
    Height = 25
    Caption = 'zeigen'
    TabOrder = 4
    OnClick = Button4Click
  end
  object save: TSaveDialog
    DefaultExt = '.xml'
    FileName = 'test.xml'
    Left = 538
    Top = 118
  end
  object load: TOpenDialog
    DefaultExt = ',xml'
    FileName = 'test.xml'
    Left = 572
    Top = 120
  end
end
