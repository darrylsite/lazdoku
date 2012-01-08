{*********************************************************
 ** Analyse une grille donnee pour trouver d'eventuelles *
 ** erreurs                                              *
 *********************************************************}


unit utcontrolor;

{$mode objfpc}{$H+}

interface

uses
     UTPlateau, UTGroupControlor, utConst;

type  TControlor= class
                   private

                     procedure analyzeLine();
                     procedure analyzeGroup();
                     procedure detectErrorLine(nb: byte; line : byte);
                     procedure detectErrorCol(nb: byte; column : byte);

                    public

                     constructor init(plat : TPlateau);
                     constructor init2();
                     procedure analyze();
                     function isInOrder() :boolean;
                     function isComplete() : boolean;

                     {:(}
                     public
                     plateau : TPlateau;
                     ordre : boolean;
                  end;

implementation

 constructor TControlor.init(plat : TPlateau);
 begin
  plateau:=plat;
 end;

 constructor TControlor.init2();
 begin
 end;

 {**
  **  determine si toutes les cases ont ete choisi
  **  @return true si toutes les cases ont ete choisie, false sinon
 **}
 function TControlor.isComplete() : boolean;
 var i, j : byte;
     choisi: boolean;
 begin
  choisi:=true;
  for i:= 1 to tDim do
  begin
   if (not choisi) then
    break;
   for j:=1 to tDim do
    if (not plateau.tableau[i, j].choisi) then
    begin
     choisi:= false;
     break;
     end;
   end;

  isComplete:=choisi;
 end;

 {**
  **  indique si il y a des erreur lors du remplissage des cases
  **  @return true si toutes les cases ont ete bien remplie, false sinon
  **  @require une analyse doit etre effectuee avant l'appel de cette methode
 **}
 function TControlor.isInOrder() :boolean;
 begin
  isInOrder:=ordre;
 end;

 {**
  ** cherche si il y'a des erreur sur une ligne, en comptant le nombre
  ** d'occurence d'un chiffre sur la ligne
  **}
 procedure TControlor.detectErrorLine(nb: byte; line : byte);
   var i, cpt : byte;
 begin
 cpt:=0;
 for i:=1 to tDim do
  begin
   if (plateau.tableau[line, i].choisi) then
     if(plateau.tableau[line, i].choix=nb) then
     begin
      inc(cpt);
      if cpt=2 then
       begin
        ordre:=false;
        exit;
       end;
     end;
  end;
 ordre:=true;
 end;

 {**
  ** cherche si il y'a des erreur sur une colonne, en comptant le nombre
  ** d'occurence d'un chiffre sur la colonne
  **}
 procedure TControlor.DetectErrorCol(nb: byte; column : byte);
   var i, cpt : byte;
 begin
 cpt:=0;
 for i:=1 to tDim do
  begin
   if (plateau.tableau[i, column].choisi) then
     if(plateau.tableau[i, column].choix=nb) then
     begin
      inc(cpt);
      if cpt=2 then
      begin
       ordre:=false;
       exit;
      end;
     end;
  end;
 ordre:=true;
 end;


 {**
  ** analize les lignes et colonnes du tableau afin de detecter d'eventuelles erreurs
 **}
 procedure TControlor.analyzeLine();
  var l, i : byte;
 begin
  for l:=1 to tDim do
   for i:=1 to tDim do
    begin
      detectErrorLine(l, i);
      if ordre then        {one stone to kill to birds}
       detectErrorCol(l, i);
      if not ordre then exit;
    end;
 end;


 {**
  ** analize les regions du tableau afin de detecter d'eventuelles erreurs
 **}
 procedure TControlor.analyzeGroup();
  var cont : TGroupControlor;
      i, j : byte;
 begin
  cont:=TGroupControlor.init(nil);
   for i:=1 to gDim do
    for j:=1 to gDim do
    begin
     cont.groupe:=plateau.groupes[i, j];
     cont.analyze();
     ordre:=ordre and cont.ordre;
     if not ordre then
      exit;
    end;
 end;

 {**
  **analyse le tableau afin de detecter d'eventuelles erreurs
 **}
 procedure TControlor.analyze();
 begin
   ordre:=true;
   analyzeLine();
   if  ordre then
    analyzeGroup();
 end;

end.

