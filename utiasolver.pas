{************************************************************
 ** Classe permettant la resolution d'une grille de sudoku  *
 ** la methode de la resolution est une methode hibride     *
 ** force brute+logique
 ************************************************************}

unit utiasolver;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UTPlateau, UTGroup, UTArraylist, UTCase, UTControlor,  Dialogs, utConst;

 type TIASolver = class
                   private
                    plateau : TPlateau;
                    modif : boolean;
                    control : TControlor;

                    procedure eleminatePossibility(i, j, p : byte);

                    procedure searchGroupOnePos();
                    procedure searchLineOnePos();
                    procedure searchColumnOnePos();

                    procedure searchGroupMultiple(nb : byte);
                    procedure searchLineMultiple(nb : byte);
                    procedure searchColumnMultiple(nb : byte);

                    procedure searchGroupInnerParity();
                    procedure searchLineInnerParity();
                    procedure searchColumnInnerParity();

                    procedure searchgLineGroupOnlyPos();
                    procedure searchColumnGroupOnlyPos();

                    procedure pseudoSolve();

                    procedure searchGroupLine();
                    procedure searchGroupColumn();

                    procedure fixOnePossibility();
                    procedure searchOnePossibility();
                    procedure searchMultiple(nb : byte);
                    procedure searchInnerParity();
                    procedure searchgroupOnlyPos();
                    procedure searchGroup();
                    procedure logic();

                    public

                    constructor init(plat : TPlateau);
                    procedure solve();
                    function getPlateau() : TPlateau;
                    function fcountUnveil() : byte;
                    procedure setUnveil(b : byte);
                    procedure countunVeil();

                    {:(}
                    public
                    devoile : byte;
                    findSol : boolean;
                    solPlat : TPLateau;
                  end;


implementation

{**
 ** construit la classe et initialise les parametres
**}
constructor TIASolver.init(plat : TPlateau);
begin
 plateau:=plat;
 findSol :=false;
end;

{compte le nombre de chiffre devoile}
function TIASolver.fcountUnveil() : byte;
begin
 countUnveil();
 fcountUnveil:= devoile;
end;


procedure TIASolver.setUnveil(b : byte);
begin
 devoile :=b;
end;

{resolution logique}
procedure TIASolver.logic();
begin
 {resolution logique ...}
  modif:=true;
  while (modif) and (devoile<81)  do
  begin
    modif:=false;
   searchOnePossibility();
    if(devoile=81) then exit;
    {recherche de paires}
   searchColumnMultiple(2);
    if modif then continue;
   searchLineMultiple(2);
    if modif then continue;
    searchGroupMultiple(2);
     if modif then continue;
   {recherche de paires cachees}
   //searchGroupInnerParity();
   searchLineInnerParity();
    if modif then continue;
   searchColumnInnerParity();
  end;
end;

{logique+force brute}
procedure  TIASolver.solve();
 var i, j, c, a, b : byte;
     plat : TPlateau;
     solveur : TIASolver;
     trouve : boolean;
begin
  logic();
  if devoile>80 then
   exit;

  {force brute ...}
   c:=10;
   trouve:=false;
   for i:=$1 to tDim do
   begin
   if (trouve) then
   break;
    for j:=$1 to tDim do
     if (not plateau.tableau[i, j].choisi) then
      if (plateau.tableau[i, j].getPossibilitySize()<c) then
       begin
        a:=i;
        b:=j;
        c:=plateau.tableau[i, j].getPossibilitySize();
        if (c<=2) then
         begin
          trouve:=true;
          break;
         end;
       end;
      end;

   for i:=$1 to c do
    begin
     plat:=TPlateau.cloner(plateau);
     j:=plateau.tableau[a, b].getPossibility(i);
     plat.tableau[a, b].choix:=j;
     plat.tableau[a, b].choisi:=true;
     solveur:= TIASolver.init(plat);
     solveur.devoile:=succ(devoile);
     solveur.solPlat:=plateau;
     solveur.eleminatePossibility(a, b, j);
     solveur.pseudoSolve();
     if solveur.findSol then
      exit;
    end;

end;

{force brute+ logic : recursion}
procedure TIASolver.pseudoSolve();
  var i, j, c, a, b : byte;
     plat : TPlateau;
     solveur : TIASolver;
     trouve : boolean;
begin
  searchOnePossibility();
  if devoile=81 then
   exit;

  {force brute}
  {on determine la case qui contient le moins de candidats}
   c:=10;
   trouve:=false;
   for i:=$1 to tDim do
   begin
    if (trouve) then break;
    for j:=$1 to tDim do
     if (not plateau.tableau[i, j].choisi) then
      if (plateau.tableau[i, j].getPossibilitySize()<c) then
       begin
       a:=i;
       b:=j;
        c:=plateau.tableau[a, b].getPossibilitySize();
        if (c<=$2) then
        begin
         trouve:=true;
          break;
         end;
       end;
      end;

   {on essaie toutes les combinaisons possibles}
   control:= TControlor.init2();
   for i:=$1 to c do
    begin
     j:=plateau.tableau[a, b].getPossibility(i);
     plat:=TPlateau.cloner(plateau);
     plat.tableau[a, b].choix:=j;
     plat.tableau[a, b].choisi:=true;
     solveur:= TIASolver.init(plat);
     solveur.devoile:=succ(devoile);
     solveur.solPlat:=solPlat;
     solveur.eleminatePossibility(a, b, j);
     if (solveur.devoile<81) then
      solveur.pseudoSolve();
     {on quitte si la solution est dejà trouvée}
     if solveur.findsol then
     begin
      findSol:=true;
      exit;
     end;
     {on verifie la grille complete ne contient pas d'erreur}
     if solveur.devoile=81 then
     begin
     control.plateau:=plat;
     control.analyze();
     if (control.ordre) then
     begin
       solPlat.tableau:=plat.tableau;
       findSol:=true;
       exit;
     end;
    end;
    end;
end;



{**
 ** @return retourne le plateau sur lequel porte la resolution
**}
function TIASolver.getPlateau() : TPlateau;
begin
 getPlateau:=plateau;
end;

{**
 ** compte le nombre des cases dont les chiffres sont certains
**}
procedure TIASolver.countunVeil();
 var i, j, cpt : byte;
begin
 cpt:=0;
 for i:=$1 to tDim do
  for j:=$1 to tDim do
   if (plateau.getCase(i, j).choisi) then
    inc(cpt);

 devoile:=cpt;
end;

{**
 ** elemine une possibilite presente dans une case, dans les possibilites des
 ** autres cases presentes sur la meme ligne, colonne ou region.
 ** @param i numero de la ligne  ou se trouve la case
 ** @param j numero de la colonne ou se trouve la case
 ** @param p la possibilite presente dans la case(i,j) et a eleminer dans
 ** les autres cases
**}
procedure TIASolver.eleminatePossibility(i, j, p : byte);
 var a, b, x, k : byte;
     groupe : TGroup;
     cas : Tcase;
begin

 for k:=$1 to tDim do
  begin
  {pour les lignes}
  if (k<>j) then
  if (not plateau.tableau[i, k].choisi) then
   begin
    cas:= plateau.tableau[i, k];
    cas.possibilite[p]:=0;
    if (cas.isMorePossibility()) then
     begin
      cas.doChoice();
      eleminatePossibility(i, k, cas.choix);
      inc(devoile);
     end;
   end;

   {pour les colonnes}
 if (k<>i) then
  if (not plateau.tableau[k, j].choisi) then
   begin
   cas:= plateau.tableau[k, j];
   cas.possibilite[p]:=0;
    if (cas.isMorePossibility()) then
     begin
      cas.doChoice();
      eleminatePossibility(k, j, cas.choix);
      inc(devoile);
     end;
   end;

  end;

   {pour les region}
   case i of
    $1, $2, gDim: a:=$1;
    4, 5, 6: a:=$2;
    7, 8, tDim :a:=gDim;
   end;

   case j of
    $1, $2, gDim: b:=$1;
    4, 5, 6: b:=$2;
    7, 8, tDim :b:=gDim;
   end;
   groupe:= plateau.groupes[a, b];
   {determine les indices de la case de la region}

   case i of
    $1, 4, 7 : x:=$1;
    $2, 5, 8 : x:=$2;
    gDim, 6, tDim : x:=gDim;
   end;

   case j of
    $1, 4, 7 : k:=$1;
    $2, 5, 8 : k:=$2;
    gDim, 6, tDim : k:=gDim;
   end;

   for a:=$1 to gDim do
    for b:=$1 to gDim do
     if (a<>x) and (b<>k) then
     if (not groupe.tableau[a, b].choisi) then
      begin
       cas:= groupe.tableau[a, b];
       cas.possibilite[p]:=0;
       if (cas.isMorePossibility()) then
       begin
        cas.doChoice();
        eleminatePossibility(cas.positionX, cas.positionY, cas.choix);
        inc(devoile);
       end;

      end;
 end;


{**
 ** verifie dans le tableau, les cases qui n'ont qu'une seule possibilite et les fixes
**}
procedure TIASolver.fixOnePossibility();
 var i, j : byte;
begin
 for i:=$1 to tDim do
  for j:=$1 to tDim do
   if (not plateau.tableau[i, j].choisi) then
    if (plateau.tableau[i, j].isMorePossibility()) then
     begin
      plateau.tableau[i, j].doChoice();
      inc(devoile);
      eleminatePossibility(i, j, plateau.tableau[i, j].choix);
     end;
end;


 {**
  ** cherche dans les differentes regions, si dans une region donnee il existe
  ** une case qui contient un candidat qui n'apparait nulpart
  ** ailleurs dans la region, cette possibilite devient la valeur certaine
  ** de cette case
 **}
procedure TIASolver.searchGroupOnePos();
 var i, j, x, y, cpt, p: byte;
     a, b :byte;
     gp : Tgroup;
     cas: Tcase;
begin

for x:=$1 to gDim do
 for y:=$1 to gDim do {on parcours toutes les regions}
 begin
  gp:= plateau.groupes[x, y];
  for p:=$1 to tDim do
   begin
   cpt:=0;
   i:=$1;
   while i<4 do
    begin
     j:=$1;
     while j<4 do
     begin
      if not (gp.tableau[i, j].choisi) then
       begin
        if (gp.tableau[i, j].possibilite[p]=p) then
         begin
          inc(cpt);
          if (cpt=$2) then
           begin
            i:=4;
            j:=4;
            continue;
           end;
          a:=i;
          b:=j;
         end;
       end;
       inc(j);
     end;
    inc(i);
 end;

   if (cpt=$1) then
    begin
     cas:=gp.tableau[a, b];
     cas.choisi:=true;
     cas.choix:=p;
     inc(devoile);
     eleminatePossibility(cas.positionX, cas.positionY, p);
    end;
   end;
  end;
end;

{**
  ** cherche sur les differentes lignes, si sur une ligne donnee il existe
  ** il existe une case qui contient un candidat qui n'apparait nulpart
  ** ailleurs sur la ligne, cet candidat devient la valeur certaine
  ** de cette case
 **}
procedure TIASolver.searchLineOnePos();
 var  a, b, j, i, cpt, p : byte;
begin

for i:=$1 to tDim do
 begin
for p:=$1 to tDim do
  begin
    cpt:=0;
    j:=$1;
   while j<$A do
    begin
     if (not plateau.tableau[i, j].choisi) then
     begin
      if (plateau.tableau[i, j].possibilite[p]=p) then
       begin
        inc(cpt);
        if (cpt>$1) then
         begin
          j:=$A;
          continue;
         end;
         a:=i;
         b:=j;
        end;
     end;
      inc(j);
    end;

       if (cpt=$1) then
        begin
         plateau.tableau[a, b].choix:=p;
         plateau.tableau[a, b].choisi:=true;
         inc(devoile);
         eleminatePossibility(a, b, p);
        end;
   end;
 end;
end;


{**
  ** cherche sur les differentes colonnes, si sur une colonne donnee il existe
  ** il existe une case qui contient un candidat qui n'apparait nulpart
  ** ailleurs sur la colonne, cet candidat devient la valeur certaine
  ** de cette case
 **}
procedure TIASolver.searchColumnOnePos();
 var i, j, cpt, p, a, b: byte;
begin
for j:=$1 to tDim do
 begin
 for p:=$1 to tDim do
   begin
    cpt:=0;
    i:=$1;
  while i<$A do
   begin
     if (not plateau.tableau[i, j].choisi) then
      if (plateau.tableau[i, j].possibilite[p]=p) then
       begin
        inc(cpt);
        if(cpt>$1) then
         begin
         i:=$A;
         continue;
         end;
         a:=i;
         b:=j;
       end;
      inc(i);
    end;

       if (cpt=$1) then
        begin
         plateau.tableau[a, b].choix:=p;
         plateau.tableau[a, b].choisi:=true;
         inc(devoile);
         eleminatePossibility(a, b, p);
        end;
    end;
   end;
end;


procedure TIASolver.searchOnePossibility();
begin
 searchLineOnePos();
 searchColumnOnePos();
 searchGroupOnePos();
end;

{**
 ** cherche sur une region si il existe des cases dont le nombre
 ** des possibilites  est identique au nombre des cases et dont les possibilites sont les meme. Si il les trouve, ces possibilites ne
 ** peuvent apparaitre que dans ces cases par consequent, il elemine dans les autres cases
 ** ces deux possibilites
**}
procedure TIASolver.searchGroupMultiple(nb : byte);
 var i, j, x, y,a ,b, c, g : byte;
     groupe : TGroup;
     test : boolean;
     liste : TArraylist;
     cas : TCase;

begin
 for x:=$1 to gDim do  {on balaie toutes les regions}
  for y:=$1 to gDim do
   begin
    groupe:= plateau.groupes[x, y];
    for i:=$1 to gDim do  {on cherche une case qui contient exactement deux possibilites}
     for j:=$1 to gDim do
      if (not groupe.tableau[i, j].choisi) then
      if (groupe.tableau[i, j].getPossibilitySize()=nb) then
       begin
       liste:= TArraylist.init();
       liste.add(groupe.tableau[i, j]);
        for a:=$1 to gDim do {on cherche une autre case qui contient exactement deux possibilites}
         for b:=$1 to gDim do {et qui sont les meme que precedemment}
          if ((a<>i) or (b<>j)) then
           if (not groupe.tableau[a, b].choisi) then
          if (groupe.tableau[a, b].getPossibilitySize()=nb) then
           begin
            test:=true;
            for g:=$1 to nb do
             if ( groupe.tableau[a, b].possibilite[groupe.tableau[i, j].getPossibility(g)]=0) then
             begin
              test:=false;
              break;
              end;
            if (test) then
             liste.add(groupe.getCase(a, b));
           end;

         if (liste.taille=nb) then
         begin
          for a:=$1 to gDim do
           for b:=$1 to gDim do
           if not groupe.tableau[a, b].choisi then
            begin
             test:=true;
             for g:=$1 to nb do
             begin
             cas:=liste.get(g);
              if (groupe.tableau[a, b].positionx=cas.positionx) and (groupe.tableau[a, b].positiony=cas.positiony) then
               begin
                test:=false;
                break;
               end;
             end;
              if (test) then
              begin
               for g:=$1 to nb do
                begin
                 c:= groupe.tableau[i, j].getPossibility(g);
                 if (groupe.tableau[a, b].Possibilite[c]<>0) then
                  begin
                   groupe.tableau[a, b].Possibilite[c]:=0;
                   modif:=true;
                  end;
                end;
              end;
            end;
         end;
       end;
   end;
end;

{**
 ** cherche sur une ligne si il existe des cases dont le nombre
 ** des possibilites  est identique au nombre des cases et dont les possibilites sont les meme. Si il les trouve, ces possibilites ne
 ** peuvent apparaitre que dans ces cases par consequent, il elemine dans les autres cases
 ** ces deux possibilites
**}
procedure TIASolver.searchLineMultiple( nb : byte);
 var i, j, k,  g, h: byte;
     liste: TArrayList;
     test : boolean;
begin

 for i:=$1 to tDim do {les lignes}
  for j:=$1 to tDim do   {les colonnes}
  if (not plateau.tableau[i, j].choisi) then
   if (plateau.tableau[i, j].getPossibilitySize()=nb) then
    begin
    liste:= TArraylist.init();
    liste.add(plateau.tableau[i,j]);
    for k:=succ(j) to tDim do
      if (not plateau.tableau[i, k].choisi) then
      if (plateau.tableau[i, k].getPossibilitySize()=nb) then
       begin
       test:= true;
       for g:=$1 to nb do
        if (plateau.tableau[i, k].possibilite[plateau.tableau[i,j].getPossibility(g)]=0) then
        begin
          test:=false;
          break;
        end;
        if (test)  then
          liste.add(plateau.tableau[i, k]);
       end;

      if (liste.taille=nb) then
      begin
        for g:=$1 to tDim do
         if not plateau.tableau[i, g].choisi then
         begin
          test:=true;
          for h:=$1 to nb do
           begin
           if (liste.get(h).positionY=g) then
            begin
             test:=false;
             break;
            end;
           end;
          if (test) then
           begin
            for h:=$1 to nb do
             begin
              k:=plateau.tableau[i, j].getPossibility(h);
               if (plateau.tableau[i, g].possibilite[k]<>0) then
                begin
                 plateau.tableau[i, g].possibilite[k]:=0;
                 modif:=true;
                end;
             end;
           end;
         end;
      end;
    end;

end;

{**
 ** cherche sur une colonne si il existe des cases dont le nombre
 ** des possibilites  est identique au nombre des cases et dont les possibilites sont les meme. Si il les trouve, ces possibilites ne
 ** peuvent apparaitre que dans ces cases par consequent, il elemine dans les autres cases
 ** ces deux possibilites
**}
procedure TIASolver.searchColumnMultiple(nb : byte);
 var i, j, k, g, h : byte;
     test : boolean;
     liste : TArrayList;
begin

 for i:=$1 to tDim do
  for j:=$1 to tDim do
   if (not plateau.tableau[j, i].choisi) then
   if (plateau.tableau[j, i].getPossibilitySize()=nb) then
    begin
    liste:= TArraylist.init();
    liste.add(plateau.tableau[j, i]);

    for k:=succ(j) to tDim do
      if (not plateau.tableau[k, i].choisi) then
      if (plateau.tableau[k, i].getPossibilitySize()=nb) then
       begin
        test:=true;
        for g:=$1 to nb do
        if (not plateau.tableau[k, i].existPossibility(plateau.tableau[j, i].getPossibility(g))) then
        begin
         test:=false;
         break;
         end;
        if (test)  then
        begin
         liste.add(plateau.tableau[k, i]);
         end;
       end;

     if (liste.taille=nb) then
      begin
        for g:=$1 to tDim do
        if not (plateau.tableau[g, i].choisi) then
         begin
          test:=true;
          for h:=$1 to nb do
           if (liste.get(h).positionX=g) then
            begin
             test:=false;
             break;
            end;
          if (test) then
           begin
            for h:=$1 to nb do
               if (not plateau.tableau[g, i].choisi) then
                begin
                 k:=plateau.tableau[j, i].getPossibility(h);
                 if (plateau.tableau[g, i].possibilite[k]<>0) then
                  begin
                   plateau.tableau[g, i].possibilite[k]:=0;
                   modif:=true;
                  end;
                end;
           end;
         end;
      end;
  end;
end;


{**
 ** cherche sur une colonne, ligne et region si il existe des cases dont le nombre
 ** des possibilites  est identique au nombre des cases et dont les possibilites sont les meme. Si il les trouve, ces possibilites ne
 ** peuvent apparaitre que dans ces cases par consequent, il elemine dans les autres cases
 ** ces deux possibilites
**}
procedure TIASolver.searchMultiple(nb : byte);
begin
 searchColumnMultiple(nb);
 searchLineMultiple(nb);
 searchGroupMultiple(nb);
end;

{recherche des pairs caches cans les region}
 procedure TIASolver.searchGroupInnerParity();
 const nb=$2;
 var a, b, c, d, i, j : byte;
     liste : TArraylist;
     t : array[$1..tDim] of byte;
     gp : TGroup;
begin

 for c:=$1 to gDim do  {parcour des differentes regions}
  for d:=$1 to gDim do
   begin
    gp:= plateau.groupes[c, d];
    for i:=$1 to tDim do
     t[i]:=0;

    for a:=$1 to tDim do {on compte le nombre d'occurence de chaque candidat}
     for i:=$1 to gDim do
      for j:=$1 to gDim do
      if (not gp.tableau[i, j].choisi) then
       if (gp.tableau[i, j].possibilite[a]<>0) then
        inc(t[a]);

    for a:=$1 to 8 do
     if (t[a]=nb) then
      for b:=succ(a) to tDim do
       if (t[b]=nb) then
        begin
         liste:=Tarraylist.init();
         for i:=$1 to gDim do
          for j:=$1 to gDim do
          if (not gp.tableau[i, j].choisi) then
           if (gp.tableau[i, j].possibilite[a]<>0) and (gp.tableau[i, j].possibilite[b]<>0) then
           begin
            liste.add(gp.tableau[i, j]);
           end;


         if (liste.taille=nb) then
         begin
         if (liste.get($1).getPossibilitySize()=$2) and (liste.get($2).getPossibilitySize()=$2) then
           continue;

          for i:=$1 to nb do
           for j:=$1 to tDim do
            if ((j<>a) and (j<>b)) then
             liste.get(i).possibilite[j]:=0;
           modif:=true;
         end;
        end;
   end;
end;

{**
 ** recherche des paires caches sur les lignes
**}
procedure TIASolver.searchLineInnerParity();
 const nb=$2;
 var liste : TArraylist;
     i, j, k, l, y : byte;
     t: array[$1..tDim] of byte;
begin
 for l:=$1 to tDim do
  begin
   for i:=$1 to tDim do
     t[i]:=0;

   for i:=$1 to tDim do
    for j:=$1 to tDim do
    if (not plateau.tableau[l, j].choisi) then
     if (plateau.tableau[l, j].possibilite[i]<>0) then
      inc(t[i]);

   for i:=$1 to 8 do
    if (t[i]=nb) then
    for j:=succ(i) to tDim do
     if (t[j]=nb) then
      begin
       liste:= TArraylist.init();
       for k:=$1 to tDim do
       if (not plateau.tableau[l, k].choisi) then
        if (plateau.tableau[l, k].possibilite[i]<>0) and (plateau.tableau[l, k].possibilite[j]<>0) then
        begin
         liste.add(plateau.tableau[l, k]);
        end;

       if (liste.taille=nb) then
        begin
         if (liste.get($1).getPossibilitySize()=$2) then
          if (liste.get($2).getPossibilitySize()=$2) then
           continue;
         for k:=$1 to nb do
          for y:=$1 to tDim do
           if ((y<>i) and (y<>j)) then
            liste.get(k).possibilite[y]:=0;
         modif:=true;
        end;
      end;
  end;
end;

{**
 ** recherche des paires caches dans sur les clononnes
**}
procedure TIASolver.searchColumnInnerParity();
 const nb=$2;
 var liste : TArraylist;
     i, j, k, l, y : byte;
     t: array[$1..tDim] of byte;
begin

 for l:=$1 to tDim do   {les colonnes}
  begin
   for i:=$1 to tDim do
     t[i]:=0;
   for i:=$1 to tDim do
    for j:=$1 to tDim do
    if (not plateau.tableau[j, l].choisi) then
     if (plateau.tableau[j, l].possibilite[i]<>0) then
      inc(t[i]);

   for i:=$1 to 8 do
    if (t[i]=nb) then
    for j:=succ(i) to tDim do
     if (t[j]=nb) then
      begin
       liste:= TArraylist.init();
       for k:=$1 to tDim do
        if (not plateau.tableau[k, l].choisi) then
        if (plateau.tableau[k, l].possibilite[i]<>0) and (plateau.tableau[k, l].possibilite[j]<>0) then
        begin
         liste.add(plateau.tableau[k, l]);
        end;

       if (liste.taille=nb) then
        begin
         if (liste.get($1).getPossibilitySize=$2) then
          if (liste.get($2).getPossibilitySize=$2) then
           continue;

         for k:=$1 to nb do
          for y:=$1 to tDim do
           if ((y<>i) and (y<>j)) then
            liste.get(k).possibilite[y]:=0;
         modif:=true;
        end;
      end;
  end;
end;


{**
 ** recherche des pairs caches sur les lignes, colonnes, et dans les regions
**}
procedure TIASolver.searchInnerParity();
begin
 searchColumnInnerParity();
 searchLineInnerParity();
 searchGroupInnerParity();
end;


{**
 ** parcourt ligne, determine les possibilites qui n'appartiennent qu'a une region, et
 ** non dans les deux autres regions presentes sur cette ligne. Si il en trouve, supprime
 ** ces possibilites sur les cases de cette regions qui sont pas sur cette ligne
 **}
procedure TIASolver.searchgLineGroupOnlyPos();
 var i, j, k, l, m, nb : byte;
     t : array[$1..gDim] of byte;
     gp : TGroup;
begin

 for l:=$1 to tDim do {on parcourt les lignes }
  begin
   for i:=$1 to tDim do   {les differents chiffres}
    begin
    for j:=$1 to gDim do
    t[j]:=0;

     for j:=$1 to tDim do {on parcours les cases qui sont sur la ligne}
     if not(plateau.tableau[l, j].choisi) then
      if (plateau.tableau[l, j].possibilite[i]<>0) then
      begin
       case j of   {on repere les groupes qui contiennent les chiffres}
        $1, $2, gDim : t[$1]:=$1;
        4, 5, 6 : t[$2]:=$1;
        7, 8, tDim : t[gDim]:=$1;
       end;
       end;

      if((t[$1]+t[$2]+t[gDim])=$1) then
       begin
        for k:=$1 to gDim do
         if (t[k]=$1) then
          begin
           case l of
            $1, $2, gDim : gp:= plateau.groupes[$1, k];
            4, 5, 6 : gp:= plateau.groupes[$2, k];
            7, 8, tDim : gp:= plateau.groupes[gDim, k];
           end;
          end;

        case l of
         $1, 4, 7 : nb:=$1;
         $2, 5, 8 : nb:=$2;
         gDim, 6, tDim : nb:=gDim;
        end;

        for k:=$1 to gDim do
         for m:=$1 to gDim do
          if not gp.tableau[k, m].choisi then
          if (k<>nb) then
           if (gp.tableau[k, m].possibilite[i]<>0) then
           begin
            gp.tableau[k, m].possibilite[i]:=0;
            modif:=true;
           end;
       end;
    end;
  end;
end;

{**
 ** parcourt colonne, determine les possibilites qui n'appartiennent qu'a une region, et
 ** non dans les deux autres regions presentes sur cette colonne. Si il en trouve, supprime
 ** ces possibilites sur les cases de cette regions qui sont pas sur cette colonne
 **}
procedure TIASolver.searchColumnGroupOnlyPos();
var i, j, k, l, m, nb : byte;
     t : array[$1..gDim] of byte;
     gp : TGroup;
begin

 for l:=$1 to tDim do {on parcourt les colonnes }
  begin
   for i:=$1 to tDim do   {les differents chiffres}
    begin
    for j:=$1 to gDim do
    t[j]:=0;
     for j:=$1 to tDim do {on parcours les cases qui sont sur la colonne}
     if not(plateau.tableau[j, l].choisi) then
      if (plateau.tableau[j, l].possibilite[i]<>0) then
       case j of   {on repere les groupes qui contiennent les chiffres}
        $1, $2, gDim : t[$1]:=$1;
        4, 5, 6 : t[$2]:=$1;
        7, 8, tDim : t[gDim]:=$1;
       end;

      if((t[$1]+t[$2]+t[gDim])=$1) then
       begin
        for k:=$1 to gDim do
         if (t[k]=$1) then
         begin
          case l of
            $1, $2, gDim : gp:= plateau.groupes[k, $1];
            4, 5, 6 : gp:= plateau.groupes[k, $2];
            7, 8, tDim : gp:= plateau.groupes[k, gDim];
           end;
          break;
          end;
        case l of
         $1, 4, 7 : nb:=$1;
         $2, 5, 8 : nb:=$2;
         gDim, 6, tDim : nb:=gDim;
        end;

        for k:=$1 to gDim do
         for m:=$1 to gDim do
         if not gp.tableau[m, k].choisi then
          if (k<>nb) then
           if ( gp.tableau[m, k].possibilite[i]<>0) then
           begin
             modif:=true;
             gp.tableau[m, k].possibilite[i]:=0;
           end;
       end;
    end;
  end;
end;

{**
 ** parcourt ligne et colonne, determine les possibilites qui n'appartiennent qu'a une region, et
 ** non dans les deux autres regions presentes sur cette ligne ou colonne. Si il en trouve, supprime
 ** ces possibilites sur les cases de cette regions qui sont pas sur cette ligne, ou colonne
 **}
procedure TIASolver.searchgroupOnlyPos();
begin
 searchColumnGroupOnlyPos();
 searchgLineGroupOnlyPos();
end;


{**
 ** cherche dans une region, les possibilites qui ne se trouve que sur une ligne
 ** donnée, il on en trouve, supprime ces possibilites dans les autres cases
 ** des autres regions se trouvant sur cette ligne
**}
procedure TIASolver.searchGroupLine();
 var t : array[$1..gDim] of byte;
     i, j, k, n, a, b : byte;
     liste : TArraylist;
     test : boolean;
     gp : TGroup;
begin

for a:=$1 to gDim do
 for b:=$1 to gDim do
  begin
  gp :=plateau.groupes[a, b];
 for i:=$1 to tDim do {les differents chiffres}
  begin
   for j:=$1 to gDim do
    t[j]:=0;

    for k:=$1 to gDim do
     for j:=$1 to gDim do
      if (not gp.getCase(k, j).isChoosen()) then
       if (gp.getCase(k, j).existPossibility(i)) then
        t[k]:=$1;

    if ((t[$1]+t[$2]+t[gDim])=$1) then
    begin
     liste:= TArraylist.init();
     for k:=$1 to gDim do
      if (t[k]=$1) then
       for j:=$1 to gDim do
       liste.add(gp.getCase(k, j));

     n:=liste.get($1).getX();
     {elimination de cette possibilite dans les autres cases qui sont sur la ligne}
     for k:=$1 to tDim do  {les cases presente sur cette ligne}
      begin
       test :=true;
       for j:=$1 to gDim do
        if (liste.get(j).getY()=k) then
         test:=false;
       if (test) then
         if (plateau.getCase(n, k).possibilite[i]<>0) then
          begin
           plateau.getCase(n, k).possibilite[i]:=0;
           modif:=true;
          end;
        end;
    end;
  end;
  end;
end;

{**
 ** cherche dans une region, les possibilites qui ne se trouve que sur une colonne
 ** donnée, il on en trouve, supprime ces possibilites dans les autres cases
 ** des autres regions se trouvant sur cette colonne
**}
procedure TIASolver.searchGroupColumn();
 var t : array[$1..gDim] of byte;
     i, j, k, n, a, b : byte;
     liste : TArraylist;
     test : boolean;
     gp : TGroup;
begin

for a :=$1 to gDim do
 for b:=$1 to gDim do
 begin
  gp :=plateau.groupes[a, b];
 for i:=$1 to tDim do {les differents chiffres}
  begin
   for j:=$1 to gDim do
    t[j]:=0;

    for k:=$1 to gDim do
     for j:=$1 to gDim do
      if (not gp.tableau[j, k].choisi) then
       if (gp.tableau[j, k].possibilite[i]<>0) then
        t[k]:=$1;

    if ((t[$1]+t[$2]+t[gDim])=$1) then
    begin
     liste:= TArraylist.init();
     for k:=$1 to gDim do
      if (t[k]=$1) then
       for j:=$1 to gDim do
       liste.add(gp.tableau[j, k]);

     n:=liste.get($1).positionY;
     {elimination de cette possibilite dans les autres cases qui sont sur la ligne}
     for k:=$1 to tDim do  {les cases presentes sur cette colonne}
      begin
       test :=true;
       for j:=$1 to gDim do
        if (liste.get(j).positionX=k) then
         test:=false;
      if (test) then
       if (plateau.getCase(k, n).possibilite[i]<>0) then
        begin
         plateau.getCase(k, n).possibilite[i]:=0;
         modif:=true;
        end;
      end;
    end;
  end;
  end;
end;

procedure TIASolver.searchGroup();
begin
 searchGroupColumn();
 searchGroupLine();
end;



end.

