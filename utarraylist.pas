{*****************************************************
 ** Arraylist est un tableau d'objet TCase dynamique *
 *****************************************************}

unit utarraylist;

interface

uses utcase;

  type
      tpointe=^pointe;
      pointe= record
               ca : TCase;
               suivant : tpointe;
              end;

  type TArrayList = class
                      private

                       public
 {:(}
                        tete, queue : ^pointe;
                       taille : byte;

                        constructor init;
                        procedure add(ca: TCase);
                        procedure addList(liste : TArraylist);
                        function get(index : byte) : TCase;
                        function getSize : byte;
                        destructor destroyed;

                       
                     end;


implementation


{**
 ** construit la classe et initialise les propietes de la classe
**}
 constructor TArrayList.init;
 begin
  taille :=0;
  tete:=nil;
  queue:=nil;
 end;

 {**
  ** ajoute des element en fin de la liste
  ** @require getSize()<255
 **}
 procedure TArraylist.add(ca : Tcase);
  var p :tpointe;
 begin
  if (tete=nil) then
   begin
    new(tete);
    new(queue);
    tete^.ca:=ca;
    queue:=tete;
    tete^.suivant:=nil;
    taille:=1;
   end
  else
   begin
    new(p);
    p^.ca:=ca;
    p^.suivant:=nil;
    queue^.suivant:=p;
    queue:=p;
    inc(taille);
   end;
 end;

{**
 ** donne la taille de la liste
 ** @return la taille de la liste
 ** @ensure 0<=getSize()<=255
**}
function TArrayList.getSize : byte;
begin
 getSize:=taille;
end;

{**
** retourne un element de la liste
** @param index la position de l'element dans la liste
** @return retourne l'element case correspondant a cette position
** @require 1<=index<=getSize()
**}
function TArraylist.get(index : byte) : TCase;
 var i : integer;
     p : tpointe;
begin
if index=1 then
 begin
  get:=tete^.ca;
  exit;
 end;

if index=2 then
 begin
  get:=tete^.suivant^.ca;
  exit;
 end;

 //if(index<1) or (index>taille) then
 // i:=taille;
 p:=tete;
 for i:=$1 to pred(index) do
  begin
   p:= p^.suivant;
  end;
 get:=p^.ca;
end;

{**
 ** ajoute les elements d'une liste donnee a la suite des elements de la courante
 ** @param liste la liste contenant les elements a ajoutes
**}
procedure TArrayList.addList(liste : TArraylist);
 var i : integer;
begin
 for i:=1 to liste.taille do
  add(liste.get(i));
end;

{**
 ** libere les ressouces allouees dans la classe
**}
destructor TArrayList.destroyed;
 var p : tpointe;
begin
 while(tete<>nil) do
  begin
   p:=tete;
   tete:=tete^.suivant;
   dispose(p);
  end;
end;


end.

