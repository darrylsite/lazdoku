{**********************************************************
 **cette classe modelise une case sur la grille de sudoku *
 **@author Kpizingui Darryl                               *
 **********************************************************}

unit UTCase;

{$mode objfpc}{$H+}

interface
uses utConst;

Type
     TCase =class
              protected

              public

               constructor initchoix(choice : byte);
               constructor init;
               constructor cinit();
               function isHidden : boolean;
               procedure setHidden(hide : boolean);
               function getChoice : byte;
               procedure setChoice( choice: byte);
               function isChoosen() : boolean;
               procedure addPossibility(pos : byte);
               function getPossibility(index : byte) : byte;
               function getPossibilitySize : byte;
               procedure clearPossibility(poss : byte);
               procedure clearAllPossibility();
               function existPossibility(poss : byte) : boolean;
               procedure clearChoice;
               procedure setPosition(x, y : byte);
               function getX() : byte;
               function getY() : byte;
               function cloner() : TCase;
               function isMorePossibility() : boolean;

               procedure fillPossibility();
               procedure doChoice();

               {:(}
               public
               cacher : boolean;
               choix  : byte;
               choisi : boolean;
               possibilite: array[1..tDim] of byte;
               positionx : byte;
               positionY : byte;
            end;


implementation


  {*
  **cree une case dont le chiffre contenu dans la case est devoilé
  **@param choix le chiffre devoilé à mettre dans la case
  *}
constructor TCase.initChoix(choice : byte);
 //var i: byte;
 begin
  cacher:=false;
  choix:= choice;
  choisi:=true;
  //for i:=1 to tDim do
  //possibilite[i]:=0;
 end;

 {*
  **cree une nouvelle case dont le chiffre contenu dans la case n'est pas
  **devoilé
  *}
 constructor TCase.init();
 begin
  cacher:=true;
  choisi:=false;
  choix:=0;
 end;

 constructor TCase.cinit();
 begin
 end;
   {*
   **@return retourne true si au depart le chiffre retenu pour cette case
   **a ete cache, false sinon
   **@see setHidden
   *}
 function TCase.isHidden : boolean;
  begin
   isHidden := cacher;
  end;

  procedure TCase.setHidden(hide : boolean);
   begin
    cacher:=hide;
   end;

 {*
  **donne le chiffre retenu pour cette case
  **@require isChoosen=true
  **@return retourne le chiffre retenu pour cette case
  **@see setChoice
  *}
 function TCase.getChoice : byte;
  begin
   getChoice:= choix;
  end;

 procedure TCase.setChoice( choice: byte);
  begin
   choisi:=true;
   choix:=choice;
  end;

  {*
   **indique si un chiffre a ete retenu pour cette case
   **@return  true si un chiffre a ete retenu, false sinon
   *}
  function TCase.isChoosen() : boolean;
   begin
    isChoosen := choisi;
   end;

  {*
   **ajoute un nouveau candidat pour cette case
   *}
  procedure TCase.addPossibility(pos : byte);
   begin
     possibilite[pos]:=pos;
   end;

    {*
    **@param index l'indice du candidat dans la liste des candidat
    **@return retourne la valeur du candidat
    **@require (0 < index) and (index <= nbPossibilite)
    **
    *}
  function TCase.getPossibility(index : byte) : byte;
   var i, n :byte;
   begin
    n:=0;
    for i:=1 to tDim do
     if (possibilite[i]<>0) then
      begin
       inc(n);
       if (n=index) then
        begin
         getPossibility:=possibilite[i];
         break;
        end;
      end;
   end;

   {*
   **donne le nombre de candidat inscrit pour cette case
   **@return le nombre de possibilite
   *}
   function TCase.getPossibilitySize() : byte;
    var i, c : byte;
    begin
    c:=0;
    for i:=1 to tDim do
     if (possibilite[i]<>0) then
      inc(c);
     getPossibilitySize:=c;
    end;

    {**
    ** determine si il y a plus d'un candidat dans la case
    **@return true si il y a au plus un candidat, false sinon
    **}
    function TCase.isMorePossibility() : boolean;
     var i, c : byte;
    begin
     c:=0;
    for i:=1 to tDim do
     if (possibilite[i]<>0) then
     begin
      inc(c);
      if (c>1) then
       begin
        isMorePossibility:=false;
         exit;
       end;
     end;
    isMorePossibility:=true;
    end;

    {*
    **indique si un chiffre donne appartient à la liste des candidat
    **@param le chiffre à verifie
    **@return retourne true si pos appartient à la liste des candidats,
    ** false sinon
    *}
   function TCase.existPossibility(poss : byte) : boolean;
    begin
     existPossibility:=possibilite[poss]=poss;
    end;

    {*
    **efface un chiffre donnee dans la liste des candidats
    **@param le chiffre à effacer
    *}
    procedure Tcase.clearPossibility(poss : byte);
    begin
      possibilite[poss]:=0;
    end;

   procedure TCase.clearChoice;
    begin
     choisi:=false;
    end;

   {**
   ** enregistre la position de la case sur le plateau
   **}
   procedure TCase.setPosition(x, y : byte);
   begin
    positionX:=x;
    positionY:=y;
   end;

   {**
    ** indique le nomero de la ligne sur laquelle se trouve la case
    **}
   function TCase.getX() : byte;
   begin
    getX:=positionX;
   end;

   {**
   ** indique le nomero de la colonne sur laquelle se trouve la case
   **}
   function TCase.getY() : byte;
   begin
    getY:=positionY;
   end;

   {**
    ** remplit toutes les possibilies de la cases
   **}
   procedure TCase.fillPossibility();
    var i : byte;
   begin
    for i:=1 to tDim do
     possibilite[i]:=i;
   end;

   procedure TCase.clearAllPossibility();
    var i : byte;
   begin
    for i:=1 to tDim do
     possibilite[i]:=0;
   end;

 function TCase.cloner() : TCase;
  var ca : TCase;
      i : byte;
 begin
  ca :=TCase.cinit();
  ca.cacher:=cacher;
  ca.choix:=choix;
  ca.choisi:=choisi;
  ca.positionX:=positionX;
  ca.positionY:=positionY;
  for i:=1 to tDim do
   ca.possibilite[i]:=possibilite[i];

  cloner:= ca;
 end;

 procedure TCase.doChoice();
  var i:byte;
 begin
    for i:=1 to tDim do
     if (possibilite[i]<>0) then
     begin
      choix:=i;
      choisi:=true;
      exit;
     end;
end;

end.
