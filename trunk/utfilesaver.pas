{*************************************************
 ** cette classe permet d'enregistrer une grille *
 ** dans un fichier sur le disque                *
 *************************************************}

unit utfilesaver;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UTPlateau;
  type TFileSaver= class
                    private
                     chemin : String;
                     plateau : TPlateau;

                    public
                     constructor init(plat : TPlateau; path : String);
                     procedure save();
                   end;

implementation


constructor TFileSaver.init(plat : TPlateau; path : String);
begin
 plateau:=plat;
 chemin:=path;
end;

procedure TFileSaver.save;
 var fichier :TextFile;
     i, j : byte;
begin
 assign(fichier, chemin);
 rewrite(fichier);

 for i:=1 to 9 do
  begin
   for j:=1 to 9 do
    if (plateau.getCase(i, j).isChoosen) then
     write(fichier, plateau.getCase(i, j).getChoice)
    else
     write(fichier, 0);
   writeln(fichier);
  end;

 close(fichier);
end;



end.

