{ne fait pas partie du projet
resolution par dancing links
}
unit utdanseLinks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, utplateau;

  const maxCol=750;
        maxRow=750;

type PtrNode=^strNode;
     strNode= record
               header : ptrNode;
               right, left : ptrNode;
               up : ptrNode;
               down : ptrNode;
               idNum : integer;
              end;

     TMatrix= array[0..maxCol-1, 0..maxRow-1] of strNode;

     TDanseLink=class
                 private

                  ncol, nrow : integer;
                  matrix : TMatrix;
                  root : strNode;
                  rootNode : ptrNode; //a initialiser
                  rowHeader : array[0..maxRow-1] of ptrNode;
                  data : array[0..maxCol-1, 0..maxRow-1] of integer;
                  result : array[0..maxRow-1] of integer;
                  nresult : integer; //a initialiser
                  finished : byte;
                  maxK : integer;
                  plateau : TPlateau;

                  function dataLeft(i : integer) : integer;
                  function dataRight(i : integer) :integer;
                  function dataUp(i : integer) : integer;
                  function dataDown( i : integer) : integer;
                  procedure createMatrix();
                  function chooseColumn() : ptrNode;
                  procedure cover(var colNode : ptrNode);
                  procedure unCover(var colNode : PtrNode);
                  procedure soLutionRow(var rowNode : ptrNode);
                  procedure search(k: integer);
                  function  retNb(n : integer) : integer;
                  function retRw(n: integer) : integer;
                  function retCl(n: integer) : integer;
                  function retBx(n: integer): integer;
                  function retSq(n: integer): integer;
                  function retRn(n: integer): integer;
                  function retCn(n: integer): integer;
                  function retBn(n: integer): integer;
                  function getIn(nb: integer; rw: integer; cl: integer): integer;
                  procedure printSolution();
                  procedure buildData();
                  procedure addNumber(n, r, c: integer);
                  procedure load();
                 public
                  constructor init(plat : TPLateau);
                  procedure solve();
                end;


implementation
const
      sqOffset=0;
      rwOffset=81;
      clOffset=162;
      bxOffset=243;

constructor TDanseLink.init(plat : TPLateau);
begin
 plateau:=plat;
 rootNode :=@root;
 nresult:=0;
end;

function TDanseLink.dataLeft(i : integer) : integer;
begin
 if pred(i)<0 then
  dataLeft:=pred(nCol)
 else
  dataLeft:=pred(i);
end;

function TDanseLink.dataRight(i : integer) :integer;
begin
 dataRight:= succ(i) mod nCol;
end;

function TDanseLink.dataUp(i :integer) : integer;
begin
 if pred(i)<0 then
  dataUp:=pred(nRow)
 else
  dataUp:=pred(i);
end;

function TDanseLink.dataDown( i : integer) : integer;
begin
 dataDown:=succ(i) mod nRow;
end;

procedure TDanseLink.createMatrix();
 var a, b, i, j : integer;
begin
 for a:=0 to pred(nCol) do
  begin
  for b:=0 to pred(nRow) do
  begin
   if data[a, b]<>0 then
    begin
     //left pointer
     i:=a; j:=b;
     repeat
      i:=dataLeft(i);
     until data[i, j]<>0;
     matrix[a, b].left:=@matrix[i, j];
     //right pointer
     i:=a;
     j:=b;
     repeat
      i:= dataRight(i);
     until  data[i, j]<>0;
     Matrix[a, b].Right:= @matrix[i, j];
     //up pointer
     i:=a; j:=b;
     repeat
      j:=dataUp(j);
     until data[i, j]<>0;
     Matrix[a, b].Up := @Matrix[i, j];
     //down pointer
     i:=a; j:=b;
     repeat
      j:=dataDown(j);
     until data[i, j]<>0;
     Matrix[a, b].Down := @Matrix[i, j];
     //header pointer
     Matrix[a, b].Header := @Matrix[a, pred(nRow)];
     Matrix[a, b].IDNum := b;
     //Row Header
     RowHeader[b] := @Matrix[a, b];
    end
   end;
  end;

  for a:=0 to pred(nCol) do
   begin
    Matrix[a, pred(nRow)].IDNum := a;
   end;

 //insert root
    Root.Left := @Matrix[pred(nCol), pred(nRow)];
    Root.Right := @Matrix[0, pred(nRow)];
    Matrix[pred(nCol), pred(nRow)].Right := @Root;
    Matrix[0, pred(nRow)].Left := @Root;

end;

// --> DLX ALgorithme functions
function TDanseLink.chooseColumn() : ptrNode;
begin
 chooseColumn:= RootNode^.Right;
end;

procedure TDanseLink.cover(var colNode : ptrNode);
 var rowNode, rightNode : ptrNode;
begin
 colNode^.right^.left:=colNode^.left;
 colNode^.left^.right:=colNode^.right;
 RowNode := ColNode^.Down;
 while(RowNode<>ColNode) do
 begin
  RightNode := RowNode^.Right;
  while RightNode<>RowNode do
  begin
   RightNode^.Up^.Down := RightNode^.Down;
   RightNode^.Down^.Up := RightNode^.Up;
   //----------------------------
   RightNode := RightNode^.Right
  end;
  RowNode:= RowNode^.down;
 end;
end;

procedure TDanseLink.unCover(var colNode : PtrNode);
 var rowNode, leftNode : PtrNode;
begin
 RowNode := ColNode^.Up;
 while RowNode<>ColNode do
 begin
  LeftNode := RowNode^.Left;
  while LeftNode<>RowNode do
  begin
     LeftNode^.Up^.Down := LeftNode;
     LeftNode^.Down^.Up := LeftNode;
    //-------
    LeftNode := LeftNode^.Left;
  end;
  RowNode := RowNode^.Up;
 end;
 ColNode^.Right^.Left := ColNode;
 ColNode^.Left^.Right := ColNode;
end;

procedure TDanseLink.soLutionRow(var rowNode : ptrNode);
 var rightNode : ptrNode;
begin
 cover(RowNode^.Header);
 rightNode := RowNode^.Right;
 while RightNode<>RowNode do
 begin
   Cover(RightNode^.Header);
  //------
  RightNode := RightNode^.Right;
 end;
end;

procedure TDanseLink.search(k: integer);
 var column, rowNode, rightNode :ptrNode;
begin
 if(((RootNode^.Left=RootNode) and (RootNode^.Right=RootNode)) or (k=(81-MaxK))) then
  begin
        //Valid solution!
        //debugln('----------- SOLUTION FOUND -----------');
        PrintSolution();
        Finished := 1;
        exit;
  end;
  column:=ChooseColumn();
  Cover(Column);
  rightnode:=nil;
  RowNode := Column^.Down;
  while (RowNode<>Column ) and (finished=0) do
  begin
   // Try this row node on!
   Result[nResult] := RowNode^.IDNum;
   inc(nresult);
   //
   RightNode := RowNode^.Right;
   while (RightNode<>RowNode)  do
   begin
     Cover(RightNode^.Header);
    //
    RightNode:= RightNode^.Right;
   end;
   Search(k+1);
   // Ok, that node didn't quite work
    RightNode :=RowNode^.Right;
    while RightNode<>RowNode do
    begin
    UnCover(RightNode^.Header);
    //
    RightNode := RightNode^.Right
    end;
    Result[nResult-1] := 0;
    nResult:=nResult-1;
   //
   RowNode := RowNode^.Down;
  end;
  UnCover(Column);
end;

//--> sudoku to exact cover conversion
// Functions that extract data from a given 3-digit integer index number in the format [N] [R] [C].
function  TDanseLink.retNb(n : integer) : integer;
begin
 retNb:=n div 81;
end;

function TDanseLink.retRw(n: integer) : integer;
begin
 retRw:=(n div 9) mod 9;
end;

function TDanseLink.retCl(n: integer) : integer;
begin
 retCl:=n mod 9;
end;

function TDanseLink.retBx(n: integer): integer;
begin
 retBx:=((retRw(n) div 3)*3) + (retCl(n) div 3);
end;

function TDanseLink.retSq(n: integer): integer;
begin
 retSq:=retRw(N)*9 + retCl(N);
end;

function TDanseLink.retRn(n: integer): integer;
begin
 retRn:=retNb(n)*9 + retRw(n);
end;

function TDanseLink.retCn(n: integer): integer;
begin
 retCn:=retNb(n)*9 + retCl(n);
end;

function TDanseLink.retBn(n: integer): integer;
begin
 retBn:=retNb(N)*9 + retBx(N);
end;

// Function that get 3-digit integer index from given info
function TDanseLink.getIn(nb: integer; rw: integer; cl: integer): integer;
begin
 getIn:=Nb*81 + Rw*9 + Cl;
end;

procedure TDanseLink.printSolution();
 var a, b : integer;
begin
 for a:=0 to pred(nResult) do
 begin
  plateau.tableau[succ(retRw(Result[a]))][succ(retCl(Result[a]))].choisi:=true;
  plateau.tableau[succ(retRw(Result[a]))][succ(retCl(Result[a]))].choix:=succ(retNb(Result[a]));
 end;
end;

procedure TDanseLink.buildData();
 var a, b, c, index: integer;
begin
 nCol:=324;
 nRow:=730;

 for a:=0 to 8 do
  for b:=0 to 8 do
   begin
    for c:=0 to 8 do
    begin
      Index := getIn(c, a, b);
      Data[SQOFFSET + retSq(Index)][Index] := 1; //Constraint 1: Only 1 per square
      Data[RWOFFSET + retRn(Index)][Index] := 1; //Constraint 2: Only 1 of per number per Row
      Data[CLOFFSET + retCn(Index)][Index] := 1; //Constraint 3: Only 1 of per number per Column
      Data[BXOFFSET + retBn(Index)][Index] := 1; //Constraint 4: Only 1 of per number per Box
    end;
   end;
   for a:=0 to pred(nCol) do
    Data[a][pred(nRow)] := 2;
   CreateMatrix();
   for a:=0 to pred(rwOffset) do
   begin
    Matrix[a][nRow-1].IDNum := a;
   end;
   for a:=rwOffSet to pred(clOffset) do
   begin
    Matrix[a][pred(nRow)].IDNum :=a-RWOFFSET;
   end;
   for a:=clOffset to pred(bxOffset) do
   begin
    Matrix[a][nRow-1].IDNum := a-CLOFFSET;
   end;
   for a:=bxOffset to nCol-1 do
   begin
    Matrix[a][pred(nRow)].IDNum := a-BXOFFSET;
   end;
end;

procedure TDanseLink.addNumber(n, r, c: integer);
begin
 SolutionRow(RowHeader[getIn(N, R, C)]);
 inc(MaxK);
 Result[succ(nResult+1)] := getIn(N, R, C);
 inc(nresult);
end;

procedure TDanseLink.load();
 var a, b : byte;
begin
 for a:=1 to 9 do
  for b:=1 to 9 do
   if (plateau.tableau[a, b].choisi) then
    addNumber(pred(plateau.tableau[a, b].choix), pred(a), pred(b));
end;

procedure TDanseLink.solve();
begin
 BuildData();
 Load();
 Search(0);
end;

end.
