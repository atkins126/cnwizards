{*******************************************************}
{                                                       }
{       Pascal Script Source File                       }
{       Run by RemObjects Pascal Script in CnWizards    }
{                                                       }
{       Generated by CnPack IDE Wizards                 }
{                                                       }
{*******************************************************}

program ProjOption;

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, CnWizUtils, CnWizIdeUtils;

var
  Options: IOTAProjectOptions;
  Strs: TStringList;
  I: Integer;
  Proj: IOTAProject;
begin
  if _SUPPORT_OTA_PROJECT_CONFIGURATION = True then
  begin
    Proj := CnOtaGetCurrentProject();
    if Proj <> nil then
    begin
      // Writeln('FrameworkType: ' + Proj.GetFrameworkType());
      // Writeln('Platform: ' + Proj.GetPlatform());
      // Can NOT Compile when NOT Support PROJECT_CONFIGURATION
    end;
  end;

  Options := CnOtaGetActiveProjectOptions(nil);
  if Options = nil then Exit;
  Strs := TStringList.Create;

  CnOtaGetOptionsNames(Options, Strs, False);
  Writeln('');
  Writeln(Format('Project Options Total %d', [Strs.Count]));

  for I := 0 to Strs.Count - 1 do
  begin
    try
      Writeln(Strs[I] + ': ' + string(Options.GetOptionValue(Strs[I])));
    except
      Writeln(Strs[I] + ': <Can NOT get the value>');
      Continue;
    end;
  end;

  Strs.Free;

  Writeln('');
  Writeln('Output Directory: ' + CnOtaGetProjectOutputDirectory(nil));
end.
