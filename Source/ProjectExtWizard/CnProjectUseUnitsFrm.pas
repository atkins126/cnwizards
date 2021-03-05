{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
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

unit CnProjectUseUnitsFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������鵥Ԫ�б�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע��
* ����ƽ̨��PWinXPPro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2018.03.29 V1.1
*               �ع���֧��ģ��ƥ��
*           2007.04.01 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, Contnrs,
{$IFDEF COMPILER6_UP}
  StrUtils,
{$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics,  ActnList, ImgList, CnCommon, CnConsts, CnWizConsts, CnWizOptions,
  CnWizUtils, CnIni, CnWizIdeUtils, CnWizMultiLang, CnProjectViewBaseFrm,
  CnProjectViewUnitsFrm, CnWizEditFiler, CnProjectExtWizard, CnWizClasses,
  CnWizManager,CnProjectViewFormsFrm, CnInputSymbolList, CnStrings;

type
  TCnUseUnitInfo = class(TCnBaseElementInfo)
  public
    FullNameWithPath: string; // ��·���������ļ���
    IsInProject: Boolean;
    IsOpened: Boolean;
    IsSaved: Boolean;
    ImageIndex: Integer;
  end;

//==============================================================================
// ������ use ��Ԫ�б���
//==============================================================================

{ TCnProjectUseUnitsForm }

  TCnProjectUseUnitsForm = class(TCnProjectViewBaseForm)
    rbIntf: TRadioButton;
    rbImpl: TRadioButton;
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure rbIntfKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbImplKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbIntfDblClick(Sender: TObject);
    procedure cbbProjectListChange(Sender: TObject);
  private
    FIsCppMode: Boolean;
    FUnitNameListRef: TUnitNameList;
    procedure FillUnitInfo(AInfo: TCnUseUnitInfo);
    function SearchPasInsertPos(IsIntf: Boolean; out HasUses: Boolean;
      out CharPos: TOTACharPos): Boolean;
    function SearchCppInsertPos(IsH: Boolean; out CharPos: TOTACharPos;
      SourceEditor: IOTASourceEditor = nil): Boolean;
  protected
    function DoSelectOpenedItem: string; override;
    procedure DoSelectItemChanged(Sender: TObject); override;
    function GetSelectedFileName: string; override;
    procedure UpdateStatusBar; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;

    procedure UpdateComboBox; override;
    procedure DrawListPreParam(Item: TListItem; ListCanvas: TCanvas); override;
    
    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; override;
    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; override;
  public
    constructor Create(AOwner: TComponent; CppMode: Boolean;
      UnitNameList: TUnitNameList); reintroduce;

    procedure InternalCreateList;
    property IsCppMode: Boolean read FIsCppMode write FIsCppMode;
    property UnitNameListRef: TUnitNameList read FUnitNameListRef write FUnitNameListRef;
  end;

// UnitNameList �����ⲿ���룬����ÿ�δ� Form ʱ���ع���
function ShowProjectUseUnits(Ini: TCustomIniFile; out Hooked: Boolean;
  var UnitNameList: TUnitNameList): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} CnPasWideLex, CnBCBWideTokenList,
  mPasLex, mwBCBTokenList, CnPasCodeParser, CnCppCodeParser;

const
  SProject = 'Project';
  csUseUnits = 'UseUnitsAndHdr';

  UseUnitHelpContext = 3135;
  // ViewDialog �� UseUnit ������ʱ�� HelpContext

{ TCnUseUnitInfo }

function ShowProjectUseUnits(Ini: TCustomIniFile; out Hooked: Boolean;
  var UnitNameList: TUnitNameList): Boolean;
var
  IsCppMode: Boolean;
  OldCursor: TCursor;
begin
  if CurrentSourceIsC then
  begin
    IsCppMode := True;
    if UnitNameList = nil then
    begin
      OldCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
      try
        UnitNameList := TUnitNameList.Create(True, True, False);
      finally
        Screen.Cursor := OldCursor;
      end;
    end;
  end
  else
  begin
    IsCppMode := False;
    if UnitNameList = nil then
    begin
      OldCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
      try
        UnitNameList := TUnitNameList.Create(True, False, False);
      finally
        Screen.Cursor := OldCursor;
      end;
    end;
  end;

  with TCnProjectUseUnitsForm.Create(nil, IsCppMode, UnitNameList) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csUseUnits);
      InternalCreateList;

      Result := ShowModal = mrOk;
      Hooked := actHookIDE.Checked;
      SaveSettings(Ini, csUseUnits);
      UnitNameListRef := nil;
    finally
      Free;
    end;
  end;
end;

//==============================================================================
// ������ uses �б���
//==============================================================================

{ TCnProjectUseUnitsForm }

constructor TCnProjectUseUnitsForm.Create(AOwner: TComponent; CppMode: Boolean;
  UnitNameList: TUnitNameList);
begin
  FIsCppMode := CppMode;
  FUnitNameListRef := UnitNameList;
  inherited Create(AOwner);
end;

function TCnProjectUseUnitsForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
end;

function TCnProjectUseUnitsForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(TCnUseUnitInfo(lvList.ItemFocused.Data).FullNameWithPath);
end;

function TCnProjectUseUnitsForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtUseUnits';
end;

procedure TCnProjectUseUnitsForm.FillUnitInfo(AInfo: TCnUseUnitInfo);
begin
  AInfo.IsOpened := CnOtaIsFileOpen(AInfo.FullNameWithPath);
  AInfo.IsSaved := FileExists(AInfo.FullNameWithPath);

  AInfo.ImageIndex := 78; // Unit Icon
end;

procedure TCnProjectUseUnitsForm.OpenSelect;
var
  CharPos: TOTACharPos;
  Info: TCnUseUnitInfo;
  IsIntfOrH: Boolean;
  IsFromSystem: Boolean;
  EditView: IOTAEditView;
  SrcEditor: IOTASourceEditor;
  HasUses: Boolean;
  LinearPos: LongInt;
  Sl: TStrings;
  F: string;
  J: Integer;

  // ����Դ�����͵õ������ uses �� include �ַ�����FileHasUses ֻ�� Pascal ����
  // ��Ч��IsHFromSystem ֻ�� Cpp �ļ���Ч
  function JoinUsesOrInclude(FileHasUses: Boolean; IsHFromSystem: Boolean;
    const IncFiles: TStrings): string;
  var
    I: Integer;
  begin
    Result := '';
    if (IncFiles = nil) or (IncFiles.Count = 0) then
      Exit;

    if FIsCppMode then
    begin
      for I := 0 to IncFiles.Count - 1 do
      begin
        if IsHFromSystem then
          Result := Result + Format('#include <%s>' + #13#10, [IncFiles[I]])
        else
          Result := Result + Format('#include "%s"' + #13#10, [IncFiles[I]]);
      end;
    end
    else
    begin
      if FileHasUses then
      begin
        for I := 0 to IncFiles.Count - 1 do
          Result := Result + ', ' + IncFiles[I];
      end
      else
      begin
        Result := #13#10#13#10 + 'uses' + #13#10 + Spc(CnOtaGetBlockIndent) + IncFiles[0];
        for I := 1 to IncFiles.Count - 1 do
          Result := Result + ', ' + IncFiles[I];
        Result := Result + ';';
      end;
    end;
  end;

begin
  if lvList.SelCount > 0 then
  begin
    ModalResult := mrOk;
    Sl := TStringList.Create;
    for J := 0 to lvList.Items.Count - 1 do
      if lvList.Items[J].Selected then
        Sl.Add(lvList.Items[J].Caption);

    IsIntfOrH := rbIntf.Checked;
    EditView := CnOtaGetTopMostEditView;
    if EditView = nil then
      Exit;

    if FIsCppMode then
    begin
      // ��ȡ Cpp �� H �� EditView �� SourceEditor
      F := EditView.Buffer.FileName;
      SrcEditor := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, F);

      if IsIntfOrH and not (IsH(F) or IsHpp(F)) then
      begin
        F := _CnChangeFileExt(F, '.h');
        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        SrcEditor := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, F);
      end
      else if not IsIntfOrH and not IsCpp(F) then
      begin
        F := _CnChangeFileExt(f, '.cpp');
        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        SrcEditor := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, F);
      end;

      if (EditView = nil) or (SrcEditor = nil) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsgError('Insert include: No EditView or SourceEditor.');
{$ENDIF}
        Exit;
      end;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('EditView and SourceEditor Got. %s - %s', [EditView.Buffer.FileName,
        SrcEditor.FileName]);
{$ENDIF}

      // ���� include
      if not SearchCppInsertPos(IsIntfOrH, CharPos, SrcEditor) then
      begin
        ErrorDlg(SCnProjExtUsesNoCppPosition);
        Exit;
      end;

      Info := TCnUseUnitInfo(lvList.Selected.Data);
      if Info <> nil then
        IsFromSystem := not Info.IsInProject
      else
        IsFromSystem := False;

      // �Ѿ��õ��� 1 �� 0 ��ʼ�� CharPos���� EditView.CharPosToPos(CharPos) ת��Ϊ����;
      LinearPos := EditView.CharPosToPos(CharPos);
      CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(HasUses, IsFromSystem, Sl),
        LinearPos, SrcEditor);
    end
    else
    begin
      // Pascal ֻ��Ҫʹ�õ�ǰ�ļ��� EditView ���� uses�����ô����� uses �����
      if not SearchPasInsertPos(IsIntfOrH, HasUses, CharPos) then
      begin
        ErrorDlg(SCnProjExtUsesNoPasPosition);
        Exit;
      end;

      // �Ѿ��õ��� 1 �� 0 ��ʼ�� CharPos���� EditView.CharPosToPos(CharPos) ת��Ϊ����;
      LinearPos := EditView.CharPosToPos(CharPos);
      CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(HasUses, False, Sl), LinearPos);
    end;
  end;
end;

procedure TCnProjectUseUnitsForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  Item: TListItem;
begin
  Item := lvList.ItemFocused;
  if Assigned(Item) then
  begin
    if FileExists(TCnUseUnitInfo(Item.Data).FullNameWithPath) then
      DrawCompactPath(StatusBar.Canvas.Handle, Rect, TCnUseUnitInfo(Item.Data).FullNameWithPath)
    else
      DrawCompactPath(StatusBar.Canvas.Handle, Rect,
        TCnUseUnitInfo(Item.Data).FullNameWithPath + SCnProjExtNotSave);

    StatusBar.Hint := TCnUseUnitInfo(Item.Data).FullNameWithPath;
  end;
end;

procedure TCnProjectUseUnitsForm.InternalCreateList;
var
  I, Idx: Integer;
  Stream: TMemoryStream;
  UsesList: TStringList;
  Names: TStringList;
  Paths: TStringList;
  Info: TCnUseUnitInfo;
begin
  Names := nil;
  Paths := nil;
  UsesList := nil;
  Stream := nil;

  if FIsCppMode then
  begin
    rbIntf.Caption := SCnProjExtCppHead;
    rbImpl.Caption := SCnProjExtCppSource;
  end
  else
  begin
    rbIntf.Caption := SCnProjExtPasIntf;
    rbImpl.Caption := SCnProjExtPasImpl;
  end;

  try
    ClearDataList;

    Names := TStringList.Create;
    Paths := TStringList.Create;
    UsesList := TStringList.Create;
    Stream := TMemoryStream.Create;

    // ���δѡ��ȫ����������·��
    FUnitNameListRef.DoInternalLoad(cbbProjectList.ItemIndex = 0);
    FUnitNameListRef.ExportToStringList(Names, Paths);

    // ��ʱ�õ������п����õĵ�Ԫ�б�
    CnOtaSaveCurrentEditorToStream(Stream, False);
    if FIsCppMode then
      ParseUnitIncludes(PAnsiChar(Stream.Memory), UsesList)
    else
      ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);

    if not FIsCppMode then // Pascal �� uses �Լ�
    begin
      Idx := Names.IndexOf(_CnChangeFileExt(_CnExtractFileName(CnOtaGetCurrentSourceFile), ''));
      if Idx >= 0 then
      begin
        Names.Delete(Idx);
        Paths.Delete(Idx);
      end;
    end;

    for I := 0 to UsesList.Count - 1 do
    begin
      Idx := Names.IndexOf(UsesList[I]);
      if Idx >= 0 then
      begin
        Names.Delete(Idx);
        Paths.Delete(Idx);
      end;
    end;

    for I := 0 to Names.Count - 1 do
    begin
      Info := TCnUseUnitInfo.Create;
      Info.Text := Names[I];
      Info.FullNameWithPath := Paths[I];
      Info.IsInProject := Integer(Names.Objects[I]) <> 0;
      FillUnitInfo(Info);
      DataList.AddObject(Info.Text, Info);
    end;
  finally
    UsesList.Free;
    Stream.Free;
    Names.Free;
    Paths.Free;
  end;
end;

procedure TCnProjectUseUnitsForm.UpdateComboBox;
begin
  with cbbProjectList do // ǰ�����������ͬ���������ʱ�����û���� ProjectInfo
  begin
    Clear;
    Items.Add(SCnProjExtProjectAll);
    Items.Add(SCnProjExtCurrentProject);
  end;
end;

procedure TCnProjectUseUnitsForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := '';
    Panels[2].Text := Format(SCnProjExtUnitsFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectUseUnitsForm.DrawListPreParam(Item: TListItem; ListCanvas: TCanvas);
begin
  if Assigned(Item) and (Item.Data <> nil) and TCnUseUnitInfo(Item.Data).IsOpened then
    ListCanvas.Font.Color := clGreen;
end;

procedure TCnProjectUseUnitsForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnUseUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnUseUnitInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;

    with Item.SubItems do
    begin
      Add(_CnExtractFileDir(Info.FullNameWithPath));
      if Info.IsInProject then
        Add(SProject)
      else
        Add('');

      if Info.IsSaved then
        Add('')
      else
        Add(SNotSaved);
    end;
    RemoveListViewSubImages(Item);
  end;
end;

function TCnProjectUseUnitsForm.SearchCppInsertPos(IsH: Boolean;
  out CharPos: TOTACharPos; SourceEditor: IOTASourceEditor): Boolean;
var
  Stream: TMemoryStream;
  LastIncLine: Integer;
{$IFDEF UNICODE}
  CParser: TCnBCBWideTokenList;
{$ELSE}
  CParser: TBCBTokenList;
{$ENDIF}
begin
  // �������һ�� include ǰ�档���� include��h �ļ��� cpp ������ͬ��
  Result := False;
  Stream := nil;
  CParser := nil;

  try
    Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
    CParser := TCnBCBWideTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStreamW(SourceEditor, Stream, False);
    CParser.SetOrigin(PWideChar(Stream.Memory), Stream.Size div SizeOf(Char));
{$ELSE}
    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStream(SourceEditor, Stream, False);
    CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
{$ENDIF}

    LastIncLine := -1;
    while CParser.RunID <> ctknull do
    begin
      if CParser.RunID = ctkdirinclude then
      begin
{$IFDEF UNICODE}
        LastIncLine := CParser.LineNumber;
{$ELSE}
        LastIncLine := CParser.RunLineNumber;
{$ENDIF}
      end;
      CParser.NextNonJunk;
    end;

    if LastIncLine >= 0 then
    begin
      Result := True;
      CharPos.Line := LastIncLine + 1; // ���һ�� inc ������
      CharPos.CharIndex := 0;
    end;
  finally
    CParser.Free;
    Stream.Free;
  end;
end;

function TCnProjectUseUnitsForm.SearchPasInsertPos(IsIntf: Boolean; out HasUses: Boolean;
  out CharPos: TOTACharPos): Boolean;
var
  Stream: TMemoryStream;
{$IFDEF UNICODE}
  Lex: TCnPasWideLex;
  LineText: string;
  S: AnsiString;
{$ELSE}
  Lex: TmwPasLex;
  {$IFDEF IDE_STRING_ANSI_UTF8}
  LineText: string;
  S: AnsiString;
  {$ENDIF}
{$ENDIF}
  InIntf: Boolean;
  MeetIntf: Boolean;
  InImpl: Boolean;
  MeetImpl: Boolean;
  IntfLine, ImplLine: Integer;
begin
  Result := False;
  Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
  Lex := TCnPasWideLex.Create;
  CnOtaSaveCurrentEditorToStreamW(Stream, False);
{$ELSE}
  Lex := TmwPasLex.Create;
  CnOtaSaveCurrentEditorToStream(Stream, False);
{$ENDIF}

  InIntf := False;
  InImpl := False;
  MeetIntf := False;
  MeetImpl := False;

  HasUses := False;
  IntfLine := 0;
  ImplLine := 0;

  CharPos.Line := 0;
  CharPos.CharIndex := -1;

  try
{$IFDEF UNICODE}
    Lex.Origin := PWideChar(Stream.Memory);
{$ELSE}
    Lex.Origin := PAnsiChar(Stream.Memory);
{$ENDIF}

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
      tkUses:
        begin
          if (IsIntf and InIntf) or (not IsIntf and InImpl) then
          begin
            HasUses := True; // �������Լ���Ҫ�� uses ��
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // ����λ�þ��ڷֺ�ǰ
              Result := True;
{$IFDEF UNICODE}
              CharPos.Line := Lex.LineNumber;
              CharPos.CharIndex := Lex.TokenPos - Lex.LineStartOffset;

              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));  // ������ Unicode ������� TOTACharPos ΪʲôҲ��Ҫ�� Utf8 ת��
{$ELSE}
              CharPos.Line := Lex.LineNumber + 1;
              CharPos.CharIndex := Lex.TokenPos - Lex.LinePos;
  {$IFDEF IDE_STRING_ANSI_UTF8}
              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));
  {$ENDIF}
{$ENDIF}
              Exit;
            end
            else // uses ���Ҳ��ŷֺţ�����
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
      tkInterface:
        begin
          MeetIntf := True;
          InIntf := True;
          InImpl := False;
{$IFDEF UNICODE}
          IntfLine := Lex.LineNumber;
{$ELSE}
          IntfLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      tkImplementation:
        begin
          MeetImpl := True;
          InIntf := False;
          InImpl := True;
{$IFDEF UNICODE}
          ImplLine := Lex.LineNumber;
{$ELSE}
          ImplLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      end;
      Lex.Next;
    end;

    // ������ϣ����˴���û�� uses ������
    if IsIntf and MeetIntf then    // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      CharPos.Line := IntfLine;
      CharPos.CharIndex := Length('interface');
    end
    else if not IsIntf and MeetImpl then // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      CharPos.Line := ImplLine;
      CharPos.CharIndex := Length('implementation');
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

procedure TCnProjectUseUnitsForm.DoSelectItemChanged(Sender: TObject);
var
  Item: TListItem;
  Info: TCnUseUnitInfo;
begin
  inherited;
  Item := lvList.Selected;
  if Item <> nil then
  begin
    Info := TCnUseUnitInfo(Item.Data);
    if Info <> nil then
    begin
      rbIntf.Checked := not Info.IsInProject; // ϵͳ��Ĭ���� intf / h �ļ��м�
      rbImpl.Checked := Info.IsInProject;
    end;
  end;
end;

procedure TCnProjectUseUnitsForm.rbIntfKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_LEFT then
    edtMatchSearch.SetFocus
  else if Key = VK_RIGHT then
  begin
    rbIntf.Checked := False;
    rbImpl.Checked := True;
    rbImpl.SetFocus;
  end;
end;

procedure TCnProjectUseUnitsForm.rbImplKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_LEFT then
  begin
    rbIntf.Checked := True;
    rbImpl.Checked := False;
    rbIntf.SetFocus;
  end;
end;

procedure TCnProjectUseUnitsForm.edtMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_RIGHT then
  begin
    if edtMatchSearch.SelStart = Length(edtMatchSearch.Text) then
    begin
      if rbIntf.Checked then
      begin
        rbIntf.Checked := False;
        rbImpl.Checked := True;
        rbImpl.SetFocus;
      end
      else
      begin
        rbIntf.Checked := True;
        rbImpl.Checked := False;
        rbIntf.SetFocus;
      end;
    end;
  end;
end;

procedure TCnProjectUseUnitsForm.rbIntfDblClick(Sender: TObject);
begin
  OpenSelect;
end;

procedure TCnProjectUseUnitsForm.CreateList;
begin
  // ���� CreateList �ﴦ�����ڳ����� InternalCreateList �ﴦ��
end;

procedure TCnProjectUseUnitsForm.cbbProjectListChange(Sender: TObject);
var
  Old: TCursor;
begin
  Old := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    InternalCreateList;
  finally
    Screen.Cursor := Old;
  end;
  inherited;
end;

function TCnProjectUseUnitsForm.CanMatchDataByIndex(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean;
var
  Info: TCnUseUnitInfo;
begin
  Result := False;

  // ���޶����̣����̲��������������޳�
  Info := TCnUseUnitInfo(DataList.Objects[DataListIndex]);
  if (ProjectInfoSearch <> nil) and not Info.IsInProject then
    Exit;

  if AMatchStr = '' then
  begin
    Result := True;
    Exit;
  end;

  case AMatchMode of // ����ʱ��Ԫ������ƥ�䣬�����ִ�Сд
    mmStart:
      begin
        Result := (Pos(UpperCase(AMatchStr), UpperCase(DataList[DataListIndex])) = 1);
      end;
    mmAnywhere:
      begin
        Result := (Pos(UpperCase(AMatchStr), UpperCase(DataList[DataListIndex])) > 0);
      end;
    mmFuzzy:
      begin
        Result := FuzzyMatchStr(AMatchStr, DataList[DataListIndex], MatchedIndexes);
      end;
  end;
end;

function TCnProjectUseUnitsForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnUseUnitInfo;
begin
  Info1 := TCnUseUnitInfo(Obj1);
  Info2 := TCnUseUnitInfo(Obj2);

  case ASortIndex of // ��Ϊ����ʱֻ������һ�в���ƥ�䣬�������ʱҪ���ǵ�������ƥ��ʱ��ȫƥ����ǰ
    0:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.Text, Info2.Text, SortDown);
      end;
    1: Result := CompareText(Info1.FullNameWithPath, Info2.FullNameWithPath);
    2: Result := CompareInt(Ord(Info1.IsInProject), Ord(Info2.IsInProject));
    3: Result := CompareInt(Ord(Info1.IsSaved), Ord(Info2.IsSaved));
  else
    Result := 0;
  end;

  if SortDown and (ASortIndex in [1..3]) then
    Result := -Result;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
