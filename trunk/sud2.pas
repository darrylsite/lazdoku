{*********************************************
 ** fenetre principale du projet             *
 *********************************************}
unit sud2; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,LCLType, LCLProc, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, UTFileLoader, UTFileSaver, UTPlateau,
  utdisplay,   Menus, utpanels, FPimage, ulicence, uAide, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu: TMainMenu;
    menuFichier: TMenuItem;
    menuAide: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    menuLicence: TMenuItem;

     //les menus
     ficNew, ficOuvrir, ficSauver, ficQuitter : TMenuItem;
     aidJeu, aidProg :TMenuItem;
     fouvrir: TOpenDialog;
     licProg, licprop, licCont : TMenuItem;
    //-----------

    MyDrawingControl: TMyDrawingControl;
    pan : TMyPanel;
    fsauver: TSaveDialog;
    PopupMenu1: TPopupMenu;
    tray: TTrayIcon;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure Paint; override;
    procedure ficNewClick(Sender: TObject);
    procedure ficOuvrirClick(Sender : TObject);
    procedure ficSauverClick(Sender : TObject);
    procedure ficQuitterClick(Sender : TObject);
    procedure licProgClick(sender : TObject);
    procedure aideClick(sender : TObject);
    procedure aideSudClick(Sender : TObject);
    procedure trayClick(Sender: TObject);
  private
    plateau : TPlateau;
    drawAC, new: boolean;
    procedure createMenu;

  public



  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.FormClick(Sender: TObject);
begin
  self.ActiveControl:=nil;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   CreateMenu;
   drawAc :=true;
   new:=false;
   repaint();
   OnDropFiles:=@FormDropFiles;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  MyDrawingControl.Free;

end;

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of String);
 var charge : TFileLoader;
begin
  if (MyDrawingControl=nil) then
    ficNew.Click;
  charge := TFileLoader.init(fileNames[0]);
  charge.load;
  plateau:=charge.getPlateau();
  MyDrawingControl.setPlateau(plateau);
  MyDrawingControl.setDraw(true);
  MyDrawingControl.Repaint;
  pan.setPlateau(plateau);

end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
 if (licence=nil) then
 licence:= Tlicence.Create(self);
 licence.PageControl1.ActivePage:=licence.TabSheet3;
 licence.Show
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
 ficQuitterClick(self);
end;


procedure TForm1.CreateMenu;
 var pic:TPicture;
begin
pic:=TPicture.create();
{** Menu fichier **}
 ficNew:=TMenuItem.Create(menuFichier);
 ficNew.caption:='&Nouvelle grille';
 menuFichier.Add(ficNew);
 ficNew.OnClick:=@ficNewClick;
 pic.LoadFromLazarusResource('menu_nouv');
 ficNew.Bitmap:=pic.Bitmap;
 menuFichier.AddSeparator;

 ficOuvrir:=TMenuItem.Create(menuFichier);
 ficOuvrir.caption:='&Charger';
 menuFichier.Add(ficOuvrir);
 ficOuvrir.onClick:=@ficOuvrirClick;
 pic.LoadFromLazarusResource('menu_ouv');
 ficOuvrir.Bitmap:=pic.Bitmap;
 menuFichier.AddSeparator;

 ficSauver:=TMenuItem.Create(menuFichier);
 ficSauver.caption:='&Enregister';
 menuFichier.Add(ficSauver);
 ficSauver.OnClick:= @ficSauverClick;
 pic.LoadFromLazarusResource('filesave');
 ficSauver.Bitmap:=pic.Bitmap;
 menuFichier.AddSeparator;

 ficQuitter:= TMenuItem.Create(menuFichier);
 ficQuitter.caption:='&Quitter';
 menuFichier.Add(ficQuitter);
 pic.LoadFromLazarusResource('fileclose');
 ficQuitter.Bitmap:=pic.Bitmap;
 ficQuitter.OnClick:=@ficQuitterClick;
 {** Fin menu fichier **}


 (** Menu Aide **)
  aidJeu :=TMenuItem.Create(menuAide);
  aidjeu.caption:='Aide du Jeu';
  menuAide.add(aidjeu);
  menuAide.AddSeparator;
  aidjeu.OnClick:=@aideClick;

  aidProg :=TMenuItem.Create(menuAide);
  aidProg.caption:='Aide du logiciel';
  aidProg.onClick:=@aideSudClick;
  menuAide.add(aidProg);
 (** Fin menu Aide**)

 (** Menu Licence **)
 licProg := TMenuItem.create(menuLicence);
 licProg.caption:='A propos';
 licProg.onClick:=@licProgClick;
 menuLicence.add(licProg);
 (** Fin Menu Licence**)
end;

procedure TForm1.paint;
  var pic:TPicture;
      re: TRect;
      c, cc : TColor;
begin
  c:=$fadee9;
  cc:=$292325;
  re.Left:=0;
  re.Top:=0;
  re.Right:=self.Width;
  re.Bottom:=self.Height;
  canvas.GradientFill(re, c, cc, gdVertical);
if drawac then
 begin
  pic:=TPicture.create();

  pic.LoadFromLazarusResource('accueil');

  Canvas.Font.Color:=$fadee9;
  Canvas.Draw((canvas.Width div 2)-(pic.Width div 2), (canvas.Height div 2)-(pic.Height div 2), pic.Bitmap);
 end;

end;

procedure TForm1.ficNewClick(Sender: TObject);
begin
  if not new then
  begin
  drawac:=false;
  repaint();
  MyDrawingControl:= TMyDrawingControl.Create(Self);
  MyDrawingControl.Height := 350;
  MyDrawingControl.Width := 350;
  MyDrawingControl.Top := 10;
  MyDrawingControl.Left := 10;
  MyDrawingControl.Parent := Self;
  MyDrawingControl.DoubleBuffered := True;
  MyDrawingControl.setDraw(false);
  MyDrawingControl.form:=self;

  pan:=TMyPanel.create(self);
  pan.top:=10;
  pan.width:=120;
  pan.height:=300;
  pan.Left:=365;
  pan.Parent:=self;
  pan.form:=self;
  pan.sudo:=MyDrawingControl;

  new:=true;
 end;

  plateau:= TPlateau.init();
  pan.setPlateau(plateau);
  MyDrawingControl.setPlateau(plateau);
  MyDrawingControl.setDraw(true);
  MyDrawingControl.Repaint;
end;

procedure TForm1.ficOuvrirClick( Sender : TObject);
  var charge : TFileLoader;
      choix : boolean;
begin

  choix:=fouvrir.execute;
  if (not choix)  then
   exit;
  if (MyDrawingControl=nil) then
    ficNew.Click;
  charge := TFileLoader.init(fouvrir.FileName);
  charge.load;
  plateau:=charge.getPlateau();
  MyDrawingControl.setPlateau(plateau);
  MyDrawingControl.setDraw(true);
  MyDrawingControl.Repaint;
  pan.setPlateau(plateau);
end;

procedure TForm1.ficSauverClick(Sender : TObject);
 var b : boolean;
     sav : TFileSaver;
begin
 if (plateau=nil) then
  exit;
 b:=fSauver.Execute;
 if (not b) then
  exit;
  if fSauver.FileName='' then
   exit;
 sav.init(plateau, fsauver.FileName);
 sav.save();
 showMessage('La grille a ete bien enregistree');
end;

procedure TForm1.ficQuitterClick(Sender : TObject);
 var rep : longint;
begin
 rep:=Application.MessageBox('Voulez Vous vraiment quitter lazdoku?', 'Lazdoku v.1', MB_ICONQUESTION + MB_YESNO);
 if (rep=IDYES) then
  Application.Terminate
end;

procedure TForm1.licProgClick(sender : TObject);
begin
 licence:= Tlicence.Create(self);
 licence.ShowModal;
end;

procedure TForm1.aideClick(sender : TObject);
begin
 fAide:=TfAide.Create(self);
 fAide.ShowModal;
end;

procedure TForm1.aideSudClick(Sender : TObject);
begin
// SysUtils.ShellExecute(0,'open','aide/index.html',nil,nil,SW_SHOWNORMAL);
end;

procedure TForm1.trayClick(Sender: TObject);
begin
  tray.ShowBalloonHint;
end;

initialization
  {$I sud2.lrs}
  {$I accueil.lrs}
end.

