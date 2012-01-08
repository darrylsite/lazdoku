{**********************************************
 ** cette classe modelise la grille de sudoku *
 **********************************************}

unit UTPlateau;

{$mode objfpc}{$H+}

interface

uses UTCase, UTGroup, utConst;

type
          TPlateau =class
              protected

               procedure createGroup;
               procedure createCase;

              public
               tableau : array[1..tDim, 1..tDim] of TCase;
               groupes : array[1..gDim, 1..gDim] of TGroup;
               constructor init;
               constructor cloner(plat : TPlateau);
               function getCase(i, j: byte) : TCase;
               function getGroup(i,  j : byte) : TGroup;
               function findOnLine(index : byte; choice : byte) : boolean;
               function findOnColumn(index : byte; choice: byte) : boolean;

            end;


implementation


constructor TPlateau.init;
 begin
  createCase;
  createGroup;
 end;

 constructor TPlateau.cloner(plat : TPlateau);
 var i, j : byte;
  begin
   for i:=1 to tDim do
    for j:=1 to tDim do
     tableau[i, j]:= plat.tableau[i, j].cloner();
   createGroup;
  end;

 {**
  ** cree et initialise les cases du plateau
  **}
 procedure TPLateau.createCase;
  var i, j : byte;
  begin
   for i:=1 to tDim do
    for j:=1 to tDim do
    begin
     tableau[i, j]:= TCase.init();
     tableau[i, j].setPosition(i, j);
     end;
  end;

  {**
   **cree et initialise les regions que nous appelons ici group
   **
   **}
  procedure TPlateau.createGroup();
   var i, j, a, b, c, d : byte;
  begin
   for i:=1 to gDim do
    for j:=1 to gDim do
      groupes[i, j]:= TGroup.init;

   for i:=1 to tDim do
    for j:=1 to tDim do
    begin
     case i of
      1, 2, gDim : a:=1;
      4, 5, 6 : a:=2;
      7, 8, tDim : a:=gDim;
     end;
     case j of
      1, 2, gDim : b:=1;
      4, 5, 6 : b:=2;
      7, 8, tDim : b:=gDim;
     end;
     case i of
      1, 4, 7 : c:=1;
      2, 5, 8 : c:=2;
      gDim, 6, tDim : c:=gDim;
     end;

     case j of
      1, 4, 7 : d:=1;
      2, 5, 8 : d:=2;
      gDim, 6, tDim : d:=gDim;
     end;

     groupes[a, b].tableau[c, d]:= tableau[i, j];
    end;

  end;

  {**
   **@param i, j position horizontale et verticale de la case
   **sur le plateau
   **@return l'objet case situé à la position i, j
   **@require 1<=i,j<=tDim
  **}
  function TPlateau.getCase(i, j: byte) : TCase;
  begin
   getCase:= tableau[i, j];
  end;

  {**
   **@param i, j position horizontale et verticale de la region
   **sur le plateau
   **@return l'objet group situé à la position i, j
   **@require 1<=i,j<=gDim
   **}
   function TPlateau.getGroup(i, j : byte) : TGroup;
   begin
     getGroup:=groupes[i, j];
   end;

   {**
    **determine si un chiffre donné se trouve sur une ligne
    **@param index le numero de la ligne
    **@param choice le chiffre a rechercher
    **@return retourne true si le chiffre a été trouvé, false sinon
    **@require  (1<=index<=tDim) and (1<=choice<=tDim)
    **}
   function TPlateau.findOnLine(index : byte; choice : byte) : boolean;
    var i : byte;
        trouve : boolean;
   begin
   trouve:=false;
   i:=1;
   while (not trouve) and (i<=tDim) do
    begin
    if (tableau[index, i].choisi) then
     if(tableau[index, i].choix=choice)  then
      trouve:=true;
     inc(i);
    end;

    findOnLine:=trouve;
   end;

   {**
    **determine si un chiffre donné se trouve sur une colonne
    **@param index le numero de la colonne
    **@param choice le chiffre à rechercher
    **@return retourne true si le chiffre a été trouvé, false sinon
    **@require  (1<=index<=tDim) and (1<=choice<=tDim)
    **}
   function TPlateau.findOnColumn(index : byte; choice : byte) : boolean;
    var i : byte;
        trouve : boolean;
   begin
   trouve:=false;
   i:=1;
   while (not trouve) and (i<=tDim) do
    begin
    if (tableau[index, i].choisi) then
     if(tableau[index, i].choix=choice) then
      trouve:=true;
     inc(i);
    end;

    findOnColumn:=trouve;
   end;

end.

