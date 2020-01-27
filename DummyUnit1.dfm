object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 235
  ClientWidth = 475
  Color = clSkyBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    475
    235)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 211
    Height = 23
    Caption = 'Dummy Project Version 2'
    Color = clSkyBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 37
    Width = 459
    Height = 163
    Alignment = taCenter
    Anchors = []
    AutoSize = False
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -48
    Font.Name = 'Source Code Variable'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object Button1: TButton
    Left = 392
    Top = 203
    Width = 75
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 392
    Top = 6
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Update'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 344
    Top = 48
  end
end
