unit TestPasCodeDoc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon, ComCtrls, FileCtrl, CnPasCodeDoc, CnPasConvert, CnPascalAST,
  mPasLex;

type
  TFormPasDoc = class(TForm)
    btnExtractFromFile: TButton;
    mmoResult: TMemo;
    dlgOpen1: TOpenDialog;
    btnCombineInterface: TButton;
    dlgSave1: TSaveDialog;
    tvPas: TTreeView;
    btnConvertDirectory: TButton;
    btnCheckParamList: TButton;
    btnGenParamList: TButton;
    procedure btnExtractFromFileClick(Sender: TObject);
    procedure btnCombineInterfaceClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvPasDblClick(Sender: TObject);
    procedure btnConvertDirectoryClick(Sender: TObject);
    procedure btnCheckParamListClick(Sender: TObject);
    procedure btnGenParamListClick(Sender: TObject);
  private
    FDoc: TCnDocUnit;
    FAllFile: TStringList;
    procedure DumpToTreeView(Doc: TCnDocUnit);
    class function TrimComment(const Comment: string): string;
    {* �����˵����ע�ͱ��}
    class function PasCodeToHtml(const Code: string): string;
    {* �� Pascal ������� HTML ��ǣ���Ӧ��ʽ�ⲿԤ����}

    procedure OnProcedureCheck(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
      const CurrentType: string);
    procedure OnProcedureGenerate(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
      const CurrentType: string);
  public
    procedure FileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);


    class procedure DumpDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);
  end;

var
  FormPasDoc: TFormPasDoc;

implementation

{$R *.DFM}

const
  HTML_HEAD_FMT = // ͷ��ָ�� UTF 8���� %s �ǵ�Ԫ��
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' + #13#10 +
    '<html>' + #13#10 +
    '<head>' + #13#10 +
    '<title>%s</title>' + #13#10 +
    '<meta http-equiv="Content-Type" content="text/html; charset=gb2312">' + #13#10 +
    '<link rel="stylesheet" href="style.css" type="text/css">' + #13#10 +
    '</head>' + #13#10 +
    '' + #13#10 +
    '<body>' + #13#10 +
    '<table width="100%%" border="0" cellpadding="4">' + #13#10 +
      '<tr>' + #13#10 +
        '<td class="head" height="16">%s</td>' + #13#10 +
      '</tr>' + #13#10 + 
      '<tr>' + #13#10 +
        '<td bgcolor="#FF9900" height="6"></td>' + #13#10 +
      '</tr>' + #13#10 + 
      '<tr>' + #13#10 +
        '<td height=4></td>' + #13#10 +
      '</tr>' + #13#10 +
      '</table>' + #13#10;

  HTML_TAIL_FMT = // β�����ַ���
    '<p class="text" align="center"><a href="https://www.cnpack.org">(C)��Ȩ���� 2001-2024 CnPack ������</a></p>' + #13#10 +
    '</body>' + #13#10 +
    '</html>';

  HTML_DIRECTORY_LIST_FMT = // Ŀ¼��Ŀ
    '<li><p class="uc" align="left"><a href="%s" target="_content">%s</p></li>';

  HTML_UNIT_FMT = // ��Ԫ˵������ע
    '<table width="100%%" border="0" cellpadding="1">' + #13#10 +
    '<tr><td width=90 valign=top><p class="text"><span class="uc"><b>��Ԫ����</b>��</td><td valign=top><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=90 valign=top><p class="text"><b>��Ԫ˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr></table>' + #13#10;

  HTML_CONST_FMT = // ����˵��
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>����</b>��</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>����</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_TYPE_FMT =  // ����˵��
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>����</b>��</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>����</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_PROCEDURE_FMT = // ����˵��
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>����</b>��</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>����</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_VAR_FMT =   // ����˵��
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>����</b>��</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>����</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_PROP_FMT =   // ����˵��
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>����</b>��</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>����</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>�ɼ�</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_METHOD_FMT = // ����˵��
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>����</b>��</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>����</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>�ɼ�</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

procedure TFormPasDoc.btnExtractFromFileClick(Sender: TObject);
var
  Html: TStringList;
begin
  if dlgOpen1.Execute then
  begin
    FreeAndNil(FDoc);
    FDoc := CnCreateUnitDocFromFileName(dlgOpen1.FileName);
    FDoc.DumpToStrings(mmoResult.Lines);
    DumpToTreeView(FDoc);

    Html := TStringList.Create;
    try
      DumpDocToHtml(FDoc, Html);
      dlgSave1.FileName := ChangeFileExt(dlgOpen1.FileName, '.html');
      if dlgSave1.Execute then
        Html.SaveToFile(dlgSave1.FileName);
    finally
      Html.Free;
    end;
  end;
end;

procedure TFormPasDoc.btnConvertDirectoryClick(Sender: TObject);
var
  Dir, F: string;
  I: Integer;
  Html: TStringList;
begin
  if SelectDirectory('Select a Directory', '', Dir) then
  begin
    FAllFile.Clear;
    Screen.Cursor := crHourGlass;

    try
      FindFile(Dir, '*.pas', FileCallBack);
      FAllFile.Sort;

      // ���ɿ���ļ�
      Html := TStringList.Create;
      try
        Html.Add('<html><frameset cols="280,*">');
        Html.Add('<frame src="directory.html">');
        Html.Add(Format('<frame src="%s" name="_content">', [ChangeFileExt(FAllFile[0], '.html')]));
        Html.SaveToFile(ExtractFileDir(FAllFile[0]) + '\index.html');
      finally
        Html.Free;
      end;

      // ����Ŀ¼�ļ�
      Html := TStringList.Create;
      try
        Html.Add(Format(HTML_HEAD_FMT, ['Ŀ¼', 'Ŀ¼']));
        Html.Add('<ul>');
        for I := 0 to FAllFile.Count - 1 do
        begin
          Dir := ChangeFileExt(ExtractFileName(FAllFile[I]), '');
          F := ChangeFileExt(FAllFile[I], '.html');
          Html.Add(Format(HTML_DIRECTORY_LIST_FMT, [F, Dir]));
        end;
        Html.Add('</ul><hr>');
        Html.Add(HTML_TAIL_FMT);

        Html.SaveToFile(ExtractFileDir(FAllFile[0]) + '\directory.html');
      finally
        Html.Free;
      end;

      // ����ÿ����Ԫ�İ����ļ�
      for I := 0 to FAllFile.Count - 1 do
      begin
        FreeAndNil(FDoc);
        try
          FDoc := CnCreateUnitDocFromFileName(FAllFile[I]);
        except
          on E: Exception do
            ShowMessage(FAllFile[I] + ' ' + E.Message);
        end;

        Html := TStringList.Create;
        try
          DumpDocToHtml(FDoc, Html);
          F := ChangeFileExt(FAllFile[I], '.html');
          Html.SaveToFile(F);
        finally
          Html.Free;
        end;
      end;


      // ���������ļ�
    finally
      Screen.Cursor := crDefault;
    end;

    ShowMessage('Convert OK');
  end;
end;

procedure TFormPasDoc.btnCombineInterfaceClick(Sender: TObject);
var
  I, J, ImplIdx: Integer;
  Dir: string;
  FIntf, F: TStringList;
begin
  if not GetDirectory('Select a Pascal Directory', Dir, False) then
    Exit;

  FAllFile.Clear;
  FindFile(Dir, '*.pas', FileCallBack);

  mmoResult.Lines.Clear;
  mmoResult.Lines.AddStrings(FAllFile);

  F := nil;
  FIntf := nil;
  try
    FIntf := TStringList.Create;
    F := TStringList.Create;
    for I := 0 to FAllFile.Count - 1 do
    begin
      F.Clear;
      F.LoadFromFile(FAllFile[I]);

      ImplIdx := 0;
      for J := 0 to F.Count - 1 do
      begin
        if Trim(F[J]) = 'implementation' then
        begin
          ImplIdx := J;
          Break;
        end;
      end;

      // 0 �� ImplIdx - 1 �����ݣ���ɾ�� ImplIdx ��β
      for J := F.Count - 1 downto ImplIdx do
        F.Delete(F.Count - 1);

      FIntf.AddStrings(F);
      FIntf.Add('{*************************************************************}');
      FIntf.Add('');
    end;

    if dlgSave1.Execute then
      FIntf.SaveToFile(dlgSave1.FileName);
  finally
    F.Free;
    FIntf.Free;
  end;
end;

procedure TFormPasDoc.FormCreate(Sender: TObject);
begin
  FAllFile := TStringList.Create;
end;

procedure TFormPasDoc.FormDestroy(Sender: TObject);
begin
  FAllFile.Free;
  FDoc.Free;
end;

procedure TFormPasDoc.FileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  FAllFile.Add(FileName);
end;

procedure TFormPasDoc.DumpToTreeView(Doc: TCnDocUnit);
var
  Root: TTreeNode;

  // �������Ѵ����� ParentItem �����Ӧ�� ParentNode�������̴������ӽڵ�
  procedure AddSubs(ParentNode: TTreeNode; ParentItem: TCnDocBaseItem);
  var
    I: Integer;
    Node: TTreeNode;
  begin
    // ����ֵ
    ParentNode.Data := ParentItem;

    // ���ӽڵ�
    for I := 0 to ParentItem.Count - 1 do
    begin
      Node := tvPas.Items.AddChild(ParentNode, ParentItem[I].DeclareName);
      AddSubs(Node, ParentItem[I]);
    end;
  end;

begin
  tvPas.Items.Clear;

  Root := tvPas.Items.Add(nil, Doc.DeclareName);
  Root.Data := Doc;
  AddSubs(Root, Doc);

  tvPas.FullExpand;
end;

procedure TFormPasDoc.tvPasDblClick(Sender: TObject);
var
  Item: TCnDocBaseItem;
begin
  if tvPas.Selected <> nil then
  begin
    Item := TCnDocBaseItem(tvPas.Selected.Data);
    if Item <> nil then
      ShowMessage(Item.DeclareType + #13#10 + Item.Comment);
  end;
end;

class procedure TFormPasDoc.DumpDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);
var
  I, J: Integer;
  S: string;
  Item, Sub: TCnDocBaseItem;
begin
  if (Doc = nil) or (HtmlStrings = nil) then
    Exit;

  S := Format(HTML_HEAD_FMT, [Doc.DeclareName + '.pas', Doc.DeclareName + '.pas']);
  HtmlStrings.Add(S);

  S := Format(HTML_UNIT_FMT, [Doc.DeclareType, Doc.Comment]);
  HtmlStrings.Add(S);

  for I := 0 to Doc.Count - 1 do
  begin
    // дÿ������
    Item := Doc.Items[I];
    HtmlStrings.Add('<hr>');
    case Item.DocType of
      dtType: // �����ڲ�������������
        begin
          S := Format(HTML_TYPE_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
          if Item.Count > 0 then
          begin
            HtmlStrings.Add('<blockquote>');
            for J := 0 to Item.Count - 1 do
            begin
              Sub := Item.Items[J];
              case Sub.DocType of
                dtProperty:
                  begin
                    HtmlStrings.Add('<hr>');
                    S := Format(HTML_PROP_FMT, [Sub.DeclareName, PasCodeToHtml(Sub.DeclareType), Sub.GetScopeStr, TrimComment(Sub.Comment)]);
                    HtmlStrings.Add(S);
                  end;
                dtProcedure:
                  begin
                    HtmlStrings.Add('<hr>');
                    S := Format(HTML_METHOD_FMT, [Sub.DeclareName, PasCodeToHtml(Sub.DeclareType), Sub.GetScopeStr, TrimComment(Sub.Comment)]);
                    HtmlStrings.Add(S);
                  end;
              end;
            end;
            HtmlStrings.Add('</blockquote>');
          end;
        end;
      dtConst:
        begin
          S := Format(HTML_CONST_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
      dtProcedure:
        begin
          S := Format(HTML_PROCEDURE_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
      dtVar:
        begin
          S := Format(HTML_VAR_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
    else
      ;
    end;
  end;

  HtmlStrings.Add('<hr>');
  HtmlStrings.Add(HTML_TAIL_FMT);
end;

class function TFormPasDoc.PasCodeToHtml(const Code: string): string;
var
  Conv: TCnSourceToHtmlConversion;
  InStream, OutStream: TMemoryStream;
  S: AnsiString;
begin
  Result := '';
  if Length(Code) = 0 then
    Exit;

  Conv := nil;
  InStream := nil;
  OutStream := nil;

  try
    InStream := TMemoryStream.Create;
    InStream.Write(Code[1], Length(Code) * SizeOf(Char));

    Conv := TCnSourceToHtmlConversion.Create;
    Conv.InStream := InStream;

    OutStream := TMemoryStream.Create;
    Conv.OutStream := OutStream;
    Conv.SourceType := stPas;

    Conv.Convert(False);
    SetLength(S, OutStream.Size);
    OutStream.Position := 0;
    OutStream.Read(S[1], OutStream.Size);

    Result := StringReplace(S, '&nbsp;', ' ', [rfIgnoreCase, rfReplaceAll]); // �Ȳ����� UTF8 �����
  finally
    OutStream.Free;
    InStream.Free;
    Conv.Free;
  end;
end;

class function TFormPasDoc.TrimComment(const Comment: string): string;
begin
  Result := Comment;
  if Pos('{* ', Result) = 1 then
    Delete(Result, 1, 3);
  if Pos('}', Result) = Length(Result) then
    Delete(Result, Length(Result), 1);
end;

procedure TFormPasDoc.btnCheckParamListClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoResult.Lines.Clear;
    CnScanFileProcDecls(dlgOpen1.FileName, OnProcedureCheck);
  end;
end;

{
function
  <FunctionName>
  FormalParameters
    (
      FormalParam
        IdentList
          A
          ,
          B
        :
        CommonType
          TypeID
            Int64
      ;
      FormalParam
      ...
      FormalParam
      ...
    )
  :
  COMMONTYPE
    TypeID
      Boolean
}
procedure TFormPasDoc.OnProcedureCheck(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
  const CurrentType: string);
var
  L1, L2, L3: TCnPasAstLeaf;
  J, K: Integer;
begin
  if ProcLeaf.Count < 2 then
    Exit;

  L1 := ProcLeaf[1]; // formalparameters
  if L1.Count > 0 then
  begin
    L2 := L1[0];       // (
    for J := 0 to L2.Count - 1 do
    begin
      K := 0;
      if L2[J].Count = 0 then // ���������ڷָ������ķֺ�
        Continue;

      if L2[J][K].NodeType <> cntIdentList then
        Inc(K);
      L3 := L2[J][K];  // identlist
      if L3.Count > 1 then // �ҳ�һ���������������ͬ���Ͳ�����
      begin
        if CurrentType <> '' then
          mmoResult.Lines.Add(CurrentType + '.' + ProcLeaf[0].Text)
        else
          mmoResult.Lines.Add(ProcLeaf[0].Text);
      end;
    end;
  end;
end;

procedure TFormPasDoc.OnProcedureGenerate(ProcLeaf: TCnPasAstLeaf;
  Visibility: TCnDocScope; const CurrentType: string);
var
  L1, L2: TCnPasAstLeaf;
  J, I: Integer;
  S1, S2: string;
begin
  if ProcLeaf.Count < 2 then
    Exit;

  if CurrentType <> '' then
    mmoResult.Lines.Add(CurrentType + '.' + ProcLeaf[0].Text)
  else
    mmoResult.Lines.Add(ProcLeaf[0].Text);

  L1 := ProcLeaf[1]; // formalparameters
  if L1.Count > 0 then
  begin
    L2 := L1[0];       // (
    for J := 0 to L2.Count - 1 do // �� ( Ҳ���� L2 ������ÿһ�� FormalParams
    begin
      if (L2[J].Count = 0) or (L2[J].NodeType <> cntFormalParam) then // ���������ڷָ������ķֺ�
        Continue;

      // L2[J] �� FormalParam�������������ճ�һ��
      S1 := '';
      S2 := '';
      for I := 0 to L2[J].Count - 1 do
      begin
        if L2[J][I].NodeType = cntIdentList then
          S1 := L2[J][I].GetPascalCode;
        if L2[J][I].NodeType = cntCommonType then
          S2 := L2[J][I].GetPascalCode
      end;

      if (S1 <> '') and (S2 <> '') then
        mmoResult.Lines.Add(Format('  %s: %s', [S1, S2]));
    end;
  end;
end;

procedure TFormPasDoc.btnGenParamListClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoResult.Lines.Clear;
    CnScanFileProcDecls(dlgOpen1.FileName, OnProcedureGenerate);
  end;
end;

end.
