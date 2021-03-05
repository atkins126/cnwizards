{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnVclToFmxConverter;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizards VCL/FMX ����ת������Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�Ԫ�� Delphi 10.3.1 �� VCL �� FMX Ϊ����ȷ����һЩӳ���ϵ
* ����ƽ̨��PWin7 + Delphi 10.3.1
* ���ݲ��ԣ�XE2 �����ϣ���֧�ָ��Ͱ汾
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2019.04.10 V1.0
*               ������Ԫ��ʵ�ֻ�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Winapi.Windows,
  FMX.Types, FMX.Edit, FMX.ListBox, FMX.ListView, FMX.StdCtrls, FMX.ExtCtrls,
  FMX.TabControl, FMX.Memo, FMX.Dialogs, Vcl.ComCtrls, Vcl.Graphics, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg, FMX.Graphics, Vcl.Controls, System.TypInfo,
  CnFmxUtils, CnVclToFmxMap, CnWizDfmParser;

type
  // === ����ת���� ===

  TCnPositionConverter = class(TCnPropertyConverter)
  {* �� Left/Top ת���� Position ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnSizeConverter = class(TCnPropertyConverter)
  {* �� Width/Height ת���� Size ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnCaptionConverter = class(TCnPropertyConverter)
  {* �� Caption ת���� Text ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnFontConverter = class(TCnPropertyConverter)
  {* �� Font ת���� TextSettings ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnTouchConverter = class(TCnPropertyConverter)
  {* ת�� Touch ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnGeneralConverter = class(TCnPropertyConverter)
  {* ת��һЩ��ͨ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  // === ���ת���� ===

  TCnTreeViewConverter = class(TCnComponentConverter)
  {* �����ת�� TreeView �����ת����}
  private
    class procedure LoadTreeLeafFromStream(Root, Leaf: TCnDfmLeaf; Stream: TStream);
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnImageConverter = class(TCnComponentConverter)
  {* �����ת�� Image �����ת��������Ҫ������ Picture.Data ����}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnGridConverter = class(TCnComponentConverter)
  {* �����ת�� Grid �����ת��������Ҫ������ Options �����Լ���}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnImageListConverter = class(TCnComponentConverter)
  {* �����ת�� ImageList �����ת��������Ҫ������ Bitmap ����}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnToolBarConverter = class(TCnComponentConverter)
  {* �����ת�� ToolBar �����ת��������Ҫ������ Images ���Ը��ڲ��� Button}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

implementation

type
  TVclGraphicAccess = class(Vcl.Graphics.TGraphic);

  TVclImageListAccess = class(Vcl.Controls.TImageList);

// �� [a, b] ���ּ�����ʽ���ַ���ת��Ϊ����� a b ����Ԫ���ַ���
procedure ConvertSetStringToElements(const SetString: string; OutElements: TStringList);
var
  S: string;
begin
  S := SetString;
  if Length(S) <= 2 then
    Exit;

  if S[1] = '[' then
    Delete(S, 1, 1);
  if S[Length(S)] = ']' then
    Delete(S, Length(S), 1);

  S := StringReplace(S, ' ', '', [rfReplaceAll]);
  OutElements.CommaText := S;
end;

// �� a b ���ַ���ļ���Ԫ���ַ�����ϳ� [a, b] ���ּ�����ʽ���ַ���
function ConvertSetElementsToString(InElements: TStrings): string;
var
  I: Integer;
begin
  if (InElements = nil) or (InElements.Count = 0) then
  begin
    Result := '[]';
    Exit;
  end;

  Result := '[' + InElements.CommaText + ']';
  Result := StringReplace(Result, ',', ', ', [rfReplaceAll]);
end;

function SearchPropertyValueAndRemoveFromStrings(List: TStrings; const PropertyName: string): string;
var
  I, P: Integer;
  S: string;
begin
  Result := '';
  S := PropertyName + ' = ';
  for I := List.Count - 1 downto 0 do
  begin
    P := Pos(S, List[I]);
    if P = 1 then
    begin
      Result := Copy(List[I], Length(S) + 1, MaxInt);
      List.Delete(I);
      Exit;
    end;
  end;
end;

{ TCnPositionConverter }

class procedure TCnPositionConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Top');
    OutProperties.Add('Left');
  end;
end;

class procedure TCnPositionConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  X, Y: Integer;
  V, OutClassName: string;
  Cls: TClass;
begin
  OutClassName := CnGetFmxClassFromVclClass(TheClassName);
  if not CnIsSupportFMXControl(OutClassName) then
  begin
    // Ŀ���಻�� FMX.TControl �����ֱ࣬��ʹ��ԭʼ Left/Top������ Position.X/Y
    OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
  end
  else
  begin
    if PropertyName = 'Top' then
    begin
      Y := StrToIntDef(PropertyValue, 0);
      V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Left');
      X := StrToIntDef(V, 0);
    end
    else if PropertyName = 'Left' then
    begin
      X := StrToIntDef(PropertyValue, 0);
      V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Top');
      Y := StrToIntDef(V, 0);
    end
    else
      Exit;

    OutProperties.Add('Position.X = ' + GetFloatStringFromInteger(X));
    OutProperties.Add('Position.Y = ' + GetFloatStringFromInteger(Y));
  end;
end;

{ TCnTextConverter }

class procedure TCnCaptionConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
    OutProperties.Add('Caption');
end;

class procedure TCnCaptionConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
begin
  // FMX TPanel / TToolBar ��Ӧ�� TGridLayout / ToolButton ��Ӧ�� SpeedButton û�� Text ����
  if (PropertyName = 'Caption') and ((TheClassName <> 'TPanel') and
    (TheClassName <> 'TToolBar') and (TheClassName <> 'TToolButton')) then
    OutProperties.Add('Text = ' + PropertyValue);
end;

{ TCnSizeConverter }

class procedure TCnSizeConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Width');
    OutProperties.Add('Height');
  end;
end;

class procedure TCnSizeConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  W, H: Integer;
  V: string;
begin
  if PropertyName = 'Width' then
  begin
    W := StrToIntDef(PropertyValue, 0);
    V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Height');
    H := StrToIntDef(V, 0);
  end
  else if PropertyName = 'Height' then
  begin
    H := StrToIntDef(PropertyValue, 0);
    V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Width');
    W := StrToIntDef(V, 0);
  end
  else
    Exit;

  OutProperties.Add('Size.Width = ' + GetFloatStringFromInteger(W));
  OutProperties.Add('Size.Height = ' + GetFloatStringFromInteger(H));
end;

{ TCnFontConverter }

class procedure TCnFontConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Font.Charset'); // û��
    OutProperties.Add('Font.Color');   // TextSettings.FontColor
    OutProperties.Add('Font.Height');  // TextSettings.Font.Size���Ӹ��������㷨���о�
    OutProperties.Add('Font.Name');    // TextSettings.Font.Family
    OutProperties.Add('Font.Style');   // TextSettings.Font.StyleExt������������ת��������о�
    OutProperties.Add('WordWrap');     // TextSettings.WordWrap
  end;
end;

class procedure TCnFontConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  V, ScreenLogPixels: Integer;
  DC: HDC;
  NewStr: string;
begin
  if PropertyName = 'Font.Charset' then
    // ɶ���������������Ҳ�����Ӧ��
  else if PropertyName = 'Font.Color' then
  begin
    NewStr := CnConvertEnumValue(PropertyValue);
    if Length(NewStr) > 0 then
    begin
      if NewStr[1] in ['A'..'Z'] then // TextSettings �� FontColor ֵ����ɫ����ǰ��Ҫ�� cla
        NewStr := 'cla' + NewStr;
      OutProperties.Add('TextSettings.FontColor = ' + NewStr);
    end;
  end
  else if PropertyName = 'Font.Name' then
    OutProperties.Add('TextSettings.Font.Family = ' + PropertyValue)
  else if PropertyName = 'Font.Height' then
  begin
    // ���� Height ���� Size ��ֵ
    V := StrToIntDef(PropertyValue, -11);
    DC := GetDC(0);
    ScreenLogPixels := GetDeviceCaps(DC, LOGPIXELSY);
    ReleaseDC(0, DC);
    V := -MulDiv(V, 72, ScreenLogPixels);
    OutProperties.Add('TextSettings.Font.Size = ' + GetFloatStringFromInteger(V));
  end
  else if PropertyName = 'Font.Style' then
  begin
    // TODO: ���� StyleExt �Ķ�����ֵ
    OutProperties.Add('TextSettings.Font.StyleExt = ');
  end
  else if PropertyName = 'WordWrap' then
    OutProperties.Add('TextSettings.WordWrap = ' + PropertyValue);
end;

{ TCnTouchConverter }

class procedure TCnTouchConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
    OutProperties.Add('Touch.');
end;

class procedure TCnTouchConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
begin
  if Pos('Touch.', PropertyName) = 1 then
    OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
end;

{ TCnGeneralConverter }

class procedure TCnGeneralConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Action');      // ����������ֵ�������
    OutProperties.Add('Anchors');
    OutProperties.Add('Cancel');
    OutProperties.Add('Cursor');
    OutProperties.Add('DragMode');
    OutProperties.Add('Default');
    OutProperties.Add('DefaultDrawing');
    OutProperties.Add('Enabled');
    OutProperties.Add('GroupIndex');
    OutProperties.Add('HelpContext');
    OutProperties.Add('Hint');
    OutProperties.Add('ImageIndex');
    OutProperties.Add('Images');
    OutProperties.Add('ItemHeight');
    OutProperties.Add('ItemIndex');
    OutProperties.Add('Items.Strings');
    OutProperties.Add('Lines.Strings');
    OutProperties.Add('ModalResult');
    OutProperties.Add('ParentShowHint');
    OutProperties.Add('PopupMenu');
    OutProperties.Add('ReadOnly');
    OutProperties.Add('RowCount');
    OutProperties.Add('ShowHint');
    OutProperties.Add('ShortCut');
    OutProperties.Add('TabStop');
    OutProperties.Add('TabOrder');
    OutProperties.Add('Tag');
    OutProperties.Add('Text');
    OutProperties.Add('Visible');

    OutProperties.Add('ActivePage');   // ������Ҫ��������ֵ�����
    OutProperties.Add('ButtonHeight'); // ToolBar �� ButtonHeight/ButtonWidth
    OutProperties.Add('ButtonWidth');  // Ҫ�ĳ� TGridLayout �� ItemHeight/ItemWidth
    OutProperties.Add('Checked');      // TRadioButton/TCheckBox �� IsChecked
    OutProperties.Add('DefaultRowHeight'); // StringGrid �ĳ� RowHeight
    OutProperties.Add('PageIndex');
    OutProperties.Add('ScrollBars');   // ����������ֵ�����
    OutProperties.Add('TabPosition');  // ����������ĵ�����ֵҪ���
  end;
end;

class procedure TCnGeneralConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  NewPropName: string;
begin
  // FMX �� TComboBox �� Text ���Բ����ڣ�����
  if (TheClassName = 'TComboBox') and (PropertyName = 'Text') then
    Exit;

  if PropertyName = 'ActivePage' then
    NewPropName := 'ActiveTab'
  else if PropertyName = 'PageIndex' then
    NewPropName := 'Index'
  else if (PropertyName = 'Checked') and ((TheClassName = 'TRadioButton') or
    (TheClassName = 'TCheckBox')) then
    NewPropName := 'IsChecked'
  else if (PropertyName = 'DefaultRowHeight') and (TheClassName = 'TStringGrid') then
    NewPropName := 'RowHeight'
  else if (PropertyName = 'ButtonWidth') and (TheClassName = 'TToolBar') then
  begin
    NewPropName := 'ItemWidth'
  end
  else if (PropertyName = 'ButtonHeight') and (TheClassName = 'TToolBar') then
  begin
    NewPropName := 'ItemHeight'
  end
  else if PropertyName = 'ScrollBars' then
  begin
    if PropertyValue = 'ssNone' then
      OutProperties.Add('ShowScrollBars = False')
    else
      OutProperties.Add('ShowScrollBars = True');
    Exit;    // ����ֵ���ˣ�д����˳���������д PropertyValue ��
  end
  else if PropertyName = 'TabPosition' then
  begin
    OutProperties.Add('TabPosition = ' + CnConvertEnumValue(PropertyValue));
    Exit;    // ����ֵ���ˣ�д����˳���������д PropertyValue ��
  end
  else
    NewPropName := PropertyName;

  OutProperties.Add(Format('%s = %s', [NewPropName, PropertyValue]));
end;

{ TCnTreeViewConverter }

class procedure TCnTreeViewConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TTreeView');
end;

class procedure TCnTreeViewConverter.LoadTreeLeafFromStream(Root, Leaf: TCnDfmLeaf;
  Stream: TStream);
var
  I, Size: Integer;
  ALeaf: TCnDfmLeaf;
  Info: TNodeInfo;
begin
  Stream.ReadBuffer(Size, SizeOf(Size));
  Stream.ReadBuffer(Info, Size);

  // �� Info �������� Leaf �� Properties ��
  Leaf.ElementKind := dkObject;
  Leaf.ElementClass := 'TTreeViewItem';
  Leaf.Text := 'TTreeViewItem' + IntToStr(Leaf.Tree.GetSameClassIndex(Leaf) + 1);
  Leaf.Properties.Add('Text = ' + ConvertWideStringToDfmString(Info.Text));
  Leaf.Properties.Add('ImageIndex = ' + IntToStr(Info.ImageIndex));

  // �ݹ���������ӽڵ�
  for I := 0 to Info.Count - 1 do
  begin
    ALeaf := Leaf.Tree.AddChild(Leaf) as TCnDfmLeaf;
    LoadTreeLeafFromStream(Root, ALeaf, Stream);
  end;
end;

class procedure TCnTreeViewConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I, Count: Integer;
  Stream: TStream;
  Leaf: TCnDfmLeaf;
begin
  // ���� SourceLeaf �е� Items.Data ���������ݣ�����ת�����ӿؼ���ӵ���Ӧ DestLeaf ��
  I := IndexOfHead('Items.Data = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    if SourceLeaf.Properties.Objects[I] <> nil then
    begin
      // �� Stream �ж���ڵ���Ϣ
      Stream := TStream(SourceLeaf.Properties.Objects[I]);
      Stream.Position := 0;
      Stream.ReadBuffer(Count, SizeOf(Count));
      for I := 0 to Count - 1 do
      begin
        // �� DestLeaf ���һ���ӽڵ㣬��������ӽڵ������
        Leaf := DestLeaf.Tree.AddChild(DestLeaf) as TCnDfmLeaf;
        LoadTreeLeafFromStream(DestLeaf, Leaf, Stream);
      end;
    end;
  end;
end;

{ TCnImageConverter }

function LoadGraphicFromDfmBinStream(Stream: TStream): Vcl.Graphics.TGraphic;
var
  ClzName: ShortString;
  Clz: Vcl.Graphics.TGraphicClass;
begin
  Result := nil;
  if (Stream = nil) or (Stream.Size <= 0) then
    Exit;

  Stream.Read(ClzName[0], 1);
  Stream.Read(ClzName[1], Ord(ClzName[0]));

  Clz := Vcl.Graphics.TGraphicClass(FindClass(ClzName));
  if Clz <> nil then
  begin
    Result := Vcl.Graphics.TGraphic(Clz.NewInstance);
    Result.Create;
    TVclGraphicAccess(Result).ReadData(Stream);
  end;
end;

class procedure TCnImageConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TImage');
end;

class procedure TCnImageConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I: Integer;
  Stream: TStream;
  TmpStream: TMemoryStream;
  AGraphic: Vcl.Graphics.TGraphic;
  FmxBitmap: FMX.Graphics.TBitmap;
begin
  I := IndexOfHead('Picture.Data = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    if SourceLeaf.Properties.Objects[I] <> nil then
    begin
      // �� Stream �ж��� Bitmap ��Ϣ
      Stream := TStream(SourceLeaf.Properties.Objects[I]);
      Stream.Position := 0;

      AGraphic := nil;
      FmxBitmap := nil;
      TmpStream := nil;

      try
        AGraphic := LoadGraphicFromDfmBinStream(Stream);

        if (AGraphic <> nil) and not AGraphic.Empty then
        begin
          TmpStream := TMemoryStream.Create;
          AGraphic.SaveToStream(TmpStream);

          FmxBitmap := FMX.Graphics.TBitmap.Create;
          FmxBitmap.LoadFromStream(TmpStream);
          TmpStream.Clear;
          FmxBitmap.SaveToStream(TmpStream);

          // TmpStream ���Ѿ��� PNG �ĸ�ʽ�ˣ�д�� Bitmap.PNG ��Ϣ
          TmpStream.Position := 0;
          DestLeaf.Properties.Add('Bitmap.PNG = {' +
            ConvertStreamToHexDfmString(TmpStream) + '}');
        end;
      finally
        AGraphic.Free;
        FmxBitmap.Free;
        TmpStream.Free;
      end;
    end;
  end;
end;

{ TCnGridConverter }

class procedure TCnGridConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TStringGrid');
end;

class procedure TCnGridConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I, Count: Integer;
  OptionString, Value: string;
  Options: TStringList;
  Leaf: TCnDfmLeaf;
begin
  I := IndexOfHead('Options = ', SourceLeaf.Properties);
  if I >= 0 then
    OptionString := SourceLeaf.Properties[I]
  else // Ĭ������
    OptionString := '[goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect]';

  Delete(OptionString, 1, Length('Options = '));
  Options := TStringList.Create;
  try
    ConvertSetStringToElements(OptionString, Options);

    // ת������Ԫ�أ������ڶ�Ӧ��ϵ����ɾ��
    for I := Options.Count - 1 downto 0 do
    begin
      OptionString := CnConvertEnumValueIfExists(Options[I]);
      if OptionString <> '' then
        Options[I] := OptionString
      else
        Options.Delete(I);
    end;

    OptionString := ConvertSetElementsToString(Options);
    DestLeaf.Properties.Add('Options = ' + OptionString);
  finally
    Options.Free;
  end;

  I := IndexOfHead('ColCount = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    Value := SourceLeaf.Properties[I];
    Delete(Value, 1, Length('ColCount = '));

    Count := StrToIntDef(Value ,0);
    if Count > 0 then
    begin
      for I := 1 to Count do
      begin
        // �� DestLeaf ���һ���ӽڵ㣬û��������
        Leaf := DestLeaf.Tree.AddChild(DestLeaf) as TCnDfmLeaf;
        Leaf.ElementClass := 'TStringColumn';
        Leaf.ElementKind := dkObject;
        Leaf.Text := 'StringColumn' + IntToStr(Leaf.Tree.GetSameClassIndex(Leaf) + 1);
      end;
    end;
  end;
end;

{ TCnImageListConverter }

class procedure TCnImageListConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TImageList');
end;

class procedure TCnImageListConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I: Integer;
  Stream: TStream;
  ImageList: TImageList;
  ImgStr: string;
  TmpStream: TMemoryStream;
  VclBitmap: Vcl.Graphics.TBitmap;
  FmxBitmap: FMX.Graphics.TBitmap;

  procedure TrySetPropertyToImageList(const PropName: string);
  var
    Idx: Integer;
  begin
    Idx := IndexOfHead(PropName + ' = ', SourceLeaf.Properties);
    if Idx >= 0 then
    begin
      Idx := GetIntPropertyValue(SourceLeaf.Properties[Idx], PropName);
      SetOrdProp(ImageList, PropName, Idx);
    end;
  end;

begin
  I := IndexOfHead('Bitmap = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    if SourceLeaf.Properties.Objects[I] <> nil then
    begin
      // �� Stream �ж��� Bitmap ��Ϣ
      Stream := TStream(SourceLeaf.Properties.Objects[I]);
      Stream.Position := 0;

      ImageList := TImageList.Create(nil);
      try
        TrySetPropertyToImageList('Height');
        TrySetPropertyToImageList('Width');
        TrySetPropertyToImageList('AllocBy');

        TVclImageListAccess(ImageList).ReadData(Stream);

      // TODO: �� ImageList �а������⻭
      // д   Source = <
      // ѭ��д item
      //          MultiResBitmap.LoadSize = 0
      //          MultiResBitmap = <
      //            item
      //              Scale = 1.000000000000000000
      //              Width = 16
      //              Height = 16
      //              PNG = {
      //              }
      //              FileName = '\\VBOXSVR\Downloads\delphi5_setup\delphi.ico'
      //            end>
      //          Name = 'delphi'
      //        end
      // ����ѭ��д >

        if ImageList.Count > 0 then
        begin
          // д Source
          ImgStr := 'Source = <' + #13#10;
          for I := 0 to ImageList.Count - 1 do
          begin
            ImgStr := ImgStr + StringOfChar(' ', 2) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'MultiResBitmap.LoadSize = 0' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'MultiResBitmap = < ' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Scale = 1.000000000000000000' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Width = ' + IntToStr(ImageList.Width) + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Height = ' + IntToStr(ImageList.Height) + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'PNG = {';

            VclBitmap := nil;
            TmpStream := nil;
            FmxBitmap := nil;
            try
              VclBitmap := Vcl.Graphics.TBitmap.Create;
              VclBitmap.Width := ImageList.Width;
              VclBitmap.Height := ImageList.Height;
              ImageList.Draw(VclBitmap.Canvas, 0, 0, I, True);

              TmpStream := TMemoryStream.Create;
              VclBitmap.SaveToStream(TmpStream);
              TmpStream.Position := 0;
              FmxBitmap := Fmx.Graphics.TBitmap.Create;
              FmxBitmap.LoadFromStream(TmpStream);
              TmpStream.Clear;
              FmxBitmap.SaveToStream(TmpStream);

              TmpStream.Position := 0;
              ImgStr := ImgStr + ConvertStreamToHexDfmString(TmpStream, 10) + '}' + #13#10;
            finally
              VclBitmap.Free;
              FmxBitmap.Free;
              TmpStream.Free;
            end;

            // ImgStr := ImgStr + StringOfChar(' ', 8) + 'FileName = ''''' + #13#10; û���ļ���
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'end>' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'Name = ''Item ' + IntToStr(I) + ''''#13#10;

            // ��������һͼ����β
            if I = ImageList.Count - 1 then
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end>' + #13#10
            else
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end' + #13#10;
          end;

          // д Destination
          ImgStr := ImgStr + 'Destination = <' + #13#10;
          for I := 0 to ImageList.Count - 1 do
          begin
            ImgStr := ImgStr + StringOfChar(' ', 2) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'Layers = <' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Name = ''Item ' + IntToStr(I) + ''''#13#10;
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'end>' + #13#10;

            // ��������һͼ����β
            if I = ImageList.Count - 1 then
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end>'
            else
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end' + #13#10;
          end;

          DestLeaf.Properties.Add(ImgStr);
        end;
      finally
        ImageList.Free;
      end;
    end;
  end;
end;

{ TCnToolBarConverter }

class procedure TCnToolBarConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TToolBar');
end;

class procedure TCnToolBarConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I: Integer;
  S: string;
  Leaf: TCnDfmLeaf;
begin
  I := IndexOfHead('Images = ', DestLeaf.Properties);
  if I >= 0 then
  begin
    S := DestLeaf.Properties[I];
    Delete(S, 1, Length('Images = '));
    DestLeaf.Properties.Delete(I);

    for I := 0 to DestLeaf.Count - 1 do
    begin
      if IndexOfHead('Images = ', DestLeaf.Items[I].Properties) < 0 then
        DestLeaf.Items[I].Properties.Add('Images = ' + S);
    end;
  end;
end;

initialization
  RegisterCnPropertyConverter(TCnPositionConverter);
  RegisterCnPropertyConverter(TCnSizeConverter);
  RegisterCnPropertyConverter(TCnCaptionConverter);
  RegisterCnPropertyConverter(TCnFontConverter);
  RegisterCnPropertyConverter(TCnTouchConverter);
  RegisterCnPropertyConverter(TCnGeneralConverter);

  RegisterCnComponentConverter(TCnTreeViewConverter);
  RegisterCnComponentConverter(TCnImageConverter);
  RegisterCnComponentConverter(TCnGridConverter);
  RegisterCnComponentConverter(TCnImageListConverter);
  RegisterCnComponentConverter(TCnToolBarConverter);

  RegisterClasses([TIcon, TBitmap, TMetafile, TWICImage, TJpegImage, TGifImage, TPngImage]);

end.
