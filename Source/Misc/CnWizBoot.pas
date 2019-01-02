{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2019 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizBoot;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家引导工具
* 单元作者：何清（QSoft）  qsoft@cnpack.org
* 备    注：现在用户可以在启动Delphi时按下左Shift来启动该工具，用于临时禁用/启动
*           专家。
*
* 开发平台：PWin2000Pro + Delphi 5.62
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.10.03 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, ComCtrls, StdCtrls, Buttons, ToolWin, CnWizConsts, CnWizOptions;

type
  TCnWizBootForm = class(TCnTranslateForm)
    lvWizardsList: TListView;
    ToolBar1: TToolBar;
    tbnSelectAll: TToolButton;
    tbnUnSelect: TToolButton;
    tbnReverseSelect: TToolButton;
    tbtnOK: TToolButton;
    ToolButton5: TToolButton;
    tbtnCancel: TToolButton;
    stbStatusbar: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure tbtnOKClick(Sender: TObject);
    procedure tbtnCancelClick(Sender: TObject);
    procedure tbnSelectAllClick(Sender: TObject);
    procedure tbnUnSelectClick(Sender: TObject);
    procedure tbnReverseSelectClick(Sender: TObject);
    procedure lvWizardsListClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure UpdateStatusBar;
  public
    { Public declarations }
    procedure GetBootList(var ABoots: array of boolean);
  end;

implementation

uses CnWizClasses, CnWizManager;

{$R *.DFM}

procedure TCnWizBootForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to GetCnWizardClassCount - 1 do
  begin
    with lvWizardsList.Items.Add do
    begin
      Caption := IntToStr(i + 1); 
      SubItems.Add(TCnWizardClass(GetCnWizardClassByIndex(i)).WizardName);
      SubItems.Add(TCnWizardClass(GetCnWizardClassByIndex(i)).GetIDStr);
      SubItems.Add(GetCnWizardTypeNameFromClass(TCnWizardClass(GetCnWizardClassByIndex(i))));
      Checked := WizOptions.ReadBool(SCnBootLoadSection,
        TCnWizardClass(GetCnWizardClassByIndex(i)).ClassName,
        CnWizardMgr.WizardCanCreate[TCnWizardClass(GetCnWizardClassByIndex(i)).ClassName]);
    end;
  end;
  UpdateStatusBar;
end;

procedure TCnWizBootForm.UpdateStatusBar;
var
  i, count: integer;
begin
  count := 0;
  for i := 0 to lvWizardsList.Items.Count - 1 do
  begin
    if lvWizardsList.Items[i].Checked then
      Inc(count);
  end;
  
  stbStatusbar.Panels[1].Text := Format(SCnWizBootCurrentCount, [lvWizardsList.Items.Count]);
  stbStatusbar.Panels[2].Text := Format(SCnWizBootEnabledCount, [count]);
end;

procedure TCnWizBootForm.GetBootList(var ABoots: array of boolean);
var
  i: integer;
begin
  for i := 0 to lvWizardsList.Items.Count - 1 do
  begin
    ABoots[i] := lvWizardsList.Items[i].Checked;
  end;
end;

procedure TCnWizBootForm.tbtnOKClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to GetCnWizardClassCount - 1 do
  begin
    WizOptions.WriteBool(SCnBootLoadSection,
      TCnWizardClass(GetCnWizardClassByIndex(i)).ClassName,
      lvWizardsList.Items[i].Checked);
  end;
  ModalResult := mrOK;
end;

procedure TCnWizBootForm.tbtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCnWizBootForm.tbnSelectAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to lvWizardsList.Items.Count - 1 do
  begin
    lvWizardsList.Items[i].Checked := True;
  end;
  UpdateStatusBar;
end;

procedure TCnWizBootForm.tbnUnSelectClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to lvWizardsList.Items.Count - 1 do
  begin
    lvWizardsList.Items[i].Checked := False;
  end;
  UpdateStatusBar;
end;

procedure TCnWizBootForm.tbnReverseSelectClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to lvWizardsList.Items.Count - 1 do
  begin
    lvWizardsList.Items[i].Checked := not lvWizardsList.Items[i].Checked;
  end;  
  UpdateStatusBar;
end;

procedure TCnWizBootForm.lvWizardsListClick(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TCnWizBootForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    tbtnCancelClick(Nil);
end;

end.

