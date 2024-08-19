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

unit CnPasCodeDoc;
{* |<PRE>
================================================================================
* ������ƣ�CnPack ������Ԫ
* ��Ԫ���ƣ��� CnPack �Ĵ����г�ȡע���γ��ĵ��Ĺ��ߵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.04.02 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

{$I CnPack.inc}

interface

uses
  Classes, SysUtils, Contnrs;

type
  ECnPasCodeDocException = class(Exception);
  {* ���������ĵ��쳣}

  TCnDocType = (dtUnit, dtConst, dtType, dtProcedure, dtVar, dtField, dtProperty);
  {* ֧���ĵ���Ԫ������}

  TCnDocScope = (dsNone, dsPrivate, dsProtected, dsPublic, dsPublished);
  {* Ԫ�صĿɼ��ԣ��޿ɼ��Ե�Ϊ dsNone}

  TCnDocBaseItem = class(TObject)
  {* �����ĵ�Ԫ�صĻ���}
  private
    FItems: TObjectList;
    FDeclareName: string;
    FDeclareType: string;
    FComment: string;
    FOwner: TCnDocBaseItem;
    FScope: TCnDocScope;
    FDocType: TCnDocType;
    function GetItem(Index: Integer): TCnDocBaseItem;
    procedure SetItem(Index: Integer; const Value: TCnDocBaseItem);
    function GetCount: Integer;
  protected
    procedure Sort; virtual;
    {* �ڲ�����}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddItem(Item: TCnDocBaseItem): Integer;
    {* ���һ���ⲿ�Ѿ������õ��ĵ������ڲ��б�������}
    procedure Exchange(Index1, Index2: Integer);
    {* �����������������Ӷ���}
    procedure Delete(Index: Integer);
    {* ��������ɾ���Ӷ���}
    function Extract(Item: TCnDocBaseItem): TCnDocBaseItem;
    {* ���б��г����Ӷ��󣬵����ͷ���}

    procedure DumpToStrings(Strs: TStrings; Indent: Integer = 0);
    {* �����ݱ��浽�ַ����б���}

    function GetScopeStr: string;
    {* ���� FScope ��Ӧ���ַ���}

    property DocType: TCnDocType read FDocType;
    {* �ĵ�Ԫ������}

    property DeclareName: string read FDeclareName write FDeclareName;
    {* �����͵Ķ������ƣ���ͬ�������в�ͬ�Ĺ涨}
    property DeclareType: string read FDeclareType write FDeclareType;
    {* �����͵Ķ������ͣ���ͬ������Ҳ�в�ͬ����;�������ڴ洢��������}
    property Comment: string read FComment write FComment;
    {* ��Ԫ�ص�ע���ĵ�}
    property Scope: TCnDocScope read FScope write FScope;
    {* ��Ԫ�صĿɼ���}
    property Owner: TCnDocBaseItem read FOwner write FOwner;
    {* ��Ԫ�ش�����һ����Ԫ��}

    property Items[Index: Integer]: TCnDocBaseItem read GetItem write SetItem; default;
    {* ��Ԫ�ص���Ԫ���б�}
    property Count: Integer read GetCount;
    {* ��Ԫ�ص���Ԫ������}
  end;

  TCnDocUnit = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еĵ�Ԫ�Ķ���}
  private
    FUnitBrief: string;
  protected
    procedure Sort; override;
    {* �������������������������̡���������}
  public
    constructor Create; override;

    procedure ParseBrief;
    {* ��ע���н�������Ԫ��飬�Լ��ñ�ע�ֶ������滻 Comment ��������}
    property UnitBrief: string read FUnitBrief write FUnitBrief;
    {* ��Ԫ��飬Ҳ����ע��ͷ���ĵ�Ԫ�����ֶ�����}
  end;

  TCnConstDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еĳ�������}
  public
    constructor Create; override;
  end;

  TCnVarDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еı�������}
  public
    constructor Create; override;
  end;

  TCnProcedureDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��еĺ������̶���}
  public
    constructor Create; override;
  end;

  TCnTypeDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��е����Ͷ���}
  public
    constructor Create; override;
  end;

  TCnPropertyDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��е����Զ���}
  public
    constructor Create; override;
  end;

  TCnFieldDocItem = class(TCnDocBaseItem)
  {* ����һ��������ĵ��е��ֶζ���}
  public
    constructor Create; override;
  end;

function CnCreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
{* ����Դ���ļ��������ڲ��Ĵ���ע�ͣ������´����ĵ�Ԫע�Ͷ������}

implementation

uses
  CnPascalAst, mPasLex;

const
  COMMENT_NODE_TYPE = [cntBlockComment];
  COMMENT_SKIP_NODE_TYPE = [cntBlockComment, cntLineComment];
  COMMENT_NONE = '<none>';

  SCOPE_STRS: array[TCnDocScope] of string =
    ('', 'private', 'protected', 'public', 'published');

// �� ParentLeaf �ĵ� 0 ���ӽڵ㿪ʼԽ��ע���ҷ��ϵĽڵ㣬���ط��ϵĽڵ㣬���������׳��쳣�ҷ��� nil
function DocSkipCommentToChild(ParentLeaf: TCnPasAstLeaf;
  MatchedNodeTypes: TCnPasNodeTypes; NeedRaise: Boolean = True): TCnPasAstLeaf;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ParentLeaf.Count - 1 do
  begin
    if ParentLeaf[I].NodeType in MatchedNodeTypes then
    begin
      Result := ParentLeaf[I];
      Exit;
    end;

    if not (ParentLeaf[I].NodeType in COMMENT_SKIP_NODE_TYPE) then
      if NeedRaise then
        raise ECnPasCodeDocException.Create('Skip Comment To Node Error.');
  end;
end;

// �� ParentLeaf �ĵ� Index ���ӽڵ㿪ʼ�ҷ��ϵĽڵ㣬���ط��ϵĽڵ��Լ����º�� Index���������򷵻� nil��Index ���Ჽ��
function DocSkipToChild(ParentLeaf: TCnPasAstLeaf; var Index: Integer;
  MatchedNodeTypes: TCnPasNodeTypes; MatchedTokenKinds: TTokenKinds): TCnPasAstLeaf;
begin
  Result := nil;
  if Index >= ParentLeaf.Count then
    Exit;

  while Index < ParentLeaf.Count do
  begin
    if (ParentLeaf[Index].NodeType in MatchedNodeTypes) and
      (ParentLeaf[Index].TokenKind in MatchedTokenKinds) then
    begin
      Result := ParentLeaf[Index];
      Exit;
    end;
    Inc(Index);
  end;
end;

// ��� ParentLeaf �ĵ� Index ���ӽڵ��ǷֺŻ� Directive����������ֱ���� Directive �ҷǷֺŵĵط����ٻ���һ
// ����ʱ Index Ӧ��ָ�� Directive ֮ǰ�ķֺ�
procedure DocSkipDirective(ParentLeaf: TCnPasAstLeaf; var Index: Integer);
begin
  Inc(Index);
  while Index < ParentLeaf.Count do
  begin
    if not (ParentLeaf[Index].NodeType in [cntSemiColon, cntDirective, cntDefault]) then
      Break;    // ���ܻ��������������� cntDirective �еĹؼ���

    Inc(Index);
  end;
  Dec(Index);
end;

// �� ParentLeaf �ĵ� Index ���ӽڵ����ռ�ע�Ͳ�ƴһ�顣
// ��� Index ��ע�ʹ����� Index �Ჽ�������һ��ע�ʹ������� Index ��һ
function DocCollectComments(ParentLeaf: TCnPasAstLeaf; var Index: Integer): string;
var
  S: string;
  SL: TStrings;
begin
  if (Index < ParentLeaf.Count) and (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE) then
  begin
    S := ParentLeaf[Index].Text;
    if (Length(S) > 2) and (S[1] = '{') and (S[2] = '*') then
    begin
      // ��ʾ�з���Ҫ���ע�ͣ�������ӵ�һ��
      SL := TStringList.Create;
      try
        repeat
          SL.Add(ParentLeaf[Index].Text);
          Inc(Index);
        until (Index >= ParentLeaf.Count) or not (ParentLeaf[Index].NodeType in COMMENT_NODE_TYPE);
        Dec(Index); // �ص����һ��ע�ʹ�

        Result := Trim(SL.Text);
        Exit;
      finally
        SL.Free;
      end;
    end;
  end;

  Result := '';
  if Index > 0 then
    Dec(Index);
end;

// ���� const �ڵ㣬�����ӽڵ�����һ�����У�CONSTDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
procedure DocFindConsts(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
var
  K: Integer;
  Leaf: TCnPasAstLeaf;
  Item: TCnConstDocItem;
begin
  K := 0;
  while K < ParentLeaf.Count do
  begin
    Leaf := DocSkipToChild(ParentLeaf, K, [cntConstDecl], [tkNone]);
    if Leaf = nil then
    begin
      Inc(K);
      Continue;
    end;
    //  raise ECnPasCodeDocException.Create('NO Const Decl Exists.');

    Item := TCnConstDocItem.Create;
    if Leaf.Count > 0 then
    begin
      Item.DeclareName := Leaf[0].Text; // ������
      Item.DeclareType := Leaf.GetPascalCode; // �ó������������������������ͺ�����������
    end;

    Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Const Semicolon Exists.');

    Inc(K); // ��������һ��������ע�͵ĵط��������ע�ͣ�K ָ��ע��ĩβ��������ǣ�K ���һ�Ե����˴β���
    Item.Comment := DocCollectComments(ParentLeaf, K);
    OwnerItem.AddItem(Item);
    Inc(K);
  end;
end;

// var �����ӽڵ�����һ�����У�VARDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
procedure DocFindVars(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
var
  K: Integer;
  Leaf: TCnPasAstLeaf;
  Item: TCnVarDocItem;
begin
  K := 0;
  while K < ParentLeaf.Count do
  begin
    Leaf := DocSkipToChild(ParentLeaf, K, [cntVarDecl], [tkNone]);
    if Leaf = nil then
    begin
      Inc(K);
      Continue;
    end;
    // raise ECnPasCodeDocException.Create('NO Var Decl Exists.');

    Item := TCnVarDocItem.Create;
    if Leaf.Count > 0 then
    begin
      if Leaf[0].Count > 0 then
        Item.DeclareName := Leaf[0][0].Text; // IDENTList �ĵ�һ��������
      Item.DeclareType := Leaf.GetPascalCode; // ����������
    end;

    Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
    if Leaf = nil then
      raise ECnPasCodeDocException.Create('NO Var Semicolon Exists.');

    Inc(K); // ��������һ��������ע�͵ĵط��������ע�ͣ�K ָ��ע��ĩβ��������ǣ�K ���һ�Ե����˴β���
    Item.Comment := DocCollectComments(ParentLeaf, K);
    OwnerItem.AddItem(Item);
    Inc(K);
  end;
end;

// ��ͬ���ڵ�����һ�飺procedure/function���ӽڵ������ƣ����ֺš�����ע�Ϳ�
// ע������ ParentLeaf �� procedure/function �ڵ㣬Index �Ǹýڵ��ڸ��ڵ��е�����
procedure DocFindProcedure(ParentLeaf: TCnPasAstLeaf; var Index: Integer;
  OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsNone);
var
  K: Integer;
  Leaf, P: TCnPasAstLeaf;
  Item: TCnProcedureDocItem;
begin
  K := 0;
  Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create('NO Procedure/Function Ident Exists.');

  Item := TCnProcedureDocItem.Create;
  Item.DeclareName := Leaf.Text; // ����������
  Item.Scope := AScope;
  Item.DeclareType := ParentLeaf.GetPascalCode; // ��ȡ���������������� Directives

  // ����һ��ȥ�ҷֺ���ע��
  P := ParentLeaf.Parent;
  Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create('NO Procedure/Function Semicolon Exists.');

  // �˴����������ܴ��ڵ� Directives �����һ���ֺ�
  DocSkipDirective(P, Index);

  Inc(Index); // ��������һ��������ע�͵ĵط��������ע�ͣ�Index ָ��ע��ĩβ��������ǣ�Index ���һ�Ե����˴β���
  Item.Comment := DocCollectComments(P, Index);
  OwnerItem.AddItem(Item);
end;

// ����һ�� property��ParentLeaf �� Property �ڵ㣬Index �� ParentLeaf ���丸�ڵ��е�������
// Property �ڵ���沢�зֺź� default �ȣ���������ӽڵ�
procedure DocFindProperty(ParentLeaf: TCnPasAstLeaf; Index: Integer; OwnerItem: TCnDocBaseItem;
  AScope: TCnDocScope = dsNone);
var
  K: Integer;
  Leaf, P: TCnPasAstLeaf;
  Item: TCnPropertyDocItem;
begin
  K := 0;
  Leaf := DocSkipToChild(ParentLeaf, K, [cntIdent], [tkIdentifier]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create('NO Property Ident Exists.');

  Item := TCnPropertyDocItem.Create;
  Item.DeclareName := Leaf.Text;   // ������
  Item.Scope := AScope;
  Item.DeclareType := ParentLeaf.GetPascalCode; // ������������

  // ����һ��ȥ�ҷֺ���ע��
  P := ParentLeaf.Parent;
  Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create('NO Property Semicolon Exists.');

  // �˴����������ܴ��ڵ� Directives �����һ���ֺ�
  DocSkipDirective(P, Index);

  Inc(Index);
  Item.Comment := DocCollectComments(P, Index);
  OwnerItem.AddItem(Item);
end;

// ParentLeaf �� Class �ڵ�� ClassField �ֶνڵ㣬�ռ��䵥�� Field ��ע�͡�Index �� ParentLeaf ���� Parent �е�����
procedure DocFindField(ParentLeaf: TCnPasAstLeaf; Index: Integer; OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsPublic);
var
  Leaf, P: TCnPasAstLeaf;
  Item: TCnFieldDocItem;
begin
  Leaf := nil;
  if (ParentLeaf.Count > 0) and (ParentLeaf[0].Count > 0) then
    Leaf := ParentLeaf[0][0];
  if (Leaf = nil) or (Leaf.NodeType <> cntIdent) then
    raise ECnPasCodeDocException.Create('NO Class Field Ident Exists.');

  Item := TCnFieldDocItem.Create;
  Item.DeclareName := Leaf.Text; // �ֶ���
  Item.Scope := AScope;
  Item.DeclareType := ParentLeaf.GetPascalCode; // �����ֶ�����

  // ����һ��ȥ�ҷֺ���ע��
  P := ParentLeaf.Parent;
  Leaf := DocSkipToChild(P, Index, [cntSemiColon], [tkSemiColon]);
  if Leaf = nil then
    raise ECnPasCodeDocException.Create('NO Class Field Semicolon Exists.');

  Inc(Index); // ��������һ��������ע�͵ĵط��������ע�ͣ�Index ָ��ע��ĩβ��������ǣ�Index ���һ�Ե����˴β���
  Item.Comment := DocCollectComments(P, Index);
  OwnerItem.AddItem(Item);
end;

// record �ڵ���ӽڵ㣬�ռ��� Field ��ע��
procedure DocFindRecordFields(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsPublic);
var
  K: Integer;
  Leaf: TCnPasAstLeaf;
begin
  if ParentLeaf.Count > 0 then
  begin
    ParentLeaf := DocSkipCommentToChild(ParentLeaf, [cntFieldList]); // record �� FieldList

    K := 0;
    while K < ParentLeaf.Count do
    begin
      Leaf := ParentLeaf[K];
      if Leaf.NodeType = cntFieldDecl then
        DocFindField(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end;
  end;
end;

// ���� interface �� class �ĳ�Ա����������/���̡�Field�����Եȡ�ParentLeaf �� ClassBody �� interface
procedure DocFindMembers(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem; AScope: TCnDocScope = dsNone);
var
  K: Integer;
  Leaf: TCnPasAstLeaf;
  MyScope: TCnDocScope;
begin
  K := 0;
  while K < ParentLeaf.Count do
  begin
    Leaf := ParentLeaf[K];
    if Leaf.NodeType in [cntProcedure, cntFunction] then
    begin
      DocFindProcedure(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end
    else if Leaf.NodeType = cntProperty then
    begin
      DocFindProperty(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end
    else if Leaf.NodeType = cntClassField then
    begin
      DocFindField(Leaf, K, OwnerItem, AScope);
      Inc(K);
    end
    else if (Leaf.NodeType = cntVisibility) and (Leaf.TokenKind in [tkProtected, tkPublic, tkPublished]) then
    begin
      case Leaf.TokenKind of
        tkProtected: MyScope := dsProtected;
        tkPublic:    MyScope := dsPublic;
        tkPublished: MyScope := dsPublished;
      else
        MyScope := dsNone;
      end;
      DocFindMembers(Leaf, OwnerItem, MyScope);
      Inc(K);
    end
    else
    begin
      Inc(K);
    end;
  end;
end;

// �ݹ���ã�������ȱ���������ע��ʱ��ֹ�������ڻ�ȡ������ע��ǰ�Ĳ���
function InternalGetPascalCodeFromLeafUntilComment(ALeaf: TCnPasAstLeaf; var ToAbort: Boolean): string;
var
  I: Integer;
  S: string;
  Son: TTokenKind;
begin
  if ToAbort then
  begin
    Result := '';
    Exit;
  end;

  Result := ALeaf.Text;
  for I := 0 to ALeaf.Count - 1 do
  begin
    Son := ALeaf.Items[I].TokenKind;
    if Son in [tkBorComment, tkAnsiComment, tkSlashesComment] then
    begin
      ToAbort := True;
      Exit;
    end;

    S := InternalGetPascalCodeFromLeafUntilComment(ALeaf.Items[I], ToAbort);
    if Result = '' then
      Result := S
    else if S <> '' then
    begin
      if ALeaf.NoSpaceBehind or ALeaf.Items[I].NoSpaceBefore or    // ������ڵ���治Ҫ�ո񣬻��ӽڵ�ǰ�治Ҫ�ո�
        (ALeaf.TokenKind in [tkRoundOpen, tkSquareOpen, tkPoint]) or       // ���ڵ���Щ���治Ҫ�ո�
        (Son in [tkPoint, tkDotdot, tkPointerSymbol, tkSemiColon, tkColon, // �ӽڵ���Щǰ�治Ҫ�ո�
        tkRoundClose, tkSquareOpen, tkSquareClose, tkComma]) then
        Result := Result + S
      else
        Result := Result + ' ' + S;
    end;
  end;
end;

function GetPascalCodeFromLeafUntilComment(ALeaf: TCnPasAstLeaf): string;
var
  ToAbort: Boolean;
begin
  ToAbort := False;
  Result := InternalGetPascalCodeFromLeafUntilComment(ALeaf, ToAbort);
end;

// ��ȡ�ӿ��������������ע�ͣ�ParentLeaf ָ��߲�� TYPEDECL�������������
procedure DocGetClassIntfNameComments(ParentLeaf: TCnPasAstLeaf; IsClass: Boolean;
  var Comment: string; var FullType: string);
var
  I: Integer;
  Leaf, TmpLeaf: TCnPasAstLeaf;
begin
  // �������� end �ģ���������ʽ�����������Ѱ����ע��
{
  Class ����ʽ����      Class ����ʽ����        Interface ����ʽ����   Interface ����ʽ����

  TYPEDECL              TYPEDECL                TYPEDECL               TYPEDECL
    Ident                 Ident                   Ident                  Ident
    =                     =                       =                      =
    RESTRICTEDTYPE        RESTRICTEDTYPE          RESTRICTEDTYPE         RESTRICTEDTYPE
      class                 class                   interface              interface
        ע��                  CLASSBODY               ע��                   INTERFACEHERITAGE
                                CLASSHERITAGE                                  (
                                  (                                            )
                                  )                                            ע��
                                  ע��
}

  Comment := '';
  FullType := GetPascalCodeFromLeafUntilComment(ParentLeaf);

  if ParentLeaf.Count > 2 then
  begin
    Leaf := ParentLeaf[2];
    if Leaf.Count > 0 then
    begin
      Leaf := Leaf[0]; // class/interface
      if (Leaf.Count > 0) and (Leaf[0].NodeType in COMMENT_NODE_TYPE) then
      begin
        I := 0;
        Comment := DocCollectComments(Leaf, I); // ��������ʽ����Ĵ���
      end
      else // ��������ʽ����
      begin
        if IsClass then
        begin
          if Leaf.Count > 0 then // class ��ǰ������ʱ����û����
          begin
            Leaf := Leaf[0]; // ClassBody
            if Leaf.Count > 0 then
              Leaf := Leaf[0]; // CLASSHERITAGE
          end;
        end
        else if Leaf.Count > 0 then // interface ��ǰ������ʱ����û����
        begin
          Leaf := Leaf[0]; // INTERFACEHERITAGE
        end;

        I := 0; // Ѱ��������
        TmpLeaf := DocSkipToChild(Leaf, I, [cntRoundClose], [tkRoundClose]);
        if TmpLeaf <> nil then // 
        begin
          Inc(I);
          Comment := DocCollectComments(Leaf, I);
        end;
      end;
    end;
  end;

  if Comment <> '' then
    Exit;

  // �������� end �ģ�����������ʽ���������������ֱ��Ѱ����ע��
  Leaf := ParentLeaf.Parent;
  I := ParentLeaf.Index;
  TmpLeaf := DocSkipToChild(Leaf, I, [cntSemiColon], [tkSemiColon]);
  if TmpLeaf = nil then
    raise ECnPasCodeDocException.Create('NO Class/Interface SemiColon Exists.');

  Inc(I);
  Comment := DocCollectComments(Leaf, I);
end;

// ParentLeaf �� type�������ӽڵ�����һ�����У�TYPEDECL���ӽڵ������ƣ����ֺš������еĵ���ע�Ϳ�
procedure DocFindTypes(ParentLeaf: TCnPasAstLeaf; OwnerItem: TCnDocBaseItem);
var
  K, M: Integer;
  Leaf, DeclLeaf, CIRRoot, Tmp: TCnPasAstLeaf;
  Item: TCnTypeDocItem;
  IsIntf, IsClass, IsRecord: Boolean;
begin
  K := 0;
  while K < ParentLeaf.Count do
  begin
    Leaf := DocSkipToChild(ParentLeaf, K, [cntTypeDecl], [tkNone]);
    if Leaf = nil then // û�ҵ�����˵����β���˿�������ע���ˣ�
    begin
      Inc(K);
      Continue;
    end;
    // raise ECnPasCodeDocException.Create('NO Type Decl Exists.');

    DeclLeaf := Leaf;
    Item := TCnTypeDocItem.Create;
    if Leaf.Count > 0 then
      Item.DeclareName := Leaf[0].Text; // ������

    // �ж� Leaf ���±�Ϊ 2 ���ӽڵ����ͣ������ RESTRICTEDTYPE�����ʾ�� interface��class��Ҫ���⴦��
    // ����� COMMMONTYPE ���ٺ�������ӽڵ��� packed record ��һ�� record��ҲҪ���⴦��
    IsIntf := False;
    IsClass := False;
    IsRecord := False;
    CIRRoot := nil;

    if (Leaf.Count >= 2) and (Leaf[2].NodeType = cntRestrictedType) then
    begin
      if Leaf[2].Count > 0 then
      begin
        CIRRoot := Leaf[2][0];
        if CIRRoot.NodeType = cntInterfaceType then
          IsIntf := True
        else if CIRRoot.NodeType = cntClassType then
        begin
          IsClass := True;
          if CIRRoot.Count > 0 then
          begin
            Tmp := DocSkipCommentToChild(CIRRoot, [cntClassBody], False);
            if Tmp <> nil then
              CIRRoot := Tmp
            else
            begin
              // ���� nil ��ʾ�� class of xxxx ���֣��ƺ�Ҳ������ɶ
            end;
          end;
        end;

        if IsIntf or IsClass then
          DocGetClassIntfNameComments(Leaf, IsClass, Item.FComment, Item.FDeclareType);
      end;
    end
    else if (Leaf.Count >= 2) and (Leaf[2].NodeType = cntCommonType) then
    begin
      Leaf := Leaf[2]; // Ҫ�ж� Leaf[2] ���ӽڵ��Ƿ��� record
      M := 0;
      Leaf := DocSkipToChild(Leaf, M, [cntRecord], [tkRecord]);
      if Leaf <> nil then
      begin
        IsRecord := True;
        CIRRoot := Leaf;
        M := 0;
        Item.Comment := DocCollectComments(Leaf, M);
        Item.DeclareType := GetPascalCodeFromLeafUntilComment(DeclLeaf); // Record ���͵���������
      end;
    end;

    // ���˴���Ӧ���жϺ� IsIntf �� IsClass������ ClassIntfRoot ָ��Ƚ�ͨ�õ�һ�����ڵ�
    if (CIRRoot <> nil) and (IsIntf or IsClass or IsRecord) then
    begin
      // CIRRoot ָ��Ƚ�ͨ�õ�һ�����ڵ㣬ClassBody �� interface �� record
      // ���������������ݣ��� K ��������ϵ�λ��
      if IsIntf or IsClass then
      begin
        DocFindMembers(CIRRoot, Item);
        OwnerItem.AddItem(Item);
      end
      else
      begin
        DocFindRecordFields(CIRRoot, Item);
        OwnerItem.AddItem(Item);
      end;

      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Type Semicolon Exists.');
      // �ҷֺţ���ûע����
      Inc(K);
    end
    else // ������ͨ����
    begin
      Leaf := DocSkipToChild(ParentLeaf, K, [cntSemiColon], [tkSemiColon]);
      if Leaf = nil then
        raise ECnPasCodeDocException.Create('NO Type Semicolon Exists.');

      Item.DeclareType := DeclLeaf.GetPascalCode; // �����͵���������

      Inc(K); // ��������һ��������ע�͵ĵط��������ע�ͣ�K ָ��ע��ĩβ��������ǣ�K ���һ�Ե����˴β���
      Item.Comment := DocCollectComments(ParentLeaf, K);
      OwnerItem.AddItem(Item);
      Inc(K);
    end;
  end;
end;

function CnCreateUnitDocFromFileName(const FileName: string): TCnDocUnit;
var
  AST: TCnPasAstGenerator;
  SL: TStrings;
  TempLeaf, UnitLeaf, IntfLeaf: TCnPasAstLeaf;
  I: Integer;
begin
  Result := nil;
  if not FileExists(FileName) then
    Exit;

  AST := nil;
  SL := nil;

  try
    SL := TStringList.Create;
    SL.LoadFromFile(FileName);

    AST := TCnPasAstGenerator.Create(SL.Text);
    AST.Build;

    // Root ������ֱ���� Unit �ڵ㣬Unit ���ӽڵ��Ƿֺš����֡�֮�������ע��ƴ��ע�͡�
    // ֮���� interface �ڵ㡣�� interface �ڵ�Ϊ���ڵ�ֱ���ֱ���� const��type��var��procedure��function ��ֱ���ڵ�
    // ���ÿ���ڵ㣬�����������ӽڵ㲢��ע�͡�
    UnitLeaf := nil;
    for I := 0 to AST.Tree.Root.Count - 1 do
    begin
      if (AST.Tree.Root.Items[I].NodeType = cntUnit) and (AST.Tree.Root.Items[I].TokenKind = tkUnit) then
      begin
        UnitLeaf := AST.Tree.Root.Items[I];
        Break;
      end;
    end;

    if UnitLeaf = nil then
      raise ECnPasCodeDocException.Create('NO Unit Exists.');

    Result := TCnDocUnit.Create;

    // �� Unit ��
    I := 0;
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntIdent], [tkIdentifier]);
    if TempLeaf <> nil then
      Result.DeclareName := TempLeaf.Text;

    // �ҷֺ�
    TempLeaf := DocSkipToChild(UnitLeaf, I, [cntSemiColon], [tkSemiColon]);
    if TempLeaf = nil then
      raise ECnPasCodeDocException.Create('NO Unit Semicolon Exists.');

    // �ҷֺź��һ��ע��
    Inc(I);
    Result.Comment := DocCollectComments(UnitLeaf, I);

    // �� interface �ڵ�
    IntfLeaf := DocSkipToChild(UnitLeaf, I, [cntInterfaceSection], [tkInterface]);
    if IntfLeaf = nil then
      raise ECnPasCodeDocException.Create('NO InterfaceSection Part Exists.');

    // �� interface �ڵ��µ�ֱ���ڵ��ǲ�����
    I := 0;
    while I < IntfLeaf.Count do
    begin
      case IntfLeaf[I].NodeType of
        cntConstSection: // ���� const �� resourcestring
          begin
            DocFindConsts(IntfLeaf[I], Result);
          end;
        cntVarSection:   // var ��
          begin
            DocFindVars(IntfLeaf[I], Result);
          end;
        cntTypeSection:  // ������
          begin
            // �����ӽڵ����������
            // �����ͣ�����һ�����У�TYPEDECL���ӽڵ������ƣ����ֺš�����ע�Ϳ�
            // �� class/record/interface �ȵ� TYPEDECL��ע�Ϳ������ڲ�
            DocFindTypes(IntfLeaf[I], Result);
          end;
        cntProcedure, cntFunction:
          begin
            DocFindProcedure(IntfLeaf[I], I, Result);
          end;
      end;
      Inc(I);
    end;

    Result.Sort;
    Result.ParseBrief;
  finally
    SL.Free;
    AST.Free;
  end;
end;

procedure DocTypeBubbleSort(RootItem: TCnDocUnit);
var
  I, J: Integer;
begin
  for I := 0 to RootItem.Count - 1 do
    for J := 0 to RootItem.Count - I - 2 do
      if Ord(RootItem[J].DocType) > Ord(RootItem[J + 1].DocType) then
        RootItem.Exchange(J, J + 1);
end;

procedure DocScopeBubbleSort(RootItem: TCnDocBaseItem);
var
  I, J: Integer;
begin
  for I := 0 to RootItem.Count - 1 do
    for J := 0 to RootItem.Count - I - 2 do
      if Ord(RootItem[J].Scope) > Ord(RootItem[J + 1].Scope) then
        RootItem.Exchange(J, J + 1);
end;

procedure SortDocUnit(RootItem: TCnDocUnit);
var
  I: Integer;
begin
  // Unit ����һ����0 �� Count - 1 ������ const��type��procedure��var ��˳������ϲ�
  DocTypeBubbleSort(RootItem); // ��ð�ݶ����ÿ�������Ϊ��Ҫ����ԭλ�ȶ�

  // ÿ�����ӿڣ�����İ� Scope ����
  for I := 0 to RootItem.Count - 1 do
  begin
    if RootItem[I].Count > 1 then
      DocScopeBubbleSort(RootItem[I]);
  end;
end;

{ TCnDocBaseItem }

function TCnDocBaseItem.AddItem(Item: TCnDocBaseItem): Integer;
begin
  FItems.Add(Item);
  Item.Owner := Self;
  Result := FItems.Count;
end;

constructor TCnDocBaseItem.Create;
begin
  FItems := TObjectList.Create(True);
end;

procedure TCnDocBaseItem.Delete(Index: Integer);
begin
  FItems.Delete(Index);
end;

destructor TCnDocBaseItem.Destroy;
begin
  inherited;
  FItems.Free;
end;

procedure TCnDocBaseItem.DumpToStrings(Strs: TStrings; Indent: Integer);
var
  I: Integer;

  function Spcs(Cnt: Integer): string;
  begin
    if Cnt < 0 then
      Result := ''
    else
    begin
      SetLength(Result, Cnt);
      FillChar(Result[1], Cnt, 32);
    end;
  end;

begin
  if Indent < 0 then
    Indent := 0;

  Strs.Add(Spcs(Indent * 2) + FDeclareName);
  if FScope <> dsNone then
    Strs.Add(Spcs(Indent * 2) + SCOPE_STRS[FScope]);
  Strs.Add(Spcs(Indent * 2) + FDeclareType);
  Strs.Add(Spcs(Indent * 2) + FComment);
  Strs.Add('');

  for I := 0 to FItems.Count - 1 do
    Items[I].DumpToStrings(Strs, Indent + 1);
end;

procedure TCnDocBaseItem.Exchange(Index1, Index2: Integer);
begin
  FItems.Exchange(Index1, Index2);
end;

function TCnDocBaseItem.Extract(Item: TCnDocBaseItem): TCnDocBaseItem;
begin
  Result := TCnDocBaseItem(FItems.Extract(Item));
end;

function TCnDocBaseItem.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCnDocBaseItem.GetItem(Index: Integer): TCnDocBaseItem;
begin
  Result := TCnDocBaseItem(FItems[Index]);
end;

function TCnDocBaseItem.GetScopeStr: string;
begin
  Result := SCOPE_STRS[FScope];
end;

procedure TCnDocBaseItem.SetItem(Index: Integer;
  const Value: TCnDocBaseItem);
begin
  FItems[Index] := Value;
end;

procedure TCnDocBaseItem.Sort;
begin
  // ����ɶ������
end;

{ TCnDocUnit }

constructor TCnDocUnit.Create;
begin
  inherited;
  FDocType := dtUnit;
end;

procedure TCnDocUnit.ParseBrief;
const
  UNIT_NAME = '* ��Ԫ���ƣ�';
  MEMO_START = '* ��    ע��';
  MEMO_BODY = '*   ';
var
  I: Integer;
  SL, MO: TStringList;
  MF: Boolean;
begin
  // Comment �������Һ��ʵ�����
  SL := TStringList.Create;
  MO := TStringList.Create;

  try
    SL.Text := FComment;
    MF := False;

    for I := 0 to SL.Count - 1 do
    begin
      if Pos(UNIT_NAME, SL[I]) = 1 then
        FDeclareType := Copy(SL[I], Length(UNIT_NAME) + 1, MaxInt)
      else if Pos(MEMO_START, SL[I]) = 1 then
      begin
        MO.Add(Copy(SL[I], Length(MEMO_START) + 1, MaxInt));
        MF := True;
      end
      else if MF then
      begin
        if Pos(MEMO_BODY, SL[I]) = 1 then
          MO.Add(Copy(SL[I], Length(MEMO_BODY) + 1, MaxInt))
        else if Trim(SL[I]) = '*' then // ע���еĿ��У�������Ӳ�س�
          MO.Add('')
        else
          Break;
      end;
    end;

    FComment := MO.Text;
    FComment := StringReplace(FComment, #13#10#13#10, '<br><br>', [rfReplaceAll]);
  finally
    MO.Free;
    SL.Free;
  end;
end;

procedure TCnDocUnit.Sort;
begin
  SortDocUnit(Self);
end;

{ TCnConstDocItem }

constructor TCnConstDocItem.Create;
begin
  inherited;
  FDocType := dtConst;
end;

{ TCnVarDocItem }

constructor TCnVarDocItem.Create;
begin
  inherited;
  FDocType := dtVar;
end;

{ TCnProcedureDocItem }

constructor TCnProcedureDocItem.Create;
begin
  inherited;
  FDocType := dtProcedure;
end;

{ TCnTypeDocItem }

constructor TCnTypeDocItem.Create;
begin
  inherited;
  FDocType := dtType;
end;

{ TCnPropertyDocItem }

constructor TCnPropertyDocItem.Create;
begin
  inherited;
  FDocType := dtProperty;
end;

{ TCnFieldDocItem }

constructor TCnFieldDocItem.Create;
begin
  inherited;
  FDocType := dtField;
end;

end.
