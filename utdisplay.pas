{************************************************************
 ** Graphisme :                                              *
 ** Definit le controle permettant l'affichage de la grille *
 ************************************************************}

unit utdisplay;

{$mode objfpc}{$H+}

interface

uses
 Classes,  SysUtils, LCLType, Controls, Graphics,  UTPlateau, Dialogs, Forms;

type
  TMyDrawingControl = class(TCustomControl)
                       private
                       plateau : TPlateau;

                        dx, dy : real;
                        lx, ly : byte;
                        des : boolean;
                        px, py : word;
                        clickOn : boolean;
                        mouseTp : boolean;
                        procedure dessiner(Bitmap: TBitmap);
                        private
                        clickCol, rectCol, fixCol, searchCol : TColor;
                       public
                        constructor Create(AOwner: TComponent);override;
                        procedure EraseBackground(DC: HDC); override;
                        procedure Paint; override;
                        procedure setDraw(b : boolean);
                        procedure setPlateau(plat : TPlateau);

                        procedure KeyPress(var Key: char); override;
                        procedure click; override;
                        procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
                        public
                        form : TForm;
                        xx, yy : integer;
                        lastBut : TMouseButton;
                       end;

implementation

constructor TMyDrawingControl.Create(AOwner: TComponent);
begin
 inherited create(AOwner);
 des:= false;
 clickOn:=false;
 clickCol:= TColor($00D9FF);
 dx:=(Width-4)/9;
 dy:=(Height-4)/9;
 lx:=1;
 ly:=1;
 rectCol:= clGray;
 fixCol:= clRed;
 searchCol:= clBlack;
 mouseTp:=false;
 plateau:=TPlateau.init;
 des:=true;
end;

procedure TMyDrawingControl.EraseBackground(DC: HDC);
begin
end;

procedure TMyDrawingControl.Paint;
var
  x, y: Integer;
  Bitmap: TBitmap;
begin
  lx:=1;
  ly:=1;
  Bitmap := TBitmap.Create;
  dx:=(Width-4)/9;
  dy:=(Height-4)/9;

  try
    // Initializes the Bitmap Size
    Bitmap.Height := Height;
    Bitmap.Width := Width;
    //backgroung
    Bitmap.Canvas.Pen.Color:=clGray;
    Bitmap.Canvas.Pen.Width:=2;
    Bitmap.Canvas.RoundRect(0, 0, Width, Height, 10, 10);

    Bitmap.Canvas.Pen.Color := clGray;
    Bitmap.Canvas.Pen.Width:=1;
    for x := 1 to 9 do
     for y := 1 to 9 do
      Bitmap.Canvas.RoundRect(lx+Round((x - 1) * dx+2),ly+ Round((y - 1) * dy+2),lx+ Round(x * dx-2),ly+ Round(y * dy-2), 5, 5);
     if (clickOn) then
     begin
      bitmap.Canvas.Brush.Color:=clickCol;
      bitmap.Canvas.FloodFill(lx+Round((px - 1) * dx+5),ly+ Round((py - 1) * dy+5), clGray, fsBorder);
     end;

    Bitmap.Canvas.Pen.Color:=clGray;
    Bitmap.Canvas.Pen.Width:=Bitmap.Canvas.Pen.Width+1;

    for x:=1 to 2 do
     begin
      Bitmap.Canvas.Line(lx+0, ly+Round( x*3*dy),lx+ Width,ly+ Round(x*3*dy));
       Bitmap.Canvas.Line(lx+Round( x*3*dx), ly+ 0,lx+ Round(x*3*dx),ly+ Height);
     end;

     if (des) then
       dessiner(Bitmap);

    Canvas.Draw(0, 0, Bitmap);
  finally
    Bitmap.Free;
  end;

  inherited Paint;
end;


procedure TMyDrawingControl.dessiner(Bitmap: TBitmap);
 var i, j, k, x , y : byte;
     ch : String;
begin
 for i:=1 to 9 do
  for j:=1 to 9 do
   begin
   if clickon then
   if (i=py) and (j=px) then
    bitmap.Canvas.Brush.Color:=clickCol
   else
    bitmap.Canvas.Brush.Color:=TColor($FFFFFF);
    if (plateau.getCase(i, j).isChoosen()) then
     begin
     Bitmap.Canvas.Font.Size:=12;
     Bitmap.Canvas.Font.Bold:=true;
      if (plateau.getCase(i, j).isHidden()) then
       Bitmap.Canvas.Font.Color:= clBlack
      else
       Bitmap.Canvas.Font.Color :=clRed;
       str(plateau.getCase(i, j).getChoice(), ch);
       Bitmap.Canvas.TextOut(round((j-1)*dx+dx/2-Bitmap.Canvas.TextWidth(ch)/ 2), round((i-1)*dy+dy/2-Bitmap.Canvas.TextHeight(ch)/2), ch);
     end
     else
      begin
        Bitmap.Canvas.Font.Color := clBlack;
        Bitmap.Canvas.Font.Size:=7;
        Bitmap.Canvas.Font.Bold:=false;
        x:=0;
        y:=0;
        for k:=1 to plateau.getCase(i, j).getPossibilitySize() do
         begin
          str(plateau.getCase(i, j).getPossibility(k), ch);
          Bitmap.Canvas.TextOut(round((j-1)*dx+(x*dx/3)+5), round(5+(i-1)*dy+(y*dy/4)), ch);
          inc(x);
          if (x>2) then
           begin
            x:=0;
            inc(y);
           end;
         end;
      end;
    end;
end;

procedure TMyDrawingControl.setDraw(b : boolean);
begin
 des:=b;
end;

procedure TMyDrawingControl.setPlateau(plat : TPlateau);
begin
 plateau:=plat;

end;

procedure TMyDrawingControl.KeyPress(var Key: char);
 var c: byte;
begin
if (plateau=nil) then
 exit;

des:=true;
c:=ord(key)-ord('0');
 if (key='c') or (key='C') then
 begin
  if (mouseTp) then
  plateau.getCase(pY, pX).clearChoice
 else
  plateau.getCase(pY, pX).clearAllPossibility();
 repaint;
 exit;
end;

 if not(key in ['1'..'9']) then
  exit;
 if (mouseTp) then
  plateau.getCase(pY, pX).setChoice(c)
 else
  plateau.getCase(pY, pX).addPossibility(c);

 repaint;

end;

procedure TMyDrawingControl.click;
begin
  //form.ActiveControl:=self;
end;

procedure TMyDrawingControl.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
  form.ActiveControl:=self;
 if (button=mbLeft) then
  begin
   mouseTp:=true;
   clickCol:= TColor($00D9FF);
   lastBut:=button;
  end
 else
  begin
   mouseTp:=false;
   clickCol:=TColor($669999);
   lastBut:=button;
  end;

 px:=trunc((x-lx-2)/dx+1);
 py:=trunc((y-ly-2)/dy+1);
 xx:=x;
 yy:=y;
 clickOn:=true;
 self .Repaint;
end;

end.
