{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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

unit CnSampleComponent;
{ |<PRE>
================================================================================
* ������ƣ�CnPack ר�Ұ�
* ��Ԫ���ƣ�ʾ�������Ԫ
* ��Ԫ���ߣ���Х��LiuXiao�� liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5
* ���ݲ��ԣ�δ����
* �� �� �����ô����е��ַ����ݲ����ϱ��ػ�����ʽ
* �޸ļ�¼��2021.08.07
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TCnDynIntArray = array of Integer;

  TCnSampleComponent = class(TComponent)
  private
    FHint: AnsiString;
    FAccChar: Char;
    FFloatValue: Double;
    FInt64Value: Int64;
    FHeight: Integer;
    FIntfValue: IUnknown;
    FCaption: string;
    FDynArray: TCnDynIntArray;
    FAnchorKind: TAnchorKind;
    FAnchors: TAnchors;
    FParent: TControl;
    FArrayValue: TKeyboardState;
    FOnClick: TNotifyEvent;
    FVarValue: Variant;
    FWideAccChar: WideChar;
    FWideHint: WideString;
    FPoint: TPoint;
{$IFDEF UNICODE}
    FUniStr: string;
{$ENDIF}
    FReadOnlyHint: AnsiString;
    FReadOnlyAccChar: Char;
    FReadOnlyFloatValue: Double;
    FReadOnlyInt64Value: Int64;
    FReadOnlyHeight: Integer;
    FReadOnlyIntfValue: IUnknown;
    FReadOnlyCaption: string;
    FReadOnlyDynArray: TCnDynIntArray;
    FReadOnlyAnchorKind: TAnchorKind;
    FReadOnlyAnchors: TAnchors;
    FReadOnlyParent: TControl;
    FReadOnlyArrayValue: TKeyboardState;
    FReadOnlyOnClick: TNotifyEvent;
    FReadOnlyVarValue: Variant;
    FReadOnlyWideAccChar: WideChar;
    FReadOnlyWideHint: WideString;
    FReadOnlyPoint: TPoint;
    FReadOnlyFont: TFont;
{$IFDEF UNICODE}
    FReadOnlyUniStr: string;
{$ENDIF}
  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ArrayValue: TKeyboardState read FArrayValue write FArrayValue;
    property DynArray: TCnDynIntArray read FDynArray write FDynArray;
    property ReadOnlyArrayValue: TKeyboardState read FReadOnlyArrayValue;
    property ReadOnlyDynArray: TCnDynIntArray read FReadOnlyDynArray;

  published
{   ���Ժ��ǣ�
    tkInteger, tkChar, tkEnumeration, tkFloat,
    tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString,
    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray,
    tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
}

    property Height: Integer read FHeight write FHeight;
    property AccChar: Char read FAccChar write FAccChar;
    property AnchorKind: TAnchorKind read FAnchorKind write FAnchorKind;
    property FloatValue: Double read FFloatValue write FFloatValue;
    property Caption: string read FCaption write FCaption;
    property Anchors: TAnchors read FAnchors write FAnchors;
    property Parent: TControl read FParent write FParent;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property WideAccChar: WideChar read FWideAccChar write FWideAccChar;
    property Hint: AnsiString read FHint write FHint;
    property WideHint: WideString read FWideHint write FWideHint;
    property VarValue: Variant read FVarValue write FVarValue;
    property Point: TPoint read FPoint write FPoint;
    property IntfValue: IUnknown read FIntfValue write FIntfValue;
    property Int64Value: Int64 read FInt64Value write FInt64Value;
{$IFDEF UNICODE}
    property UniStr: string read FUniStr write FUniStr;
{$ENDIF}

    property ReadOnlyHeight: Integer read FReadOnlyHeight;
    property ReadOnlyAccChar: Char read FReadOnlyAccChar;
    property ReadOnlyAnchorKind: TAnchorKind read FReadOnlyAnchorKind;
    property ReadOnlyFloatValue: Double read FReadOnlyFloatValue;
    property ReadOnlyCaption: string read FReadOnlyCaption;
    property ReadOnlyAnchors: TAnchors read FReadOnlyAnchors;
    property ReadOnlyParent: TControl read FReadOnlyParent;
    property ReadOnlyOnClick: TNotifyEvent read FReadOnlyOnClick;
    property ReadOnlyWideAccChar: WideChar read FReadOnlyWideAccChar;
    property ReadOnlyHint: AnsiString read FReadOnlyHint;
    property ReadOnlyWideHint: WideString read FReadOnlyWideHint;
    property ReadOnlyVarValue: Variant read FReadOnlyVarValue;
    property ReadOnlyPoint: TPoint read FReadOnlyPoint;
    property ReadOnlyIntfValue: IUnknown read FReadOnlyIntfValue;
    property ReadOnlyInt64Value: Int64 read FReadOnlyInt64Value;
    property ReadOnlyFont: TFont read FReadOnlyFont;
{$IFDEF UNICODE}
    property ReadOnlyUniStr: string read FReadOnlyUniStr write FReadOnlyUniStr;
{$ENDIF}
  end;

implementation

{ TCnSampleComponent }

constructor TCnSampleComponent.Create(AOwner: TComponent);
var
  WStr: WideString;
begin
  inherited;
  WStr := '��';

  FHint := 'Ansi Hint';
{$IFDEF UNICODE}
  FAccChar := '��';
{$ELSE}
  FAccChar := 'A';
{$ENDIF}
  FFloatValue := 3.1415926;
  FInt64Value := 9999999988888888;
  FHeight := 80;
  FIntfValue := nil;
  FCaption := 'Caption';

  FAnchorKind := akRight;
  FAnchors := [akLeft, akBottom];
  FParent := nil;

  FArrayValue[0] := 10;

  FOnClick := nil;
  FVarValue := 0;
  FWideAccChar := WStr[1];
  FWideHint := 'Wide Hint';
  FPoint.x := 10;
  FPoint.y := 20;

  FReadOnlyFont := TFont.Create;
end;

destructor TCnSampleComponent.Destroy;
begin
  FReadOnlyFont.Free;
  inherited;
end;

end.
 