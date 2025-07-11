{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnScript_ToolsAPI_UI_D120A;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ű���չ ToolsAPI.UI ע����
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�� UnitParser v0.7 �Զ����ɵ��ļ��޸Ķ���
* ����ƽ̨��PWin7 + Delphi
* ���ݲ��ԣ�PWin7/10 + Delphi
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.05.01 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;

type
(*----------------------------------------------------------------------------*)
  TPSImport_ToolsAPI_UI = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;


{ compile-time registration functions }
procedure SIRegister_INTAIDEUIServices(CL: TPSPascalCompiler);
procedure SIRegister_INTAIDEUIServices290(CL: TPSPascalCompiler);
procedure SIRegister_ToolsAPI_UI(CL: TPSPascalCompiler);

{ run-time registration functions }

procedure Register;

implementation


uses
   Graphics
  ,Forms
  ,Dialogs
  ,Vcl.TitleBarCtrls
  ,ToolsAPI.UI
  ;


procedure Register;
begin
  RegisterComponents('Pascal Script', [TPSImport_ToolsAPI_UI]);
end;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAIDEUIServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAIDEUIServices290', 'INTAIDEUIServices') do
  with CL.AddInterface(CL.FindInterface('INTAIDEUIServices290'),INTAIDEUIServices, 'INTAIDEUIServices') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAIDEUIServices290(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAIDEUIServices290') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAIDEUIServices290, 'INTAIDEUIServices290') do
  begin
    RegisterMethod('Function GetThemeAwareColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Function GetDarkColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Function GetGenericColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Function GetLightColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Procedure SetupTitleBar( AForm : TCustomForm; ATitleBar : TTitleBarPanel; InsertRootPanel : Boolean)', cdRegister);
    RegisterMethod('Function MessageDlg( const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint) : Integer;', cdRegister);
    RegisterMethod('Function MessageDlg1( const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint; DefaultButton : TMsgDlgBtn) : Integer;', cdRegister);
    RegisterMethod('Function InputBox( const ACaption, APrompt, ADefault : string) : string', cdRegister);
    RegisterMethod('Function InputQuery( const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryFunc : TInputCloseQueryFunc) : Boolean;', cdRegister);
    RegisterMethod('Function InputQuery1( const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryEvent : TInputCloseQueryEvent; Context : TObject) : Boolean;', cdRegister);
    RegisterMethod('Function InputQuery2( const ACaption, APrompt : string; var Value : string) : Boolean;', cdRegister);
    RegisterMethod('Procedure ShowMessage( const Msg : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_ToolsAPI_UI(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TIDEThemeColors', '( itcBlue, itcRed, itcYellow, itcGreen, itcVi'
   +'olet, itcGray, itcOrange )');
  SIRegister_INTAIDEUIServices290(CL);
  SIRegister_INTAIDEUIServices(CL);
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290InputQuery2_P(Self: INTAIDEUIServices290;  const ACaption, APrompt : string; var Value : string) : Boolean;
Begin Result := Self.InputQuery(ACaption, APrompt, Value); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290InputQuery1_P(Self: INTAIDEUIServices290;  const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryEvent : TInputCloseQueryEvent; Context : TObject) : Boolean;
Begin Result := Self.InputQuery(ACaption, APrompts, AValues, CloseQueryEvent, Context); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290InputQuery_P(Self: INTAIDEUIServices290;  const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryFunc : TInputCloseQueryFunc) : Boolean;
Begin Result := Self.InputQuery(ACaption, APrompts, AValues, CloseQueryFunc); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290MessageDlg1_P(Self: INTAIDEUIServices290;  const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint; DefaultButton : TMsgDlgBtn) : Integer;
Begin Result := Self.MessageDlg(Msg, DlgType, Buttons, HelpCtx, DefaultButton); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290MessageDlg_P(Self: INTAIDEUIServices290;  const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint) : Integer;
Begin Result := Self.MessageDlg(Msg, DlgType, Buttons, HelpCtx); END;



{ TPSImport_ToolsAPI_UI }
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_UI.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ToolsAPI_UI(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_UI.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
end;
(*----------------------------------------------------------------------------*)


end.
