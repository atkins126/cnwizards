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
  SysUtils, Classes, CnNative, CnJSON, CnAICoderEngine, CnAICoderNetClient;

type
  TCnOpenAIAIEngine = class(TCnAIBaseEngine)
  {* OpenAI ����}
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
    // һ��ԭʼ�������˺Ŵﵽ��󲢷���
    Result := BytesToAnsi(Response);
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

initialization
  RegisterAIEngine(TCnOpenAIAIEngine);
  RegisterAIEngine(TCnQWenAIEngine);
  RegisterAIEngine(TCnMoonshotAIEngine);
  RegisterAIEngine(TCnChatGLMAIEngine);
  RegisterAIEngine(TCnBaiChuanAIEngine);
  RegisterAIEngine(TCnDeepSeekAIEngine);

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
