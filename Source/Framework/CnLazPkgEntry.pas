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

unit CnLazPkgEntry;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizard ר�� Lazarus ע����ڵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7Pro + Lazarus 4.0
* ���ݲ��ԣ�PWin9X/2000/XP + Lazarus 4.0
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.06.23 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, LCLType, Forms, Controls, CnWizManager,
  IDEWindowIntf, IDEOptionsIntf, IDEOptEditorIntf, MenuIntf, IDEImagesIntf,
  LazIDEIntf, IDECommands;

procedure Register;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

procedure MenuExecute(Sender: TObject);
begin
{$IFDEF DEBUG}
  //CnDebugger.EvaluateControlUnderPos(Mouse.CursorPos);
  CnDebugger.EvaluateObject(Application.MainForm);
{$ENDIF}
end;

procedure Register;
var
  Catgory: TIDECommandCategory;
  Cmd: TIDECommand;
  SC: TIDEShortCut;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Laz Register Unit');
{$ENDIF}
  SC := IDEShortCut(VK_1, [ssAlt]);
  Catgory := RegisterIDECommandCategory(nil, 'CnPack', 'CnPack Category');
  Cmd := RegisterIDECommand(Catgory, 'Test', 'Test Entry', nil, @MenuExecute);

  RegisterIDEMenuCommand( mnuTools, 'CnPackTest', 'CnPack Test...', nil, nil, Cmd);

  CnWizardMgr := TCnWizardMgr.Create;
end;

initialization

finalization
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Laz CnLazPkgEntry Finalization');
{$ENDIF}
  CnWizardMgr.Free;

end.
