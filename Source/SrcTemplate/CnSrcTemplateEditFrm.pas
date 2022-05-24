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

unit CnSrcTemplateEditFrm;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Editor ר�ұ༭���嵥Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���ô��������޸ı༭������
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2002.11.04 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ActnList,
  StdCtrls, ComCtrls, Buttons, CnSrcTemplate, CnWizConsts, CnCommon, CnWizUtils,
  CnWizManager, CnWizMacroText, CnWizOptions, CnWizMultiLang, CnWizMacroUtils;

type
  TCnSrcTemplateEditForm = class(TCnTranslateForm)
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    OpenDialog: TOpenDialog;
    grp1: TGroupBox;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl7: TLabel;
    btnOpen: TSpeedButton;
    edtHint: TEdit;
    HotKey: THotKey;
    cbbInsertPos: TComboBox;
    edtIcon: TEdit;
    chkDisabled: TCheckBox;
    edtCaption: TEdit;
    chkSavePos: TCheckBox;
    grp2: TGroupBox;
    lbl6: TLabel;
    mmoContent: TMemo;
    cbbMacro: TComboBox;
    btnInsert: TButton;
    chkForDelphi: TCheckBox;
    chkForBcb: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FItemIndex: Integer;
  protected
    function GetHelpTopic: string; override;
  public
    property ItemIndex: Integer read FItemIndex write FItemIndex;
    {* �����Ӧ�� EditorItem ������������Ѱ�Ҷ�Ӧ Action}
  end;

function ShowEditorEditForm(EditorItem: TCnEditorItem): Boolean; overload;
{* ��ʾ�༭��ר�ұ༭���壬���ڱ༭����}

function ShowEditorEditForm(var ACaption, AHint, AIconName: string;
  var AShortCut: TShortCut; var AInsertPos: TEditorInsertPos;
  var AEnabled, ASavePos: Boolean; var AContent: string; var AForDelphi,
  AForBcb: Boolean): Boolean; overload;
{* ��ʾ�༭��ר�ұ༭���壬������������}

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}

implementation

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

{$R *.DFM}

function ShowEditorEditForm(EditorItem: TCnEditorItem): Boolean;
begin
  Assert(EditorItem <> nil);
  with TCnSrcTemplateEditForm.Create(nil) do
  try
    ItemIndex := EditorItem.Index;
    ShowHint := WizOptions.ShowHint;
    edtCaption.Text := EditorItem.Caption;
    edtHint.Text := EditorItem.Hint;
    edtIcon.Text := EditorItem.IconName;
    HotKey.HotKey := EditorItem.ShortCut;
    cbbInsertPos.ItemIndex := Ord(EditorItem.InsertPos);
    chkDisabled.Checked := not EditorItem.Enabled;
    chkSavePos.Checked := EditorItem.SavePos;
    mmoContent.Lines.Text := EditorItem.Content;
    chkForDelphi.Checked := EditorItem.ForDelphi;
    chkForBcb.Checked := EditorItem.ForBcb;
    Result := ShowModal = mrOk;
    if Result then
    begin
      EditorItem.Caption := edtCaption.Text;
      EditorItem.Hint := edtHint.Text;
      EditorItem.IconName := edtIcon.Text;
      EditorItem.ShortCut := HotKey.HotKey;
      EditorItem.InsertPos := TEditorInsertPos(cbbInsertPos.ItemIndex);
      EditorItem.Enabled := not chkDisabled.Checked;
      EditorItem.SavePos := chkSavePos.Checked;
      EditorItem.Content := mmoContent.Lines.Text;
      EditorItem.ForDelphi := chkForDelphi.Checked;
      EditorItem.ForBcb := chkForBcb.Checked;
    end;
  finally
    Free;
  end;
end;

function ShowEditorEditForm(var ACaption, AHint, AIconName: string;
  var AShortCut: TShortCut; var AInsertPos: TEditorInsertPos;
  var AEnabled, ASavePos: Boolean; var AContent: string; var AForDelphi,
  AForBcb: Boolean): Boolean; overload;
begin
  with TCnSrcTemplateEditForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    edtCaption.Text := ACaption;
    edtHint.Text := AHint;
    edtIcon.Text := AIconName;
    HotKey.HotKey := AShortCut;
    cbbInsertPos.ItemIndex := Ord(AInsertPos);
    chkDisabled.Checked := not AEnabled;
    chkSavePos.Checked := ASavePos;
    mmoContent.Lines.Text := AContent;
    chkForDelphi.Checked := AForDelphi;
    chkForBcb.Checked := AForBcb;
    Result := ShowModal = mrOk;
    if Result then
    begin
      ACaption := edtCaption.Text;
      AHint := edtHint.Text;
      AIconName := edtIcon.Text;
      AShortCut := HotKey.HotKey;
      AInsertPos := TEditorInsertPos(cbbInsertPos.ItemIndex);
      AEnabled := not chkDisabled.Checked;
      ASavePos := chkSavePos.Checked;
      AContent := mmoContent.Lines.Text;
      AForDelphi := chkForDelphi.Checked;
      AForBcb := chkForBcb.Checked;
    end;
  finally
    Free;
  end;
end;

{ TCnSrcTemplateEditForm }

procedure TCnSrcTemplateEditForm.FormCreate(Sender: TObject);
var
  InsertPos: TEditorInsertPos;
  Macro: TCnWizMacro;
begin
  ItemIndex := -1;
  cbbInsertPos.Clear;
  for InsertPos := Low(InsertPos) to High(InsertPos) do
    cbbInsertPos.Items.Add(csEditorInsertPosDescs[InsertPos]^);
  cbbInsertPos.ItemIndex := 0;
  cbbMacro.Clear;
  for Macro := Low(Macro) to High(Macro) do
    cbbMacro.Items.Add(Format('%s - %s', [GetMacroEx(Macro),
      csCnWizMacroDescs[Macro]^]));
  cbbMacro.ItemIndex := 0;
end;

procedure TCnSrcTemplateEditForm.btnInsertClick(Sender: TObject);
var
  i: Integer;
  Macro: string;
begin
  if cbbMacro.ItemIndex >= 0 then
  begin
    Macro := GetMacro(GetMacroDefText(TCnWizMacro(cbbMacro.ItemIndex)));
    for i := 1 to Length(Macro) do
      mmoContent.Perform(WM_CHAR, Ord(Macro[i]), 0); 
  end;
  mmoContent.SetFocus;
end;

procedure TCnSrcTemplateEditForm.btnOKClick(Sender: TObject);
begin
  if edtCaption.Text = '' then
    ErrorDlg(SCnSrcTemplateCaptionIsEmpty)
  else if mmoContent.Lines.Text = '' then
    ErrorDlg(SCnSrcTemplateContentIsEmpty)
  else
    ModalResult := mrOk;
end;

procedure TCnSrcTemplateEditForm.btnOpenClick(Sender: TObject);
begin
  OpenDialog.FileName := edtIcon.Text;
  if OpenDialog.Execute then
    edtIcon.Text := OpenDialog.FileName;
end;

procedure TCnSrcTemplateEditForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSrcTemplateEditForm.GetHelpTopic: string;
begin
  Result := 'CnSrcTemplate';
end;

procedure TCnSrcTemplateEditForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Wizard: TCnSrcTemplate;
begin
  CanClose := True;
  if ModalResult <> mrOK then
    Exit;

  Wizard := nil;
  if CnWizardMgr.WizardByClass(TCnSrcTemplate) <> nil then
    if CnWizardMgr.WizardByClass(TCnSrcTemplate) is TCnSrcTemplate then
      Wizard := TCnSrcTemplate(CnWizardMgr.WizardByClass(TCnSrcTemplate));

  if Wizard = nil then
    Exit;

  if ItemIndex < 0 then // ��ʾ��ԭʼ Action�����½�����
  begin
    if CheckQueryShortCutDuplicated(HotKey.HotKey, nil) = sdDuplicatedStop then
    begin
      CanClose := False;
      Exit;
    end;
  end
  else
  begin
    if CheckQueryShortCutDuplicated(HotKey.HotKey, // �˵�������ǰ����һ����á����� 1 ��ƫ����
      TCustomAction(Wizard.SubActions[ItemIndex + 1])) = sdDuplicatedStop then
    begin
      CanClose := False;
      Exit;
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}
end.
