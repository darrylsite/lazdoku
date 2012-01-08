{****************************************************************************
 ** cette classe permet la generation des candidats des differentes cases   *
 ** d'une grille de sodoku                                                  *
 **@author Kpizingui Darryl                                                 *
 ****************************************************************************}

unit utgenerator;

{$mode objfpc}{$H+}

interface

uses
     UTPlateau, UTGroup, utConst;

 type TGenerator= class
                   private

                    plateau : TPlateau;

                    procedure generateGroup();
                    procedure generateOneGroup(gp : TGroup);
                    procedure generateColumn();
                    procedure generateLine();

                   public

                    constructor init(plat : TPlateau);
                    procedure generate();
                  end;


implementation

constructor  TGenerator.init(plat : TPlateau);
 var i, j : byte;
begin
 plateau:= plat;
 for i:=1 to tDim do
  for j:=1 to tDim do
   if (not plateau.tableau[i, j].choisi) then
    plateau.tableau[i, j].fillPossibility();
end;


{**
 ** l'algorithme utilise est que on charge chaque case incertaine avec les neuf candidats
 ** en suite pour une region, ligne ou colonne donnee, on enleve les choix certains
 ** des candidats des autres cases qui figurent dans la meme region, ligne ou colonne
**}

{**
** genere les possibilites pour une region donnee
** @param gp la region a traitee
**}
procedure TGenerator.generateOneGroup(gp : TGroup);
 var i, j, k, l : byte;
begin
 for i:=1 to gDim do
  for j:=1 to gDim do
   if(not gp.tableau[i, j].choisi) then
    for k:=1 to gDim do
     for l:=1 to gDim do
     if(gp.tableau[k, l].choisi) then
      if ((i<>k) and (j<>l)) then
       gp.tableau[i, j].possibilite[gp.tableau[k, l].choix]:=0;
end;

{**
 ** genere les possibilites pour toutes les regions
**}
procedure TGenerator.generateGroup();
 var i, j : byte;
begin
 for i:=1 to gDim do
  for j:=1 to gDim do
   begin
    generateOneGroup(plateau.groupes[i, j]);
   end;
end;

{**
 ** genere les possibilites pour toutes les colonnes
**}
procedure TGenerator.generateColumn();
 var i, j, cl : byte;
begin
for cl:=1 to tDim do
 for i:=1 to tDim do
  if(not plateau.tableau[i, cl].choisi) then
   for j:=1 to tDim do
    if(plateau.tableau[j, cl].choisi) then
     if (i<>j) then
      plateau.tableau[i, cl].possibilite[plateau.tableau[j, cl].choix]:=0;
end;

{**
 ** on genere les possibilites pour toutes les lignes
**}
procedure TGenerator.generateLine();
 var i, j, l : byte;
begin
for l:=1 to tDim do
 for i:=1 to tDim do
  if(not plateau.tableau[l, i].choisi) then
   for j:=1 to tDim do
    if(plateau.tableau[l, j].choisi) then
     if (i<>j) then
      plateau.tableau[l, i].possibilite[plateau.tableau[l, j].choix]:=0;
end;

{**
 ** on genere les possibilites pour toutes les cases du tableau
**}
procedure TGenerator.generate();
begin
 generateColumn();
 generateLine();
 generateGroup();
end;

end.
