{***************************************************
 ** Graphisme :                                    *
 ** definit le panneau de controle situe a droite  *
 ** de la grille quand elle est presente a l'ecran *
 ***************************************************}

unit utpanels;

{$mode objfpc}{$H+}

interface

uses
 Classes,  SysUtils, LCLType, Controls, Graphics,  UTPlateau, Forms,  LResources,
 uthreadsolve, utdisplay, Dialogs;

type
  TPoint= class
           x, y, d : integer;
           function hitTest(ax, ay: integer) : boolean;
           constructor init;
          end;

  TMyPanel = class(TCustomControl)
                       private
                        plateau : TPlateau;
                        dx, dy : real;
                        lx, ly : byte;
                        cx, cy : integer;
                        clickOn : boolean;
                        xx, yy : byte;
                        clockPos, cleanPos, turnPos, souris, solvePos  : TPoint;

                        procedure dessiner(Bitmap: TBitmap);
                        procedure resoudre();

                       public

                        constructor Create(AOwner: TComponent);override;
                        procedure EraseBackground(DC: HDC); override;
                        procedure Paint; override;
                        procedure setPlateau(plat : TPlateau);
                        procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
                        procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); dynamic;

                        {:(}
                        public
                        form : TForm;
                        sudo : TMyDrawingControl;
                        temps : string;

                       end;

implementation

constructor TPoint.init();
begin
end;

function  TPoint.hitTest(ax, ay : integer) : boolean;
begin
 hitTest:=false;
 if(ax>x) and (ax<(x+d)) then
  if(ay>y) and (ay<(y+d)) then
   hitTest:=true;
end;

constructor TMyPanel.Create(AOwner: TComponent);
begin
 inherited create(AOwner);
 dx:=30;
 dy:=30;
 lx:=3;
 ly:=2;
 xx:=14;
 yy:=12;
 clickOn:=false;
 turnPos:=TPoint.init();
 turnPos.x:=5;
 turnPos.y:=130;
 turnPos.d:=30;

 cleanPos:=TPoint.init();
 cleanPos.x:=80;
 cleanPos.y:=130;
 cleanPos.d:=30;

 clockPos:=TPoint.init();
 clockPos.x:=5;
 clockPos.y:=180;
 clockPos.d:=24;

 solvePos:=TPoint.init();
 solvePos.x:=5;
 solvePos.y:=220;
 solvePos.d:=32;

 souris:=TPoint.init();

 temps:='00:000:000  S';
end;


procedure TMyPanel.EraseBackground(DC: HDC);
begin
end;

procedure TMyPanel.Paint;
 var  Bitmap: TBitmap;
      re: TRect;
      c, cc : TColor;
begin
  c:=$fadee9;
  cc:=$292325;
  re.Left:=0;
  re.Top:=0;
  re.Right:=self.Width;
  re.Bottom:=self.Height;

  Bitmap := TBitmap.Create;
  Bitmap.Height := 300;
  Bitmap.Width := 120;
  bitmap.Canvas.GradientFill(re, c, cc, gdVertical);
  try
   dessiner(bitmap);
   Canvas.Draw(0, 0, Bitmap);
  finally
    Bitmap.Free;
  end;
    inherited Paint;
end;


procedure TMyPanel.dessiner(Bitmap: TBitmap);
 var pic:TPicture;
     i, j, c : integer;
      s: string;
begin
  //image de fond
  pic:=TPicture.create();
  pic.LoadFromLazarusResource('conteneur');
  bitmap.Canvas.Draw(0, 0, pic.Bitmap);
  //------------------------
  c:=1;
  for j:=1 to 3 do
   for i:=1 to 3 do
    begin
     str(c, s);
     c:=c+1;
     pic.LoadFromLazarusResource('img'+s);
     if clickOn then
     begin
     if (cx=i) and (cy=j) then
      bitmap.Canvas.Draw(xx+trunc((i-1)*dx+lx+2), yy+trunc((j-1)*dy+ly+2), pic.Bitmap)
     else
      bitmap.Canvas.Draw(xx+trunc((i-1)*dx+lx), yy+trunc((j-1)*dy+ly), pic.Bitmap);
     end
     else
      bitmap.Canvas.Draw(xx+trunc((i-1)*dx+lx), yy+trunc((j-1)*dy+ly), pic.Bitmap);
    end;

  //autres boutons

  if clickOn then
  begin
   pic.LoadFromLazarusResource('turn');
   if turnPos.hitTest(souris.x, souris.y) then
    bitmap.Canvas.Draw(turnPos.x+2, turnPos.y+2, pic.Bitmap)
   else
    bitmap.Canvas.Draw(turnPos.x, turnPos.y, pic.Bitmap);

   pic.LoadFromLazarusResource('clean');
   if cleanPos.hitTest(souris.x, souris.y) then
    bitmap.Canvas.Draw(cleanPos.x+2, cleanPos.y+2, pic.Bitmap)
   else
    bitmap.Canvas.Draw(cleanPos.x, cleanPos.y, pic.Bitmap);

   pic.LoadFromLazarusResource('resolve');
   if solvePos.hitTest(souris.x, souris.y) then
    bitmap.Canvas.Draw(solvePos.x+2, solvePos.y+2, pic.Bitmap)
   else
    bitmap.Canvas.Draw(solvePos.x, solvePos.y, pic.Bitmap);
  end
  else
  begin
   pic.LoadFromLazarusResource('turn');
   bitmap.Canvas.Draw(turnPos.x, turnPos.y, pic.Bitmap);
   pic.LoadFromLazarusResource('clean');
   bitmap.Canvas.Draw(cleanPos.x, cleanPos.y, pic.Bitmap);
   pic.LoadFromLazarusResource('resolve');
   bitmap.Canvas.Draw(solvePos.x, solvePos.y, pic.Bitmap);
  end;


  pic.LoadFromLazarusResource('clock');
  bitmap.Canvas.Draw(clockPos.x, clockPos.y, pic.Bitmap);
  Bitmap.Canvas.Font.Color := clWhite;
  Bitmap.Canvas.Font.Size:=8;
  Bitmap.Canvas.Font.Bold:=true;
  bitmap.Canvas.Brush.Color:=$292325;
  Bitmap.Canvas.TextOut(clockPos.x+round(clockPos.d*1.3), clockPos.y+(clockPos.d div 3), temps);

end;


procedure TMyPanel.setPlateau(plat : TPlateau);
begin
 plateau:=plat;
end;

procedure TMyPanel.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
 var sa: byte;
     c: char;
     fini :boolean;
begin
 if (sudo=nil) then
  exit;
  souris.x:=x;
  souris.y:=y;
  fini:=false;
  clickOn:=true;
 {click des boutons}
 if (cleanPos.hitTest(x, y)) then
  begin
   c:='c';
   sudo.KeyPress(c);
   fini:=true;
  end;
 if(turnPos.hitTest(x, y)) then
  begin
   if(sudo.lastBut=mbRight) then
    sudo.MouseUp(mbLeft, Shift, sudo.xx, sudo.yy)
   else
    sudo.MouseUp(mbRight, Shift, sudo.xx, sudo.yy);
   fini:=true;
  end;

  if(solvePos.hitTest(x, y)) then
  begin
   resoudre;
   fini:=true;
  end;

 cx:=trunc((x-lx-xx)/dx+1);
 cy:=trunc((y-ly-yy)/dy+1);
 repaint();
 sleep(200);
 clickOn:=false;
 repaint();
 if fini then
  exit;
 sa:=0;
 case cy of
   1: if (cx=1) then sa:=1
      else if (cx=2) then sa:=2
      else if cx=3 then sa:=3;
   2: if (cx=1) then sa:=4
      else if (cx=2) then sa:=5
      else if cx=3 then sa:=6;
   3: if (cx=1) then sa:=7
      else if (cx=2) then sa:=8
      else if cx=3 then sa:=9;
 end;
 c:=char(ord('0')+sa);
 sudo.KeyPress(c);

end;

procedure TMyPanel.MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin

end;

procedure TMyPanel.resoudre();
 var   solv : TThreadSolve;
begin
 if plateau=nil then
  begin
   showMessage('Impossible de resoudre une grille nulle');
   exit;
  end;

 solv:=TThreadSolve.create(true);
 solv.setDisplay(sudo);
 solv.setPlateau(plateau);
 solv.pan:=self;
 {$IF DEFINED(LINUX)}
  solv.execute;
  {$ELSE}
  solv.resume;
  {$ENDIF}
end;

initialization
  {$I design.lrs}
end.
