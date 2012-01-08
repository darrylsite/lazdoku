{***********************************************************
 ** thread permettant de lancer la resolution d'une grille *
 ***********************************************************}

unit uthreadsolve;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UTPlateau, UTIAsolver, UTDisplay, UTControlor, EpikTimer, UTGenerator, Dialogs,
   lclproc;


  type TThreadSolve= class(TThread)

                      private
                       plateau : TPlateau;
                       solveur : TIASolver;
                       display : TMyDrawingControl;
                       tps : extended;
                       ordre : boolean;
                       //les methodes
                       procedure control;
                       procedure reDisplay;
                       procedure displayResult;
                      public
                      //les constructeur
                       constructor create(sus : boolean);
                       //les setters
                       procedure setPlateau(plat : TPlateau);
                       procedure setDisplay(dp : TMyDrawingControl);
                       //getter
                       function isInOrder() : boolean;
                       //function getTime() : String;
                       procedure execute; override;
                       public
                       pan : TObject;
                     end;



implementation
 uses utpanels;

constructor TThreadSolve.create(sus : boolean);
begin
{$IF DEFINED(LINUX)}
  {$ELSE}
  inherited Create(sus);
  {$ENDIF}
 FreeOnTerminate := True;
end;

procedure TThreadSolve.execute;
 var gen : TGenerator;
     timer : TEpikTimer;
     var i, j : byte;
begin

  //controle de la grille
  Synchronize(@control);
  if not ordre then
   exit;

   for i:=1 to 9 do
    for j:=1 to 9 do
     if(plateau.tableau[i, j].choisi) then
      plateau.tableau[i, j].setHidden(false);
   //resolution
   gen:= TGenerator.init(plateau);
   gen.generate();
   solveur:= TIASolver.init(plateau);
   solveur.countunVeil();

   timer:= TEpikTimer.Create(display);
   timer.Clear;

   timer.Start;
   solveur.solve();
   timer.Stop;
   tps:=timer.Elapsed;

   //fin resolution
   Synchronize(@control);
   if not ordre then
    exit;
 //affichage de la grille
  Synchronize(@reDisplay);

end;

procedure TThreadSolve.reDisplay;
begin
 display.Repaint;
 displayResult;
end;


procedure TThreadSolve.setPlateau(plat : TPlateau);
begin
 plateau:=plat;
end;

procedure TThreadSolve.setDisplay(dp : TMyDrawingControl);
begin
 display:=dp;
end;

procedure TThreadSolve.control;
 var cont : TControlor;
begin
 ordre:=true;
 cont:= TControlor.init(plateau);
 cont.analyze();
 if not cont.isInOrder() then
  begin
   showMessage('la grille contient des erreurs');
   ordre:=false;
  end;
end;

function TThreadSolve.isInOrder() : boolean;
begin
 isInOrder:= ordre;
end;


procedure TThreadSolve.displayResult;
 var pn : TMyPanel;
     s, ms, mms : integer;
     st, mst, mmst : string;
begin

    s:=trunc(tps);
    tps:=(tps-s)*1000;
    ms:=trunc(tps);
    tps:=(tps-ms)*1000;
    mms:=trunc(tps);

    str(s, st);
    if(s<10) then
     st:='0'+st;

    str(ms, mst);
    if(ms<10)  then
     mst:='00'+mst
    else if(ms<100)  then
     mst:='0'+mst;

    str(mms, mmst);
    if(mms<10) then
     mmst:='00'+mmst
     else if(mms<100) then
     mmst:='0'+mmst;

  pn:=TMYpanel(pan);
  pn.temps:=st+':'+mst+':'+mmst+' S';
  pn.Repaint;
end;


end.

