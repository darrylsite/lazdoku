{*****************************************************************************
 *                                                                           *
 *  This file is part of the Lazdoku V.1                                     *
 *                                                                           *
 *  Lazdoku is under the GNU General Public Licence. See file distributed    *
 *  with the package for more detail about the licence                       *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 ***************************************************************************** }

program lazdoku;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, sud2, UTGroup, utgenerator, utdisplay,
  utfileloader, utfilesaver, UTGroupControlor, utiasolver, UTPlateau,
  utarraylist, UTCase, utcontrolor, EpikTimer, uthreadsolve, utpanels,
  ulicence, uaide, utConst;

{$IFDEF WINDOWS}{$R project1.rc}{$ENDIF}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

