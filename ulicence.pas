{*************************************************
 ** Definition de la fenetre A propos ************
 **************************************************}

unit ulicence; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls;

type

  { Tlicence }

  Tlicence = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Paint; override;
    procedure TabControl1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  licence: Tlicence;

implementation

{ Tlicence }

procedure Tlicence.Image1Click(Sender: TObject);
begin

end;

procedure Tlicence.Memo1Change(Sender: TObject);
begin

end;

procedure Tlicence.FormCreate(Sender: TObject);
begin

end;

procedure Tlicence.paint;
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

procedure Tlicence.TabControl1Change(Sender: TObject);
begin

end;


initialization
  {$I ulicence.lrs}

end.

