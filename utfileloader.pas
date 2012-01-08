{*******************************************************
 ** definit la classe permettant de charger une grille *
 ** depuis un fichier sur le disque                    *
 *******************************************************}

unit utfileloader;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UTPlateau, dialogs;

 type TFileLoader= class
                    private
                     plateau : TPlateau;
                     chemin : String;
                    public
                     constructor init(path : String);
                     procedure load();
                     function getPlateau() : TPlateau;
                   end;


implementation


{**
 **construit la classe et initialise les proprietes de la classe
**}
constructor TFileLoader.init(path : String);
begin
 chemin:=path;
 plateau:= TPlateau.init;
end;

{**
 ** cree un plateau en chargeant le contenant a partir d'un fichier
**}
procedure TFileLoader.load();
 var fichier :TextFile;
     cpt, valeur, i, code :byte;
     ligne : string[9];

begin
try
 assign(fichier, chemin);
 reset(fichier);
 except
  showMessage('Erreur lors de louverture du fichier !');
  exit;
 end;

 cpt:=0;
 while (not eof(fichier)) do
  begin
    cpt:=cpt+1;
    readln(fichier, ligne);
    if (length(ligne)<>9) or (cpt>9) then
     begin
      showMessage('Format du fichier incorrect !');
      exit;
     end;
     for i:=1 to 9 do
      begin
       val(ligne[i], valeur, code);
       if (code<>0) then
        begin
         showMessage('Format du fichier incorrect !');
         exit;
        end;
       if (valeur<>0) then
       begin
        plateau.getCase(cpt, i).setChoice(valeur);
         plateau.getCase(cpt, i).setHidden(false);
       end
      else
        plateau.getCase(cpt, i).setHidden(true);
      end;
  end;
  close(fichier);
end;

{**
 ** @return retourne le tableau charge a partir d'un fichier
 ** @require la methode load doit etre utilisee avant l'appel de cette methode
**}
function TFileLoader.getPlateau() : TPlateau;
begin
 getPlateau:=plateau;
end;

end.

