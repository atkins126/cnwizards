{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
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

unit CnUsesInitTreeFrm;
{ |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����������������Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin7/10 + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ���֧�ֱ��ػ�������ʽ
* �޸ļ�¼��2021.08.21 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ToolWin, ExtCtrls, ActnList, ToolsAPI,
  CnTree, CnCommon, CnWizMultiLang, CnWizConsts, CnWizUtils, CnWizIdeUtils,
  Menus;

type
  TCnUsesInitTreeForm = class(TCnTranslateForm)
    grpFilter: TGroupBox;
    chkProjectPath: TCheckBox;
    chkSystemPath: TCheckBox;
    grpTree: TGroupBox;
    tvTree: TTreeView;
    pnlTop: TPanel;
    lblProject: TLabel;
    cbbProject: TComboBox;
    tlbUses: TToolBar;
    btnGenerateUsesTree: TToolButton;
    grpInfo: TGroupBox;
    actlstUses: TActionList;
    actGenerateUsesTree: TAction;
    actHelp: TAction;
    actExit: TAction;
    btn1: TToolButton;
    btnHelp: TToolButton;
    btnExit: TToolButton;
    lblSourceFile: TLabel;
    lblDcuFile: TLabel;
    lblSearchType: TLabel;
    lblUsesType: TLabel;
    lblSourceFileText: TLabel;
    lblDcuFileText: TLabel;
    lblSearchTypeText: TLabel;
    lblUsesTypeText: TLabel;
    actExport: TAction;
    actSearch: TAction;
    btnSearch: TToolButton;
    btnExport: TToolButton;
    btn2: TToolButton;
    actOpen: TAction;
    btnOpen: TToolButton;
    actLocateSource: TAction;
    btnLocateSource: TToolButton;
    pmTree: TPopupMenu;
    Open1: TMenuItem;
    OpeninExplorer1: TMenuItem;
    ExportTree1: TMenuItem;
    Search1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    dlgSave: TSaveDialog;
    procedure actGenerateUsesTreeExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkSystemPathClick(Sender: TObject);
    procedure tvTreeChange(Sender: TObject; Node: TTreeNode);
    procedure actExitExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actlstUsesUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actExportExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
  private
    FTree: TCnTree;
    FFileNames: TStringList;
    FLibPaths: TStringList;
    FDcuPath: string;
    FProjectList: TInterfaceList;
    procedure InitProjectList;
    procedure TreeSaveANode(ALeaf: TCnLeaf; ATreeNode: TTreeNode; var Valid: Boolean);
    procedure SearchAUnit(const AFullDcuName, AFullSourceName: string; ProcessedFiles: TStrings;
      UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
    {* �ݹ���ã����������Ҷ�Ӧ dcu ��Դ��� Uses �б������뵽���е� UnitLeaf ���ӽڵ���}
    procedure UpdateTreeView;
    procedure UpdateInfo(Leaf: TCnLeaf);
  public

  end;

implementation

{$R *.DFM}

uses
  CnWizShareImages, CnDCU32;

const
  csDcuExt = '.dcu';
  csSearchTypeStrings: array[Low(TCnModuleSearchType)..High(TCnModuleSearchType)] of PString =
    (nil, @SCnUsesInitTreeSearchInProject, @SCnUsesInitTreeSearchInProjectSearch,
    @SCnUsesInitTreeSearchInSystemSearch);

type
  TCnUsesLeaf = class(TCnLeaf)
  private
    FIsImpl: Boolean;
    FDcuName: string;
    FSearchType: TCnModuleSearchType;
    FSourceName: string;
  public
    property SourceName: string read FSourceName write FSourceName;
    {* Դ�ļ�����·����}
    property DcuName: string read FDcuName write FDcuName;
    {* Dcu �ļ�����·����}
    property SearchType: TCnModuleSearchType read FSearchType write FSearchType;
    {* ������������}
    property IsImpl: Boolean read FIsImpl write FIsImpl;
    {* �����Ƿ��� implementation ����}
  end;

function GetDcuName(const ADcuPath, ASourceFileName: string): string;
begin
  if ADcuPath = '' then
    Result := _CnChangeFileExt(ASourceFileName, csDcuExt)
  else
    Result := _CnChangeFileExt(ADcuPath + _CnExtractFileName(ASourceFileName), csDcuExt);
end;

procedure TCnUsesInitTreeForm.actGenerateUsesTreeExecute(Sender: TObject);
var
  Proj, P: IOTAProject;
  I: Integer;
  ProjDcu, S: string;
begin
  Proj := nil;
  if cbbProject.ItemIndex <= 0 then // ��ǰ����
  begin
    Proj := CnOtaGetCurrentProject;
    if (Proj = nil) or not IsDelphiProject(Proj) then
      Exit;
  end
  else
  begin
    // �ض����ƵĹ���
    for I := 0 to FProjectList.Count - 1 do
    begin
      P := FProjectList[I] as IOTAProject;
      if cbbProject.Items[cbbProject.ItemIndex] = _CnExtractFileName(P.FileName) then
      begin
        Proj := P;
        Break;
      end;
    end;
  end;

  if (Proj = nil) or not IsDelphiProject(Proj) then
    Exit;

  // ���빤��
  if not CompileProject(Proj) then
  begin
    Close;
    ErrorDlg(SCnUsesCleanerCompileFail);
    Exit;
  end;

  FTree.Clear;
  FFileNames.Clear;
  FDcuPath := GetProjectDcuPath(Proj);
  GetLibraryPath(FLibPaths, False);

  (FTree.Root as TCnUsesLeaf).SourceName := CnOtaGetProjectSourceFileName(Proj);;
  (FTree.Root as TCnUsesLeaf).DcuName := ProjDcu;
  (FTree.Root as TCnUsesLeaf).SearchType := mstInProject;
  (FTree.Root as TCnUsesLeaf).IsImpl := False;
  (FTree.Root as TCnUsesLeaf).Text := _CnExtractFileName((FTree.Root as TCnUsesLeaf).SourceName);
  ProjDcu := GetDcuName(FDcuPath, (FTree.Root as TCnUsesLeaf).SourceName);

  Screen.Cursor := crHourGlass;
  try
    SearchAUnit(ProjDcu, FTree.Root.Text, FFileNames, FTree.Root, FTree, Proj);
  finally
    Screen.Cursor := crDefault;
  end;

  UpdateTreeView;
end;

procedure TCnUsesInitTreeForm.FormCreate(Sender: TObject);
begin
  FFileNames := TStringList.Create;
  FLibPaths := TStringList.Create;
  FTree := TCnTree.Create(TCnUsesLeaf);
  FProjectList := TInterfaceList.Create;

  FTree.OnSaveANode := TreeSaveANode;

  InitProjectList;
end;

procedure TCnUsesInitTreeForm.FormDestroy(Sender: TObject);
begin
  FProjectList.Free;
  FTree.Free;
  FLibPaths.Free;
  FFileNames.Free;
end;

procedure TCnUsesInitTreeForm.InitProjectList;
var
  I: Integer;
  Proj: IOTAProject;
{$IFDEF BDS}
  PG: IOTAProjectGroup;
{$ENDIF}
begin
  CnOtaGetProjectList(FProjectList);
  cbbProject.Items.Clear;

  if FProjectList.Count <= 0 then
    Exit;

  for I := 0 to FProjectList.Count - 1 do
  begin
    Proj := IOTAProject(FProjectList[I]);
    if Proj.FileName = '' then
      Continue;

{$IFDEF BDS}
    // BDS ��ProjectGroup Ҳ֧�� Project �ӿڣ������Ҫȥ��
    if Supports(Proj, IOTAProjectGroup, PG) then
      Continue;
{$ENDIF}

    if not IsDelphiProject(Proj) then
      Continue;

    cbbProject.Items.Add(_CnExtractFileName(Proj.FileName));
  end;

  if cbbProject.Items.Count > 0 then
  begin
    cbbProject.Items.Insert(0, SCnProjExtCurrentProject);
    cbbProject.ItemIndex := 0;
  end;
end;

procedure TCnUsesInitTreeForm.SearchAUnit(const AFullDcuName,
  AFullSourceName: string; ProcessedFiles: TStrings; UnitLeaf: TCnLeaf;
  Tree: TCnTree; AProject: IOTAProject);
var
  St: TCnModuleSearchType;
  ASourceFileName, ADcuFileName: string;
  UsesList: TStringList;
  I, J: Integer;
  Leaf: TCnUsesLeaf;
  Info: TCnUnitUsesInfo;
begin
  // ���� DCU ��Դ��õ� intf �� impl �������б����������� UnitLeaf ��ֱ���ӽڵ�
  // �ݹ���ø÷���������ÿ�������б��е����õ�Ԫ��
  if  not FileExists(AFullDcuName) and not FileExists(AFullSourceName) then
    Exit;

  UsesList := TStringList.Create;
  try
    if FileExists(AFullDcuName) then // �� DCU �ͽ��� DCU
    begin
      Info := TCnUnitUsesInfo.Create(AFullDcuName);
      try
        for I := 0 to Info.IntfUsesCount - 1 do
          UsesList.Add(Info.IntfUses[I]);
        for I := 0 to Info.ImplUsesCount - 1 do
          UsesList.AddObject(Info.ImplUses[I], TObject(True));
      finally
        Info.Free;
      end;
    end
    else // �������Դ��
    begin
      ParseUnitUsesFromFileName(AFullSourceName, UsesList);
    end;

    // UsesList ���õ�������������·�������ҵ�Դ�ļ�������� dcu
    for I := 0 to UsesList.Count - 1 do
    begin
      // �ҵ�Դ�ļ�
      ASourceFileName := GetFileNameSearchTypeFromModuleName(UsesList[I], St, AProject);
      if (ASourceFileName = '') or (ProcessedFiles.IndexOf(ASourceFileName) >= 0) then
        Continue;

      // ���ұ����� dcu�������ڹ������Ŀ¼�Ҳ������ϵͳ�� LibraryPath ��
      ADcuFileName := GetDcuName(FDcuPath, ASourceFileName);
      if not FileExists(ADcuFileName) then
      begin
        // ��ϵͳ�Ķ�� LibraryPath ����
        for J := 0 to FLibPaths.Count - 1 do
        begin
          if FileExists(MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt) then
          begin
            ADcuFileName := MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt;
            Break;
          end;
        end;
      end;

      if not FileExists(ADcuFileName) then
        Continue;

      // ASourceFileName ������δ���������½�һ�� Leaf���ҵ�ǰ Leaf ����
      Leaf := Tree.AddChild(UnitLeaf) as TCnUsesLeaf;
      Leaf.Text := _CnExtractFileName(_CnChangeFileExt(ASourceFileName, ''));
      Leaf.SourceName := ASourceFileName;
      Leaf.DcuName := ADcuFileName;
      Leaf.SearchType := St;
      Leaf.IsImpl := UsesList.Objects[I] <> nil;

      ProcessedFiles.Add(ASourceFileName);
      SearchAUnit(ADcuFileName, ASourceFileName, ProcessedFiles, Leaf, Tree, AProject);
    end;
  finally
    UsesList.Free;
  end;
end;

procedure TCnUsesInitTreeForm.UpdateTreeView;
var
  Node: TTreeNode;
  I: Integer;
  Leaf: TCnUsesLeaf;
begin
  tvTree.Items.Clear;
  Node := tvTree.Items.AddObject(nil,
    _CnExtractFileName(_CnChangeFileExt(FTree.Root.Text, '')), FTree.Root);

  FTree.SaveToTreeView(tvTree, Node);

  if chkSystemPath.Checked and chkProjectPath.Checked then
  begin
    if tvTree.Items.Count > 0 then
      tvTree.Items[0].Expand(True);
    Exit;
  end;

  for I := tvTree.Items.Count - 1 downto 0 do
  begin
    Node := tvTree.Items[I];
    Leaf := TCnUsesLeaf(Node.Data);

    if not chkSystemPath.Checked and (Leaf.SearchType = mstSystemSearch) then
      tvTree.Items.Delete(Node)
    else if not chkProjectPath.Checked and (Leaf.SearchType = mstProjectSearch) then
      tvTree.Items.Delete(Node);
  end;

  if tvTree.Items.Count > 0 then
    tvTree.Items[0].Expand(True);
end;

procedure TCnUsesInitTreeForm.chkSystemPathClick(Sender: TObject);
begin
  UpdateTreeView;
end;

procedure TCnUsesInitTreeForm.TreeSaveANode(ALeaf: TCnLeaf;
  ATreeNode: TTreeNode; var Valid: Boolean);
begin
  ATreeNode.Text := ALeaf.Text;
  ATreeNode.Data := ALeaf;
end;

procedure TCnUsesInitTreeForm.tvTreeChange(Sender: TObject;
  Node: TTreeNode);
var
  Leaf: TCnUsesLeaf;
begin
  if Node <> nil then
  begin
    Leaf := TCnUsesLeaf(Node.Data);
    if Leaf <> nil then
      UpdateInfo(Leaf);
  end;
end;

procedure TCnUsesInitTreeForm.UpdateInfo(Leaf: TCnLeaf);
var
  ALeaf: TCnUsesLeaf;
begin
  ALeaf := TCnUsesLeaf(Leaf);

  lblSourceFileText.Caption := ALeaf.SourceName;
  lblDcuFileText.Caption := ALeaf.DcuName;
  if ALeaf.SearchType <> mstInvalid then
    lblSearchTypeText.Caption := csSearchTypeStrings[ALeaf.SearchType]^
  else
    lblSearchTypeText.Caption := SCnUnknownNameResult;

  if ALeaf.IsImpl then
    lblUsesTypeText.Caption := 'implementation'
  else if not IsDpr(ALeaf.SourceName) and not IsDpk(ALeaf.SourceName) then
    lblUsesTypeText.Caption := 'interface'
  else
    lblUsesTypeText.Caption := '';
end;

procedure TCnUsesInitTreeForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TCnUsesInitTreeForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnUsesInitTreeForm.actOpenExecute(Sender: TObject);
var
  Leaf: TCnUsesLeaf;
begin
  if tvTree.Selected <> nil then
  begin
    Leaf := TCnUsesLeaf(tvTree.Selected.Data);
    if (Leaf <> nil) and (Leaf.SourceName <> '') then
      CnOtaOpenFile(Leaf.SourceName);
  end;
end;

procedure TCnUsesInitTreeForm.actlstUsesUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (Action = actOpen) or (Action = actLocateSource) then
    TCustomAction(Action).Enabled := tvTree.Selected <> nil
  else if (Action = actExport) or (Action = actSearch) then
    TCustomAction(Action).Enabled := tvTree.Items.Count > 1
  else if Action = actGenerateUsesTree then
    TCustomAction(Action).Enabled := cbbProject.Items.Count > 0;
end;

procedure TCnUsesInitTreeForm.actExportExecute(Sender: TObject);
var
  I: Integer;
  L: TStringList;
begin
  if dlgSave.Execute then
  begin
    L := TStringList.Create;
    try
      for I := 0 to tvTree.Items.Count - 1 do
      begin
        L.Add(Format('%2.2d:%s%s',[I + 1, StringOfChar(' ', tvTree.Items[I].Level),
          tvTree.Items[I].Text]));
      end;
      L.SaveToFile(dlgSave.FileName);
    finally
      L.Free;
    end;
  end;
end;

procedure TCnUsesInitTreeForm.actSearchExecute(Sender: TObject);
begin
  // Search Content in Tree
end;

end.
