{******************************************************
 ** Analyse une region donnee pour trouver d'eventuel *
 ** erreurs                                           *
 ******************************************************}

unit UTGroupControlor;

{$mode objfpc}{$H+}

interface

uses
   UTGroup, utConst;


 type TGroupControlor= class
                         private


                           procedure detectError(nb : byte);
                          public

                          constructor init(group : TGroup);
                          procedure Analyze;
                          function isInOrder : boolean;
                          function isComplete : boolean;

                          {:(}
                          public
                          ordre : boolean;
                          groupe : TGroup;
                        end;


implementation


{**
 ** le constructeur de la classe
 **@param group indique le groupe a controle
**}
constructor TGroupControlor.init(group : TGroup);
 begin
  groupe:= group;
 end;

 {**
  ** indique si la region contient des erreurs
  ** @return true retourne true si tout est en ordre, false sinon
 **}
 function TGroupControlor.isInOrder : boolean;
  begin
   isInOrder:=ordre;
  end;

 {**
  ** indique si toutes les cases de la regions ont ete renseignees
  ** @return true si toutes les cases sont renseignees, false sinon
 **}
 function TGroupControlor.isComplete : boolean;
  var i, j : byte;
     choisi: boolean;
 begin
  choisi:=true;
  for i:= 1 to gDim do
  begin
   if (not choisi) then
    break;
   for j:=1 to gDim do
    if (not groupe.tableau[i, j].choisi) then
    begin
     choisi:= false;
     break;
     end;
   end;
  isComplete:=choisi;
 end;

 procedure TGroupControlor.detectError(nb : byte);
  var i, j, cpt : byte;
 begin
 cpt:=0;
 for i:=1 to gDim do
  for j:=1 to gDim do
    if (groupe.tableau[i, j].choisi) then
     if(groupe.tableau[i, j].choix=nb) then
     begin
      inc(cpt);
      if cpt=2 then
      begin
        ordre:=false;
       exit;
       end;
     end;
 end;

 {**
  **analyse la region afin de detecter d'eventuelles erreurs
 **}
 procedure TGroupControlor.analyze;
  var  k : byte;
 begin
  ordre:=true;
  for k:=1 to tDim do
  begin
   detectError(k);
   if (not ordre) then
    break;
  end;
 end;
end.
