{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
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

unit CnViewOption;
{ |<PRE>
================================================================================
* �������ƣ�CnDebugViewer
* ��Ԫ���ƣ����ô��嵥Ԫ
* ��Ԫ���ߣ�С����kend�� kending@21cn.com
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�������ʽ
* �޸ļ�¼��2008.01.18
*               Sesame: ���ӱ���������λ��ѡ��
*           2005.01.01
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, CnLangMgr, Spin;

type
  TCnViewerOptionsFrm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    chkMinToTrayIcon: TCheckBox;
    chkCloseToTrayIcon: TCheckBox;
    hkShowFormHotKey: THotKey;
    grpTrayIcon: TGroupBox;
    chkShowTrayIcon: TCheckBox;
    grpCapture: TGroupBox;
    chkCapDebug: TCheckBox;
    lblCapOD: TLabel;
    lblHotKey: TLabel;
    chkMinStart: TCheckBox;
    chkSaveFormPosition: TCheckBox;
    chkUDPMsg: TCheckBox;
    seUDPPort: TSpinEdit;
    lblPort: TLabel;
    dlgFont: TFontDialog;
    btnFont: TButton;
    lblRestart: TLabel;
    chkLocalSession: TCheckBox;
    grp1: TGroupBox;
    mmoWhiteList: TMemo;
    mmoBlackList: TMemo;
    rbWhiteList: TRadioButton;
    rbBlackList: TRadioButton;
    procedure chkShowTrayIconClick(Sender: TObject);
    procedure chkUDPMsgClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
  private
    FFontChanged: Boolean;
    procedure SwitchTrayIconControls(const AShow: Boolean);
  protected
    procedure DoCreate; override;    
  public
    procedure LoadFromOptions;
    procedure SaveToOptions;

    property FontChanged: Boolean read FFontChanged;
  end;

implementation

uses CnViewCore;

{$R *.dfm}

{ TCnViewerOptionsFrm }

procedure TCnViewerOptionsFrm.DoCreate;
begin
  inherited;
  CnLanguageManager.TranslateForm(Self);
end;

procedure TCnViewerOptionsFrm.LoadFromOptions;
begin
  with CnViewerOptions do
  begin
    chkMinStart.Checked := StartMin;
    chkShowTrayIcon.Checked := ShowTrayIcon;
    chkMinToTrayIcon.Checked := MinToTrayIcon;
    chkCloseToTrayIcon.Checked := CloseToTrayIcon;
    chkSaveFormPosition.Checked := SaveFormPosition;
    hkShowFormHotKey.HotKey := MainShortCut;
    chkCapDebug.Checked := not IgnoreODString;
    chkLocalSession.Checked := LocalSession;
    chkUDPMsg.Checked := EnableUDPMsg;
    seUDPPort.Value := UDPPort;
    rbBlackList.Checked := UseBlackList;
    rbWhiteList.Checked := not UseBlackList;
    mmoWhiteList.Lines.CommaText := WhiteList;
    mmoBlackList.Lines.CommaText := BlackList;
    SwitchTrayIconControls(ShowTrayIcon);
    chkUDPMsgClick(nil);

    if DisplayFont = nil then
      dlgFont.Font.Assign(Application.MainForm.Font)
    else
      dlgFont.Font.Assign(DisplayFont);
  end;
  FFontChanged := False;
end;

procedure TCnViewerOptionsFrm.SaveToOptions;
begin
  with CnViewerOptions do
  begin
    StartMin := chkMinStart.Checked;
    ShowTrayIcon := chkShowTrayIcon.Checked;
    MinToTrayIcon := chkMinToTrayIcon.Checked;
    CloseToTrayIcon := chkCloseToTrayIcon.Checked;
    SaveFormPosition := chkSaveFormPosition.Checked;
    MainShortCut := hkShowFormHotKey.HotKey;
    IgnoreODString := not chkCapDebug.Checked;
    LocalSession := chkLocalSession.Checked;
    EnableUDPMsg := chkUDPMsg.Checked;
    UDPPort := seUDPPort.Value;
    UseBlackList := rbBlackList.Checked;
    WhiteList := mmoWhiteList.Lines.CommaText;
    BlackList := mmoBlackList.Lines.CommaText;
    ChangeCount := ChangeCount + 1;

    if FFontChanged then
      DisplayFont := dlgFont.Font;
  end;
end;

procedure TCnViewerOptionsFrm.SwitchTrayIconControls(const AShow: Boolean);
begin
  chkMinToTrayIcon.Enabled := AShow;
  chkCloseToTrayIcon.Enabled := AShow;
end;

procedure TCnViewerOptionsFrm.chkShowTrayIconClick(Sender: TObject);
begin
  SwitchTrayIconControls(chkShowTrayIcon.Checked);
end;

procedure TCnViewerOptionsFrm.chkUDPMsgClick(Sender: TObject);
begin
  seUDPPort.Enabled := chkUDPMsg.Checked;
end;

procedure TCnViewerOptionsFrm.btnFontClick(Sender: TObject);
begin
  if dlgFont.Execute then
    FFontChanged := True;
end;

end.