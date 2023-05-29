{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
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

unit CnPropertyCompConfigFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack ר�Ұ�
* ��Ԫ���ƣ�������ԶԱ����ô��嵥Ԫ
* ��Ԫ���ߣ���Х��LiuXiao�� liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5
* ���ݲ��ԣ�δ����
* �� �� �����ô����е��ַ����ݲ����ϱ��ػ�����ʽ
* �޸ļ�¼��2021.08.08
*               ������Ԫ��ʵ�ֻ�������
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnWizMultiLang;

type
  TCnPropertyCompConfigForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgc1: TPageControl;
    tsProperty: TTabSheet;
    chkSameType: TCheckBox;
    lblAll: TLabel;
    mmoIgnoreProperties: TMemo;
    chkShowMenu: TCheckBox;
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

var
  CnPropertyCompConfigForm: TCnPropertyCompConfigForm;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

{$R *.DFM}

{ TCnPropertyCompConfigForm }

function TCnPropertyCompConfigForm.GetHelpTopic: string;
begin
  Result := 'CnAlignSizeConfig';
end;

procedure TCnPropertyCompConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}
end.
