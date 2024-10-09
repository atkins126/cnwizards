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

unit CnAICoderEngineImpl;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵ�����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin7/10/11 + Delphi/C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.04 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, CnNative, CnJSON, CnAICoderEngine, CnAICoderNetClient,
  CnAICoderConfig;

type
  TCnOpenAIAIEngine = class(TCnAIBaseEngine)
  {* OpenAI ����}
  public
    class function EngineName: string; override;
  end;

  TCnMistralAIAIEngine = class(TCnAIBaseEngine)
  {* MistralAI ����}
  public
    class function EngineName: string; override;
  end;

  TCnClaudeAIEngine = class(TCnAIBaseEngine)
  {* Claude ����}
  protected
    // Claude �������֤ͷ��Ϣ������������ͬ
    procedure PrepareRequestHeader(Headers: TStringList); override;

    // Claude �� HTTP �ӿڵ� JSON ��ʽ����������������ͬ
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; override;

    // Claude ����Ϣ���ظ�ʽҲ��ͬ
    function ParseResponse(var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; override;
  public
    class function EngineName: string; override;
    class function OptionClass: TCnAIEngineOptionClass; override;
  end;

  TCnGeminiAIEngine = class(TCnAIBaseEngine)
  {* Gemini ����}
  protected
    // Gemini �� URL ������������ͬ
    function GetRequestURL(DataObj: TCnAINetRequestDataObject): string; override;

    // Gemini �������֤ͷ��Ϣ������������ͬ
    procedure PrepareRequestHeader(Headers: TStringList); override;

    // Claude �� HTTP �ӿڵ� JSON ��ʽ����������������ͬ
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; override;

    // Claude ����Ϣ���ظ�ʽҲ��ͬ
    function ParseResponse(var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; override;
  public
    class function EngineName: string; override;

  end;

  TCnQWenAIEngine = class(TCnAIBaseEngine)
  {* ͨ��ǧ�� AI ����}
  protected
    // ͨ��ǧ�ʵ� HTTP �ӿڵ� JSON ��ʽ����������������ͬ
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; override;
    function ParseResponse(var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; override;
  public
    class function EngineName: string; override;
  end;

  TCnMoonshotAIEngine = class(TCnAIBaseEngine)
  {* ��֮���� AI ����}
  public
    class function EngineName: string; override;
  end;

  TCnChatGLMAIEngine = class(TCnAIBaseEngine)
  {* �������� AI ����}
  public
    class function EngineName: string; override;
  end;

  TCnBaiChuanAIEngine = class(TCnAIBaseEngine)
  {* �ٴ� AI ����}
  public
    class function EngineName: string; override;
  end;

  TCnDeepSeekAIEngine = class(TCnAIBaseEngine)
  {* ������� AI ����}
  public
    class function EngineName: string; override;
  end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

const
  CRLF = #13#10;
  LF = #10;

{ TCnOpenAIEngine }

class function TCnOpenAIAIEngine.EngineName: string;
begin
  Result := 'OpenAI';
end;

{ TCnQWenAIEngine }

function TCnQWenAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Input, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', Option.Model);
    ReqRoot.AddPair('temperature', Option.Temperature);

    Input := TCnJSONObject.Create;
    ReqRoot.AddPair('input', Input);
    Arr := Input.AddArray('messages');

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'system');
    Msg.AddPair('content', Option.SystemMessage);
    Arr.AddValue(Msg);

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    Msg.AddPair('content', Option.ExplainCodePrompt + #13#10 + Code);

    Arr.AddValue(Msg);

    Input := TCnJSONObject.Create;
    ReqRoot.AddPair('parameters', Input);
    Input.AddPair('result_format', 'message');

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

class function TCnQWenAIEngine.EngineName: string;
begin
  Result := 'ͨ��ǧ��';
end;

function TCnQWenAIEngine.ParseResponse(var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType;
  const Response: TBytes): string;
var
  RespRoot, Output, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  Result := '';
  S := BytesToAnsi(Response);
  RespRoot := CnJSONParse(S);
  if RespRoot = nil then
  begin
    // һ��ԭʼ����
    Result := S;
  end
  else
  begin
    try
      // ������Ӧ
      if (RespRoot['output'] <> nil) and (RespRoot['output'] is TCnJSONObject) then
      begin
        Output := TCnJSONObject(RespRoot['output']);
        if (Output['choices'] <> nil) and (Output['choices'] is TCnJSONArray) then
        begin
          Arr := TCnJSONArray(Output['choices']);
          if (Arr.Count > 0) and (Arr[0]['message'] <> nil) and (Arr[0]['message'] is TCnJSONObject) then
          begin
            Msg := TCnJSONObject(Arr[0]['message']);
            Result := Msg['content'].AsString;
          end;
        end;
      end;

      if Result = '' then
      begin
        // ֻҪû��������Ӧ����˵��������
        Success := False;

        // һ��ҵ����󣬱��� Key ��Ч��
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONObject) then
        begin
          Msg := TCnJSONObject(RespRoot['error']);
          Result := Msg['message'].AsString;
        end;

        // һ��������󣬱��� URL ���˵�
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONString) then
          Result := RespRoot['error'].AsString;
        if (RespRoot['message'] <> nil) and (RespRoot['message'] is TCnJSONString) then
        begin
          if Result = '' then
            Result := RespRoot['message'].AsString
          else
            Result := Result + ', ' + RespRoot['message'].AsString;
        end;
      end;
    finally
      RespRoot.Free;
    end;
  end;

  // ����һ�»س�����
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

{ TCnMoonshotAIEngine }

class function TCnMoonshotAIEngine.EngineName: string;
begin
  Result := '��֮����';
end;

{ TCnChatGLMAIEngine }

class function TCnChatGLMAIEngine.EngineName: string;
begin
  Result := '��������';
end;

{ TCnBaiChuanAIEngine }

class function TCnBaiChuanAIEngine.EngineName: string;
begin
  Result := '�ٴ�����';
end;

{ TCnDeepSeekAIEngine }

class function TCnDeepSeekAIEngine.EngineName: string;
begin
  Result := 'DeepSeek';
end;

{ TCnMistralAIAIEngine }

class function TCnMistralAIAIEngine.EngineName: string;
begin
  Result := 'MistralAI';
end;

{ TCnClaudeAIEngine }

function TCnClaudeAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', Option.Model);
    ReqRoot.AddPair('temperature', Option.Temperature);
    ReqRoot.AddPair('max_tokens', (Option as TCnClaudeAIEngineOption).MaxTokens);

    ReqRoot.AddPair('system', Option.SystemMessage); // Claude ����� System ��Ϣ
    Arr := ReqRoot.AddArray('messages');

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    if RequestType = artExplainCode then
      Msg.AddPair('content', Option.ExplainCodePrompt + #13#10 + Code)
    else if RequestType = artReviewCode then
      Msg.AddPair('content', Option.ReviewCodePrompt + #13#10 + Code)
    else if RequestType = artRaw then
      Msg.AddPair('content', Code);

    Arr.AddValue(Msg);

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

class function TCnClaudeAIEngine.EngineName: string;
begin
  Result := 'Claude';
end;

class function TCnClaudeAIEngine.OptionClass: TCnAIEngineOptionClass;
begin
  Result := TCnClaudeAIEngineOption;
end;

function TCnClaudeAIEngine.ParseResponse(var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType;
  const Response: TBytes): string;
var
  RespRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  Result := '';
  S := BytesToAnsi(Response);
  RespRoot := CnJSONParse(S);
  if RespRoot = nil then
  begin
    // һ��ԭʼ����
    Result := S;
  end
  else
  begin
    try
      // ������Ӧ
      if (RespRoot['content'] <> nil) and (RespRoot['content'] is TCnJSONArray) then
      begin
        Arr := TCnJSONArray(RespRoot['content']);
        if (Arr.Count > 0) and (Arr[0]['text'] <> nil) and (Arr[0]['text'] is TCnJSONString) then
          Result := Arr[0]['text'].AsString;
      end;

      if Result = '' then
      begin
        // ֻҪû��������Ӧ����˵�������ˣ��� Claude ���ĵ���û��˵����ֻ���������� AI ����д
        Success := False;

        // һ��ҵ����󣬱��� Key ��Ч��
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONObject) then
        begin
          Msg := TCnJSONObject(RespRoot['error']);
          Result := Msg['message'].AsString;
        end;

        // һ��������󣬱��� URL ���˵�
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONString) then
          Result := RespRoot['error'].AsString;
        if (RespRoot['message'] <> nil) and (RespRoot['message'] is TCnJSONString) then
        begin
          if Result = '' then
            Result := RespRoot['message'].AsString
          else
            Result := Result + ', ' + RespRoot['message'].AsString;
        end;
      end;

      // ���ף����н�������Ч��ֱ�������� JSON ��Ϊ������Ϣ
      if Result = '' then
        Result := S;

    finally
      RespRoot.Free;
    end;
  end;

  // ����һ�»س�����
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

procedure TCnClaudeAIEngine.PrepareRequestHeader(Headers: TStringList);
begin
  inherited;
  Headers.Add('x-api-key: ' + Option.ApiKey);
  // ԭ�ȵ� Authorization: Bearer ��ʱ��ɾ

  Headers.Add('anthropic-version: ' + (Option as TCnClaudeAIEngineOption).AnthropicVersion);
end;

{ TCnGeminiAIEngine }

function TCnGeminiAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Msg, Txt: TCnJSONObject;
  Cont, Part: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    Cont := ReqRoot.AddArray('contents');
    Msg := TCnJSONObject.Create;

    // Gemini ��֧�� system role��һ��� user ��
    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    Part := Msg.AddArray('parts');
    Txt := TCnJSONObject.Create;

    if RequestType = artExplainCode then
      Txt.AddPair('text', Option.SystemMessage + #13#10 + Option.ExplainCodePrompt + #13#10 + Code)
    else if RequestType = artReviewCode then
      Txt.AddPair('text', Option.SystemMessage + #13#10 + Option.ReviewCodePrompt + #13#10 + Code)
    else if RequestType = artRaw then
      Txt.AddPair('text', Option.SystemMessage + #13#10 + Code);

    Part.AddValue(Txt);
    Cont.AddValue(Msg);

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

class function TCnGeminiAIEngine.EngineName: string;
begin
  Result := 'Gemini';
end;

function TCnGeminiAIEngine.GetRequestURL(DataObj: TCnAINetRequestDataObject): string;
begin
  // ģ�����������֤�� Key ���� URL ��
  Result := DataObj.URL + Option.Model + ':generateContent?key=' + Option.ApiKey;
end;

function TCnGeminiAIEngine.ParseResponse(var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType;
  const Response: TBytes): string;
var
  RespRoot, Parts, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  Result := '';
  S := BytesToAnsi(Response);
  RespRoot := CnJSONParse(S);
  if RespRoot = nil then
  begin
    // һ��ԭʼ�������˺Ŵﵽ��󲢷���
    Result := S;
  end
  else
  begin
    try
      // ������Ӧ��Gemini ��ʽ
      if (RespRoot['candidates'] <> nil) and (RespRoot['candidates'] is TCnJSONArray) then
      begin
        Arr := TCnJSONArray(RespRoot['candidates']);
        if (Arr.Count > 0) and (Arr[0]['content'] <> nil) and (Arr[0]['content'] is TCnJSONObject) then
        begin
          Parts := TCnJSONObject(Arr[0]['content']);
          if (Parts['parts'] <> nil) and (Parts['parts'] is TCnJSONArray) then
          begin
            Arr := TCnJSONArray(Parts['parts']);
            if (Arr.Count > 0) and (Arr[0]['text'] <> nil) and (Arr[0]['text'] is TCnJSONString) then
            begin
              Msg := TCnJSONObject(Arr[0]);
              Result := Msg['text'].AsString;
            end;
          end;
        end;
      end;

      if Result = '' then
      begin
        // ֻҪû��������Ӧ����˵��������
        Success := False;

        // һ��ҵ����󣬱��� Key ��Ч��
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONObject) then
        begin
          Msg := TCnJSONObject(RespRoot['error']);
          Result := Msg['message'].AsString;
        end;

        // һ��������󣬱��� URL ���˵�
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONString) then
          Result := RespRoot['error'].AsString;
        if (RespRoot['message'] <> nil) and (RespRoot['message'] is TCnJSONString) then
        begin
          if Result = '' then
            Result := RespRoot['message'].AsString
          else
            Result := Result + ', ' + RespRoot['message'].AsString;
        end;
      end;

      // ���ף����н�������Ч��ֱ�������� JSON ��Ϊ������Ϣ
      if Result = '' then
        Result := S;
    finally
      RespRoot.Free;
    end;
  end;

  // ����һ�»س�����
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

procedure TCnGeminiAIEngine.PrepareRequestHeader(Headers: TStringList);
begin
  inherited;
  // ��ʱ��ɾ��ģ������֤�� URL ��
end;

initialization
  RegisterAIEngine(TCnOpenAIAIEngine);
  RegisterAIEngine(TCnMistralAIAIEngine);
  RegisterAIEngine(TCnGeminiAIEngine);
  RegisterAIEngine(TCnClaudeAIEngine);
  RegisterAIEngine(TCnQWenAIEngine);
  RegisterAIEngine(TCnMoonshotAIEngine);
  RegisterAIEngine(TCnChatGLMAIEngine);
  RegisterAIEngine(TCnBaiChuanAIEngine);
  RegisterAIEngine(TCnDeepSeekAIEngine);

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
