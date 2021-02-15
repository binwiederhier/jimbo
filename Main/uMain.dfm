object frmMain: TfrmMain
  Left = 458
  Top = 209
  Width = 919
  Height = 715
  Caption = 'Jimbo Planer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = formClose
  OnCreate = formCreate
  OnDestroy = formDestroy
  OnPaint = mapEventPaint
  PixelsPerInch = 96
  TextHeight = 13
  object pCustomers: TPanel
    Left = 151
    Top = 70
    Width = 506
    Height = 485
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    object pCustomersFilter: TPanel
      Left = 0
      Top = 0
      Width = 506
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 0
      object cbCustomersFilter: TComboBox
        Left = 6
        Top = 4
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 0
        Text = 'Nachname'
        Items.Strings = (
          'Nachname'
          'Vorname'
          'Firma'
          'Stra'#223'e'
          'PLZ'
          'Telefon'
          'eMail')
      end
      object edCustomerFind: TEdit
        Left = 152
        Top = 4
        Width = 191
        Height = 21
        TabOrder = 1
      end
      object btnCustomersFind: TSpTBXButton
        Left = 344
        Top = 4
        Width = 65
        Height = 21
        Caption = 'Suche >'
        TabOrder = 2
        OnClick = btnCustomersFindClick
        Default = True
        LinkFont.Charset = DEFAULT_CHARSET
        LinkFont.Color = clBlue
        LinkFont.Height = -11
        LinkFont.Name = 'MS Sans Serif'
        LinkFont.Style = [fsUnderline]
      end
    end
    object pCustomersMain: TPanel
      Left = 0
      Top = 26
      Width = 506
      Height = 459
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 1
      object splCustomers: TSplitter
        Left = 4
        Top = 185
        Width = 498
        Height = 4
        Cursor = crVSplit
        Align = alBottom
        MinSize = 2
        ResizeStyle = rsLine
      end
      object lvCustomers: TListView
        Left = 4
        Top = 4
        Width = 498
        Height = 181
        Align = alClient
        Columns = <>
        FullDrag = True
        GridLines = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnColumnClick = lvCustomersColumnClick
        OnContextPopup = lvCustomersContextPopup
        OnDblClick = lvCustomersDblClick
        OnEditing = lvCustomersEditing
        OnKeyUp = lvCustomersKeyUp
        OnMouseDown = lvCustomersMouseDown
      end
      object lvCustomerShops: TListView
        Left = 4
        Top = 189
        Width = 498
        Height = 266
        Align = alBottom
        Columns = <>
        FullDrag = True
        GridLines = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        OnColumnClick = lvCustomerShopsColumnClick
        OnContextPopup = lvCustomerShopsContextPopup
        OnDblClick = lvCustomerShopsDblClick
        OnEditing = lvCustomerShopsEditing
        OnKeyUp = lvCustomerShopsKeyUp
        OnMouseDown = lvCustomerShopsMouseDown
      end
    end
  end
  object tbDockTop: TSpTBXDock
    Left = 0
    Top = 0
    Width = 911
    Height = 50
    object tbMenu: TSpTBXToolbar
      Left = 0
      Top = 0
      Caption = 'tbMenu'
      CloseButton = False
      DockPos = -264
      FullSize = True
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object tbMenuFile: TSpTBXSubmenuItem
        CaptionW = 'Datei'
        object tbMenuFileNew: TSpTBXItem
          ImageIndex = 3
          Images = ilMenu
          OnClick = tbSbNoProjectNewClick
          CaptionW = 'Neu ...'
        end
        object tbMenuFileOpen: TSpTBXItem
          ImageIndex = 2
          Images = ilMenu
          OnClick = menuFileOpenClick
          CaptionW = #214'ffnen ...'
        end
        object tbMenuFileClose: TSpTBXItem
          OnClick = menuFileCloseClick
          CaptionW = 'Schlie'#223'en'
        end
        object tbMenuFileLine1: TSpTBXSeparatorItem
        end
        object tbMenuFileSettings: TSpTBXItem
          OnClick = menuFileSettingsClick
          CaptionW = 'Einstellungen ...'
        end
        object tbMenuFileLine2: TSpTBXSeparatorItem
        end
        object tbMenuFileMRU: TTBXMRUListItem
          MRUList = tbMRUList
        end
        object tbMenuFileLine3: TSpTBXSeparatorItem
        end
        object tbMenuFileShutdown: TSpTBXItem
          ImageIndex = 0
          Images = ilMenu
          OnClick = menuFileShutdownClick
          CaptionW = 'Beenden'
        end
      end
      object tbMenuView: TSpTBXSubmenuItem
        CaptionW = 'Ansicht'
        object tbMenuViewFastnav: TSpTBXItem
          Control = tbToolFastnav
          CaptionW = 'Schnellnavigation'
        end
        object tbMenuViewJump: TSpTBXItem
          Control = tbToolJump
          CaptionW = 'Springen'
        end
        object tbMenuViewNavigator: TSpTBXItem
          Control = tbPanNavigation
          CaptionW = 'Navigator'
        end
        object TBXSeparatorItem5: TSpTBXSeparatorItem
        end
        object TBXItem11: TSpTBXItem
          GroupIndex = 1
          RadioItem = True
          OnClick = tbSbProjectClick
          CaptionW = 'Veranstaltung'
        end
        object TBXItem12: TSpTBXItem
          GroupIndex = 1
          RadioItem = True
          OnClick = tbSbMapClick
          Control = pMap
          CaptionW = 'Stadtplan'
        end
        object TBXItem10: TSpTBXItem
          GroupIndex = 1
          RadioItem = True
          OnClick = tbSbCustomersClick
          Control = pCustomers
          CaptionW = 'Kundenverwaltung'
        end
        object TBXItem13: TSpTBXItem
          GroupIndex = 1
          RadioItem = True
          OnClick = tbSbShopsClick
          Control = pShops
          CaptionW = 'Gesamt'#252'bersicht'
        end
      end
      object TBXSubmenuItem2: TSpTBXSubmenuItem
        CaptionW = 'Hilfe'
        object TBXItem7: TSpTBXItem
          CaptionW = 'Hilfe'
        end
        object TBXSeparatorItem4: TSpTBXSeparatorItem
        end
        object TBXItem8: TSpTBXItem
          CaptionW = 'Silversun Homepage'
        end
        object TBXItem9: TSpTBXItem
          CaptionW = 'Jimbo Homepage'
        end
        object TBXSeparatorItem3: TSpTBXSeparatorItem
        end
        object TBXItem4: TSpTBXItem
          OnClick = menuHelpInfoClick
          CaptionW = 'Info'
        end
      end
    end
    object tbToolJump: TSpTBXToolbar
      Left = 312
      Top = 23
      Caption = 'Springen'
      DockPos = 0
      DockRow = 1
      TabOrder = 1
      object TBXLabelItem1: TTBXLabelItem
        Caption = 'Springen'
        Margin = 3
      end
      object tbToolJumpList: TSpTBXComboBoxItem
        EditWidth = 130
        OnSelect = tbToolJumpListSelect
        OnChange = tbToolJumpListChange
        OnItemClick = tbToolJumpListItemClick
      end
    end
    object tbToolFastnav: TSpTBXToolbar
      Left = 0
      Top = 23
      Caption = 'Schnellnavigation'
      DockPos = -8
      DockRow = 1
      TabOrder = 2
      object tbFastNavProject: TTBXVisibilityToggleItem
        Caption = 'Veranstaltung'
        DisplayMode = nbdmImageAndText
        ImageIndex = 6
        Images = ilSidebar16
        OnClick = tbSbProjectClick
      end
      object tbFastNavShops: TTBXVisibilityToggleItem
        Caption = #220'bersicht'
        Control = pShops
        DisplayMode = nbdmImageAndText
        ImageIndex = 5
        Images = ilSidebar16
        OnClick = tbSbShopsClick
      end
      object tbFastNavMap: TTBXVisibilityToggleItem
        Caption = 'Stadtplan'
        Control = pMap
        DisplayMode = nbdmImageAndText
        ImageIndex = 0
        Images = ilSidebar16
        OnClick = tbSbMapClick
      end
      object tbFastNavCustomers: TTBXVisibilityToggleItem
        Caption = 'Kunden'
        Control = pCustomers
        DisplayMode = nbdmImageAndText
        ImageIndex = 4
        Images = ilSidebar16
        OnClick = tbSbCustomersClick
      end
    end
  end
  object pShops: TPanel
    Left = 532
    Top = 258
    Width = 375
    Height = 129
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    Visible = False
    object lvMax: TListView
      Left = 0
      Top = 26
      Width = 375
      Height = 103
      Align = alClient
      Columns = <>
      FlatScrollBars = True
      FullDrag = True
      GridLines = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnColumnClick = lvMaxColumnClick
      OnContextPopup = lvMaxContextPopup
      OnDblClick = lvMaxDblClick
      OnEditing = lvMaxEditing
      OnKeyUp = lvMaxKeyUp
      OnMouseDown = lvMaxMouseDown
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 375
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 1
      object edShopFind: TEdit
        Left = 114
        Top = 4
        Width = 111
        Height = 21
        TabOrder = 0
      end
      object cbShopFilter: TComboBox
        Left = 6
        Top = 4
        Width = 99
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
      end
      object btnShopFind: TSpTBXButton
        Left = 230
        Top = 4
        Width = 65
        Height = 21
        Caption = 'Suche >'
        TabOrder = 2
        OnClick = btnShopFindClick
        Default = True
        LinkFont.Charset = DEFAULT_CHARSET
        LinkFont.Color = clBlue
        LinkFont.Height = -11
        LinkFont.Name = 'MS Sans Serif'
        LinkFont.Style = [fsUnderline]
      end
    end
  end
  object tbDockLeft: TSpTBXMultiDock
    Left = 0
    Top = 50
    Width = 175
    Height = 624
    Position = dpxLeft
    object tbPanProject: TSpTBXDockablePanel
      Left = 0
      Top = 0
      Caption = 'Veranstaltung'
      CloseButton = False
      CloseButtonWhenDocked = False
      DockableTo = [dpLeft, dpRight]
      DockedWidth = 171
      DockPos = 0
      FloatingWidth = 137
      FloatingHeight = 128
      ShowCaption = False
      ShowCaptionWhenDocked = False
      SplitHeight = 324
      TabOrder = 0
      OnCloseQuery = tbPanProjectCloseQuery
      object TBXRadioButton2: TSpTBXRadioButton
        Left = 14
        Top = 90
        Width = 106
        Height = 15
        Caption = 'TBXRadioButton2'
        TabOrder = 0
      end
      object TBXCheckBox1: TSpTBXCheckBox
        Left = 12
        Top = 132
        Width = 96
        Height = 15
        Caption = 'TBXCheckBox1'
        TabOrder = 1
      end
      object tbScrollMain: TTBXPageScroller
        Left = 0
        Top = 26
        Width = 171
        Height = 362
        Align = alClient
        AutoRange = True
        DoubleBuffered = False
        TabOrder = 2
        object pSbDetails: TTBXAlignmentPanel
          Left = 0
          Top = 381
          Width = 171
          Height = 46
          Align = alClient
          AutoSize = True
          Margins.Left = 5
          Margins.Top = 1
          Margins.Right = 5
          TabOrder = 0
          Visible = False
          object tbSbDetailsCpt: TTBXLabel
            Left = 5
            Top = 1
            Width = 161
            Height = 26
            Align = alTop
            Caption = 'Details'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            Margins.Left = 4
            Margins.Top = 8
            Margins.Right = 4
            Margins.Bottom = 4
            ParentFont = False
            Underline = True
          end
          object tbDetails: TTBXLabel
            Left = 5
            Top = 27
            Width = 161
            Height = 19
            Align = alTop
            Caption = '(AutoWert)'
            Margins.Left = 5
            Margins.Top = 3
            Margins.Right = 5
            Margins.Bottom = 3
          end
        end
        object pSbDates: TTBXAlignmentPanel
          Left = 0
          Top = 78
          Width = 171
          Height = 74
          Align = alTop
          AutoSize = True
          Margins.Left = 5
          Margins.Top = 1
          Margins.Right = 5
          Margins.Bottom = 9
          TabOrder = 1
          Visible = False
          object tbSbDatesCpt: TTBXLabel
            Left = 5
            Top = 1
            Width = 161
            Height = 26
            Align = alTop
            Caption = 'Termine'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            Margins.Left = 4
            Margins.Top = 8
            Margins.Right = 4
            Margins.Bottom = 4
            ParentFont = False
            Underline = True
          end
          object tbSbDates: TTBXAlignmentPanel
            Left = 5
            Top = 27
            Width = 161
            Height = 38
            Align = alTop
            AutoSize = True
            Margins.Left = 5
            Margins.Top = 1
            Margins.Right = 5
            TabOrder = 1
          end
        end
        object pSbNoProject: TTBXAlignmentPanel
          Left = 0
          Top = 0
          Width = 171
          Height = 78
          Align = alTop
          AutoSize = True
          Margins.Left = 5
          Margins.Top = 1
          Margins.Right = 5
          Margins.Bottom = 9
          TabOrder = 2
          object tbSbNoProjectCpt: TTBXLabel
            Left = 5
            Top = 1
            Width = 161
            Height = 26
            Align = alTop
            Caption = 'Veranstaltung'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            Margins.Left = 4
            Margins.Top = 8
            Margins.Right = 4
            Margins.Bottom = 4
            ParentFont = False
            Underline = True
          end
          object tbSbNoProjectOpen: TTBXLink
            Left = 5
            Top = 48
            Width = 161
            Height = 21
            Cursor = crArrow
            Hint = #214'ffnet eine vorhande Veranstaltung'
            Align = alTop
            Caption = #214'ffnen ...'
            ImageIndex = 2
            Images = ilMenu
            Margins.Left = 5
            Margins.Top = 3
            Margins.Right = 5
            Margins.Bottom = 3
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnClick = tbSbNoProjectOpenClick
          end
          object tbSbNoProjectNew: TTBXLink
            Left = 5
            Top = 27
            Width = 161
            Height = 21
            Cursor = crArrow
            Hint = 'Erstellt eine neue Veranstaltung'
            Align = alTop
            Caption = 'Neu ...'
            ImageIndex = 3
            Images = ilMenu
            Margins.Left = 5
            Margins.Top = 3
            Margins.Right = 5
            Margins.Bottom = 3
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
            OnClick = tbSbNoProjectNewClick
          end
        end
        object pSbLastFiles: TTBXAlignmentPanel
          Left = 0
          Top = 152
          Width = 171
          Height = 66
          Align = alTop
          AutoSize = True
          Margins.Left = 5
          Margins.Top = 1
          Margins.Right = 5
          Margins.Bottom = 9
          TabOrder = 3
          object tbSbLastFilesCpt: TTBXLabel
            Left = 5
            Top = 1
            Width = 161
            Height = 26
            Align = alTop
            Caption = 'Letzte Dateien'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            Margins.Left = 4
            Margins.Top = 8
            Margins.Right = 4
            Margins.Bottom = 4
            ParentFont = False
            Underline = True
          end
          object tbSbLastFiles: TTBXAlignmentPanel
            Left = 5
            Top = 27
            Width = 161
            Height = 30
            Align = alTop
            AutoSize = True
            Margins.Left = 5
            Margins.Top = 1
            Margins.Right = 5
            TabOrder = 1
          end
        end
        object pSbActions: TTBXAlignmentPanel
          Left = 0
          Top = 218
          Width = 171
          Height = 163
          Align = alTop
          AutoSize = True
          Margins.Left = 5
          Margins.Top = 1
          Margins.Right = 5
          Margins.Bottom = 9
          TabOrder = 4
          Visible = False
          object tbSbActionsCpt: TTBXLabel
            Left = 5
            Top = 1
            Width = 161
            Height = 26
            Align = alTop
            Caption = 'Aktionen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            Margins.Left = 4
            Margins.Top = 8
            Margins.Right = 4
            Margins.Bottom = 4
            ParentFont = False
            Underline = True
          end
          object tbSbActions: TTBXAlignmentPanel
            Left = 5
            Top = 27
            Width = 161
            Height = 127
            Align = alTop
            AutoSize = True
            Margins.Left = 5
            Margins.Top = 1
            Margins.Right = 5
            TabOrder = 1
            object tbSbActionNew: TTBXLink
              Left = 5
              Top = 1
              Width = 151
              Height = 21
              Cursor = crArrow
              Align = alTop
              Caption = 'Neuer Stand'
              ImageIndex = 3
              Images = ilSidebar16
              Margins.Top = 3
              Margins.Bottom = 3
              TabOrder = 0
              OnClick = sidebarClickShopNew
            end
            object tbSbActionEdit: TTBXLink
              Left = 5
              Top = 22
              Width = 151
              Height = 21
              Cursor = crArrow
              Align = alTop
              Caption = 'Stand bearbeiten'
              ImageIndex = 1
              Images = ilSidebar16
              Margins.Top = 3
              Margins.Bottom = 3
              TabOrder = 1
              OnClick = sidebarClickShopEdit
            end
            object tbSbActionDelete: TTBXLink
              Left = 5
              Top = 43
              Width = 151
              Height = 21
              Cursor = crArrow
              Align = alTop
              Caption = 'Stand l'#246'schen'
              ImageIndex = 2
              Images = ilSidebar16
              Margins.Top = 3
              Margins.Bottom = 3
              TabOrder = 2
              OnClick = sidebarClickShopDelete
            end
            object tbSbActionNewCustomer: TTBXLink
              Left = 5
              Top = 64
              Width = 151
              Height = 21
              Cursor = crArrow
              Align = alTop
              Caption = 'Neuer Kunde'
              ImageIndex = 3
              Images = ilSidebar16
              Margins.Top = 3
              Margins.Bottom = 3
              TabOrder = 3
              OnClick = sidebarClickNewCustomer
            end
            object tbSbActionEditCustomer: TTBXLink
              Left = 5
              Top = 85
              Width = 151
              Height = 21
              Cursor = crArrow
              Align = alTop
              Caption = 'Kunde bearbeiten'
              ImageIndex = 1
              Images = ilSidebar16
              Margins.Top = 3
              Margins.Bottom = 3
              TabOrder = 4
              OnClick = sidebarClickEditCustomer
            end
            object tbSbActionDeleteCustomer: TTBXLink
              Left = 5
              Top = 106
              Width = 151
              Height = 21
              Cursor = crArrow
              Align = alTop
              Caption = 'Kunde l'#246'schen'
              ImageIndex = 2
              Images = ilSidebar16
              Margins.Top = 3
              Margins.Bottom = 3
              TabOrder = 5
              OnClick = sidebarClickDeleteCustomer
            end
          end
        end
      end
    end
    object tbPanNavigation: TSpTBXDockablePanel
      Left = 0
      Top = 392
      Caption = 'Navigator'
      DockableTo = [dpLeft, dpRight]
      DockedWidth = 171
      DockPos = 392
      FloatingWidth = 128
      FloatingHeight = 128
      SplitHeight = 149
      TabOrder = 1
      OnResize = tbPanNavigationResize
      OnVisibleChanged = tbPanNavigationVisibleChanged
      object pSbNavigator: TTBXAlignmentPanel
        Left = 0
        Top = 26
        Width = 171
        Height = 186
        Align = alClient
        TabOrder = 0
        object pbNavigator: TPaintBox
          Left = 24
          Top = 16
          Width = 97
          Height = 81
          OnMouseDown = pbNavigatorMouseDown
          OnMouseMove = pbNavigatorMouseMove
          OnMouseUp = pbNavigatorMouseUp
          OnPaint = pbNavigatorPaint
        end
      end
    end
  end
  object tbDockRight: TSpTBXMultiDock
    Left = 904
    Top = 50
    Width = 7
    Height = 624
    Position = dpxRight
  end
  object tbDockBottom: TSpTBXMultiDock
    Left = 0
    Top = 674
    Width = 911
    Height = 7
    Position = dpxBottom
  end
  object pMap: TPanel
    Left = 672
    Top = 110
    Width = 185
    Height = 41
    BevelOuter = bvNone
    TabOrder = 6
    object pbMap: TPaintBox
      Left = 0
      Top = 0
      Width = 185
      Height = 41
      Align = alClient
      OnDblClick = pbMapDblClick
      OnMouseDown = pbMapMouseDown
      OnMouseMove = pbMapMouseMove
      OnMouseUp = pbMapMouseUp
    end
  end
  object ilSidebar16: TPngImageList
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000001734944415478DA
          63FCFFFF3F032580711819A0A8182860E6ACB7F5C39B677FC405BE6C60F8C7F8
          9F911128CDC8F01FA4E8EBD7BFFCFF7914C3DEBDFDB47BFFE669C51806D8BAC6
          96EA196834BB3B28B30B0BF230FCFBF78FE12F10FF43C2D76EBE64D8B5E7EA87
          ED1B660AFD876A841B505090531F1CEAD6F0EDDB57B886BF7F910DF80BE63F7E
          F4F2E389E3672DD6ACD97403C5801933271C945710B1FBF3E72F0E0310FC2387
          CE4E9D3D7B510EDC00777777D984C490CB9C5CCCFCC89A10ECBF28FC1BD7EF5F
          3D77F6BAC1FEFDFBFF800D088C29BC2D24C0A5E26A27C300E263B315C6FEFBF7
          2FC389F3EFFE3F7EFAE1E2C16D730D19B50D3C8D8C1D1C4FBDFDF28B599EFB1D
          83BE8E04C33FA0A27FFF419AFE430D80B9E02FC39DFB5F19BEF3EB337CFDF4E9
          EFDD93FBCD18D5359D4478450436323133F2B2FEFB729383F5D7C33F7F7E73FC
          F9F3870BA88103A8F13F1313D30F1616966F40FAFBEF7F3C0A7F9878D4FEFEFD
          FFE6EBBB0F118328250E980100623A3D7F4949C5420000000049454E44AE4260
          82}
        Name = 'PngImage0'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A0000034D4944415478DA
          9D93594C13511440E775DA329416DA026D69B10564A4DAA006904D4354820A4D
          880D1088FB16252A417E307E1A638C7FA2D58F6AA31210DC8824CA168444A9A0
          AD222828A66131A1C894CA94964E994E671C5C70FDF225E72D37F79DE4BE9B07
          188681FE67586E0264FD5EC60F7E08CC66B346181E6A2E2DD991C71E97AC2693
          511B21911AFF8CDBEE896FA515E33B96040F9A9B2EA5A5AE3BDEDBFBEC444949
          69CD8FC4CECEF65614D56E6D6F7F947BF8F0D1EEC5D8705B5C9958B9E5A272B5
          49B624B87BFF76655646F685597CD6D1DAD2A6ADAEAEF6D437D6966EC8CAA927
          FC84CFD2D39D72F0E0517B5F3D4FBC3C65573F000C12A5BD11037E7903D0D3F3
          D4AA566B528786DE5C7BF1C2764CAFCF1F94C9E4492F5F5A8D064371C562D278
          5FDE4355824AFF69626A66D9BAF6E85F055043435D5E6666F6A360900EF40FD8
          1AD3D3B20E4C639FC62C3DCF74555555C4BB0EB45CB332B786C79DE44F7D249C
          EA8C4E19F8B30B1D1D6D4D289A6498C6A628855C095BFA9E1ED959B6FBAAED4E
          9852935CF45C249C8965181AC21C14A6C9EC94FF2530994CEAEC8CF4517E2802
          BF1F7A3B526828D62EC6C77AF3BA642AD1269FDB41230201C78D238ED8D416D5
          6F827A00002702294F282ABBEC1A1AA0C3E73C5EFB845D9B7E2F71BF124D3B03
          D193F0E89BD7F678DD9A4417463913737A7F96D0151565E6C3F07600C3E12487
          1EFF1CF09C8F0B915E2101438B24427EC8561E00F9F3236E2756ABD6EACEE22E
          1A43375ABF95F0582ABD108A207A278E17454BC4F709926CC975CE543E5916F3
          8A13C95DA93C2943889A39C62B7137F10E11DDCA78D4E8C639D3499B6D8AAF02
          4B4CCCF09CCF57E3F3FB9BD572F920363B7B40EFF13CB496C7358B060485C273
          5C68E2E2E448C4DB48F7C25947AD5C1D6F2488B04974635F2CA863FB1FA7500C
          FB824107C3E5AE705354FF1EA7B3A2721F7F6D4141FA75FFD58F12EE67888101
          E516C102083EE51A8C888CCE99F77230DDB677DF4A68914AF3018F57E222C9B1
          DD387E432281C2AF9CD6DD918803AB42B82414E8A22091970709D63350583207
          626806227CDCE964FD0705F8D76FB4360A2F8B5519069AF2D24C90060CC44207
          D97B8BB9ECC4EE28D21F585B684FF8A780ED266017FE77109610169885622159
          1658FCEC5DF20BE32098F01A2A337C0000000049454E44AE426082}
        Name = 'PngImage2'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000002924944415478DA
          A593CB4F135114C6BF3B8F76A615833CA2988696570D0942D006064C581021DD
          E992AD7F850BD8F95F90D0356E306C58B06063B51B4D302A9152DA804A62694A
          020CF39EF1DC0BB18418374EF2652633F7FCEEB9DF7786455184FFB91807140A
          85FBB95C6E55D7F507F44E628CFDB32808825FB55A6D319FCFAF0B40B1582C0C
          0E0EBEF05C17084330524492AE15450415BD4AF4569661D9F6D76C363B2200E5
          72B9A4C762064C13F07D21E90AC27B11851C7055CC9249D892D4A04DBB05A052
          A99474C68CF0F818F03CB020E07DF2F351F5954754FC07D0DE0E3B996C0C0C0C
          B40089303482C3433002289D1D507AEEC1F9FC05A165431B7D48470B607F2B03
          8A02A9BB1B4E5757A3BFBFBF0548BAAEE1EFEE02E483DC7107DAA371448E83E8
          E202726727DCBD0ABCF21E22EA404EA5E0A4528DBEBEBE4BC0FEFE7E29699A86
          BBBD2D005C6A268DB831099E8857ADC179F75EB48F580C723A0D379B6D643299
          16E0D6E9A9E1944A00DF954C4CCC3F85D2DB0BFE3D3A3B83F9661D9165811140
          191A823B3A7A03D06C1AD6D61660DB88E71E439B9E82F3E123B82FFAF367087E
          FC84B9FA5A00D491117813138D743A7D09A856ABA564BD6E581B1B97BBB4B591
          893D70794714A5921D829448C0231F108F23363E0E7F66E606E0E8C830D7D600
          322D24F1A3F048798C2248EE3E1543D7A14D4EC29F9B6B012885E2ED93932767
          2B2B08CFCF0584BB1F7143F94CF0FC55154CD3C41025E6E7E1CFCED609705700
          36373797A6A7A65E593B3B0019C647994FA32C6638125318F2674A2122903636
          86EFF5FADBE1E1E11901585E5E56C9D1973418795A16F77D5FF53C4FA19F4688
          A2A4F8655F51148FE4379BCD4F0707078B0B0B0B47EC6FBF33152874D3480992
          4A223360911C5AEF5E5FFB1BA5BD6FF03CBB93DD0000000049454E44AE426082}
        Name = 'PngImage3'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000001F94944415478DA
          A5D2CDAB12511400F073EF9D2F1D0731265149AC55EB97FB962D0437F52FB4EB
          AF6817B46B1B0451EDDA29B48A88281213153F31E1F1E2493E6E45FAC6279A33
          B773AD1966DE3CDA74E02EE67EFCEE99732E1142C0FF04F18166B3D9B32CEB12
          A594789E27E4BC3FF01B183DA1A6DED41565CE1C677376FDEAD33B905A7F0880
          E170C8755DB75555DD1F22840403600329FD2524B477A0B053D8ED56AEAE7E79
          02E2F451008C46236E1886AD28CA9FD442804AFB90325E80A621ACDC02E11E09
          E63D3E02F1F34124836432196480BF12029A98C13350B52B40B4BBE0FDFA84C0
          C3AF208EEF07C06030E0A669DA9AA60519F80825C790549F83AEB481B003F0DC
          134F216FDF8358DC0B807EBFCF1389848D5944D297880C957E048DBD0186D86A
          B5DB64ACD7B7019C5701D0EBF5782693D9D7207C7BB4980E101C8787FCFBC18D
          9B76A48DDD6E97DB1861E03CE2C7743AFD562E972F47804EA7C3D3E9B48D7588
          0061C48FC9641207DAED36CF66B3FB229E07C288DC3F1E8FE340ABD5E2854261
          DFC68B001F91FBB1E571009F322F168B911A30C662887CD6D8F238D0683478A9
          54FA27E067702150AFD73FCB1AE0468AB7C8E6D3BF6B788E089C96C3C36F319F
          CF7F542A956B11A05AADB2C562A1CF663363B95C9ADBEDD6725D3725D7F0E01A
          6BE3E0433BCBE572AB7C3EBFAED56AAE5CFB0DEF4A0B1733E803050000000049
          454E44AE426082}
        Name = 'PngImage5'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000002034944415478DA
          63FCFFFF3F03258091F6063032329E6A168B6265E3B1F8FEEBCB04AB9A977789
          36E078912C278F02FF6101515943261656A66F1F5F7DF8FAE9ED0C83A2DB9544
          1970A64BA64C42DEB0935D588D81898D87E1D7DB9B0C1F5F5CBFF7E2D5276D87
          FAFB3F081A7075AAC1464171053F0E297306662E31861F4F4F307C7B7989E1D9
          E307C1D6F52FD7117641876C8EA88CEA647601790626164E86DF1F1F323C7BF2
          F039D3ADABF2C633FFFFC66B00232303A34FDEDCB549624BFC3445BF3173B2B3
          323C7DFDF5FFCEFBA2EF973C7636BCBBA9FC115E03B423A6F64A4A49167073B3
          3139701D6210FD7D9D61D92D45866F82A60C5F3E7F3DFFF2DB77EBC7AB0ABF63
          3540C3BF8B57525AEAD697FF6C12ACEC9C0C6EC6320C49CE320C51DD47197E7E
          FFC1C0C3FA8FE1D5AB378D5757E635603540DDAF57444C5AF4DEE7AFDF78D978
          441898999919D2DC1518A66FBDCDF0F7CF4F066686BF0C4CBFBFCD3BB1202B19
          AB013A8E8D3C028AA2F73E7EFB21CAC62B020C0F260645314E867B2FBE30FCFB
          FB87E1FFD7170C7FFF31AEB9BCA62A1467182839E53589CB286531B1720930B2
          009D00093086DFBFBEFFFAFAFEF5CB5B471616FE7AF7680B9E58609465666633
          61E197B066F8FF5FFDFFBFBF6240D1DFFF7E7DBBFDE7FBFBB3A0840AC4E7F0A6
          03A021BC404A1688D580580488DF02F103207E0C6203F5FEA7383702006185EF
          EF3AD7E1DD0000000049454E44AE426082}
        Name = 'PngImage5'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C000003A34944415478DA65536D4C5B55187ECEBDB72D6DD79696
          D5212BF23936DD5A681790A1C66A9645B7F0C7B1259A4DB6D415D12523D3C411
          352A13A33F80C9945F9228C66D26B02FD9129531C08FE13242EA80C0AA746C4A
          E968696FDBDB8FDB8FEB61D35FBEC97B4E4E72F2E47D9F0F62B7DBC1B2EC3EC3
          43F96F1A5946D96008179A6B8B65198546CAC6E32044042303908E414AA74090
          221C4748F8EFB074A063A49754565642A3D1F4B4B5B5355BB75623CDDF03E7FF
          194A7D000ABD1E525844C47D0744C1029938B20901CA8719C4420276BF7C719C
          98CD6668B5DAAEEEEEEE169BCD86D512791E31F71054CA59C8552C7C43F348CA
          CCD03DB903E9151EDCDDAF01B50FBB5F1B1E23168B657582AECECECE969A9A1A
          FC57D1C565782786C02866B0BE2C8BCCED2CB28A6D90156D8334F729C4F42C1A
          0E8FFC1F20E6F521786B1A4BB3BFE3C6CD25181B1A51218DA2DC380D4EC8809F
          3340A10A20A3E7D1D0F4C318A9A8AA829EAEF0D9C99E164B6E2E16AF7C0E7DCE
          1DCC2F10844CCFA376DF4B480422589EBA046DCE35AC4588129A032111C7DE57
          2F8F91ED8F6E42C690FFD15B0E47EBE3CA5B50EBAE213AF82B26A45DB0B4F7C2
          A85B03C2107843595C1FBF8E3AD559184B5620DC16F18283024CD07D670C862F
          1F6BDDD168B307C17FF70B5CFE9D301DED82A9B400623C09868AC7702C861758
          14273DC80BF5814BCCC1F1C68FE3C495A778BFA0C5DEBAB65E922F5E18C5B0EF
          10EA5A8FC354A0457C250229258225A05E2118F6EA602D97E1B7F3A770AEE758
          6CD2BDDC4FFE6A7C24BAFE58A9FA5EFF24FE605E87DBFE01B6947230A73C48DE
          70015A1D7264123C01062E7919EA9F3361E0DBD3D8BFFFE0374C563C4C8E9670
          67765AC91ED953EF311B0FBE4DC949E0A73F5994C43C284EDC05575D0D9FC0C1
          3513C616D10DDBAE5A9C1AE84793F3506F4C105E217994835C43C1C5DE4B83F5
          362A69820FC02F2A70739AB21D8940BE6103D284430959C2BAA529E4D6D9716E
          7000CD4E679F20088DA4A8B010BAFC75C74F7674BDB369632522D128942A3962
          0B0BF07BBCD058B7628D8A81145CA6FE9847D133CFE2F2F717D0DCE4EC8B4629
          4095D50ABD4E7BE2E34F3A8E6CDE6C45381C052B9723B5E247686A12328D0612
          C3418CC6C0A9D5287BFA099C3FDB0F87E3C00300ABB58A3A517BC2E96C3A525E
          5E81384D20A86C123DB3347D92985A7DD2A652CA15F4AF0AA32357F1617BFB19
          9EE75F24D594A44824521B0C06DFA5B136800AF7200D841A88B9DFB80FF7EF25
          496C96562010F82A994C7EF10F708384D7AD22AF1E0000000049454E44AE4260
          82}
        Name = 'PngImage6'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000002EE4944415478DA
          8D926D48535118C79FB3B9EDCEDD35278DD46D56C34D1BA2F852F90262E40B46
          989FEA83197D3512A2647D92A03E28297D0802EB9324D6401434289154084B2A
          954068B14296D7B9D4BBB9BBB7BBDD7B776F6703474252E770B8E79CFB3CBFF3
          9CFFFF204992E0B036A150E4A9158A531762B185C362D06180D7D9D9358526D3
          5319C719BC7E7F6F7338FCE2BF016FF5FA6B276DB67E834E57C06E6D011D8984
          BC81405F4B28F4F89F807746E380B5ACEC2649101A71771738BF1F381C134C24
          585CC92086DCFB2B600C21C262B38DD92A2B3B5432998C5F5F874D05025E4742
          C1F70DE0704C94E3382F4D3F6B0A857A0E00A609A2F07845C584A5BCBC1A2512
          C0AEAD81D7780C8807FD202914107FF4100CEF3F82904C4224994C6ED2B4D3CF
          30D73B2549406F74BACAA286868982E2E213623008CCF232D075B5A0BDD30B2A
          950A341A0D84C361F00F0F43CEF434481C07510CC2954CB506831D68DE68BC7F
          B6ABAB4FDCD981ED95152971E532D25EED02A55209595959B07F459EE781763A
          413D3222C9E371F42B168B7ABC5E3BFA60B13C29ADAABAE171BB9384C321D734
          360296001042F0A7C0A9796A30F3F3200E0D25352C2BFF4A51B7D09C56DBA926
          49873038986FAEAF37C462B17482288AE92AE840083E7FF36580D5C579C0AE7E
          F2690706C27B81C0DDB488D801997161E1274992A6A9579399536DD61220C8A3
          B0B4990D7A2D01A168024EE7472057ABFAB1DDDC5C8A454C646C9C9B9BA3CC66
          B3697CC29901D49CA9039A89C3C81207714E80689C87DB2D47404F2ADDADADAD
          C507DEC1ECEC2C65B7DB4D632F9F03760A14E086C6A61ED8F0D230B5B499815E
          AA3541B612B9DADADAEC070033333354494989697CD209822000C2FDFCB9666C
          259176635FC814DCE3F1B8DADBDB0F0246474757AD566BD106E52179814FEF99
          4D85C9BD4050C0028A295DF157C20E8914457DE9EEEEBE8873231980C3E150BA
          5CAE5C9FCFA7651846C7B26C0EF63E07FF97E316C38E306AB59AD1EBF521BCF6
          2D2E2EC65379BF0162777E1069B567B90000000049454E44AE426082}
        Name = 'PngImage6'
        Background = clWindow
      end>
    Left = 724
    Top = 62
    Bitmap = {}
  end
  object ilMapEdit: TPngImageList
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000001F94944415478DA
          A5D2CDAB12511400F073EF9D2F1D0731265149AC55EB97FB962D0437F52FB4EB
          AF6817B46B1B0451EDDA29B48A88281213153F31E1F1E2493E6E45FAC6279A33
          B773AD1966DE3CDA74E02EE67EFCEE99732E1142C0FF04F18166B3D9B32CEB12
          A594789E27E4BC3FF01B183DA1A6DED41565CE1C677376FDEAD33B905A7F0880
          E170C8755DB75555DD1F22840403600329FD2524B477A0B053D8ED56AEAE7E79
          02E2F451008C46236E1886AD28CA9FD442804AFB90325E80A621ACDC02E11E09
          E63D3E02F1F34124836432196480BF12029A98C13350B52B40B4BBE0FDFA84C0
          C3AF208EEF07C06030E0A669DA9AA60519F80825C790549F83AEB481B003F0DC
          134F216FDF8358DC0B807EBFCF1389848D5944D297880C957E048DBD0186D86A
          B5DB64ACD7B7019C5701D0EBF5782693D9D7207C7BB4980E101C8787FCFBC18D
          9B76A48DDD6E97DB1861E03CE2C7743AFD562E972F47804EA7C3D3E9B48D7588
          0061C48FC9641207DAED36CF66B3FB229E07C288DC3F1E8FE340ABD5E2854261
          DFC68B001F91FBB1E571009F322F168B911A30C662887CD6D8F238D0683478A9
          54FA27E067702150AFD73FCB1AE0468AB7C8E6D3BF6B788E089C96C3C36F319F
          CF7F542A956B11A05AADB2C562A1CF663363B95C9ADBEDD6725D3725D7F0E01A
          6BE3E0433BCBE572AB7C3EBFAED56AAE5CFB0DEF4A0B1733E803050000000049
          454E44AE426082}
        Name = 'PngImage0'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A0000034D4944415478DA
          9D93594C13511440E775DA329416DA026D69B10564A4DAA006904D4354820A4D
          880D1088FB16252A417E307E1A638C7FA2D58F6AA31210DC8824CA168444A9A0
          AD222828A66131A1C894CA94964E994E671C5C70FDF225E72D37F79DE4BE9B07
          188681FE67586E0264FD5EC60F7E08CC66B346181E6A2E2DD991C71E97AC2693
          511B21911AFF8CDBEE896FA515E33B96040F9A9B2EA5A5AE3BDEDBFBEC444949
          69CD8FC4CECEF65614D56E6D6F7F947BF8F0D1EEC5D8705B5C9958B9E5A272B5
          49B624B87BFF76655646F685597CD6D1DAD2A6ADAEAEF6D437D6966EC8CAA927
          FC84CFD2D39D72F0E0517B5F3D4FBC3C65573F000C12A5BD11037E7903D0D3F3
          D4AA566B528786DE5C7BF1C2764CAFCF1F94C9E4492F5F5A8D064371C562D278
          5FDE4355824AFF69626A66D9BAF6E85F055043435D5E6666F6A360900EF40FD8
          1AD3D3B20E4C639FC62C3DCF74555555C4BB0EB45CB332B786C79DE44F7D249C
          EA8C4E19F8B30B1D1D6D4D289A6498C6A628855C095BFA9E1ED959B6FBAAED4E
          9852935CF45C249C8965181AC21C14A6C9EC94FF2530994CEAEC8CF4517E2802
          BF1F7A3B526828D62EC6C77AF3BA642AD1269FDB41230201C78D238ED8D416D5
          6F827A00002702294F282ABBEC1A1AA0C3E73C5EFB845D9B7E2F71BF124D3B03
          D193F0E89BD7F678DD9A4417463913737A7F96D0151565E6C3F07600C3E12487
          1EFF1CF09C8F0B915E2101438B24427EC8561E00F9F3236E2756ABD6EACEE22E
          1A43375ABF95F0582ABD108A207A278E17454BC4F709926CC975CE543E5916F3
          8A13C95DA93C2943889A39C62B7137F10E11DDCA78D4E8C639D3499B6D8AAF02
          4B4CCCF09CCF57E3F3FB9BD572F920363B7B40EFF13CB496C7358B060485C273
          5C68E2E2E448C4DB48F7C25947AD5C1D6F2488B04974635F2CA863FB1FA7500C
          FB824107C3E5AE705354FF1EA7B3A2721F7F6D4141FA75FFD58F12EE67888101
          E516C102083EE51A8C888CCE99F77230DDB677DF4A68914AF3018F57E222C9B1
          DD387E432281C2AF9CD6DD918803AB42B82414E8A22091970709D63350583207
          626806227CDCE964FD0705F8D76FB4360A2F8B5519069AF2D24C90060CC44207
          D97B8BB9ECC4EE28D21F585B684FF8A780ED266017FE77109610169885622159
          1658FCEC5DF20BE32098F01A2A337C0000000049454E44AE426082}
        Name = 'PngImage1'
        Background = clWindow
      end>
    Left = 824
    Top = 116
    Bitmap = {}
  end
  object ilMenu: TPngImageList
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000002684944415478DA
          9592EF6B526114C7CF73D5AB326D1385DE4DB0415CE9C5EE42A4DC9BC6D6ABD8
          188AFD0B0B04AD4BFF42FF472FA2A05FC8426808259A0DC92CA708DA749AA4E2
          8FE1EF9FEBF63C4F5C99FAA61E385C2E9CF339DFEF390789A208971FCBB23C42
          E836FCC31B8D464FD13CC0E572C5CC66F37AAD568376BB0DBD5E0FFAFD3E0C87
          43C8E57290CD66691E6E02F57AFDD102C0E3F1C4789E5FAF56AB14D0ED766130
          18504032998442A1408B49542A156106F00221FDB1DB7D64B3D936307D0A202A
          08241A8D42B158048661687EA9549A05441C8EB34396EDDE743ACDCD66931676
          3A9D2920180C92A2A9020C13D01B95EA965CA5E219990CAE1F1C3CE90F06EA53
          A3916DAFAC50EF528CC763F0FBFD502E97A7807C3E2FA0C8CECEE1558EBB8758
          16603281DFAD1634E57248984CD03718683151A0D56AC1EBF5D219100B048007
          2AA0F0E6A657AF54EE8A7848CCD212192F059DE38214CF4357AF07629328F0F9
          7C548104C86432020A70DC4B4D2EE710B14752CCA8D520C3A0F3B53528ECED41
          0F5BC1FB861656160A85284086ED12402A9512D00793E995EEE2C22EE20E2296
          2B62B90D8E83FCFE3EC856576967690E64887875540189442221A0E700962680
          1587C662343E6C01E8B276BB4266348246A3A1DB9907480AE2F1F8DF35E21F25
          CEBBF27A79397864B5CA2D4EE735854241CE9AAE8FC82737904EA769670220DF
          582C367B07CF10D246DCAEC0D69D6D9EF80610E1DBF72F100E7FC45646B49080
          25C8E7F089B070CAC2E30727DB5BBB37B26771F874FC161A8D5F34F972483378
          FFEEE722C079FF6E5067986CFC38FD3AA1EB22C9E470E6BF3802FE8E6B01F0BF
          EF0F99446117246EB5720000000049454E44AE426082}
        Name = 'PngImage4'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A0000031B4944415478DA
          A5925B48936118C7FFDF3E37F7CD9D4C2766B34C5DF3541669D2324A12A513E5
          21ADAC209052F2501445D101CA88A28BB0C2328B0E684917D985C5CC144B12CD
          AC69330FCB3466D34DE7616ED374AE772B8B8AAE7AE177F1C1FBFF7DCFF33E0F
          65B7DBF13F87FA53205B77591826179D5F1A3A272250EAE1078A4297D6D8DDF4
          41DBA86A1D3ED2F9247BF49F82881DF9A9D9A92BF2C3E5B3BDEA549FA1D11AC1
          62B120F3F5C0F245BE68EEE8D35F29ADCDA9BB9355FA97C0112E3A915C5CFBAE
          87BE5FD102179A860B9B064D04CE8BB063CB9A504485F9DAF69C79983623710A
          1C651FCF54749A2C5FBD4A942D60180ED62B6498E72D0245049ADE2134A87B31
          3E3185C4D54160382EFA93F93532473B4E41C281BB05A7326333B22E9483EBCA
          068F71C5D5837160912A78E4DB8D61E39E528D8A864F98FC3A89BCBD31C8BB51
          75ADE4DCD64CA720AFE8F96B4F313FE241A51A7C372EDC785CC42DF3C75B8D01
          F151FE58BB6C1EEA5B75B859DE02AB75021B1401D019461A0FED5C19E9143C50
          AA0C6FDA749E2A8D1E023E43248C5314E62F41CAEA40705C587858A34153473F
          CC9609C8A562C87DDD07126242244E41A9B2D9D0D4A1F36CE91A8050C040C8E7
          814F44599B17C25BCC45F57B031ADA48D83C0ED39815321F116452D1C0A655C1
          DF05E76E55BFF6F2104694BD682702DE4F76C50793BFD3A854F56378D482D131
          82C98A98C5526875C6C6FDDB15DF5B4839525C70724F6CC6F16BD57023E53BC2
          22210FD91B83E0CAA151D6688061C84CC2168C99ADC8495C82B3E4116F9F4ECE
          FC39C6D3B9AB3A27A7A6BD9ED67F8280B421206D2445CF079BECC24BF5204C96
          71121E4774A837A66D53FAC3172A7F8DD171A27717A4169E482A7EA7D1D3556F
          7AC065B8649C1C70D86CC716C166B34111E24D1E4F6CDB97F728EDD9F5F4D2BF
          56393ABD303577EBF2CBE10B7C24EAEE41F419CDA0C92E48257C04CD9D0555FB
          97C18B458F8FBE2A395664FF11FC4D4051D46CAED84F16B72DFB6864B83C3838
          402A01EC546B67CF48C35B7597B2F852E1A4C5F0915CD5127A1C923F058EC517
          10DC09240C4F029760221809838461C2E84C05DF00BBA260F0D48A709C000000
          0049454E44AE426082}
        Name = 'PngImage1'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000002784944415478DA
          95534168134114FDB3D98D599AA4315693D4F6108BA004A11E5221505231420F
          8A95E025DE8221908045129B54E8B1224A4E0AA5DA5B0F3D896054309ED49BED
          4550828D8856620A26EE36C4346677679CD9243521BDF8E1EDFFB37FDE9B3F7F
          FF224208742C1E8F8F0D0C0C4CD2105118A8214110B82E209EE7F598E63FC662
          B1572812891CA31BCF300197CB7539994C5EC1180342481765BE83EE75369B5D
          09068311B4BCBCFCC4E170CC288A02D56A1542A110E4F37960EB6E1233A3D108
          168B05464646607575F54E381C9E474B4B4B8FAC56EBB57ABD0EA228C2D4D414
          944AA5BD6BED5789DD6E87B5B5B5EBA954EA3E5A5C5CBCEDF178E6254902A7D3
          0966B3196AB55A0FB95B8CF688E5E55C2E3791C9640A68767636EEF7FB1F140A
          05F0F97C20CB32741ADB7D3A2B9F3610388E838D8D8D678944E2A29E8B46A3E7
          0381408E11CBEA41C0D651C01A612CD8D7A8F81F0C12E20CBBDBE5EA16A24D73
          D30A3E994C26E1EBEE105886C7E07743EDE7B5C9A4E574BF5DAA3C6602E2F8F8
          F80FB7DB6DDBAC0D01B21C010D933E426B4980A6A0A16860157978FD6EF32662
          2F1716168A5EAF77F8BD7C088869B087D011C0F4A1D2AB292A6E89ABCDF2DBF5
          CF277581743ABD69B31F3E5EB14D80C96C03950E12C6ADD3749176C91DE3687F
          6469E7E5CA0DFF74A78237C5C6E0E4E089B34010B75FDF7ACCC021F890FF3697
          BB7BE99E2E909CBB952D8AA72FD88E8EB536937FAD237D6A003F2B3BC5EF5BA5
          53EB0FAF4AEC5B09E7A667FCC2A86F1E63F500D634016BAA1163E63523FDAD08
          C719141D06BE59570D5FA45F95E7F91799A7F4F02AEA1A1A563BCF04D9D8B7C1
          628DA2D986C24039DADE7412D257E47FD95F200F29FFBE05E5C1000000004945
          4E44AE426082}
        Name = 'PngImage2'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000001F94944415478DA
          A5D2CDAB12511400F073EF9D2F1D0731265149AC55EB97FB962D0437F52FB4EB
          AF6817B46B1B0451EDDA29B48A88281213153F31E1F1E2493E6E45FAC6279A33
          B773AD1966DE3CDA74E02EE67EFCEE99732E1142C0FF04F18166B3D9B32CEB12
          A594789E27E4BC3FF01B183DA1A6DED41565CE1C677376FDEAD33B905A7F0880
          E170C8755DB75555DD1F22840403600329FD2524B477A0B053D8ED56AEAE7E79
          02E2F451008C46236E1886AD28CA9FD442804AFB90325E80A621ACDC02E11E09
          E63D3E02F1F34124836432196480BF12029A98C13350B52B40B4BBE0FDFA84C0
          C3AF208EEF07C06030E0A669DA9AA60519F80825C790549F83AEB481B003F0DC
          134F216FDF8358DC0B807EBFCF1389848D5944D297880C957E048DBD0186D86A
          B5DB64ACD7B7019C5701D0EBF5782693D9D7207C7BB4980E101C8787FCFBC18D
          9B76A48DDD6E97DB1861E03CE2C7743AFD562E972F47804EA7C3D3E9B48D7588
          0061C48FC9641207DAED36CF66B3FB229E07C288DC3F1E8FE340ABD5E2854261
          DFC68B001F91FBB1E571009F322F168B911A30C662887CD6D8F238D0683478A9
          54FA27E067702150AFD73FCB1AE0468AB7C8E6D3BF6B788E089C96C3C36F319F
          CF7F542A956B11A05AADB2C562A1CF663363B95C9ADBEDD6725D3725D7F0E01A
          6BE3E0433BCBE572AB7C3EBFAED56AAE5CFB0DEF4A0B1733E803050000000049
          454E44AE426082}
        Name = 'PngImage3'
        Background = clWindow
      end>
    Left = 792
    Top = 116
    Bitmap = {}
  end
  object ilSidebar32: TPngImageList
    Height = 32
    Width = 32
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000007A24944415478DA
          C5977F5054D715C7CFDBDDB7FB76F92102B28B204B44E487898A88581A468314
          25740818631C32D18933F24F667432E844CD381DC73FD2F6AF4E0DD362356A51
          20089AA48DB51DE24C7F38F59F245534242C1270C9865DC0FDC5FE783FF6BD9E
          F3D8A5ABDD48D324ED9DB9F3F6BD77EF399F7BEEF79C7797511405FE9F8DF936
          007D2CFB0A28CA6B7C2452F392A24CFFCF002E320C6364D993E6CCCC96A526D3
          E24FC6C7EF85248920EE7FEF00E83C099DBF5F5450B031D76C36093333E00F06
          E196DD6E0F89627D8BA2DCFDDE00D0799EC960B8B66ECD9A958B5353B58A2C03
          EF7281248AC04B124138C292B473572472E33B07E8D16AAB939393BB2B2A2A72
          8C0603003A07741A9E9C041101C88A84CF6EDBED4E5E145B5F90A4F7BF330014
          DBAB8BB3B27EB2AEBC7C8956A399731E8980E2F5828C5B10421B11EC6449C6EB
          A70EC75490E7DFD8218ABFF9560018720DA7D39DB616176F5F595ABA88A1B1E4
          983A865EF17840C0DF2C42118418B545109F3B9D0F02C1E02F9E17C513FF1500
          3A4FE5F4FAABABABAACA2DCB9671B19063BC2162B783E2F7C350C0076E498012
          2E05D2390E823846884682EC8ECDCC78DC3E5F1742BCFA8D00D0F98AE4D4D43F
          6CA8AD5D9E9296A621E7B46A08852072EF1E8881000C86FC907EF020189FF911
          D8F7EE86DC192F5810228463A9AB10D8BFF278665D6EF73514E78B98A6F28200
          EF68B55B1799CD67376CDD9AAD8F892DBADF91E1610862CADD9525C87EAB1DF4
          2B0AF1B5AC8EF9EAE06B90FED930583923F078EF8F8398F6FBC38EA9A91B58B0
          1A1082FF5A0014DBEB96A2A243AB376DCA20B1A9EF30EC322A5DB6D9E00146E0
          5E4A32E49D3E039AB434E48A8006C7512710D7CF7F06ECF5EB508410B4155E7C
          1F13A7371814269CCE7F20442D42F81F02C090EB3896BD50545DFDEC13656529
          408EA32B8FA063797C1C26781EA6571480F5E45B1089C2193042690842CDED76
          ABE9E8BE7001C2E7CFC32ADC0E8AF703B421452102E1B03C3E393924CC554DD7
          3CC0658EBB5CDED4D490999FAF9F93B1AC8A4DFAF8639051ED9F87C3C03C5B0F
          D9AF1F56574DABC59A001C3A8935B213C67101D4C7EC871FC2F49B6FC25ADA42
          865121F828445810E00B876368A72896CE035CCDCA1ADCB477EF938C563B670C
          8D48376F82886936884633DBDA607173B3EA9C5A52521268A36363CE638DE008
          2280F013386FAD4E072C8E9DC1B9411A87FDFED4D4A4D7E7ABC2287CA102FC31
          27C756BD67CF0AB40A328652BA710342B3B37007DFE59F3C09A6D5AB55C3E494
          C21EDF1265118D1570A501CC98B17DFBE029BCC7EF07B81182C4E99D9D151D2E
          D7BE5DB27C5E0518C8CFB757B5B4E4CA5F7E09D2471F811B953E82AB5CD9D909
          6C5696EA849CC7AFFAEB9CC73FA38851A9B6EDD903C5189545B865244C17EA69
          C2E1E86F16841DCC0580E4DCC2425B59498985943E110828D3CB97334567CF02
          8313C8207E7DD5FE4D9CC73F13B1680D2384D5E954B28C46268051B8393A3AF4
          BC209412405A0AC7DDAAB25AF3463C9EE0838A0ACDFA33673835BFFF4347541B
          9C4E67C24A978511341A8DA0C1397F6D6808ADF2F974668381FDDBD898AD99E7
          57AA5BD0A3D16CD06934BFCBA8AC3C37BC7BF7CEA6A6A67C0A1F7EE2C18B0528
          7EF5343E16959C9C1C350D2FF6BE07F7C3E9A047C169348CFA2D88446490B02F
          334CC1CBBBB6ABE32FF7F78FE61C3EFC6714C973A170F8193C3BDC9E2F44580B
          8CA8CA504747C7586363A39500C631FFAFFDE983842BCBC8C8842D588609A0F3
          9DF7C0A95F05C9461638BD0E4409F75E88408897C0220EC26E04A062D5DFDF3F
          B27FFFFE42F4B51C7D8D262CC5A74E9D1A6B6868B04A580149C95DDD9D3097C1
          F09016AC79F950FDF426D57057DFEF61922D0513C7824E4B5551015E24001196
          4A77E0E5179BD57957AE5C193E70E04051BCBF4400E3F5F5F5790490919101ED
          BFFA25C4F410DF4A8A4BA1EA074FE3F72904DDFD1FC08854A86E8D20621D088B
          E00DF0EAB5B1600A5E7AE13915B4AFAF6FA8ADADADF4B100B805F7B76DDBB68C
          00323333E1D7A7DA817E4354064CF407016CACAC5205D873F92ABC6B4B4FB855
          8D052E68D9D11803B87BE8D0A1271704A8ABAB5301962C5902A7DFEE50B722D6
          4CCC0018303D2DF9ADB061FD4615A0F7DD6B8F05D8B5FDC76A0D410DDC4180A7
          1602B0D7D6D6E61200A5D0B9F36720CC87E326CC82C7EB87CA8D3550515E09B3
          5831AFFFE5EF306277250478626906D4D554830E33A4B7B7F7F6912347D62C08
          505353934B5F368BC502BFBD780EF739F8AF09D12D282E2A817565EBC18F4586
          8C3F5A25638DF4C363E5A30FD7A54B976E1D3D7A74ED4200139B376FCE2180EC
          EC6CE8EAE9844030F06F8609A06C4DB95A271E6D898A17017477770F1E3F7EBC
          0A6F034A74D04300982A86F6F6F6D12D5BB62CA53A60369BA1A7F7A21A666012
          03F87CBE059DD333BD5E0F5D5D5D9F9C3871A20E1FF9F09990084073ECD8B17E
          ABD5FA43966535A8013D2F840C2265C1C3088C91332A7EDFAC8870F139AAC4EA
          045E95E8BDDA315292CD66FB292EB0037DCE8734E1A1B4B5B5D58C657891C7E3
          49C2438611B38043511A302A7AEC069CA3C3BDD5E1502CF1647FDE9984E92662
          175017D4795C4818CF0F0193C9E418181898561E39982EF8C784A28217724607
          013A31B1D14ECF4879F49E4E2A52F42A463BA50E8539A23CC6C93F010039A8FD
          78ED4B3E0000000049454E44AE426082}
        Name = 'PngImage0'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000005604944415478DA
          ED976B88546518C79FF79C33D73397DD99DDD9D9DD19F7E26DB4F2CB1AA8ABA4
          1142669B097D081404C3080C229794CDDC2609A3CD85EC4256E6971023305251
          AC8C0DD4C8A0444B976DD7D9CBECEC5C762E3BD733736E3DEFD95144FAD0AC53
          427486FFBC3387C3F3FF9DE779DEF73D87A8AA0AF7F320FF03FCA70006FC84E3
          A0AE3D139F1E7BFC905AFCD70006FC758F19585DBFCE60A9D59B2C0651C88BA5
          42262D2BC5BED5BDF1CFFE51804BFEBA2316A77753BDC7E7005501552EE22003
          FD3D138FA453F1F19F0CC1D8131D8755B1EA0017FDCEE71C8D8B0FD634B4DA08
          E08733E1591594520E642101AA580041564BD1F1C14F3A7BA777561560C0EFB2
          F006FEBA67C94A2F212CB0661730069B76E78A9002291701291B025024882792
          D16C7A7ACDEADED850F5005EAB5DEB9EB7F494CDE1B6707C0370D66684684000
          098DA740CA4C82949E0031130489734074E2FAAE55BDF1FEAA015C7ABD6EBF7B
          41C75EA3C180E65EE06C1EE02CCD9800F1B6B99441001C19049C1CB97676E5BE
          D886AA015CF4D7ED71B72E3B60D4EB81B53602C7BBB10476AD04B4FE72368C99
          98D46088C503C19BBF7DD5B92FBAB97A25D8EB5CE16A6A3B67B55B6DACDE068C
          C9010C6786D926CC825C88838C7DA0883910750E353A36F442A73F76B86A00D7
          FD449FE6BC83CDAD0BDA54A90014827046F44700FCAF146750292D33C1C9502C
          124B763C75303E5135007A6CDFF6EC89ED0F0D6E9AD7602392900442382D0374
          2DA0DDCF9AEB219E91D433BFA6CFF47C7A63E35FC59813C0F2E51FEB32DEF497
          4B17B73ED9C19C653AAD97A1DDEB021664341780307A505181600C7E89D5C3D1
          C0BA44B6C4BD31726AF7BB5501F03DDD3FE0F3B5AC9A29E97420E7619125048F
          902FC06DCA819E63A024CA10CBB1F05D662DDC141782C9DE0433C9546A2A92EC
          1FFEBA7BFF3D01B475F56DF3CDF71C2A80D15AC0C595302CB4BB18888482B073
          7D1314851C0D0B47BE0D408DAB19C69398174505778D114293D1A94426D1397A
          726F604E00CD5D7E73BDC5796D5E6B4B7B384553CD69329B0C902F14A0BBAB05
          9634EA409008EC78EF67E02D76280802CE4C0988A24093D308BFDF18BF307CB2
          7BCD9C00DA37BCB57EE122EF89B4C8F2B2C2A039A30100668110061E5DE6823D
          CFF8E0FC95301C387E55DB94A81404A0A3DDCC41219B8D4C87E20F0F9F7B75A2
          7280AEBE9E077C2D6F4E254BDA8243387D390B8C9676939E85CF7775C0FBA747
          E07B84D00054F936080B0AD4F2ACF447606A6BE074CFF18A01E677F57DB4D4D7
          F27C289E07A994079DC95E364711BA1F021CD8BA183E3C330A6331EC050D40D1
          CCA5421A189D11CB6086A191F0C1E193AF74570CD0BAF1EDCD4BE6371C8BA645
          8324968033F265630A307BCD96356E3876210CB24CEF5AD1002848299F044EA7
          8706875D1D1A1A7B71F41BFF071503346EE8A977DB5D576A6CFAA694C0CED69E
          3A1302B70816349A613894A5CB9156A65B10723107BC9A8422E34C8C5DFD6173
          6AF0D425F4162B02208458BCEB5EEEF17A3C2F596B9DA6AC20E29C574052EE8A
          4163AA1441018EA5BDC181D5C8422C162D85A7E2E72706DED98D574DA077AA52
          001B4D44E38AED3B9C4D0BB7F066838137194D3AA3515FAE0028B7E2A9B35FA2
          5494665219219D11F2D964F072F8C7A3987A099F542080DE994A01741400E5A6
          D2F1F56D4667EB838C8EF760B75BB1D63CA65BAFD58310119F94F2AA2C2684F8
          C80D31373D8AE72365855123E82D57BC1222045F86A82FCB5116CD8E05A52F37
          047D08CDA332A8242A819A2E0350F392166F2E7B0142501357D9B8E60E73DC8F
          812B0348A8E21D1033A8495494DEF9ED58F7B21D93D9FDD77A17005B06A02685
          3B329053B53979578C6ABF9A11BA26D339F03703DFF777C33F01D908DEDF9FBE
          2DDF0000000049454E44AE426082}
        Name = 'PngImage1'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000000473424954080808087C0864880000001974455874536F6674776172
          65007777772E696E6B73636170652E6F72679BEE3C1A000004F04944415478DA
          ED966B4C544714C7CFDCB997DD65D95D5EEB527CA011ACA4427C34F6A14D55B4
          491FE907530D0F11699A2AAD469BF8A1493FB58DB569AC11102B2AD5226A9B36
          B12490D804A156852636D2688AD2D4567C2CB0B2C02EECC3DD7B677AEEE5EE0A
          16519B4DEB072FCCCECC99B9F3FFDD33671E84730EFFE7431E033C0678A401BE
          DA60793A393DEB4B4A04BB20D220515FC07F220800025A09C58A0840B12C6099
          0AD84C8129CCE4F7F678FA6F766E641C4E94EC1DE20F0570ECBD29CBE34C961D
          F6E9B919F6D449B69EAE4E551B38FE51D4A6AA184248220555988A0288946212
          34BB403810C773CCD9561D74F53A6F8415BEBF70B767C703011CDB929E973275
          4EDDA2D51FA5DDBCD0A8749E6B143CFDDD24D26E499D0E4953E6C0B0B31DB8AF
          1B0CF136B0662C04EE7781D2DF01A2C040A20498940CB6DC35B270698FD8E5F2
          F9BADD812308B17E4280BA8D297393D29F6C585AB26B72D0EB82EBEDDFF38B3F
          3746C5E7E6EF858C9C6560341AC1E3F1C08DDFCFC194AC0560B1DA201008C0AD
          EEABE0AC2F062BF5A2370870C71245240A23AEB312420CBA3DC15D45559E0FC7
          05C0F99E91F4C4AC9665A595198410E8FBE314846E07410ECB9AF3653000334F
          831056C30C807102F10989208742180E14641C06270082DE6E489686C01C1F87
          3506B6A9F3A1ABBE0C981C846BAEE1BE617FE883357BBCFBC600A0F824AB7DFA
          99C5F9DBB2FE3CDFE80B0587CC99B97900CA308CCC3D0AA2A82CCB105618280A
          5AB40014B08D801A7A1CCB5414C12089380D585603558D1AC108BD7F9D872BAD
          876E275A4D865B03FEDE60485EBFF60B6FBD0670687D82C56449FD15BF3E75C8
          7DBD9333253DAFB47C320938F17D36228F907C54F9E16C0C68E26C38DF5C1376
          5E3A7D1203352724330B63EC655C1DADE4C8E6B406C990600F785D9B24537CF6
          E2551F1FB0C45311647F74106DD07F21CC23659C1CD13E0F4E1D7DFFB70157D7
          AB94D2ED8CF115D890A37A200149866BDEB225673FFB5A47CE921287E2EBD55F
          8C0C08D1BA36E8281BE7E3F4FB878D0189B3619C48ACA56EEBFED59F3B37E0B4
          A762833B1A845F6F49DBE698B9705342A243C0B93533253476BDF0E8CFDDC67B
          3C77DA8820610CC961814A4357DA7F30CABEFECC35D5B886C7DB070E97D98AB3
          9F7FA3D673A50562F52467BE081D6DC79B8AAA06574CB80F4400E6BC5050EBBB
          76366600893316C18533DF3415560E3C1840EE92E2DADBDDBFC40CC03AED1968
          FFB1AEA9A0C27D7F80A31B11606969ADD277316600E6F4F970AEE9505341F9AD
          070398B7FCED5AF074C60CC094960B6D8DFB9A0B2A5C791302E0166CA82AB5AE
          5BBEF29DBDA2FF6ACC000CF6A7A0F978E54F6B2B5DAF6335809AD125160550C5
          318BFFACD052BCB2784BB921E48C198094320B4E1CDBD9BAAEAA771556FD6A8A
          406800443D7D505CF5D6F67C4B71FE9B5B779AA13F6600D436131A0E7FD256B2
          BBA700AB3E1DC07FB7078C2AC4BB2F19169414E57F97397B9E155878D43023FD
          C6860CBF473962520F2D0283835ED6F06D75C5E683EE1DBA07BCA8AB8C01D021
          24CCCC07CA1C9FA6D81DAF50D128AAC71D1FE9A79D79B8F9126D97D56E67111D
          F54C54AF419A51DB87712CB52376676CA0AFE772CD4977D9E9CBA19BFAD74745
          C7BD92E920AA474C7A1EA727514F14D413E60E8476626352BF4ABD40A8AE0BE9
          4975790053908F2376DF5BB11E1FA38523790482EBC24C178F42F0912372E2F1
          1FE96BF96380FFE2F91B7FB0A124CF60AFC40000000049454E44AE426082}
        Name = 'PngImage2'
        Background = clWindow
      end>
    Left = 756
    Top = 62
    Bitmap = {}
  end
  object tiProjectOpen: TTimer
    Enabled = False
    Interval = 1
    OnTimer = tiProjectOpenTimer
    Left = 824
    Top = 64
  end
  object tbMRUList: TTBXMRUList
    OnClick = tbMRUListClick
    Prefix = 'MRU'
    Left = 756
    Top = 214
  end
  object spCustomizer: TSpTBXCustomizer
    OnLayoutLoad = spCustomizerLayoutLoad
    OnLayoutSave = spCustomizerLayoutSave
    Left = 792
    Top = 184
  end
  object puCustomerShopsNew: TSpTBXPopupMenu
    Left = 720
    Top = 152
    object puCustomerShopsNewNew: TSpTBXItem
      Options = [tboDefault]
      OnClick = puCustomerShopsNewNewClick
      CaptionW = 'Neuen Stand erstellen ...'
    end
  end
  object puCustomersEdit: TSpTBXPopupMenu
    Images = ilMapEdit
    Left = 688
    Top = 118
    object puCustomersEditEdit: TSpTBXItem
      Options = [tboDefault]
      OnClick = puCustomersEditEditClick
      CaptionW = 'Kunde bearbeiten ...'
    end
    object puCustomersEditDelete: TSpTBXItem
      OnClick = puCustomersEditDeleteClick
      CaptionW = 'Kunde l'#246'schen'
    end
    object puCustomersEditLine1: TSpTBXSeparatorItem
    end
    object puCustomersEditNew: TSpTBXItem
      OnClick = puCustomersEditNewClick
      CaptionW = 'Neuen Kunden erstellen ...'
    end
  end
  object puCustomersNew: TSpTBXPopupMenu
    Left = 688
    Top = 184
    object puCustomersNewNew: TSpTBXItem
      Options = [tboDefault]
      OnClick = puCustomersNewNewClick
      CaptionW = 'Neuen Kunden erstellen ...'
    end
  end
  object puCustomerShopsEdit: TSpTBXPopupMenu
    Left = 688
    Top = 152
    object puCustomerShopsEditEdit: TSpTBXItem
      Options = [tboDefault]
      OnClick = puCustomerShopsEditEditClick
      CaptionW = 'Bearbeiten ...'
    end
    object puCustomerShopsEditJump: TSpTBXItem
      OnClick = puCustomerShopsEditJumpClick
      CaptionW = 'In die Karte springen'
    end
    object puCustomerShopsEditDelete: TSpTBXItem
      CaptionW = 'L'#246'schen'
    end
    object puCustomerShopsEditLine1: TSpTBXSeparatorItem
    end
    object puCustomerShopsEditNew: TSpTBXItem
      CaptionW = 'Neuen Stand erstellen ...'
    end
  end
  object puMapEdit: TSpTBXPopupMenu
    Left = 688
    Top = 216
    object puMapEditEditShop: TSpTBXItem
      MaskOptions = [tboDefault]
      OnClick = puMapEditEditClick
      CaptionW = 'Stand bearbeiten ...'
    end
    object puMapEditEditCust: TSpTBXItem
      OnClick = puMapEditEditClick
      CaptionW = 'Kunde bearbeiten ...'
    end
    object puMapEditDelete: TSpTBXItem
      OnClick = puMapEditDeleteClick
      CaptionW = 'Stand l'#246'schen'
    end
    object puMapEditDeleteBoth: TSpTBXItem
      OnClick = puMapEditDeleteBothClick
      CaptionW = 'Stand und Kunde l'#246'schen'
    end
    object puMapEditLine1: TSpTBXSeparatorItem
    end
    object puMapEditNew: TSpTBXItem
      OnClick = puMapEditNewClick
      CaptionW = 'Neuer Stand ...'
    end
  end
  object puMapNew: TSpTBXPopupMenu
    Left = 720
    Top = 216
    object puMapNewNew: TSpTBXItem
      Options = [tboDefault]
      CaptionW = 'Neuer Stand ...'
    end
  end
end
