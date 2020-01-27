unit DummyUnit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Timer1: TTimer;
    Label2: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    Counter: integer;
    procedure RunPhoenix;
  public
  end;

var
  Form1: TForm1;

implementation

uses
  System.IOUtils, Winapi.ShellAPI;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  RunPhoenix;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Counter := 0;
end;

procedure TForm1.RunPhoenix;
var
  Old, App, New,
  phoenix, commandline  : string;
begin
  App := Application.ExeName;
  New := TPath.ChangeExtension(App, '.new');
  // a quick hack here so that we can rename old back to new and start the process all over again
  Old := TPath.ChangeExtension(App, '.old');
  if fileExists(old) then
    RenameFile(old, New);
  commandLine := App + ' ' + New;
  phoenix := TPath.Combine(GetCurrentDir, 'phoenix.exe');
  ShellExecute(GetDesktopWindow, 'open', PwideChar(phoenix), PWideChar(commandline), PWideChar(GetCurrentDir), SW_SHOW);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  inc(Counter);
  Label2.caption := IntToStr(Counter);
end;

end.
