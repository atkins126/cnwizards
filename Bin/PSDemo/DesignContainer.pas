{******************************************************************************}
{                                                                              }
{                       Pascal Script Source File                              }
{                                                                              }
{             Run by RemObjects Pascal Script in CnPack IDE Wizards            }
{                                                                              }
{                                   Generated by CnPack IDE Wizards            }
{                                                                              }
{******************************************************************************}

program DesignContainer;

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, Buttons, ClipBrd, ComCtrls, ExtCtrls, ComObj, ExtDlgs, IniFiles,
  Menus, Printers, Registry, StdCtrls, TypInfo, ToolsAPI, CnDebug,
  RegExpr, ScriptEvent, CnCommon, CnWizClasses, CnWizUtils, CnWizIdeUtils,
  CnWizShortCut, CnWizOptions;

var
  I: Integer;
  B: Boolean;
begin
  B := False;
  for I := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[I].ClassNameIs('TFormContainerForm') then
    begin
      Screen.Forms[I].Color := clGreen;
      B := True;
    end;
  end;

  if not B then
    ErrorDlg('NO Conainer Form Found.');
end.
 