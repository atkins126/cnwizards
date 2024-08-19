unit AICoderUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnThreadPool, CnInetUtils, CnNative, CnContainers, CnJSON,
  CnAICoderConfig, CnAICoderEngine, CnWideStrings, FileCtrl, CnChatBox,
  ExtCtrls;

type
  TFormAITest = class(TForm)
    dlgSave1: TSaveDialog;
    dlgOpen1: TOpenDialog;
    pgcAICoder: TPageControl;
    tsHTTP: TTabSheet;
    mmoHTTP: TMemo;
    btnAddHttps: TButton;
    tsAIConfig: TTabSheet;
    btnAIConfigSave: TButton;
    btnAIConfigLoad: TButton;
    mmoConfig: TMemo;
    tsEngine: TTabSheet;
    btnLoadAIConfig: TButton;
    lblAIName: TLabel;
    cbbAIEngines: TComboBox;
    btnSaveAIConfig: TButton;
    btnExplainCode: TButton;
    mmoAI: TMemo;
    lblProxy: TLabel;
    edtProxy: TEdit;
    lblTestProxy: TLabel;
    edtTestProxy: TEdit;
    tsChat: TTabSheet;
    pnlChat: TPanel;
    btnAddInfo: TButton;
    btnAddMyMsg: TButton;
    btnAddYouMsg: TButton;
    btnAddYouLongMsg: TButton;
    btnAddMyLongMsg: TButton;
    pnlAIChat: TPanel;
    btnReviewCode: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddHttpsClick(Sender: TObject);
    procedure btnAIConfigSaveClick(Sender: TObject);
    procedure btnAIConfigLoadClick(Sender: TObject);
    procedure btnLoadAIConfigClick(Sender: TObject);
    procedure cbbAIEnginesChange(Sender: TObject);
    procedure btnSaveAIConfigClick(Sender: TObject);
    procedure btnExplainCodeClick(Sender: TObject);
    procedure btnAddInfoClick(Sender: TObject);
    procedure btnAddMyMsgClick(Sender: TObject);
    procedure btnAddYouMsgClick(Sender: TObject);
    procedure btnAddYouLongMsgClick(Sender: TObject);
    procedure btnAddMyLongMsgClick(Sender: TObject);
    procedure btnReviewCodeClick(Sender: TObject);
  private
    FNetPool: TCnThreadPool;
    FResQueue: TCnObjectQueue;
    FAIConfig: TCnAIEngineOptionManager;
    FChatBox: TCnChatBox;
    FAIChatBox: TCnChatBox;
    // �������ۺϲ���
    procedure AIOnExplainCodeAnswer(Success: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnReviewCodeAnswer(Success: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
  protected
    procedure ShowData;
  public
    procedure ProcessRequest(Sender: TCnThreadPool;
      DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
    procedure MyResponse(Success: Boolean; Thread: TCnPoolingThread;
      SendId: Integer; Data: TBytes);
  end;

  TSendThread = class(TCnPoolingThread)
  private
    FData: TBytes;
    FSendId: Integer;
  public
    property SendId: Integer read FSendId write FSendId;
    property Data: TBytes read FData write FData;
  end;

  TSendDataResponse = procedure(Success: Boolean; Thread: TCnPoolingThread;
    SendId: Integer; Data: TBytes) of object;
  {* ��������Ļص������߳ɹ���񣬳ɹ��� Data ��������}

  TSendDataObject = class(TCnTaskDataObject)
  {* ������������������࣬�ɷ����߸�����������������������Ӹ��̳߳�
    �н��ʱ�̻߳�ص� OnResponse �¼�}
  private
    FURL: string;
    FSendId: Integer;
    FOnResponse: TSendDataResponse;
  public
    function Clone: TCnTaskDataObject; override;

    property SendId: Integer read FSendId write FSendId;
    property URL: string read FURL write FURL;

    property OnResponse: TSendDataResponse read FOnResponse write FOnResponse;
    {* �յ���������ʱ�Ļص��¼���ע���������߳��б����õģ�����ʱ���� Synchronize �����߳����輰ʱ��������}
  end;

  TResponseDataObject = class(TObject)
  {* ����ص�����ķ�װ�����ڵݸ����̹߳�����}
  private
    FSendId: Integer;
    FData: TBytes;
    FSuccess: Boolean;
    FErrorCode: Cardinal;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property SendId: Integer read FSendId write FSendId;
    property Data: TBytes read FData write FData;
    property ErrorCode: Cardinal read FErrorCode write FErrorCode;
  end;

var
  FormAITest: TFormAITest;

implementation

{$R *.DFM}

uses
  CnDebug, CnAICoderNetClient;

const
  DBG_TAG = 'NET';
  AI_FILE_FMT = 'AICoderConfig%s.json';

procedure TFormAITest.FormCreate(Sender: TObject);
const
  BK_COLOR = $71EA9A;
begin
  FNetPool := TCnThreadPool.CreateSpecial(nil, TSendThread);

  FNetPool.OnProcessRequest := ProcessRequest;
  FNetPool.AdjustInterval := 5 * 1000;
  FNetPool.MinAtLeast := False;
  FNetPool.ThreadDeadTimeout := 10 * 1000;
  FNetPool.ThreadsMinCount := 0;
  FNetPool.ThreadsMaxCount := 5;
  FNetPool.TerminateWaitTime := 2 * 1000;
  FNetPool.ForceTerminate := True; // ����ǿ�ƽ���

  FResQueue := TCnObjectQueue.Create(True);

  FAIConfig := TCnAIEngineOptionManager.Create;

  FChatBox := TCnChatBox.Create(Self);
  FChatBox.Color := clWhite;
  FChatBox.Parent := pnlChat;
  FChatBox.Align := alClient;
  FChatBox.ScrollBarVisible := True;
  FChatBox.ShowDownButton := True;
  FChatBox.ColorSelection := BK_COLOR;
  FChatBox.ColorScrollButton := clRed;
  FChatBox.ColorYou := BK_COLOR;
  FChatBox.ColorMe := BK_COLOR;

  FAIChatBox := TCnChatBox.Create(Self);
  FAIChatBox.Color := clWhite;
  FAIChatBox.Parent := pnlAIChat;
  FAIChatBox.Align := alClient;
  FAIChatBox.ScrollBarVisible := True;
  FAIChatBox.ShowDownButton := True;
  FAIChatBox.ColorSelection := BK_COLOR;
  FAIChatBox.ColorScrollButton := clRed;
  FAIChatBox.ColorYou := BK_COLOR;
  FAIChatBox.ColorMe := BK_COLOR;
end;

procedure TFormAITest.FormDestroy(Sender: TObject);
begin
  FAIConfig.Free;

  FNetPool.Free;

  while not FResQueue.IsEmpty do
    FResQueue.Pop.Free;

  FResQueue.Free;
end;

type
  TThreadHack = class(TThread);

procedure TFormAITest.ProcessRequest(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
var
  HTTP: TCnHTTP;
  Stream: TMemoryStream;
begin
  HTTP := TCnHTTP.Create;
  if Trim(edtTestProxy.Text) <> '' then
  begin
    HTTP.ProxyMode := pmProxy;
    HTTP.ProxyServer := edtTestProxy.Text;
  end;

  Stream := TMemoryStream.Create;

  try
    CnDebugger.LogMsgWithTag('*** HTTP To Request.', DBG_TAG);
    Sleep(2000 + Random(5000));
    if HTTP.GetStream(TSendDataObject(DataObj).URL, Stream) then
    begin
      CnDebugger.LogMsgWithTag('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size), DBG_TAG);

      // ����Ҫ�ѽ���͸� UI ������������������ڱ��̣߳���Ϊ UI ���̵߳ĵ��ô�������ʱ���ǲ�ȷ���ģ�
      // �����˱�������Thread ��״̬��δ֪�ˣ��� Thread ������ݿ��ܻ��� Thread �����ӵ��ȶ������
      if Assigned(TSendDataObject(DataObj).OnResponse) then
        TSendDataObject(DataObj).OnResponse(True, Thread, TSendDataObject(DataObj).SendId, StreamToBytes(Stream));
    end
    else
    begin
      CnDebugger.LogMsgWithTag('*** HTTP Request Fail.', DBG_TAG);
      if Assigned(TSendDataObject(DataObj).OnResponse) then
        TSendDataObject(DataObj).OnResponse(False, Thread, TSendDataObject(DataObj).SendId, nil);
    end;
  finally
    Stream.Free;
    HTTP.Free;
  end;
end;

procedure TFormAITest.btnAddHttpsClick(Sender: TObject);
const
  A_URL = 'http://www.baidu.com/s?wd=CnPack';
var
  I: Integer;
  Obj: TSendDataObject;
begin
  // mmoHTTP.Lines.Clear;
  CnDebugger.LogMsgWithTag('*** Button Click.', DBG_TAG);
  for I := 1 to 20 do
  begin
    Obj := TSendDataObject.Create;
    Obj.URL := A_URL;
    Obj.SendId := 1000 + Random(10000);
    Obj.OnResponse := MyResponse;

    FNetPool.AddRequest(Obj);
  end;
end;

{ TSendDataObject }

function TSendDataObject.Clone: TCnTaskDataObject;
begin
  Result := TSendDataObject.Create;
  TSendDataObject(Result).URL := FURL;
  TSendDataObject(Result).SendId := FSendId;
  TSendDataObject(Result).OnResponse := FOnResponse;
end;

{ TSendThread }

procedure TFormAITest.MyResponse(Success: Boolean; Thread: TCnPoolingThread;
  SendId: Integer; Data: TBytes);
var
  Res: TResponseDataObject;
begin
  // ���¼��������߳��е��õġ�
  // ���� Synchronize ȥ���̣߳����豣�� SendId �� Data ���ӹ�ȥ
  // ���������Ƶ��ö��У�����룬���߳�ȡ
  if Success and (Length(Data) > 0) then
  begin
    Res := TResponseDataObject.Create;
    Res.Success := True;
    Res.SendId := SendId;
    Res.Data := Data;
    Res.ErrorCode := 0;

    FResQueue.Push(Res);
    TThreadHack(Thread).Synchronize(ShowData);
  end
  else
  begin
    Res := TResponseDataObject.Create;
    Res.Success := False;
    Res.SendId := SendId;
    Res.Data := Data;
    Res.ErrorCode := GetLastError;

    FResQueue.Push(Res);
    TThreadHack(Thread).Synchronize(ShowData);
  end;
end;

procedure TFormAITest.ShowData;
var
  Obj: TResponseDataObject;
begin
  Obj := TResponseDataObject(FResQueue.Pop);
  if Obj <> nil then
  begin
    if Obj.Success then
      FormAITest.mmoHTTP.Lines.Add(Format('Get Bytes %d from SendId %d', [Length(Obj.Data), Obj.SendId]))
    else
      FormAITest.mmoHTTP.Lines.Add(Format('Get Failed from SendId %d. Error Code %d', [Obj.SendId, Obj.ErrorCode]));
    Obj.Free;
  end;
end;

procedure TFormAITest.btnAIConfigSaveClick(Sender: TObject);
var
  Option: TCnAIEngineOption;
begin
  FAIConfig.Clear;

  Option := TCnAIEngineOption.Create;
  Option.EngineName := 'Moonshot';
  Option.Model := 'moonshot-v1-8k';
  Option.URL := 'https://api.moonshot.cn/v1/chat/completions';
  Option.ApiKey := 'sk-*****************';
  Option.WebAddress := 'https://platform.moonshot.cn/console';
  // Option.SystemMessage := '����һ�� Delphi ר��';
  Option.Temperature := 0.3;
  // Option.ExplainCodePrompt := '��������´��룺';

  FAIConfig.AddOption(Option);

  Option := TCnAIEngineOption.Create;
  Option.EngineName := '����������';
  Option.Model := 'cnpack-noai-9.8';
  Option.URL := 'https://upgrade.cnpack.org/';
  Option.ApiKey := '{ACED92D0-6D09-4B88-BEA7-B963A8301CA4}';
  // Option.SystemMessage := '����һ�� C++Builder ר��';
  Option.Temperature := 0.3;
  // Option.ExplainCodePrompt := '��������´��룺';

  FAIConfig.AddOption(Option);
  FAIConfig.ActiveEngine := 'Moonshot';

  dlgSave1.FileName := 'AIConfig.json';
  if dlgSave1.Execute then
    FAIConfig.SaveToFile(dlgSave1.FileName);
end;

procedure TFormAITest.btnAIConfigLoadClick(Sender: TObject);
begin
  dlgOpen1.FileName := 'AIConfig.json';
  if dlgOpen1.Execute then
  begin
    FAIConfig.LoadFromFile(dlgOpen1.FileName);
    mmoConfig.Lines.Clear;
    mmoConfig.Lines.Add(FAIConfig.SaveToJSON);
  end;
end;

procedure TFormAITest.btnLoadAIConfigClick(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  if SelectDirectory('', '', S) then
  begin
    CnAIEngineManager.LoadFromDirectory(IncludeTrailingBackslash(S), AI_FILE_FMT);

    cbbAIEngines.Items.Clear;
    for I := 0 to CnAIEngineManager.EngineCount - 1 do
      cbbAIEngines.Items.Add(CnAIEngineManager.Engines[I].EngineName);

    CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;
    cbbAIEngines.ItemIndex := CnAIEngineManager.CurrentIndex;

    edtProxy.Text := CnAIEngineOptionManager.ProxyServer;

    for I := 0 to CnAIEngineManager.EngineCount - 1 do
      mmoAI.Lines.Add(CnAIEngineManager.Engines[I].Option.SaveToJSON);
  end;
end;

procedure TFormAITest.cbbAIEnginesChange(Sender: TObject);
begin
  CnAIEngineOptionManager.ActiveEngine := cbbAIEngines.Text;
  CnAIEngineManager.CurrentEngineName := cbbAIEngines.Text;
end;

procedure TFormAITest.btnSaveAIConfigClick(Sender: TObject);
var
  Dir: string;
begin
  if SelectDirectory('', '', Dir) then
    CnAIEngineManager.SaveToDirectory(IncludeTrailingBackslash(Dir), AI_FILE_FMT);
end;

procedure TFormAITest.btnExplainCodeClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode('Application.CreateForm(TForm1, Form1);',
    Msg, artExplainCode, AIOnExplainCodeAnswer);
end;

procedure TFormAITest.AIOnExplainCodeAnswer(Success: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Explain Code OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Explain Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));

  if (Tag = nil) or not (Tag is TCnChatMessage) then
    Exit;

  if Success then
    TCnChatMessage(Tag).Text := Answer
  else
    TCnChatMessage(Tag).Text := Format('Explain Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]);
end;

procedure TFormAITest.btnAddInfoClick(Sender: TObject);
begin
  with FChatBox.Items.AddInfo do
    Text := 'info ' + IntToStr(FChatBox.Items.Count);
end;

procedure TFormAITest.btnAddMyMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'CnPack';
    FromType := cmtMe;
    Text := 'My Message';
  end;
end;

procedure TFormAITest.btnAddYouMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'AI';
    FromType := cmtYou;
    Text := 'Your Message';
  end;
end;

procedure TFormAITest.btnAddYouLongMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'AI';
    FromType := cmtYou;
    Text := 'Any data compression method involves the reduction of redundancy in the data. '
      + 'Consequently, any corruption of the data is likely to have severe effects and be difficult to correct. '
      + 'Uncompressed text, on the other hand, will probably still be readable despite the presence of some corrupted bytes.';
  end;
end;

procedure TFormAITest.btnAddMyLongMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'AI';
    FromType := cmtYou;
    Text := '�ʹ��뿪����ʽ���зḻ��UI����༭���ܣ�ͨ�����ӻ����濪����ʽ���ٹ������֣�����Ч���Ϳ����ߵ����ֳɱ������������߹���UI�����Ч�ʡ� '
      + '������������������ī���磬�����������ţ������ŷ����������أ��������ϱ�ս���еİ��ա�����ˮ½��ͨ��ݣ������Ļ����' + #13#10
      + '�ټ����жԻ�������Ӱ��ļ���ʷ(����˥�������Թ������ļ�������)���ڼ����о�����񾭷��漲��ʷ�����о�����ҩ������ʷ��'
      + '�۽��ڷ��ù�Ӱ������񾭹��ܵ�ҩ�������ز���ǰ24 h�����ú��ƾ�����Ʒ���ܼ���������˯����ؼ���ʷ��'
      + '�������ԭ��������о��ߣ�������ȱʧ��ȫ�ߡ�';
  end;
end;

procedure TFormAITest.btnReviewCodeClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode('Application.CreateForm(TForm1, Form1);',
    Msg, artReviewCode, AIOnReviewCodeAnswer);
end;

procedure TFormAITest.AIOnReviewCodeAnswer(Success: Boolean; SendId: Integer;
  const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Review Code OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Review Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));

  if (Tag = nil) or not (Tag is TCnChatMessage) then
    Exit;

  if Success then
    TCnChatMessage(Tag).Text := Answer
  else
    TCnChatMessage(Tag).Text := Format('Review Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]);
end;

end.
