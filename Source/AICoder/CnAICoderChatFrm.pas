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

unit CnAICoderChatFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵĶԻ����嵥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7/10/11 + Delphi / C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,ToolWin, ComCtrls, ActnList, Menus, Buttons, Clipbrd,
  CnWizIdeDock, CnChatBox, CnWizShareImages, CnWizOptions, CnAICoderEngine,
  CnAICoderWizard, CnWizConsts, CnEditControlWrapper;

type
  TCnAICoderChatForm = class(TCnIdeDockForm)
    pnlChat: TPanel;
    tlbAICoder: TToolBar;
    actlstAICoder: TActionList;
    actToggleSend: TAction;
    pnlTop: TPanel;
    spl1: TSplitter;
    mmoSelf: TMemo;
    btnMsgSend: TSpeedButton;
    actCopy: TAction;
    btnToggleSend: TToolButton;
    btnOption: TToolButton;
    actHelp: TAction;
    btnHelp: TToolButton;
    actOption: TAction;
    btn1: TToolButton;
    pmChat: TPopupMenu;
    N1: TMenuItem;
    actCopyCode: TAction;
    M1: TMenuItem;
    actClear: TAction;
    btnClear: TToolButton;
    N2: TMenuItem;
    Clear1: TMenuItem;
    actFont: TAction;
    btnFont: TToolButton;
    dlgFont: TFontDialog;
    cbbActiveEngine: TComboBox;
    btn2: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure actToggleSendExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actlstAICoderUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure btnMsgSendClick(Sender: TObject);
    procedure actOptionExecute(Sender: TObject);
    procedure mmoSelfKeyPress(Sender: TObject; var Key: Char);
    procedure actCopyExecute(Sender: TObject);
    procedure pmChatPopup(Sender: TObject);
    procedure actCopyCodeExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure cbbActiveEngineChange(Sender: TObject);
  private
    FChatBox: TCnChatBox;
    FWizard: TCnAICoderWizard;
    FItemUnderMouse: TCnChatItem;
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    procedure UpdateCaption;
    procedure AddMessage(const Msg, AFrom: string; IsMe: Boolean = False);

    property ChatBox: TCnChatBox read FChatBox;
    property Wizard: TCnAICoderWizard read FWizard write FWizard;
  end;

var
  CnAICoderChatForm: TCnAICoderChatForm;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  CnAICoderNetClient, CnAICoderConfig, CnCommon, CnIniStrUtils;

{$R *.DFM}

procedure TCnAICoderChatForm.AddMessage(const Msg, AFrom: string; IsMe: Boolean);
begin
  with FChatBox.Items.AddMessage do
  begin
    Text := Msg;
    if IsMe then
      FromType := cmtMe
    else
    begin
      FromType := cmtYou;
      From := AFrom;
    end;
  end;
end;

procedure TCnAICoderChatForm.FormCreate(Sender: TObject);
const
  BK_COLOR = $71EA9A;
var
  I: Integer;
begin
  FChatBox := TCnChatBox.Create(Self);
  FChatBox.Color := clWhite;
  FChatBox.Parent := pnlChat;
  FChatBox.Align := alClient;
  FChatBox.ColorYou := BK_COLOR;
  FChatBox.ColorMe := BK_COLOR;
  FChatBox.ColorSelection := BK_COLOR;
  FChatBox.ScrollBarVisible := True;
  FChatBox.PopupMenu := pmChat;

  if Trim(CnAIEngineOptionManager.ChatFontStr) <> '' then
  begin
    StringToFont(CnAIEngineOptionManager.ChatFontStr, FChatBox.Font);
    StringToFont(CnAIEngineOptionManager.ChatFontStr, mmoSelf.Font);
  end
  else
  begin
    FChatBox.Font := EditControlWrapper.FontBasic;
    mmoSelf.Font := EditControlWrapper.FontBasic;
  end;

  WizOptions.ResetToolbarWithLargeIcons(tlbAICoder);

  cbbActiveEngine.Items.Clear;
  for I := 0 to CnAIEngineManager.EngineCount - 1 do
    cbbActiveEngine.Items.Add(CnAIEngineManager.Engines[I].EngineName);

  cbbActiveEngine.ItemIndex := CnAIEngineManager.CurrentIndex;
end;

procedure TCnAICoderChatForm.actToggleSendExecute(Sender: TObject);
begin
  pnlTop.Visible := not pnlTop.Visible;
  actToggleSend.Checked := pnlTop.Visible;
end;

procedure TCnAICoderChatForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnAICoderChatForm.GetHelpTopic: string;
begin
  Result := 'CnAICoderWizard';
end;

procedure TCnAICoderChatForm.actlstAICoderUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
//  if Action = actCopyCode then
//    // ѡ������������ ```
//  else if Action = actSend then
//    (Action as TAction).Enabled := mmoSelf.Lines.Text <> '';
end;

procedure TCnAICoderChatForm.btnMsgSendClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  if Trim(mmoSelf.Lines.Text) <> '' then
  begin
    // ��������Ϣ
    Msg := ChatBox.Items.AddMessage;
    Msg.From := CnAIEngineManager.CurrentEngineName;
    Msg.Text := mmoSelf.Lines.Text;
    Msg.FromType := cmtMe;

    // ��������Ϣ
    Msg := CnAICoderChatForm.ChatBox.Items.AddMessage;
    Msg.From := CnAIEngineManager.CurrentEngineName;
    Msg.FromType := cmtYou;
    Msg.Text := '...';

    CnAIEngineManager.CurrentEngine.AskAIEngineForCode(mmoSelf.Lines.Text, Msg,
      artRaw, FWizard.ForCodeAnswer);
    mmoSelf.Lines.Text := '';
  end;
end;

procedure TCnAICoderChatForm.actOptionExecute(Sender: TObject);
begin
  if FWizard <> nil then
    FWizard.Config;
end;

procedure TCnAICoderChatForm.mmoSelfKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnMsgSend.Click;
  end;
end;

procedure TCnAICoderChatForm.UpdateCaption;
const
  SEP = ' - ';
var
  S: string;
  I: Integer;
begin
  S := Caption;
  I := Pos(SEP, S);
  if I > 0 then
    Delete(S, I, MaxInt);

  Caption := S + SEP + CnAIEngineManager.CurrentEngineName;
end;

procedure TCnAICoderChatForm.DoLanguageChanged(Sender: TObject);
begin
  UpdateCaption;
end;

procedure TCnAICoderChatForm.actCopyExecute(Sender: TObject);
begin
  if FItemUnderMouse <> nil then
  begin
    try
      if FItemUnderMouse is TCnChatMessage then
        Clipboard.AsText := TCnChatMessage(FItemUnderMouse).Text;
    except
      ; // ����ʱ��¼������µ� Item����һִ��ʱ���ͷ��ˣ��Ϳ��ܳ��쳣��Ҫץס
    end;
  end;
end;

procedure TCnAICoderChatForm.pmChatPopup(Sender: TObject);
begin
  FItemUnderMouse := FChatBox.GetItemUnderMouse;
  actCopy.Enabled := FItemUnderMouse <> nil;
  actCopyCode.Enabled := FItemUnderMouse <> nil;
end;

procedure TCnAICoderChatForm.actCopyCodeExecute(Sender: TObject);
const
  CODE_BLOCK = '```';
  DELPHI_PREFIX = 'delphi' + #13#10;
var
  S: string;
  I1, I2: Integer;
begin
  if FItemUnderMouse <> nil then
  begin
    try
      if FItemUnderMouse is TCnChatMessage then
      begin
        S := TCnChatMessage(FItemUnderMouse).Text;
        I1 := Pos(CODE_BLOCK, S);
        if I1 > 0 then
        begin
          Delete(S, 1, I1 + Length(CODE_BLOCK) - 1);
          I2 := Pos(CODE_BLOCK, S);
          if I2 > 0 then
          begin
            S := Copy(S, 1, I2 - 1);
            I2 := Pos(DELPHI_PREFIX, LowerCase(S)); // ȥ����һ�� ``` ��� delphi
            if I2 = 1 then
              Delete(S, 1, Length(DELPHI_PREFIX));

            Clipboard.AsText := Trim(S);
            Exit;
          end;
        end;

        ErrorDlg(SCnAICoderWizardErrorNoCode);
      end;
    except
      ; // ����ʱ��¼������µ� Item����һִ��ʱ���ͷ��ˣ��Ϳ��ܳ��쳣��Ҫץס
    end;
  end;
end;

procedure TCnAICoderChatForm.actClearExecute(Sender: TObject);
begin
  FChatBox.Items.ClearNoWaiting;
end;

procedure TCnAICoderChatForm.actFontExecute(Sender: TObject);
begin
  dlgFont.Font := mmoSelf.Font;
  if dlgFont.Execute then
  begin
    mmoSelf.Font := dlgFont.Font;
    FChatBox.Font := dlgFont.Font;
    CnAIEngineOptionManager.ChatFontStr := FontToString(dlgFont.Font);
  end;
end;

procedure TCnAICoderChatForm.cbbActiveEngineChange(Sender: TObject);
begin
  CnAIEngineOptionManager.ActiveEngine := cbbActiveEngine.Text;
  CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
