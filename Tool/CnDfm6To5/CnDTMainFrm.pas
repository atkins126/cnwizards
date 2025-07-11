{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
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

unit CnDTMainFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������ʽת������������
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.04.03 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, FileCtrl, CnLangTranslator, CnLangStorage,
  CnHashLangStorage, CnLangMgr, CnClasses, CnWideCtrls, ExtCtrls;

type

{$I WideCtrls.inc}

  TCnDTMainForm = class(TForm)
    GroupBox1: TGroupBox;
    rbFile: TRadioButton;
    edtFile: TEdit;
    rbDir: TRadioButton;
    edtDir: TEdit;
    cbSubDirs: TCheckBox;
    GroupBox2: TGroupBox;
    ListView: TListView;
    sbFile: TSpeedButton;
    sbDir: TSpeedButton;
    btnStart: TButton;
    btnClose: TButton;
    btnAbout: TButton;
    Label1: TLabel;
    lblURL: TLabel;
    cbReadOnly: TCheckBox;
    OpenDialog: TOpenDialog;
    CnLangManager: TCnLangManager;
    CnHashLangFileStorage: TCnHashLangFileStorage;
    CnLangTranslator1: TCnLangTranslator;
    btnBinToTxt: TButton;
    btnTxtToBin: TButton;
    bvl1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbFileClick(Sender: TObject);
    procedure sbDirClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure rbFileClick(Sender: TObject);
    procedure btnBinToTxtClick(Sender: TObject);
    procedure btnTxtToBinClick(Sender: TObject);
  private
    procedure ConvertAFile(const FileName: string);
    procedure FileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure BinToTextFile(const FileName: string);
    procedure BinToTextFileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure TextToBinFile(const FileName: string);
    procedure TextToBinFileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  protected
    procedure DoCreate; override;
    procedure TranslateStrings;
  public
    { Public declarations }
  end;

var
  CnDTMainForm: TCnDTMainForm;

implementation

uses
  CnWizDfm6To5, CnCommon, CnConsts, Registry, CnWizLangID;

{$R *.DFM}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

const
  csSection = 'CnDfm6To5';
  csSelectFile = 'SelectFile';
  csFileName = 'FileName';
  csDirName = 'DirName';
  csSubDirs = 'SubDirs';
  csReadOnly = 'ReadOnly';

var
  SCnErrorCaption: string = 'Error';
  SCnInfoCaption: string = 'Hint';
  SCnSelectDir: string = 'Please Select the Directory';
  SCnOpenFileError: string = 'File Does not Exist.';
  SCnDirNotExists: string = 'Directory Does not Exist.';
  SCnSucc: string = 'Convert Successfully.';
  SCnOpenFail: string = 'Open Failure.';
  SCnSaveFail: string = 'Save Failure.';
  SCnInvalidFormat: string = 'Invalid File Format.';
  SCnAbout: string = 'DFM File Convert Tool' + #13#10#13#10 +
    'This tool can be used to Convert Forms generated by Delphi 6/7' + #13#10 +
    'or C++Builder 6 or Above to Delphi 5 or C++ Builder 5 Format.' + #13#10 +
    'Text and Binary Format Conversions are also Supported.' + #13#10#13#10 +
    'Author: Zhou JingYu (zjy@cnpack.org)' + #13#10 +
    'Multilang: Liu Xiao (master@cnpack.org)' + #13#10 +
    'Copyright (C)2001-2025 CnPack Team';

  SCnResults: array[TCnDFMConvertResult] of string =
    ('SSucc', 'SOpenFail', 'SSaveFail', 'SInvalidFormat');

procedure TCnDTMainForm.FormCreate(Sender: TObject);
begin
  with TRegistryIniFile.Create(MakePath(SCnPackRegPath) + SCnPackToolRegPath) do
  try
    rbFile.Checked := ReadBool(csSection, csSelectFile, True);
    rbDir.Checked := not rbFile.Checked;
    edtFile.Text := ReadString(csSection, csFileName, '');
    edtDir.Text := ReadString(csSection, csDirName, '');
    cbSubDirs.Checked := ReadBool(csSection, csSubDirs, True);
    cbReadOnly.Checked := ReadBool(csSection, csReadOnly, True);
    rbFileClick(nil);
  finally
    Free;
  end;

  Application.Title := Caption;
end;

procedure TCnDTMainForm.FormDestroy(Sender: TObject);
begin
  with TRegistryIniFile.Create(MakePath(SCnPackRegPath) + SCnPackToolRegPath) do
  try
    WriteBool(csSection, csSelectFile, rbFile.Checked);
    WriteString(csSection, csFileName, edtFile.Text);
    WriteString(csSection, csDirName, edtDir.Text);
    WriteBool(csSection, csSubDirs, cbSubDirs.Checked);
    WriteBool(csSection, csReadOnly, cbReadOnly.Checked);
  finally
    Free;
  end;
end;

procedure TCnDTMainForm.ConvertAFile(const FileName: string);
var
  Res: TCnDFMConvertResult;
begin
  if cbReadOnly.Checked then
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

  Res := DFM6To5(FileName);
  with ListView.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add(SCnResults[Res]);
  end;
end;

procedure TCnDTMainForm.FileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameText(_CnExtractFileExt(FileName), '.DFM') then
    ConvertAFile(FileName);
end;

procedure TCnDTMainForm.btnStartClick(Sender: TObject);
begin
  ListView.Items.Clear;

  if rbFile.Checked then
  begin
    if FileExists(edtFile.Text) then
      ConvertAFile(edtFile.Text)
    else
      ErrorDlg(SCnOpenFileError, SCnErrorCaption);
  end
  else
  begin
    if not DirectoryExists(edtDir.Text) then
      ErrorDlg(SCnDirNotExists, SCnErrorCaption)
    else
    begin
      FindFile(edtDir.Text, '*.*', FileCallBack, nil, cbSubDirs.Checked);
    end;
  end;
end;

procedure TCnDTMainForm.sbFileClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    edtFile.Text := OpenDialog.FileName;
end;

procedure TCnDTMainForm.sbDirClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := edtDir.Text;
  if GetDirectory(SCnSelectDir, Dir) then
    edtDir.Text := Dir;
end;

procedure TCnDTMainForm.rbFileClick(Sender: TObject);
begin
  edtFile.Enabled := rbFile.Checked;
  sbFile.Enabled := rbFile.Checked;
  edtDir.Enabled := rbDir.Checked;
  sbDir.Enabled := rbDir.Checked;
  cbSubDirs.Enabled := rbDir.Checked;
end;

procedure TCnDTMainForm.btnAboutClick(Sender: TObject);
begin
  InfoDlg(SCnAbout, SCnInfoCaption);
end;

procedure TCnDTMainForm.lblURLClick(Sender: TObject);
begin
  RunFile(SCnPackUrl);
end;

procedure TCnDTMainForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TCnDTMainForm.DoCreate;
const
  csLangDir = 'Lang\';
var
  LangID: DWORD;
  I: Integer;
begin
  if CnLanguageManager <> nil then
  begin
    CnHashLangFileStorage.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
    LangID := GetWizardsLanguageID;
    for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
    begin
      if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
      begin
        CnLanguageManager.CurrentLanguageIndex := I;
        TranslateStrings;
        Break;
      end;
    end;
  end;

  inherited;
end;

procedure TCnDTMainForm.TranslateStrings;
begin
  TranslateStr(SCnErrorCaption, 'SCnErrorCaption');
  TranslateStr(SCnInfoCaption, 'SCnInfoCaption');
  TranslateStr(SCnSelectDir, 'SCnSelectDir');
  TranslateStr(SCnOpenFileError, 'SCnOpenFileError');
  TranslateStr(SCnDirNotExists, 'SCnDirNotExists');
  TranslateStr(SCnSucc, 'SCnSucc');
  TranslateStr(SCnOpenFail, 'SCnOpenFail');
  TranslateStr(SCnSaveFail, 'SCnSaveFail');
  TranslateStr(SCnInvalidFormat, 'SCnInvalidFormat');
  TranslateStr(SCnAbout, 'SCnAbout');

  SCnResults[crSucc] := SCnSucc;
  SCnResults[crOpenError] := SCnOpenFail;
  SCnResults[crSaveError] := SCnSaveFail;
  SCnResults[crInvalidFormat] := SCnInvalidFormat;
end;

procedure TCnDTMainForm.btnBinToTxtClick(Sender: TObject);
begin
  ListView.Items.Clear;

  if rbFile.Checked then
  begin
    if FileExists(edtFile.Text) then
      BinToTextFile(edtFile.Text)
    else
      ErrorDlg(SCnOpenFileError, SCnErrorCaption);
  end
  else
  begin
    if not DirectoryExists(edtDir.Text) then
      ErrorDlg(SCnDirNotExists, SCnErrorCaption)
    else
    begin
      FindFile(edtDir.Text, '*.*', BinToTextFileCallBack, nil, cbSubDirs.Checked);
    end;
  end;
end;

procedure TCnDTMainForm.btnTxtToBinClick(Sender: TObject);
begin
  ListView.Items.Clear;

  if rbFile.Checked then
  begin
    if FileExists(edtFile.Text) then
      TextToBinFile(edtFile.Text)
    else
      ErrorDlg(SCnOpenFileError, SCnErrorCaption);
  end
  else
  begin
    if not DirectoryExists(edtDir.Text) then
      ErrorDlg(SCnDirNotExists, SCnErrorCaption)
    else
    begin
      FindFile(edtDir.Text, '*.*', TextToBinFileCallBack, nil, cbSubDirs.Checked);
    end;
  end;
end;

procedure TCnDTMainForm.BinToTextFile(const FileName: string);
var
  Res: TCnDFMConvertResult;
begin
  if cbReadOnly.Checked then
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

  Res := BinToText(FileName);
  with ListView.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add(SCnResults[Res]);
  end;
end;

procedure TCnDTMainForm.BinToTextFileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameText(_CnExtractFileExt(FileName), '.DFM') or
    SameText(_CnExtractFileExt(FileName), '.XFM') then
    BinToTextFile(FileName);
end;

procedure TCnDTMainForm.TextToBinFile(const FileName: string);
var
  Res: TCnDFMConvertResult;
begin
  if cbReadOnly.Checked then
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

  Res := TextToBin(FileName);
  with ListView.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add(SCnResults[Res]);
  end;
end;

procedure TCnDTMainForm.TextToBinFileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameText(_CnExtractFileExt(FileName), '.DFM') or
    SameText(_CnExtractFileExt(FileName), '.XFM') then
    TextToBinFile(FileName);
end;

end.

