{************************************************************
 **cette classe modelise une region sur la grille de sudoku *
 **@author Kpizingui Darryl                                 *
 ************************************************************}

unit UTGroup;

{$mode objfpc}{$H+}

interface
  uses UTCase, utConst;
Type

     TGroup =class
              private

              public

               constructor init();
               procedure setCase(i, j : byte; cases : TCase);
               function getCase(i, j : byte) : TCase;
               function containsChoice(choice : byte) : boolean;
               function containsChoiceOnLine(index : byte; choice : byte) : boolean;
               function containsChoiceOnColumn(index : byte; choice : byte) : boolean;
               function countChoice(choice : byte) : byte;
               function countDigit( nb : byte) : byte;

               {:(}
               public
               tableau : array[1..gDim, 1..gDim] of TCase;

            end;



implementation


  constructor TGroup.init();
  begin
  end;

  procedure TGroup.setCase(i, j : byte; cases : TCase);
  begin
   tableau[i, j]:= cases;
  end;

  function TGroup.getCase(i, j : byte) : TCase;
  begin
   getCase:= tableau[i, j];
  end;

  {**
   **determine si un chiffre donné se trouve dans la region
   **@param choice: le chiffre à recherché
   **@return retourne true si le chiffre est trouvé, false sinon
   **@require 1<=choice<=9
   **}
  function TGroup.containsChoice(choice : byte) : boolean;
   var i, j :integer;
       trouve : boolean;
  begin
   trouve:=false;
   for i:=1 to gDim do
    for j:=1 to gDim do
     if(tableau[i, j].isChoosen) and (tableau[i, j].getChoice=choice) then
      trouve:=true;
    containsChoice:=trouve;
  end;

  {**
   **determine si un chiffre donné se trouve sur une ligne
   **@param index le numero de la ligne
   **@param choice: le chiffre à recherché
   **@return retourne true si le chiffre est trouvé, false sinon
   **@require (1<=choice<=9) and (1<=index<=9)
   **}
  function TGroup.containsChoiceOnLine(index : byte; choice: byte) : boolean;
  var j :integer;
       trouve : boolean;
  begin
   trouve:=false;
    for j:=1 to gDim do
     if(tableau[index, j].isChoosen) and (tableau[index, j].getChoice=choice) then
      trouve:=true;
    containsChoiceOnLine:=trouve;
  end;

  {**
   **determine si un chiffre donné se trouve sur une colonne
   **@param index le numero de la colonne
   **@param choice: le chiffre à recherché
   **@return retourne true si le chiffre est trouvé, false sinon
   **@require (1<=choice<=9) and (1<=index<=9)
   **}
  function TGroup.containsChoiceOnColumn(index : byte; choice : byte) : boolean;
  var i:integer;
       trouve : boolean;
  begin
   trouve:=false;
   for i:=1 to gDim do
     if(tableau[i, index].isChoosen) and (tableau[i, index].getChoice=choice) then
      trouve:=true;
    containsChoiceOnColumn:=trouve;
  end;

  {**
   **compte le nombre de fois qu'un chiffre aparait dans le groupe
   **@param choice le chiffre dont le nombre d'occurence doivent etre determiné
   **@return le nombre d'occurence
   @require 1<=choice<=9
   **}
  function TGroup.countChoice(choice : byte) : byte;
   var i, j, nb : byte;
  begin
  nb:=0;
   for i:=1 to gDim do
    for j:= 1 to gDim do
     if (tableau[i, j].choisi) and (tableau[i, j].choix=choice) then
      inc(nb);

   countChoice:=nb;
  end;

function TGroup.countDigit( nb : byte) : byte;
 var i, j, cpt : byte;
begin
 cpt :=0;
 for i:=1 to gDim do
  for j:=1 to gDim do
   if (tableau[i, j].existPossibility(nb)) then
    inc(cpt);
  countDigit:=cpt;
end;


end.

