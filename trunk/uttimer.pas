{ne fait pas partie du projet}
unit uttimer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, windows;

  type TMyTimer = class
                   private
                    debut, fin : DWORD;
                    execution : boolean;

                    function GetTickCount : DWORD;

                   public

                    constructor init();
                    procedure start();
                    procedure stop();
                    function getTiming() : DWORD;
                    function isTiming() : boolean;
                  end;
implementation

constructor TMyTimer.init();
begin
 debut:=0;
 fin:=0;
 execution:=false;
end;

procedure TMyTimer.start();
begin
 execution:=true;
 debut:=GetTickCount();
end;

procedure TMyTimer.stop();
begin
 fin :=GetTickCount();
end;

function TMyTimer.getTiming() : DWORD;
begin
 execution:=false;
 getTiming:= fin-debut;
end;

function TMyTimer.isTiming() : boolean;
begin
 isTiming:=execution;
end;

function TMyTimer.GetTickCount : DWORD;
 Var
     Syst : Windows.TSystemtime;
begin
 windows.Getlocaltime(@syst);
  GetTickCount := syst.Millisecond;
end;

end.

