unit uaide;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TfAide }

  TfAide = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Paint; override;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  fAide: TfAide;

implementation

{ TfAide }

procedure TfAide.FormCreate(Sender: TObject);
begin

end;

procedure TfAide.paint;
  var
      re: TRect;
      c, cc : TColor;
begin
  c:=$fadee9;
  cc:=$292325;
  re.Left:=0;
  re.Top:=0;
  re.Right:=self.Width;
  re.Bottom:=self.Height;
  canvas.GradientFill(re, c, cc, gdVertical);
end;

initialization
  {$I uaide.lrs}

end.

