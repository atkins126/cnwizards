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

unit CnWizMethodHook;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����󷽷��ҽӵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�����ҽ� IDE �ڲ���ķ���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2018.01.12
*               �����ʼ��ʱ���Զ��ҽӵĿ��ƣ�����ӿں�������ʵ��ַ��ȡ
*           2014.10.01
*               �� DDetours ���ø�Ϊ��̬
*           2014.08.28
*               ����DDetoursʵ�ֵ���
*           2003.10.27
*               ʵ�����Ա༭�������ҽӺ��ļ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes{$IFDEF USE_DDETOURS_HOOK}, DDetours{$ENDIF};

type
  PLongJump = ^TLongJump;
  TLongJump = packed record
    JmpOp: Byte;        // Jmp �����תָ�Ϊ $E9
    Addr: Pointer;      // ��ת������Ե�ַ
  end;

  TCnMethodHook = class
  {* ��̬�� dynamic �����ҽ��࣬���ڹҽ����о�̬����������Ϊ dynamic �Ķ�̬������
     ����ͨ���޸�ԭ�������ǰ 5�ֽڣ���Ϊ��תָ����ʵ�ַ����ҽӲ�������ʹ��ʱ
     �뱣֤ԭ������ִ���������� 5�ֽڣ�������ܻ�������غ����}
  private
    FUseDDteours: Boolean;
    FHooked: Boolean;
    FOldMethod: Pointer;
    FNewMethod: Pointer;
    FTrampoline: Pointer;
    FSaveData: TLongJump;
  public
    constructor Create(const AOldMethod, ANewMethod: Pointer; UseDDteoursHook: Boolean = False;
      DefaultHook: Boolean = True);
    {* ������������Ϊԭ������ַ���·�����ַ��ע�������ר�Ұ���ʹ�ã�ԭ������ַ
       ���� GetBplMethodAddress ת������ʵ��ַ�����������ú���Զ��ҽӴ���ķ�����
     |<PRE>
       �������Ҫ�ҽ� TTest.Abc(const A: Integer) ���������Զ����·���Ϊ��
       procedure MyAbc(ASelf: TTest; const A: Integer);
       �˴� MyAbc Ϊ��ͨ���̣���Ϊ������������һ������Ϊ Self���ʴ˴�����һ��
       ASelf: TTest ������֮��ԣ�ʵ�ִ����п��԰�����������ʵ�������ʡ�
     |</PRE>}
    destructor Destroy; override;
    {* ����������ȡ���ҽ�}

    property Hooked: Boolean read FHooked;
    {* �Ƿ��ѹҽ�}
    procedure HookMethod; virtual;
    {* ���¹ҽӣ������Ҫִ��ԭ���̣���ʹ���� UnhookMethod������ִ����ɺ����¹ҽ�}
    procedure UnhookMethod; virtual;
    {* ȡ���ҽӣ������Ҫִ��ԭ���̣�����ʹ�� UnhookMethod���ٵ���ԭ���̣���������}
    property Trampoline: Pointer read FTrampoline;
    {* DDetours �ҽӺ�ľɷ�����ַ������粻�л��ҽ�״̬��ֱ�ӵ��á�
       �粻ʹ�� DDetours����Ϊ nil}
    property UseDDteours: Boolean read FUseDDteours;
    {* �Ƿ�ʹ�� UseDDteours ����йҽ�}
  end;

function GetBplMethodAddress(Method: Pointer): Pointer;
{* ������ BPL ��ʵ�ʵķ�����ַ����ר�Ұ����� @TPersistent.Assign ���ص���ʵ��
   һ�� Jmp ��ת��ַ���ú������Է����� BPL �з�������ʵ��ַ��}

function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
{* ���� Delphi ��֧�� @AIntf.Proc �ķ�ʽ���ؽӿڵĺ�����ڵ�ַ������ Self ָ��Ҳ
   ��ƫ�����⡣���������ڷ��� AIntf �ĵ� MethodIndex ����������ڵ�ַ����������
   Self ָ���ƫ�����⡣
   MethodIndex �� 0 ��ʼ��0��1��2 �ֱ���� QueryInterface��_AddRef��_Release��
   ע�� MethodIndex �����߽��飬�����˸� Interface �ķ����������}

implementation

type
  TJmpCode = packed record
    Code: Word;                 // �����תָ����Ϊ $25FF
    Addr: ^Pointer;             // ��תָ���ַ��ָ�򱣴�Ŀ���ַ��ָ��
  end;
  PJmpCode = ^TJmpCode;

resourcestring
  SMemoryWriteError = 'Error writing method memory (%s).';

const
  csJmpCode = $E9;              // �����תָ�������
  csJmp32Code = $25FF;

// ������ BPL ��ʵ�ʵķ�����ַ
function GetBplMethodAddress(Method: Pointer): Pointer;
begin
  if PJmpCode(Method)^.Code = csJmp32Code then
    Result := PJmpCode(Method)^.Addr^
  else
    Result := Method;
end;

// ���� Interface ��ĳ��ŷ�����ʵ�ʵ�ַ�������� Self ƫ��
function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
type
  TIntfMethodEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte);        // $05 �����ֽ�
      1: (WordOpCode: Word);        // $C083 ��һ�ֽ�
      2: (DWordOpCode: DWORD);      // $04244483 ��һ�ֽڻ� $04244481 �����ֽ�
  end;
  PIntfMethodEntry = ^TIntfMethodEntry;

  // ������ת�����������ʵ���ϵ�ͬ�� TJmpCode �� TLongJmp ���ṹ�����
  TIntfJumpEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte; Offset: LongInt);         // $E9 �����ֽ�
      1: (WordOpCode: Word; Addr: ^Pointer);        // $25FF �����ֽ�
  end;
  PIntfJumpEntry = ^TIntfJumpEntry;
  PPointer = ^Pointer;

var
  OffsetStubPtr: Pointer;
  IntfPtr: PIntfMethodEntry;
  JmpPtr: PIntfJumpEntry;
begin
  Result := nil;
  if (AIntf = nil) or (MethodIndex < 0) then
    Exit;

  OffsetStubPtr := PPointer(Integer(PPointer(AIntf)^) + SizeOf(Pointer) * MethodIndex)^;

  // �õ��� interface ��Ա������ת��ڣ�����ڻ����� Self ָ��������������
  // IUnknown �����׼������ھ��� add dword ptr [esp+$04],-$xx ��xx Ϊ ShortInt �� LongInt������Ϊ�� stdcall
  // stdcall/safecall/cdecl �Ĵ���Ϊ $04244483 ��һ�ֽڵ� ShortInt���� $04244481 �����ֽڵ� LongInt
  // ���������������÷�ʽ���п�����Ĭ�� register �� add eax -$xx ��xx Ϊ ShortInt �� LongInt��
  // stdcall/safecall/cdecl �Ĵ���Ϊ $C083 ��һ�ֽڵ� ShortInt���� $05 �����ֽڵ� LongInt
  // pascal ��������ջ��ʽ�����ƺ��Ժ� stdcall ��һ��
  IntfPtr := PIntfMethodEntry(OffsetStubPtr);

  JmpPtr := nil;
  if IntfPtr^.ByteOpCode = $05 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 1 + 4)
  else if IntfPtr^.DWordOpCode = $04244481 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 4 + 4)
  else if IntfPtr^.WordOpCode = $C083 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 2 + 1)
  else if IntfPtr^.DWordOpCode = $04244483 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 4 + 1);

  if JmpPtr <> nil then
  begin
    // Ҫ���ָ��ֲ�ͬ����ת�������� E9 �����ֽ����ƫ�ƣ��Լ� 25FF �����ֽھ��Ե�ַ�ĵ�ַ
    if JmpPtr^.ByteOpCode = csJmpCode then
    begin
      Result := Pointer(Integer(JmpPtr) + JmpPtr^.Offset + 5); // 5 ��ʾ Jmp ָ��ĳ���
    end
    else if JmpPtr^.WordOpCode = csJmp32Code then
    begin
      Result := JmpPtr^.Addr^;
    end;
  end;
end;

//==============================================================================
// ��̬�� dynamic �����ҽ���
//==============================================================================

{ TCnMethodHook }

constructor TCnMethodHook.Create(const AOldMethod, ANewMethod: Pointer;
  UseDDteoursHook, DefaultHook: Boolean);
begin
  inherited Create;
{$IFNDEF USE_DDETOURS_HOOK}
  if UseDDteoursHook then
    raise Exception.Create('DDetours NOT Included. Can NOT Hook.');
{$ENDIF}
  FUseDDteours := UseDDteoursHook;
  FHooked := False;
  FOldMethod := AOldMethod;
  FNewMethod := ANewMethod;
  FTrampoline := nil;

  if DefaultHook then
    HookMethod;
end;

destructor TCnMethodHook.Destroy;
begin
  UnHookMethod;
  inherited;
end;

procedure TCnMethodHook.HookMethod;
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
begin
  if FHooked then Exit;

  if FUseDDteours then
  begin
{$IFDEF USE_DDETOURS_HOOK}
    FTrampoline := DDetours.InterceptCreate(FOldMethod, FNewMethod);
    if not Assigned(FTrampoline) then
      raise Exception.Create('Failed to install method hook');
{$ENDIF}
  end
  else
  begin
    // ���ô���ҳд����Ȩ��
    if not VirtualProtect(FOldMethod, SizeOf(TLongJump), PAGE_EXECUTE_READWRITE, @OldProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

    try
      // ����ԭ���Ĵ���
      FSaveData := PLongJump(FOldMethod)^;

      // ����תָ���滻ԭ������ǰ 5 �ֽڴ���
      PLongJump(FOldMethod)^.JmpOp := csJmpCode;
      PLongJump(FOldMethod)^.Addr := Pointer(Integer(FNewMethod) -
        Integer(FOldMethod) - SizeOf(TLongJump)); // ʹ�� 32 λ��Ե�ַ

      // ����ദ������ָ�����ͬ��
      FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TLongJump));
    finally
      // �ָ�����ҳ����Ȩ��
      if not VirtualProtect(FOldMethod, SizeOf(TLongJump), OldProtection, @DummyProtection) then
        raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
    end;
  end;

  FHooked := True;
end;

procedure TCnMethodHook.UnhookMethod;
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
begin
  if not FHooked then Exit;

  if FUseDDteours then
  begin
{$IFDEF USE_DDETOURS_HOOK}
    if not DDetours.InterceptRemove(FTrampoline) then
      raise Exception.Create('Failed to release method hook');
{$ENDIF}
    FTrampoline := nil;
  end
  else
  begin
    // ���ô���ҳд����Ȩ��
    if not VirtualProtect(FOldMethod, SizeOf(TLongJump), PAGE_READWRITE, @OldProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

    try
      // �ָ�ԭ���Ĵ���
      PLongJump(FOldMethod)^ := FSaveData;
    finally
      // �ָ�����ҳ����Ȩ��
      if not VirtualProtect(FOldMethod, SizeOf(TLongJump), OldProtection, @DummyProtection) then
        raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
    end;

    // ����ദ������ָ�����ͬ��
    FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TLongJump));
  end;

  FHooked := False;
end;

end.
