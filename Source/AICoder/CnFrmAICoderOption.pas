{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
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

unit CnFrmAICoderOption;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ѡ�� Frame ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7/10/11 + Delphi + C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.09 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon, CnWizMultiLangFrame;

type
  TCnAICoderOptionFrame = class(TCnTranslateFrame)
    lblURL: TLabel;
    lblAPIKey: TLabel;
    edtURL: TEdit;
    edtAPIKey: TEdit;
    lblModel: TLabel;
    lblApply: TLabel;
    cbbModel: TComboBox;
    procedure lblApplyClick(Sender: TObject);
  private
    FWebAddr: string;
  public
    constructor Create(AOwner: TComponent); override;
    property WebAddr: string read FWebAddr write FWebAddr;
  end;

implementation

{$R *.DFM}

constructor TCnAICoderOptionFrame.Create(AOwner: TComponent);
begin
  inherited;
  lblApply.Font.Color := clBlue;
  lblApply.Font.Style := [fsUnderline];
end;

procedure TCnAICoderOptionFrame.lblApplyClick(Sender: TObject);
begin
  if FWebAddr <> '' then
    OpenUrl(FWebAddr);
end;

end.
