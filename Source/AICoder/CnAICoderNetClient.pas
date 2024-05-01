{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnAICoderNetClient;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家的网络线程数据对象单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin7/10/11 + Delphi/C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.05.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, CnNative, CnThreadPool;

type
  TCnAIRequestType = (artExplainCode);
  {* 请求类型}

  TCnAINetRequestDataObject = class;

  TCnAIAnswerCallback = procedure(Success: Boolean; SendId: Integer; Answer: TBytes) of object;
  {* 调用 AI 后返回的结果回调事件，Success 表示成功与否，如果成功，Answer 表示回复的内容}

  TCnAINetDataResponse = procedure(Success: Boolean; Thread: TCnPoolingThread;
    DataObj: TCnAINetRequestDataObject; Data: TBytes) of object;
  {* 网络请求的回调，告诉成功与否，成功则 Data 中是数据}

  TCnAINetRequestThread = class(TCnPoolingThread)
  {* 线程池中的线程实例}
  private
    FData: TBytes;
    FSendId: Integer;
  public
    property SendId: Integer read FSendId write FSendId;
    property Data: TBytes read FData write FData;
  end;

  TCnAINetRequestDataObject = class(TCnTaskDataObject)
  {* 代表网络请求的任务类，由发起者根据网络请求参数创建，并扔给线程池
    有结果时线程会回调 OnResponse 事件}
  private
    FEngine: string;
    FURL: string;
    FSendId: Integer;
    FData: TBytes;
    FOnResponse: TCnAINetDataResponse;
    FRequestType: TCnAIRequestType;
    FOnAnswer: TCnAIAnswerCallback;
  public
    function Clone: TCnTaskDataObject; override;

    property Engine: string read FEngine write FEngine;
    {* 具体 AI 引擎的名称}
    property RequestType: TCnAIRequestType read FRequestType write FRequestType;
    {* 请求类型}
    property Data: TBytes read FData write FData;
    {* 初步组装好的请求数据，已实现了业务逻辑，但不包括 HTTP 头的认证部分}

    property SendId: Integer read FSendId write FSendId;
    {* 请求 ID 备用}
    property URL: string read FURL write FURL;
    {* 请求地址}

    property OnAnswer: TCnAIAnswerCallback read FOnAnswer write FOnAnswer;
    {* 给调用者的回调事件，一般由用户设置到用户界面中}
    property OnResponse: TCnAINetDataResponse read FOnResponse write FOnResponse;
    {* 收到网络数据时的回调事件，一般由引擎层设置到引擎内部
      注意是在子线程中被调用的，处理时如需 Synchronize 到主线程则需及时保存数据}
  end;

implementation

{ TCnAINetRequestDataObject }

function TCnAINetRequestDataObject.Clone: TCnTaskDataObject;
begin
  Result := TCnAINetRequestDataObject.Create;

  // 注意如果 TCnAINetRequestDataObject 后面增加属性，此处要同步补充
  TCnAINetRequestDataObject(Result).URL := FURL;
  TCnAINetRequestDataObject(Result).SendId := FSendId;
  TCnAINetRequestDataObject(Result).OnResponse := FOnResponse;
end;

end.
